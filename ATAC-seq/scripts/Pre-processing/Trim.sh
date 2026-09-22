#!/bin/bash

#SBATCH -J trim_trimgalore_ATAC
#SBATCH -p batch
#SBATCH -N 2
#SBATCH --ntasks-per-node 24
#SBATCH --mem 32gb
#SBATCH --time 24:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

SECONDS=0
module load trytonp/python3/3.12.0

# Activate virtual environment containing Trim Galore (and Cutadapt/FastQC)
#source ~/cutadapt_env/bin/activate

conda activate trimgalore_env

# Paths
INPUT_DIR=/rawfiles
OUTPUT_DIR=/trimmed

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Number of threads to use (Trim Galore uses Cutadapt's `--cores` internally)
THREADS=8

# Loop through all FASTQ files in the input directory
for r1 in "$INPUT_DIR"/*_1.fq.gz; do
    # Check if R1 file exists
    if [ ! -f "$r1" ]; then
        echo "No R1 files found matching pattern"
        continue
    fi

    # Construct R2 filename
    r2=${r1/_1.fq.gz/_2.fq.gz}

    # Extract sample name
    sample=$(basename "$r1" _1_sequence.fastq.gz)

    echo "Processing sample: $sample"
    echo "R1: $r1"
    echo "R2: $r2"

    # Check if R2 file exists
    if [ ! -f "$r2" ]; then
        echo "Warning: R2 file not found: $r2"
        echo "Skipping sample: $sample"
        continue
    fi

    # Run Trim Galore in paired-end mode, send outputs to OUTPUT_DIR
    trim_galore \
        --paired \
        --cores "$THREADS" \
        --fastqc \
        --output_dir "$OUTPUT_DIR" \
        "$r1" "$r2"

    echo "Finished trimming $sample!"
done

echo "All samples processed."

duration=$SECONDS
echo "$(($duration / 3600)) hours and $((($duration % 3600) / 60)) minutes and $((($duration % 3600) % 60)) seconds elapsed."

