#!/bin/sh

#SBATCH -J ATAC_filter_bam
#SBATCH -p batch
#SBATCH -N 4
#SBATCH --ntasks-per-node 8
#SBATCH --mem 96gb
#SBATCH --time 48:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=

module load tryton/binutils/2.34
module load tryton/compiler/intel/2019

export LD_LIBRARY_PATH=/users/scratch1/carlbergc/lib:$LD_LIBRARY_PATH



## Folder where the subfolders are to be found 
projectFolder="/project"
echo "projectfolder{$projectFolder}"



samtoolCores="16" ## setting for samtools view '-q'
qualityfilter="4" ## setting for samtools view '-q'
goodRegionsBed="Goodregions.bed"

bamfolder="${projectFolder}/bam_full"
echo "bamfolder{$bamfolder}"
inputSuffix=$(echo "sorted.bam")
echo "input suffix{$inputSuffix}"

outfolderGood="${projectFolder}/goodbams"
echo "outfolderGood{$outfolderGood}"
outfolderBad="${projectFolder}/badbams"
echo "outfolderBad{$outfolderBad}"



### For logging of this pipeline step
logFileBase=$projectFolder$(echo "/log4_step4_Filter")
currDateTime=$(date +%y%m%d_%H-%M)           ## don't touch this
logFile="${logFileBase}_${currDateTime}.txt" ## ...or this


{ # this "{" is for logging



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

    ## To only mark and not remove duplicates, remove '-r' in markdup
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
     -r \
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
     -r \
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



} 2>&1 | tee $logFile #

