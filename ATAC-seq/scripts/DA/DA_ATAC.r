library(DiffBind)

Samples <- read.csv2("samples_ATAC.csv")

DBA <- dba(sampleSheet = Samples)

DBA2 <- dba.peakset(DBA,
                    consensus = DBA_CONDITION,
                    minOverlap = 1)

DBA2 <- dba(DBA2, mask = DBA2$masks$Consensus)
ConsensusPeaks <- dba.peakset(DBA2, bRetrieve = T)
#write.csv2(as.data.frame(ConsensusPeaks), "CountsydoProfile.csv")


DBA_counts <- dba.count(DBA,summits = 75, bParallel = T,
                        peaks = ConsensusPeaks,
                        bUseSummarizeOverlaps = T,
                        filterFun = mean,
                        filter = 2)

DBA_counts <- dba.normalize(DBA_counts, method = DBA_DESEQ2)


{
  res1  <- dba.contrast(DBA_counts,design = "~Condition", contrast = c("Condition", "LPS","Control"), reorderMeta = list(Condition="Control"))
  res1 <- dba.analyze(res1, method = DBA_DESEQ2)
  res2  <- dba.contrast(DBA_counts,design = "~Condition", contrast = c("Condition", "LPS_VitD","Control"), reorderMeta = list(Condition="Control"))
  res2 <- dba.analyze(res2, method = DBA_DESEQ2)
  
  res3  <- dba.contrast(DBA_counts,design = "~Condition", contrast = c("Condition", "TNF","Control"), reorderMeta = list(Condition="Control"))
  res3 <- dba.analyze(res3, method = DBA_DESEQ2)
  
  res4  <- dba.contrast(DBA_counts,design = "~Condition", contrast = c("Condition", "TNF_VitD","Control"), reorderMeta = list(Condition="Control"))
  res4 <- dba.analyze(res4, method = DBA_DESEQ2)
  
  res5  <- dba.contrast(DBA_counts,design = "~Condition", contrast = c("Condition", "VitD","Control"), reorderMeta = list(Condition="Control"))
  res5 <- dba.analyze(res5, method = DBA_DESEQ2)
}


dba.plotPCA(DBA_counts, attributes = DBA_CONDITION, vColors = c("lightblue","blue","pink","brown4","#6E6E6E","red1"))

{
  rep1 <- dba.report(res1, th = 0.05, bUsePval = T)
  rep2 <- dba.report(res2, th = 0.05, bUsePval = T)
  rep3 <- dba.report(res3, th = 0.05, bUsePval = T)
  rep4 <- dba.report(res4, th = 0.05, bUsePval = T)
  rep5 <- dba.report(res5, th = 0.05, bUsePval = T)
  library(GenomicRanges)

  sig.union <- reduce(c(rep1, rep2, rep3, rep4, rep5))
  global.peaks <- dba.peakset(DBA_counts, bRetrieve = TRUE)
  sites.mask <- global.peaks %over% sig.union
  
  
  dba.plotPCA(DBA_counts, attributes = DBA_CONDITION, vColors = c("lightblue","blue","pink","brown4","#6E6E6E","red1"),
              sites = sites.mask)
  
  
  profiles <- dba.plotProfile(DBA_counts, sites = sig.union)
  dba.plotProfile(profiles)
  
}




library(ChIPseeker)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
ADNOTACJA <- dba.report(res1, th = 1)
ADNOTACJA <- annotatePeak(ADNOTACJA, tssRegion=c(-3000, 3000),TxDb = TxDb.Hsapiens.UCSC.hg38.knownGene, annoDb="org.Hs.eg.db")




