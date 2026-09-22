#!/bin/bash

#SBATCH -J Counts_RAW
#SBATCH -p batch
#SBATCH -N 2
#SBATCH --ntasks-per-node 8
#SBATCH --mem 32gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

SECONDS=0

BAM_DIR="/mapped_trim"
GTF_FILE="gencode.v48.basic.annotation.gtf"
OUTPUT="counts_M.txt"


# Run featureCounts
featureCounts -T 8 \
  -a ${GTF_FILE} \
  -o ${OUTPUT} \
  -p \
  -s 2 \
  -B \
  --countReadPairs \
  -C \
  /users/project1/pt01001/RNASeq_JULIA/oldbams/*.out.bam \
  2> /users/project1/pt01001/RNASeq_JULIA/featureCounts.log

