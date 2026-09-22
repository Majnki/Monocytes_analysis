#!/bin/bash

#SBATCH -J Align_RAW
#SBATCH -p batch
#SBATCH -N 4
#SBATCH --ntasks-per-node 16
#SBATCH --mem 64gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

SECONDS=0
echo "STAR Alignment for trimmed files using locally installed STAR."

STAR --version

# Paths
GENOME_DIR=/GRCh38.p14_STAR
INPUT_DIR=/fastq_trimmed
OUTPUT_DIR=/mapped_trim

# Number of threads to use
THREADS=72

     
for file1 in $INPUT_DIR/*_1_trimmed.fq.gz
do
    # Derive base name by removing _1.fastq.gz
    base=$(basename "$file1" _1_trimmed.fq.gz)
    file2=$INPUT_DIR/${base}_2_trimmed.fq.gz

    STAR --runThreadN $THREADS \
         --genomeDir $GENOME_DIR \
         --readFilesIn $file1 $file2 \
         --outFileNamePrefix $OUTPUT_DIR/${base}_ \
         --outSAMtype BAM SortedByCoordinate \
         --readFilesCommand zcat \
         --outSAMunmapped Within \
         --quantMode GeneCounts \
         --outSAMattributes Standard

  echo "Finished mapping $file, starting with the next file!"

echo "Finished Mapping"

duration=$SECONDS
echo "$(($duration / 3600)) hours and $((($duration % 3600)/60)) minutes and $((($duration % 3600) % 60))seconds elapsed."

done

