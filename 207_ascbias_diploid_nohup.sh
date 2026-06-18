#!/bin/bash

IN_PHY="results/206_vcf2phylip_diploid/all_diploid.min4.phy"
OUTDIR="results/207_ascbias_diploid"
OUT_PHY="${OUTDIR}/all_diploid.min4.ascbias.phy"

[[ ! -f "${IN_PHY}" ]] && { echo "ERROR: Input PHYLIP not found: ${IN_PHY}"; exit 1; }

mkdir -p "${OUTDIR}" logs

OUT_LOG="logs/207_ascbias_$$.out"
ERR_LOG="logs/207_ascbias_$$.err"

nohup python3 ascbias.py \
  -p "${IN_PHY}" \
  -o "${OUT_PHY}" \
  > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched ascbias (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
