#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

BAM="results/009_mark_duplicates/${SLUG}.markdup.bam"

[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=32 \
  --mem=32G \
  --job-name="ind_${SLUG}" \
  --output="logs/${SLUG}_102ind_%j.out" \
  --error="logs/${SLUG}_102ind_%j.err" \
  --wrap="
    singularity exec sifs/samtools_v1.9-4-deb_cv1.sif samtools index \
      -@ 32 \
      ${BAM}
  "