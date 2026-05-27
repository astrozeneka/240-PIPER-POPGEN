

SLUG="${1:?Usage: $0 <slug>}"
REF="references/Piper_nigrum.genome.fa"
#SLUG="P_02_DKDN200003264-1A_H35LKDSXY_L3"
R1="results/004_trimmomatic/${SLUG}_R1_paired.fq.gz"
R2="results/004_trimmomatic/${SLUG}_R2_paired.fq.gz"

[[ ! -f "${R1}" ]] && { echo "ERROR: R1 file not found: ${R1}"; exit 1; }
[[ ! -f "${R2}" ]] && { echo "ERROR: R1 file not found: ${R2}"; exit 1; }

bwa-mem2 mem -t 16 -M \
    -R '@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1\tPU:unit1' \
    "${REF}" \
    ${SAMPLE}_R1.fastq.gz ${SAMPLE}_R2.fastq.gz \
    | samtools sort -@ 8 -o ${SAMPLE}.sorted.bam -

samtools index ${SAMPLE}.sorted.bam