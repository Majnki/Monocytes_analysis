#Peak Calling#
#Peakcalling




input_dir="/goodbams"
output_dir="/goodbams"

mkdir -p "$output_dir"

for bam in "$input_dir"/*_sorted.bam.sorted.bam; do

    # Extract sample name by removing the suffix
    sample=$(basename "$bam" "_sorted.bam.sorted.bam")

    echo "Calling peaks for: $sample"

    macs3 callpeak \
        -t "$bam" \
        -f BAM \
        --verbose=3 \
        -g hs \
        -q 0.01 \
        -n "$output_dir/$sample" \
        --nomodel \
        --shift 100 \
        --extsize 200 \


done


