#!/bin/bash

IN_DIR="results/202_genotype_gvcf_diploid"
OUTDIR="results/203_gather_vcfs_diploid"
OUT_VCF="${OUTDIR}/all_diploid.vcf.gz"

[[ ! -d "${IN_DIR}" ]] && { echo "ERROR: Input directory not found: ${IN_DIR}"; exit 1; }

mapfile -t VCFS < <(find "${IN_DIR}" -maxdepth 1 -name "*.vcf.gz" | sort -V)

[[ ${#VCFS[@]} -eq 0 ]] && { echo "ERROR: No VCF files found in ${IN_DIR}"; exit 1; }

echo "Found ${#VCFS[@]} VCF(s) to gather:"
printf '  %s\n' "${VCFS[@]}"

I_ARGS=()
for vcf in "${VCFS[@]}"; do
  I_ARGS+=("-I" "${vcf}")
done

mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/203_gather_vcfs_$$.out"
ERR_LOG="logs/203_gather_vcfs_$$.err"

nohup singularity run sifs/gatk_latest.sif \
  gatk GatherVcfs \
    "${I_ARGS[@]}" \
    -O "${OUT_VCF}" \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched GatherVcfs (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
