#!/bin/sh

#SBATCH -J STAR_ATAC_
#SBATCH -p batch
#SBATCH -N 2
#SBATCH --ntasks-per-node 24
#SBATCH --mem 64gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

module load tryton/binutils/2.34
module load tryton/compiler/gcc/7.4
module load tryton/compiler/intel/2019


##Date:20 Jan 2023



## TO DO
## -

## Folder where the subfolders are to be found (do not use concluding slash here or below)
projectFolder="/project"


## Common settings
seqfolder=${projectFolder}/trimmed
##inputSuffix="trimmed.fastq.gz"
inputSuffix=".fq.gz"
##STARmodule="star/2.7.2a"
STARGenomeIndexPath="GRCh38.p14_STAR/"
STARCores="48"
STARreadsubsetSize="-1" ## default is '-1'; anything else makes sense only for testing purposes
STARclip5="0"
STARclip3="0"
samsortCores="16"
STARseedlen="50" ## default is 50
STARendstype="EndToEnd"  ## 'EndtoEnd - not softclipping'
STARprotrude="0 ConcordantPair" ## default is '0 ConcordantPair'
STARbamSortTypes="SortedByCoordinate" ## 
STARfilterMismatchNmax="10" ## default 10
alnfolder=$projectFolder$(echo "/star_aligned/")
bamOutputFolder=$projectFolder$(echo "/bam_full")

## DO THE FASTQC ON BAMS



### For logging of this pipeline step
logFileBase=$projectFolder$(echo "/log_step3_Alignment_2")
currDateTime=$(date +%y%m%d_%H-%M)           ## don't touch this
logFile="${logFileBase}_${currDateTime}.txt" ## ...or this


{ # this "{" is for logging


echo " "
echo "Loading STAR module"
echo " "


echo " "
echo "Starting alignment"
date
echo " "

echo " "
echo "COMMON SETTINGS"
echo "  Sequence (input) folder            : "${seqfolder}
echo "  Main output folder                 : "${alnfolder}
echo "  STAR genome index base (full path) : "${STARGenomeIndexPath}
echo "  Read type to align                 : "${STARreadtype}
echo "  Cores for alignment                : "${STARCores}
echo "  Cores for filtering and sorting    : "${samsortCores}
echo "  Read subset size (-1 = all reads)  : "${STARreadsubsetSize}
echo "  Clip nts from 5' of each read      : "${STARclip5}
echo "  Clip nts from 3' of each read      : "${STARclip3}
echo "  Seed length                        : "${STARseedlen}
echo "  Align ends type                    : "${STARendstype}
echo "  Align protrude                     : "${STARprotrude}
echo "  BAM output sort type(s)            : "${STARbamSortTypes}
echo "  Log file                           : "${logFile}
echo " "
date
echo " "

cd "${seqfolder}"

SAMPLES="LPS_24h_1
LPS_24h_2
LPS_24h_3
LPS_vitD_24h_1
LPS_vitD_24h_2
LPS_vitD_24h_3
TNF_24h_1
TNF_24h_2
TNF_24h_3
TNF_vitD_24h_1
TNF_vitD_24h_2
VEH_24h_1
VEH_24h_2
VEH_24h_3
VEH_vitD_24h_1
VEH_vitD_24h_2
VEH_vitD_24h_3"


echo $seqfolder
echo "Processing these sample ids"
echo " "


for SAMPLE in $SAMPLES; do

	echo ${SAMPLE}
    echo kai
    echo "Processing sample         : ${SAMPLE}"

    

    infileR1=${seqfolder}${SAMPLE}1_val_1.fq.gz
    infileR2=${seqfolder}${SAMPLE}2_val_2.fq.gz
    
    echo ${seqfolder}${SAMPLE}_1.fq.gz


    echo "  Paired input for R1     : ${infileR1}"
    echo "  Paired input for R2     : ${infileR2}"

    outfolderSample=$(echo $alnfolder$SAMPLE$(echo "/"))
    mkdir ${outfolderSample}

    echo "  Output location         : ${outfolderSample}"
    echo " "

	STAR --runThreadN "${STARCores}" \
	--runMode "alignReads" \
	--genomeDir "${STARGenomeIndexPath}" \
	--genomeLoad "LoadAndKeep" \
	--readFilesIn ${infileR1} ${infileR2} \
	--readMapNumber "${STARreadsubsetSize}" \
	--clip3pNbases "${STARclip3}" \
	--clip5pNbases "${STARclip5}" \
	--seedSearchStartLmax "${STARseedlen}" \
	--alignEndsType "${STARendstype}" \
 	--alignEndsProtrude "${STARprotrude}" \
 	--outFilterMismatchNmax "${STARfilterMismatchNmax}" \
	--outFileNamePrefix "${outfolderSample}" \
	--outSAMtype BAM "${STARbamSortTypes}" \
	--limitBAMsortRAM "60000000000" \
	--outSAMattributes "All" \
	--outBAMsortingThreadN "${samsortCores}" \
	--outStd "Log" \
	--readFilesCommand zcat \
	--outSAMmapqUnique 255


###	--readFilesIn "${infileR1}" "${infileR2}" \


  ## Move output
  mv -v "${outfolderSample}Aligned.sortedByCoord.out.bam" "${bamOutputFolder}/${SAMPLE}.sorted.bam"

done

STAR --genomeDir "${STARGenomeIndexPath}" --genomeLoad Remove

echo " "
echo "DONE all alignments!"
echo " "
date
echo " "
echo " "


echo " "
echo "Starting bam indexing"
date
echo " "

cd "${bamOutputFolder}"

for bfile in $( ls | grep "\.sorted\.bam$" ); do

  echo " "
  echo "Indexing file: ${bfile}"
  bamsortinputFile="${bamOutputFolder}/${bfile}"

  samtools index "${bamsortinputFile}"
  samtools idxstats "${bamsortinputFile}" > "${bamsortinputFile}.idxstat.txt"
  samtools stats "${bamsortinputFile}" > "${bamsortinputFile}.stats.txt"

  echo "Indexing of ${bfile} complete."
  echo " "

done

echo " "
echo "Bam indexing complete"
date
echo " "





} 2>&1 | tee $logFile # This makes all the outputs that are printed

#


