#!/bin/bash

CHR="${1:?Usage: $0 <interval, e.g. Pn1>}"

REF="references/Piper_nigrum.genome.fa"
DB_DIR="results/201_genomics_db_import_diploid/${CHR}_db"
OUTDIR="results/202_genotype_gvcf_diploid"

[[ ! -f "${REF}.fai" ]] && { echo "ERROR: Reference index not found: ${REF}.fai"; exit 1; }
[[ ! -d "${DB_DIR}" ]] && { echo "ERROR: GenomicsDB workspace not found: ${DB_DIR}"; exit 1; }

mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/${CHR}_202_gt_$$.out"
ERR_LOG="logs/${CHR}_202_gt_$$.err"

nohup singularity run sifs/gatk_latest.sif \
  gatk GenotypeGVCFs \
    -R "${REF}" \
    -V "gendb://${DB_DIR}" \
    -O "${OUTDIR}/${CHR}.vcf.gz" \
    -L "${CHR}" \
    --sample-ploidy 2 \
    --standard-min-confidence-threshold-for-calling 30 \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched GenotypeGVCFs for ${CHR} (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
