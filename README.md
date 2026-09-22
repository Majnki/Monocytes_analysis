# Monocytes_analysis
RNA/ATAC scripts for processing data from monocytes - ligand+1,25D.

**RNA-seq**

Analysis uses Gencode primary assembly + v48 basic annotation.

**ATAC-seq**

Same genome versions. 

BLACKLIST used to filter out problematic regions --  **Kundaje unified exclusion set ENCFF356LFX**.

Provided BED file is used to retain alignments whose coordinates fall within the regions permitted by the GRCh38 Kundaje unified exclusion complement. Used during the filtering script.
