#!/bin/bash

IN_VCF="results/205_variant_filtration_diploid/all_diploid_filtered.vcf.gz"
OUTDIR="results/206_filtered_pass"
OUT_VCF="${OUTDIR}/all_diploid.passonly.vcf.gz"

[[ ! -f "${IN_VCF}" ]] && { echo "ERROR: Input VCF not found: ${IN_VCF}"; exit 1; }

mkdir -p "${OUTDIR}" logs

THREADS=8

OUT_LOG="logs/206_filter_pass_$$.out"
ERR_LOG="logs/206_filter_pass_$$.err"

nohup bash -c '
  singularity run sifs/bcftools_v1.9-1-deb_cv1.sif bcftools view --threads '"${THREADS}"' -f PASS -m2 -M2 -v snps "'"${IN_VCF}"'" \
  | singularity run sifs/bcftools_v1.9-1-deb_cv1.sif bcftools view --threads '"${THREADS}"' -i "F_MISSING<0.2 & MAC>=2" -Oz -o "'"${OUT_VCF}"'"
' > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched filter_pass (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
