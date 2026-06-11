#!/bin/bash

SLUG="${1:?Usage: $0 <slug> <prefix>}"

R1="./RawData/${SLUG}_1.fastq.gz"
R2="./RawData/${SLUG}_2.fastq.gz"
[[ ! -f "${R1}" ]] && { echo "ERROR: R1 file not found: ${R1}"; exit 1; }
[[ ! -f "${R2}" ]] && { echo "ERROR: R2 file not found: ${R2}"; exit 1; }

mkdir -p results/001_fastqc

sbatch \
  --ntasks=1 --cpus-per-task=4 --mem=64G \
  --job-name=tr_${SLUG} \
  --output=logs/${SLUG}_001fastqc_%j.out \
  --error=logs/${SLUG}_001fastqc_%j.err \
  --wrap="\
  singularity exec sifs/fastqc.sif \
    fastqc -t 4 -o "results/001_fastqc/" "${R1}" "${R2}"\
  "

