#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

BAM="results/009_mark_duplicates/${SLUG}.markdup.bam"

[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }

OUTDIR="results/010_mosdepth"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=32 \
  --mem=32G \
  --job-name="mosdepth_${SLUG}" \
  --output="logs/${SLUG}_010mosdepth_%j.out" \
  --error="logs/${SLUG}_010mosdepth_%j.err" \
  --wrap="
    singularity exec sifs/mosdepth_v0.3.3.sif mosdepth \
      --threads 32 \
      --no-per-base \
      --quantize 0:1:5:10:20:100: \
      ${OUTDIR}/${SLUG} \
      ${BAM}
  "