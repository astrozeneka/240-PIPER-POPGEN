#!/bin/bash

CHR="${1:?Usage: $0 <interval, e.g. Pn1>}"

REF="references/Piper_nigrum.genome.fa"
DB_DIR="results/201_genomics_db_import_diploid/${CHR}_db"
OUTDIR="results/202_genotype_gvcf_diploid"

[[ ! -f "${REF}.fai" ]] && { echo "ERROR: Reference index not found: ${REF}.fai"; exit 1; }
[[ ! -d "${DB_DIR}" ]] && { echo "ERROR: GenomicsDB workspace not found: ${DB_DIR}"; exit 1; }

mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=1 \
  --mem=32G \
  --job-name="gt_${CHR}" \
  --output="logs/${CHR}_202_gt_%j.out" \
  --error="logs/${CHR}_202_gt_%j.err" \
  --wrap="
singularity run sifs/gatk_latest.sif \
  gatk GenotypeGVCFs \
    -R ${REF} \
    -V gendb://${DB_DIR} \
    -O ${OUTDIR}/${CHR}.vcf.gz \
    -L ${CHR} \
    --sample-ploidy 2 \
    --standard-min-confidence-threshold-for-calling 30
"
