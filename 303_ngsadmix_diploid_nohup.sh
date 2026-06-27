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

run_jobs() {
  for K in $(seq "${K_MIN}" "${K_MAX}"); do
    for REP in $(seq 1 "${REPS}"); do
      singularity exec sifs/ngsadmix.sif \
        NGSadmix \
          -likes "${BEAGLE}" \
          -K "${K}" \
          -P "${THREADS_PER_RUN}" \
          -seed "${REP}" \
          -outfiles "${OUTDIR}/diploid_all_K${K}_rep${REP}" &
    done
  done
  wait
}

export BEAGLE OUTDIR K_MIN K_MAX REPS THREADS_PER_RUN
export -f run_jobs

OUT_LOG="logs/303_ngsadmix_diploid_$$.out"
ERR_LOG="logs/303_ngsadmix_diploid_$$.err"

echo "This will run ${TOTAL_THREADS} threads concurrently ((K_MAX-K_MIN+1) x REPS x THREADS_PER_RUN); make sure that many cores are free."

nohup bash -c run_jobs > "${OUT_LOG}" 2> "${ERR_LOG}" &

PID=$!
disown

echo "Launched NGSadmix runs (PID ${PID})"
echo "stdout: ${OUT_LOG}"
echo "stderr: ${ERR_LOG}"
