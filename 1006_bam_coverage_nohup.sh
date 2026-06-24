#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

BAM="results/009_mark_duplicates/${SLUG}.markdup.bam"
[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }

OUTDIR="results/1006_bam_coverage"
mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/1006_bam_coverage_${SLUG}_$$.out"
ERR_LOG="logs/1006_bam_coverage_${SLUG}_$$.err"

nohup bash -c '
  singularity exec sifs/samtools_v1.9-4-deb_cv1.sif samtools depth -a "'"${BAM}"'" \
    | awk -v slug="'"${SLUG}"'" "{sum+=\$3; cov+=(\$3>0); n++} END {printf \"sample\tmean_depth\tbreadth\n%s\t%.2f\t%.4f\n\", slug, sum/n, cov/n}" \
    > "'"${OUTDIR}"'/'"${SLUG}"'.coverage.txt"
' > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched bam coverage for ${SLUG} (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"