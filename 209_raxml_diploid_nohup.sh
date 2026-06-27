#!/bin/bash

IN_PHY="results/208_ascbias_diploid/all_diploid.min4.ascbias.phy"
OUTDIR="results/209_raxml_diploid"

[[ ! -f "${IN_PHY}" ]] && { echo "ERROR: Input PHYLIP not found: ${IN_PHY}"; exit 1; }

mkdir -p "${OUTDIR}" logs

THREADS=64
SEED=12345
BOOTSTRAPS=1000

OUT_LOG="logs/209_raxml_$$.out"
ERR_LOG="logs/209_raxml_$$.err"

nohup singularity exec sifs/raxml_latest.sif \
  raxmlHPC-PTHREADS-SSE3 \
    -f a \
    -m ASC_GTRCAT \
    --asc-corr=lewis \
    -p "${SEED}" \
    -x "${SEED}" \
    -N "${BOOTSTRAPS}" \
    -T "${THREADS}" \
    -s "${IN_PHY}" \
    -w "$(pwd)/${OUTDIR}" \
    -n all_diploid \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched RAxML (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
