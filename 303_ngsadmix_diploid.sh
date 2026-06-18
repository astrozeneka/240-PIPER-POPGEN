#!/bin/bash

BEAGLE="results/301_all_angsd_diploid/diploid_all.beagle.gz"

[[ ! -f "${BEAGLE}" ]] && { echo "ERROR: Beagle file not found: ${BEAGLE}"; exit 1; }

OUTDIR="results/303_ngsadmix_diploid"
mkdir -p "${OUTDIR}" logs

K_MIN=1
K_MAX=5
REPS=5
THREADS_PER_RUN=2
TOTAL_THREADS=$(( (K_MAX - K_MIN + 1) * REPS * THREADS_PER_RUN ))

sbatch \
  --partition=UNLIMITED \
  --ntasks=1 \
  --cpus-per-task=${TOTAL_THREADS} \
  --mem=64G \
  --job-name="ngsadmix_diploid_all" \
  --output="logs/303_ngsadmix_diploid_%j.out" \
  --error="logs/303_ngsadmix_diploid_%j.err" \
  --wrap="
for K in \$(seq ${K_MIN} ${K_MAX}); do
  for REP in \$(seq 1 ${REPS}); do
    singularity exec sifs/ngsadmix.sif \
      NGSadmix \
        -likes ${BEAGLE} \
        -K \${K} \
        -P ${THREADS_PER_RUN} \
        -seed \${REP} \
        -outfiles ${OUTDIR}/diploid_all_K\${K}_rep\${REP} &
  done
done
wait
"
