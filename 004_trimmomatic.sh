#!/bin/bash

SLUG="${1:?Usage: $0 <slug> <prefix>}"

R1="./RawData/${SLUG}_1.fastq.gz"
R2="./RawData/${SLUG}_2.fastq.gz"
[[ ! -f "${R1}" ]] && { echo "ERROR: R1 file not found: ${R1}"; exit 1; }
[[ ! -f "${R2}" ]] && { echo "ERROR: R2 file not found: ${R2}"; exit 1; }

OUTDIR="results/004_trimmomatic"
mkdir -p "${OUTDIR}"

sbatch \
  --ntasks=1 --cpus-per-task=4 --mem=16G \
  --job-name=tr_${SLUG} \
  --output=logs/${SLUG}_004trimmomatic_%j.out \
  --error=logs/${SLUG}_004trimmomatic_%j.err \
  --wrap="singularity exec sifs/trimmomatic.sif \
    trimmomatic PE \
    -threads 4 \
    -phred33 \
    ${R1} ${R2} \
    ${OUTDIR}/${SLUG}_R1_paired.fastq.gz   ${OUTDIR}/${SLUG}_R1_unpaired.fastq.gz \
    ${OUTDIR}/${SLUG}_R2_paired.fastq.gz   ${OUTDIR}/${SLUG}_R2_unpaired.fastq.gz \
    ILLUMINACLIP:/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:8:true \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36"
