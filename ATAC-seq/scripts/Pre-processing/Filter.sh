#!/bin/sh

#SBATCH -J Filter_1
#SBATCH -p batch
#SBATCH -N 2
#SBATCH --ntasks-per-node 8
#SBATCH --mem 96gb
#SBATCH --time 72:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

module load tryton/binutils/2.34
module load tryton/compiler/intel/2019

export LD_LIBRARY_PATH=/users/scratch1/carlbergc/lib:$LD_LIBRARY_PATH
## Run using this on command line
## IMPORTANT: DO NOT FORGET TO UPDATE THE SCRIPT NAME BELOW BEFORE RUNNING THIS AFTER MODIFICATIONS!!!
## As an additional safety feature against unintended overwriting of older results, always leave the run
## command below without the concluding '.sh', and only add it manually on the command line
## sh /research/groups/heikkinen/spheikki/scripts/ATACseqPipe_step4_read.filtering_v1.2_human.THP1s.Carlberg

## Takes as input a folder of aligned sorted.bams, and filters them to mark and remove duplicates
## (by location, i.e. likely PCR artefacts) and exclude reads that fall into blacklisted regions
## (a merge of chrM analogous regions and ENCODE-identified poor mappability regions). The filtered
## output is sorted and indexed sorted.bams. Separately stores also the excluded reads. Also runs
## FastQC on the good sorted.bams and finally produces .tdf viz files.

## Note: Make sure all the output folders exist before starting.
## NOTE: To avoid conflicts arising from bam sorting during two separate step along the multistep
##       samtools pipe, it is best to use enough cores to enable in-memory sorting. Typically this
##       means something like min 16 cores (6G memory use is hardcoded to the samtools sorts below).


## TO DO
## - It may finally be a bad idea to have a samtools pipe that has two sorts in it. Looks
##   like there are some conflicts in TEMP file access if samtoolsCores is less than about 16
##   i.e. when fully in-memory sorting is not possible. Therefore, to increase the reliability
##   of this script, it would be best to direct the output of the first sort to file,
##   and continue with fixmate from there. However, presently the TEMP files are named
##   differently in the two samtools sorts, and not fully tested whether already this prevents
##   the conflicts.


## Folder where the subfolders are to be found (do not use concluding slash here or below)
projectFolder="/realign/"
echo "projectfolder{$projectFolder}"

## Common settings
##   Note: Make sure the output folders exist before starting. Do not use concluding slash on
samtoolCores="16" ## setting for samtools view '-q'
qualityfilter="20" ## setting for samtools view '-q'
goodRegionsBed="/Goodregions.bed"

bamfolder="${projectFolder}/mapped"
echo "bamfolder{$bamfolder}"
inputSuffix=$(echo "sorted.bam")
echo "input suffix{$inputSuffix}"

outfolderGood="${projectFolder}/goodbams"
echo "outfolderGood{$outfolderGood}"
outfolderBad="${projectFolder}/badbams"
echo "outfolderBad{$outfolderBad}"

### Settings for FastQC. Do not use concluding slash here (esp for the 'qcOutputFolder').
#qcInputFolder=$outfolderGood
#qcOutputFolder=$projectFolder$(echo "/FastQC_filtered")
#suffixToFind="sorted.bam"
#threadCount="4"

## Note: the summarizing script automatically adds a time stamp and .txt to the output file name
#qcSumOutFileBase=$projectFolder$(echo "/notes/step4_Filter")
#qcSumHeader="FastQC summary from ATACseq pipeline after step 4: Filter aligned reads and FastQC"


## Settings for igvtools to generate the .tdfs
#TDFinputFolder="${outfolderGood}"
#TDFoutputFolder=$projectFolder$(echo "/tdf")
#TDFinputEx="sorted.bam"
#TDFfragLength="100" ## generally "the average fragment length of the library" (or rather the insert?) minus the average read length
#TDFgenome="mm10"
#TDFgenome="hg38"
#TDFigvW="25"


### For logging of this pipeline step
logFileBase=$projectFolder$(echo "/log4_step4_Filter")
currDateTime=$(date +%y%m%d_%H-%M)           ## don't touch this
logFile="${logFileBase}_${currDateTime}.txt" ## ...or this


{ # this "{" is for logging

echo " "
echo "Loading samtools module : "${samtoolsmodule}
echo " "
echo " kai"
#module load "${samtoolsmodule}"

echo " "
samtools --version
echo " "

echo " "
echo "COMMON SETTINGS"
echo "  Bam input folder                   : "${bamfolder}
echo "  Bam file suffix                    : "${inputSuffix}
echo "  Good regions bed file              : "${goodRegionsBed}
echo "  Output folder for good reads       : "${outfolderGood}
echo "  Output folder for bad reads        : "${outfolderBad}
echo "  Cores for samtools tools           : "${samtoolCores}
echo "  Log file                           : "${logFile}
echo " "
echo " "
date
echo " "

echo " "
echo "START bam filtering"
echo " "
date

cd "${bamfolder}"

for inbam in $(ls | grep "${inputSuffix}$"); do

    inSample=$(echo $inbam | sed s/"\\.${inputSuffix}"//g)

    outSampleGood=$(echo $outfolderGood$(echo "/")$inSample.sorted.bam)
    outSampleBad=$(echo $outfolderBad$(echo "/")$inSample$(echo "_excluded.regions").sorted.bam)

    echo " "
    echo "Processing sample     : ${inbam}"
    echo "   Sample ID          : ${inSample}"
    echo "   Output good reads  : ${outSampleGood}"
    echo "   Output bad reads   : ${outSampleBad}"
    echo " "

    ## Note: the two 'sort's within the same pipe get confused if the temp file prefix (-T) is
    ##   the same for both. This only came up when using too few cores to enable fully in-memory
    ##   sorting. Fixed now, though.
    samtools view \
    -b \
    -u \
    -q "${qualityfilter}" \
    -L "${goodRegionsBed}" \
    -U "${outSampleBad}" \
    -o - \
     "${inbam}" \
     | \
     samtools sort \
     -n \
     -l 0 \
     -O "BAM" \
     -T TEMP1 \
     -o - \
     - \
     | \
     samtools fixmate \
     -m \
     -O "BAM" \
     - \
     - \
     | \
     samtools sort \
     -l 0 \
     -O "BAM" \
     -T TEMP2 \
     -o - \
     - \
     | \
     samtools markdup \
     -s \
     -O "BAM" \
     - \
     "${outSampleGood}"

    echo " "
    date
    echo " "

done


echo " "
echo "DONE bam filtering!"
echo " "
date
echo " "
echo " "


echo " "
echo "Starting bam indexing of good reads"
date
echo " "

cd "${outfolderGood}"

for bfile in $( ls | grep "\.sorted\.bam$" ); do

  echo " "
  echo "Indexing file: ${bfile}"
  bamsortinputFile="${outfolderGood}/${bfile}"

  samtools index "${bamsortinputFile}"
  samtools idxstats "${bamsortinputFile}" > "${bamsortinputFile}.idxstat.txt"
  samtools stats "${bamsortinputFile}" > "${bamsortinputFile}.stats.txt"

  echo "Indexing of ${bfile} complete."
  echo " "

done

echo " "
echo "Starting bam indexing of bad reads"
date
echo " "

cd "${outfolderBad}"

for bfile in $( ls | grep "\.sorted\.bam$" ); do

  echo " "
  echo "Indexing file: ${bfile}"
  bamsortinputFile="${outfolderBad}/${bfile}"

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
#+ to terminal between the first { and this one also to be printed in the specified log file

