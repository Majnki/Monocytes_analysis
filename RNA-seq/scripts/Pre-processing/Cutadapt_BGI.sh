#!/bin/bash

#SBATCH -J Trim_J
#SBATCH -p batch
#SBATCH -N 4
#SBATCH --ntasks-per-node 16
#SBATCH --mem 64gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=#



INPUT_DIR="/fastq_raw"
OUTPUT_DIR="/fastq_trimmed"


# Loop over all R1 files and find matching R2
for r1 in "$INPUT_DIR"/*_1.fq.gz; do
    # Derive base name (removing _1.fq.gz)
    base=$(basename "$r1" _1.fq.gz)
    
    r2="$INPUT_DIR/${base}_2.fq.gz"

    # Define output filenames
    out_r1="$OUTPUT_DIR/${base}_1_trimmed.fq.gz"
    out_r2="$OUTPUT_DIR/${base}_2_trimmed.fq.gz"

    # Run cutadapt to trim 12 bp from 5' end of both reads
    cutadapt -u 12 -U 12 \
        -o "$out_r1" -p "$out_r2" \
        "$r1" "$r2"
done