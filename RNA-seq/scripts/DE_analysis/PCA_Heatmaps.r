


library(DESeq2)
library(pheatmap)
library(RColorBrewer)


# dds should be a DESEQ object constructed from gene matrix and metadata table (DEA_M.r)
# transform counts
vsd <- vst(dds, blind = F)

# intgroup - color based on treatment effect from metadata
plotPCA(vsd, intgroup = "Treatment", ntop = 100, returnData = FALSE)

PCAA <- plotPCA(vsd, intgroup = "ID", ntop = 500, returnData = F)
plotPCA(vsd, intgroup = "Treatment", ntop = 500, returnData = F)


# Custom graph
grouping_variable <- "Treatment" #from metadata
custom_colors <- c("VEH_24" = "gray", "VEH_VitD_24" = "firebrick1",
                   "LPS" = "blue", "LPS_VitD" = "green3",
                   "TNF" = "pink", "TNF_VitD" = "pink4")
pca_plot <- plotPCA(vsd, intgroup = "Treatment", ntop = 500)
library(ggplot2)

# Clean graph
pca_plot + scale_color_manual(values = custom_colors) + theme_classic()




# Extract normalized expression matrix
vsd_mat <- assay(vsd)
head(vsd_mat)
# Select the top 500 most variable genes
topVarGenes <- head(order(rowVars(vsd_mat), decreasing = TRUE), 500) # 

mat_top500 <- vsd_mat[topVarGenes, ]

head(topVarGenes)
# Create a sample annotation (treatment groups)
annotation_col <- as.data.frame(colData(dds)[, "Treatment", drop = FALSE])
colnames(annotation_col) <- "Treatment"
head(annotation_col)
# Define color palette for heatmap
heat_colors <- colorRampPalette(rev(brewer.pal(9, "RdBu")))(100)

#Treatment colors manually

treatment_colors <- c(
  "LPS" = "blue",
  "LPS_VitD" = "green",
  "TNF" = "pink",
  "TNF_VitD" = "pink4",
  "VEH_24" = "gray",
  "VEH_VitD_24" = "firebrick1")


ann_colors <- list(Treatment = treatment_colors)

pheatmap(mat_top500,
         scale = "row",                  # z-score per gene
         clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean",
         clustering_method = "complete",
         annotation_col = annotation_col,
         annotation_colors = ann_colors,
         show_rownames = FALSE,
         show_colnames = TRUE,
         fontsize_col = 9,
         color = heat_colors,
         main = "X"
)
