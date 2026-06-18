#!/bin/bash

REF="references/Piper_nigrum.genome.fa"
BAMLIST="bam_list_diploid.txt"

[[ ! -f "${BAMLIST}" ]] && { echo "ERROR: Bam list not found: ${BAMLIST}"; exit 1; }
[[ ! -f "${REF}" ]] && { echo "ERROR: Reference not found: ${REF}"; exit 1; }

OUTDIR="results/301_all_angsd_diploid"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=50 \
  --mem=64G \
  --job-name="angsd_diploid_all" \
  --output="logs/301_angsd_diploid_%j.out" \
  --error="logs/301_angsd_diploid_%j.err" \
  --wrap="
singularity run sifs/angsd_latest.sif \
  angsd \
    -bam ${BAMLIST} \
    -ref ${REF} \
    -GL 1 \
    -doGlf 2 \
    -doMaf 1 \
    -doMajorMinor 1 \
    -SNP_pval 1e-6 \
    -minMapQ 20 \
    -minQ 20 \
    -nThreads 50 \
    -out ${OUTDIR}/diploid_all
"
