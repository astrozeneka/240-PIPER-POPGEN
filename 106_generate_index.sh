#!/bin/bash

REF="references/Piper_nigrum.genome.fa"

[[ ! -f "${REF}" ]] && { echo "ERROR: Reference file not found: ${REF}"; exit 1; }

mkdir -p logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=1 \
  --mem=16G \
  --job-name="generate_index" \
  --output="logs/106_generate_index_%j.out" \
  --error="logs/106_generate_index_%j.err" \
  --wrap="
    singularity run sifs/samtools_v1.9-4-deb_cv1.sif \
      samtools faidx ${REF}

    singularity run sifs/gatk_latest.sif \
      gatk CreateSequenceDictionary \
        -R ${REF}
  "
