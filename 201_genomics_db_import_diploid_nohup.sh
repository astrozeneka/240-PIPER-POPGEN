#!/bin/bash

CHR="${1:?Usage: $0 <interval, e.g. Pn1>}"

SAMPLE_LIST="bam_list_diploid.txt"

[[ ! -f "${SAMPLE_LIST}" ]] && { echo "ERROR: Sample list not found: ${SAMPLE_LIST}"; exit 1; }

V_ARGS=()
while read -r bam; do
  [[ -z "${bam}" ]] && continue
  SLUG=$(basename "${bam}" .markdup.bam)
  BAM_DIR=$(dirname "${bam}")
  PROJECT_ROOT=$(dirname "$(dirname "${BAM_DIR}")")
  GVCF=$(find "${PROJECT_ROOT}/results" -maxdepth 2 -path "*haplotype_caller_diploid*" -iname "${SLUG}.g.vcf.gz" | head -n1)
  [[ -z "${GVCF}" ]] && { echo "ERROR: GVCF not found for ${SLUG} (looked under ${PROJECT_ROOT}/results)"; exit 1; }
  V_ARGS+=("-V" "${GVCF}")
done < "${SAMPLE_LIST}"

OUTDIR="results/201_genomics_db_import_diploid"
WORKSPACE="${OUTDIR}/${CHR}_db"
mkdir -p "${OUTDIR}" logs

[[ -e "${WORKSPACE}" ]] && { echo "ERROR: GenomicsDB workspace already exists: ${WORKSPACE}"; exit 1; }

# --reader-threads only speeds things up when a single interval is given,
# so this script processes one chromosome/contig at a time (run once per CHR).
READER_THREADS=4

OUT_LOG="logs/${CHR}_201_gdb_$$.out"
ERR_LOG="logs/${CHR}_201_gdb_$$.err"

nohup singularity run sifs/gatk_latest.sif \
  gatk GenomicsDBImport \
    "${V_ARGS[@]}" \
    --genomicsdb-workspace-path "${WORKSPACE}" \
    -L "${CHR}" \
    --batch-size 50 \
    --reader-threads ${READER_THREADS} \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched GenomicsDBImport for ${CHR} (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
