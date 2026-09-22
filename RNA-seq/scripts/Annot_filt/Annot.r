library(biomaRt)
library(dplyr)

counts <- read.csv2("counts_M.csv")

counts$Geneid <- gsub("\\..*","", counts$Geneid)
rownames(counts) <- counts$Geneid


counts_filt <- counts[,c(2:19)]

for (i in 1:ncol(counts_filt)){
  counts_filt[,i] <- counts_filt[,i]/sum(counts_filt[,i])
  counts_filt[,i] <- counts_filt[,i]*1000000
}
counts_filt <- counts_filt[rowSums(counts_filt >= 0.5) > 17,]


Geneid <- rownames(counts_filt)

###----WARNING BIOMART SERVICE WAS DISCONTINUEED BY ENSEMBL (SUMMER 2026) ---- THUS BELOW SCRIPT DOES NOT WORK ####
## ALTERNATIVE SOLUTION -- USE ARCHIVES? (115)

mart <- useEnsembl(biomart = "ensembl", 
                   dataset = "hsapiens_gene_ensembl", 
                   mirror = "www")


dat <- getBM (values = Geneid,
              filters = "ensembl_gene_id",
              attributes = c("ensembl_gene_id",
                             "entrezgene_id",
                             "external_gene_name",
                             "hgnc_symbol",
                             "description",
                             "chromosome_name",
                             "start_position",
                             "end_position",
                             #                             "percentage_gene_gc_content",
                             "gene_biotype", 
                             "strand"),
              mart = mart)


dat$description <- gsub("\\s*\\[[^\\)]+\\]","",as.character(dat$description))
dat$gene_biotype= gsub("_", " ", (dat$gene_biotype))
dat$Geneid <- dat$ensembl_gene_id
emptyHGNC <- dat %>% filter (., hgnc_symbol != "")
nrow(emptyHGNC)
dropdupl <- emptyHGNC[!duplicated(emptyHGNC$hgnc_symbol),]
nrow(dropdupl)
mt <- subset(dropdupl, chromosome_name!="MT")
ki <- filter(mt, !grepl("^KI",mt$chromosome_name)) 
gl <- filter(ki, !grepl("^GL",ki$chromosome_name))
gl2 <- gl
gl <- gl[gl$gene_biotype %in% "protein coding",]

counts_annot <- counts[counts$Geneid %in% rownames(counts_filt),]
counts_annot <- counts_annot[countsy_annotated$Geneid %in% gl$Geneid,]

write.csv2(counts_annot, "counts.csv")




