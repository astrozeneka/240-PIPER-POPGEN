#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

BAM="results/008_map_on_ref/${SLUG}.sorted.bam"

[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }

OUTDIR="results/009_mark_duplicates"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=1 \
  --mem=32G \
  --job-name="markdup_${SLUG}" \
  --output="logs/${SLUG}_009markdup_%j.out" \
  --error="logs/${SLUG}_009markdup_%j.err" \
  --wrap="
    singularity run sifs/gatk_latest.sif \
      gatk MarkDuplicates \
        -I ${BAM} \
        -O ${OUTDIR}/${SLUG}.markdup.bam \
        -M ${OUTDIR}/${SLUG}.markdup.metrics.txt
  "
