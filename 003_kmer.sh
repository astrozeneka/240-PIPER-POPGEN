#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

R1="./RawData/${SLUG}_1.fastq.gz"
R2="./RawData/${SLUG}_2.fastq.gz"
[[ ! -f "${R1}" ]] && { echo "ERROR: R1 file not found: ${R1}"; exit 1; }
[[ ! -f "${R2}" ]] && { echo "ERROR: R2 file not found: ${R2}"; exit 1; }

OUTDIR="results/003_kmer"
mkdir -p "${OUTDIR}"

sbatch \
  --ntasks=1 --cpus-per-task=2 --mem=64G \
  --job-name=kmer_${SLUG} \
  --output=logs/${SLUG}_003kmer_%j.out \
  --error=logs/${SLUG}_003kmer_%j.err \
  --wrap="\
  TMP=\$(mktemp -d) ; \
  mkfifo \${TMP}/reads.fifo ; \
  zcat ${R1} ${R2} > \${TMP}/reads.fifo & \
  singularity exec sifs/jellyfish_latest.sif \
    jellyfish count -C -m 21 -s 1G -t 2 \
      -o ${OUTDIR}/${SLUG}.jf \
      \${TMP}/reads.fifo && \
  singularity exec sifs/jellyfish_latest.sif \
    jellyfish histo \
      -o ${OUTDIR}/${SLUG}.histo \
      ${OUTDIR}/${SLUG}.jf && \
  rm -rf \${TMP} \
  "
