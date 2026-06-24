#!/bin/bash

REF="references/Piper_nigrum.genome.fa"
BAMLIST="bam_list_diploid.txt"

[[ ! -f "${BAMLIST}" ]] && { echo "ERROR: Bam list not found: ${BAMLIST}"; exit 1; }
[[ ! -f "${REF}" ]] && { echo "ERROR: Reference not found: ${REF}"; exit 1; }

OUTDIR="results/501_all_angsd_ploidagnostic"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=50 \
  --mem=90G \
  --job-name="angsd_diploid_all" \
  --output="logs/501_all_angsd_ploidagnostic_%j.out" \
  --error="logs/501_all_angsd_ploidagnostic_%j.err" \
  --wrap="
singularity run sifs/angsd_latest.sif \
  angsd \
    -bam ${BAMLIST} \
    -ref ${REF} \
    -doIBS 1 \
    -doMajorMinor 2 \
    -doCounts 1 \
    -minMapQ 20 \
    -minQ 20 \
    -nThreads 50 \
    -out ${OUTDIR}/diploid_all
"