#!/bin/bash

REF="references/Piper_nigrum.genome.fa"

sbatch \
  --ntasks=1 --cpus-per-task=4 --mem=32G \
  --job-name=index \
  --output=logs/bwa-index.out \
  --error=logs/bwa-index.err \
  --wrap="singularity run sifs/bwa-mem2.sif \
    bwa-mem2 index ${REF}"