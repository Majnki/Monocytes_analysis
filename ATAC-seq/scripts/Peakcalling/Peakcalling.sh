#Peak Calling#

#Change later to a loop

cd /goodbams/

macs3 callpeak -t LPS_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t LPS_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t LPS_24h_3.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS3 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t LPS_vitD_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS_VitD1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t LPS_vitD_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS_VitD2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t LPS_vitD_24h_3.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n LPS_VitD3 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t TNF_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n TNF1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t TNF_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n TNF2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t TNF_24h_3.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n TNF3 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t TNF_vitD_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n TNF_VitD1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t TNF_vitD_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n TNF_VitD2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_24h_3.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH3 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_vitD_24h_1.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH_VitD1 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_vitD_24h_2.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH_VitD2 -B --nomodel --shift 75 --extsize 150
macs3 callpeak -t VEH_vitD_24h_3.sorted.bam -f BAM --verbose=3 -g hs -q 0.01 -n VEH_VitD3 -B --nomodel --shift 75 --extsize 150


