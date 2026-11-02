#!/bin/sh

#SBATCH -J align
#SBATCH -p batch
#SBATCH -N 2
#SBATCH --ntasks-per-node 8
#SBATCH --mem 64gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

#!/bin/bash


module load tryton/binutils/2.34
module load tryton/compiler/gcc/7.4
module load tryton/compiler/intel/2019

cd /users/scratch1/carlbergc/Nutriome

FASTQ_DIR="/trimmed"
INDEX="/genome"
OUTPUT="/mapped"
LOGS="/logs"


THREADS=8


for R1 in ${FASTQ_DIR}/*_L1_1_val_1.fq.gz;
do
    SAMPLE=$(basename ${R1} _L1_1_val_1.fq.gz)
    R2=${FASTQ_DIR}/${SAMPLE}_L1_2_val_2.fq.gz

    echo "Processing ${SAMPLE}"

    # Alignment
    /users/scratch1/carlbergc/CutRun_NEW/subread-2.1.1-Linux-x86_64/bin/subread-align \
        -T ${THREADS} \
        -t 0 \
        -i ${INDEX} \
        -r ${R1} \
        -R ${R2} \
        -o $OUTPUT/${SAMPLE}.bam \
        > $LOGS/${SAMPLE}_align.log 2>&1
    
    samtools sort $OUTPUT/${SAMPLE}.bam -o $OUTPUT/${SAMPLE}_sorted.bam
    samtools index $OUTPUT/${SAMPLE}_sorted.bam

done

