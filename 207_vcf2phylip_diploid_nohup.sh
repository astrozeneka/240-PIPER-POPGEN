#!/bin/bash

IN_VCF="results/206_filtered_pass/all_diploid.passonly.vcf.gz"
OUTDIR="results/207_vcf2phylip_diploid"

[[ ! -f "${IN_VCF}" ]] && { echo "ERROR: Input VCF not found: ${IN_VCF}"; exit 1; }

mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/207_vcf2phylip_$$.out"
ERR_LOG="logs/207_vcf2phylip_$$.err"

nohup python3 vcf2phylip.py \
  -i "${IN_VCF}" \
  --output-folder "${OUTDIR}" \
  --output-prefix all_diploid \
  --min-samples-locus 4 \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched vcf2phylip (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
