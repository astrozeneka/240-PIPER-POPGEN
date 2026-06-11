#!/bin/bash
# THIS SCRIPT IS POORLY OPTIMZIED FOR HPC, USE FROM PROJECT 307 INSTEAD
SLUG="${1:?Usage: $0 <slug>}"

REF="references/Piper_nigrum.genome.fa"
R1="results/004_trimmomatic/${SLUG}_R1_paired.fastq.gz"
R2="results/004_trimmomatic/${SLUG}_R2_paired.fastq.gz"

[[ ! -f "${R1}" ]] && { echo "ERROR: R1 file not found: ${R1}"; exit 1; }
[[ ! -f "${R2}" ]] && { echo "ERROR: R2 file not found: ${R2}"; exit 1; }

OUTDIR="results/008_map_on_ref"
mkdir -p "${OUTDIR}" logs

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=32 \
  --mem=32G \
  --job-name="map_${SLUG}" \
  --output="logs/${SLUG}_008map_%j.out" \
  --error="logs/${SLUG}_008map_%j.err" \
  --wrap="
    singularity exec sifs/bwa-mem2.sif bwa-mem2 mem \
      -t 32 \
      -M \
      -R '@RG\tID:${SLUG}\tSM:${SLUG}\tPL:ILLUMINA\tLB:lib1\tPU:unit1' \
      ${REF} \
      ${R1} \
      ${R2} \
    | singularity exec sifs/samtools_v1.9-4-deb_cv1.sif samtools sort \
        -@ 32 \
        -o ${OUTDIR}/${SLUG}.sorted.bam -

    singularity exec sifs/samtools_v1.9-4-deb_cv1.sif samtools index \
      ${OUTDIR}/${SLUG}.sorted.bam
  "