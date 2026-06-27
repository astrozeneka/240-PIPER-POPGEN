#!/bin/bash

BAMLIST="bam_list_diploid.txt"

[[ ! -f "${BAMLIST}" ]] && { echo "ERROR: Bam list not found: ${BAMLIST}"; exit 1; }

OUTDIR="results/401_nquire_create"
mkdir -p "${OUTDIR}" logs

THREADS=13

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=${THREADS} \
  --mem=64G \
  --job-name="nquire_create_all" \
  --output="logs/401_nquire_create_%j.out" \
  --error="logs/401_nquire_create_%j.err" \
  --wrap="
    while read -r BAM; do
        SLUG=\$(basename \${BAM} .markdup.bam)
        singularity run nQuire/nquire.sif create \
            -b \${BAM} \
            -o ${OUTDIR}/\${SLUG} \
            -q 20 \
            -c 10 &
    done < ${BAMLIST}
    wait
  "
