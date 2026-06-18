#!/bin/bash

# --admix, --selection, --snp_weights, etc. can be further configured
BEAGLE="results/301_all_angsd_diploid/diploid_all.beagle.gz"

[[ ! -f "${BEAGLE}" ]] && { echo "ERROR: Beagle file not found: ${BEAGLE}"; exit 1; }

OUTDIR="results/302_pcangsd_diploid"
mkdir -p "${OUTDIR}" logs

THREADS=20

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=${THREADS} \
  --mem=64G \
  --job-name="pcangsd_diploid_all" \
  --output="logs/302_pcangsd_diploid_%j.out" \
  --error="logs/302_pcangsd_diploid_%j.err" \
  --wrap="
singularity exec sifs/pcangsd_1.35.sif \
  pcangsd \
    -b ${BEAGLE} \
    -o ${OUTDIR}/diploid_all \
    -t ${THREADS}
"
