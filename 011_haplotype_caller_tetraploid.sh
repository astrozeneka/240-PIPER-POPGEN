#!/bin/bash

SLUG="${1:?Usage: $0 <slug>}"

REF="references/Piper_nigrum.genome.fa"
BAM="results/009_mark_duplicates/${SLUG}.markdup.bam"

[[ ! -f "${BAM}" ]] && { echo "ERROR: BAM file not found: ${BAM}"; exit 1; }
[[ ! -f "${REF}.fai" ]] && { echo "ERROR: Reference index not found: ${REF}.fai"; exit 1; }
[[ ! -f "${REF%.fa}.dict" ]] && { echo "ERROR: Reference dict not found: ${REF%.fa}.dict"; exit 1; }

OUTDIR="results/011_haplotype_caller_tetraploid"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=1 \
  --mem=32G \
  --job-name="hc_${SLUG}" \
  --output="logs/${SLUG}_011_hc_%j.out" \
  --error="logs/${SLUG}_011_hc_%j.err" \
  --wrap="
singularity run sifs/gatk_latest.sif \
  gatk HaplotypeCaller \
    -R ${REF} \
    -I ${BAM} \
    -O \"${OUTDIR}/${SLUG}.g.vcf.gz\" \
    --emit-ref-confidence GVCF \
    --sample-ploidy 4 \
    --min-base-quality-score 20 \
    --minimum-mapping-quality 20 \
    --standard-min-confidence-threshold-for-calling 30 \
    --max-reads-per-alignment-start 50 \
    --active-probability-threshold 0.002
"