#!/bin/bash

IN_VCF="results/203_gather_vcfs_diploid/all_diploid.vcf.gz"

[[ ! -f "${IN_VCF}" ]] && { echo "ERROR: VCF not found: ${IN_VCF}"; exit 1; }

mkdir -p logs

OUT_LOG="logs/204_index_vcf_$$.out"
ERR_LOG="logs/204_index_vcf_$$.err"

nohup singularity run sifs/gatk_latest.sif \
  gatk IndexFeatureFile \
    -I "${IN_VCF}" \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched IndexFeatureFile for ${IN_VCF} (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
