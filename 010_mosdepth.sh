#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

BAM="results/008_map_on_ref/${SLUG}.sorted.bam"

[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }

OUTDIR="results/009_mosdepth"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=8 \
  --mem=16G \
  --job-name="mosdepth_${SLUG}" \
  --output="logs/${SLUG}_009mosdepth_%j.out" \
  --error="logs/${SLUG}_009mosdepth_%j.err" \
  --wrap="
    singularity exec sifs/mosdepth_v0.3.3.sif mosdepth \
      --threads 8 \
      --no-per-base \
      --quantize 0:1:5:100: \
      ${OUTDIR}/${SLUG} \
      ${BAM}
  "