library(DESeq2)

head(count_table)
#Read initial files - count matrix and pheno_data (change file paths to appropiate ones and if needed manipulate other arguments)

count_table <-  read.csv2(file = "counts.csv", sep = ";", row.names = 1)
pheno_data <- read.csv2(file="pheno_data.csv", sep = ";", header = T)
identical(pheno_data$ID, colnames(count_table))


for (i in 1:ncol(pheno_data)) {
  pheno_data[,i] <- as.factor(as.character(pheno_data[,i]))
}

levels(pheno_data$Treatment)

#DESEQ object
dds <- DESeqDataSetFromMatrix(countData = count_table, colData = pheno_data, design = ~ Treatment)
dds <- DESeq(dds)
#Run contrasts
{
  resLPS <- results(dds, contrast=c("Treatment","LPS","VEH_24"), alpha  = 0.05)
  resLPS_sig <- subset(resLPS , padj < 0.05)
  #resLPS_sig  <- subset(resLPS_sig , abs(log2FoldChange) > 1 )
  
  resLPS_VitD <- results(dds, contrast=c("Treatment","LPS_VitD","VEH_24"), alpha  = 0.05)
  resLPS_VitD_sig  <- subset(resLPS_VitD, padj < 0.05)
  #resLPS_VitD_sig  <- subset(resLPS_VitD_sig , abs(log2FoldChange) > 1 )
  
  resVitD  <- results(dds, contrast=c("Treatment","VEH_VitD_24","VEH_24"), alpha  = 0.05)
  resVitD_sig  <- subset(resVitD, padj < 0.05)
  #resVitD_sig  <- subset(resVitD_sig , abs(log2FoldChange) > 1 )
  
  resTNF <- results(dds, contrast=c("Treatment","TNF","VEH_24"), alpha  = 0.05)
  resTNF_sig  <- subset(resTNF, padj < 0.05)
  #resTNF_sig  <- subset(resTNF_sig , abs(log2FoldChange) > 1 )
  
  resTNF_VitD <- results(dds, contrast=c("Treatment","TNF_VitD","VEH_24"), alpha  = 0.05)
  resTNF_VitD_sig  <- subset(resTNF_VitD, padj < 0.05)
}


#####-----INT------#####

#Interaction analyses X+Y+X:Y

dds_int <- DESeqDataSetFromMatrix(countData = count_table,
                                       colData = pheno_data,
                                       design = ~ Factor + VitD + Factor:VitD)



dds_int <- DESeq(dds_int)

resultsNames(dds_int)

res_int_LPS <- results(dds_int, name = "FactorLPS.VitD1", alpha = 0.05)
res_int_TNF <- results(dds_int, name = "FactorTNF.VitD1", alpha = 0.05)

res_int_LPS_sig <- subset(res_int_LPS, padj < 0.05)
res_int_TNF_sig <- subset(res_int_TNF, padj < 0.05)


####-----LRT-----#####

#LRT here cannot distinguish between which ligand is affected by 1,25D 
dds_LRT <- DESeq(dds_int, test = "LRT", reduced = ~ Factor + VitD)
res_LRT <- results(dds_LRT, alpha = 0.05)
res_LRT <- as.data.frame(res_LRT)
res_LRT_sig <- subset(res_LRT, padj < 0.05)
nrow(res_LRT_sig)






