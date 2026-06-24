#!/bin/bash

IN_VCF="results/206_filtered_pass/all_diploid.passonly.vcf.gz"
CONVERTER="polyrelatedness/vcf2polyrelatedness.py"
SIF="sifs/polyrelatedness.sif"
OUTDIR="results/601_polyrelatedness_diploid"

[[ ! -f "${IN_VCF}" ]] && { echo "ERROR: Input VCF not found: ${IN_VCF}"; exit 1; }
[[ ! -f "${CONVERTER}" ]] && { echo "ERROR: Converter script not found: ${CONVERTER}"; exit 1; }
[[ ! -f "${SIF}" ]] && { echo "ERROR: Singularity image not found: ${SIF}"; exit 1; }

mkdir -p "${OUTDIR}" logs

THIN_BP=50000     # keeps loci well under PolyRelatedness's 65536-locus limit
ESTIMATOR=9       # Wang 2002 diploid moment estimator
MODE=0            # 0 = between all individuals, 1 = within population
THREADS=4

OUT_LOG="logs/601_polyrelateness_$$.out"
ERR_LOG="logs/601_polyrelateness_$$.err"

nohup bash -c '
  python3 "'"${CONVERTER}"'" \
    --vcf "'"${IN_VCF}"'" \
    --out "'"${OUTDIR}"'/in.txt" \
    --thin-bp '"${THIN_BP}"' \
    --nthreads '"${THREADS}"' \
  && singularity run --pwd "'"$(pwd)/${OUTDIR}"'" "'"${SIF}"'" in.txt out.txt e '"${ESTIMATOR}"' '"${MODE}"'
' > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched polyrelateness (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
