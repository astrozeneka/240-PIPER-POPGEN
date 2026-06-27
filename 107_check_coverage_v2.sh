#!/bin/bash

THREADS=9
mkdir -p logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=${THREADS} \
  --mem=8G \
  --job-name="mean_coverage" \
  --output="logs/107_mean_coverage_%j.out" \
  --error="logs/107_mean_coverage_%j.err" \
  --wrap="
    for BAM in results/009_mark_duplicates/*.markdup.bam; do
        (
            SLUG=\$(basename \${BAM} .markdup.bam)
            COV=\$(samtools coverage \${BAM} \
                | awk 'NR>1 {sum+=\$7; n++} END {printf \"%.1f\", sum/n}')
            echo \"\${SLUG}: \${COV}x mean coverage\"
        ) &
    done
    wait
  "