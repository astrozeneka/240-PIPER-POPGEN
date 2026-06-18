#!/bin/bash

REF="references/Piper_nigrum.genome.fa"
IN_VCF="results/203_gather_vcfs_diploid/all_diploid.vcf.gz"
OUTDIR="results/205_variant_filtration_diploid"
OUT_VCF="${OUTDIR}/all_diploid_filtered.vcf.gz"

[[ ! -f "${REF}.fai" ]] && { echo "ERROR: Reference index not found: ${REF}.fai"; exit 1; }
[[ ! -f "${IN_VCF}" ]] && { echo "ERROR: Input VCF not found: ${IN_VCF}"; exit 1; }

mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/205_variant_filtration_$$.out"
ERR_LOG="logs/205_variant_filtration_$$.err"

nohup singularity run sifs/gatk_latest.sif \
  gatk VariantFiltration \
    -R "${REF}" \
    -V "${IN_VCF}" \
    -O "${OUT_VCF}" \
    --filter-expression "QD < 2.0"          --filter-name "QD2" \
    --filter-expression "FS > 60.0"         --filter-name "FS60" \
    --filter-expression "MQ < 40.0"         --filter-name "MQ40" \
    --filter-expression "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    --filter-expression "SOR > 3.0"         --filter-name "SOR3" \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched VariantFiltration (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
