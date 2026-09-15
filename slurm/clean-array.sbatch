#!/bin/bash
#SBATCH --job-name=fastp_hostile
#SBATCH --partition=Background
#SBATCH --array=2-2%1
#SBATCH --cpus-per-task=10
#SBATCH --mem=24G
#SBATCH --output=logs/%A_%a.out
#SBATCH --error=logs/%A_%a.err

set -euo pipefail

CONFIG="${1:-config/my_run.env}"
source "$CONFIG"

mkdir -p logs "$OUTDIR"

if [[ "${SLURM_CPUS_PER_TASK}" != "${THREADS_PER_SAMPLE}" ]]; then
  echo "ERROR: SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}, but THREADS_PER_SAMPLE=${THREADS_PER_SAMPLE}"
  echo "Edit either #SBATCH --cpus-per-task or THREADS_PER_SAMPLE."
  exit 2
fi

line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES_TSV")

sample=$(echo "$line" | awk -F '\t' '{print $1}')
r1=$(echo "$line" | awk -F '\t' '{print $2}')
r2=$(echo "$line" | awk -F '\t' '{print $3}')

#safety - remove errant carriage returns
sample="${sample//$'\r'/}"
r1="${r1//$'\r'/}"
r2="${r2//$'\r'/}"

if [[ -z "$sample" || -z "$r1" || -z "$r2" ]]; then
  echo "ERROR: Could not parse sample sheet line ${SLURM_ARRAY_TASK_ID}"
  echo "$line"
  exit 2
fi

echo "Sample: $sample"
echo "R1: $r1"
echo "R2: $r2"
echo "Outdir: $OUTDIR"
echo "Threads: $SLURM_CPUS_PER_TASK"
echo "Hostile indices:"
printf '  %s\n' "${HOSTILE_INDICES[@]}"

bind_args=()
for bind_path in $APPTAINER_BINDS; do
  bind_args+=(--bind "$bind_path")
done

index_args=()
for idx in "${HOSTILE_INDICES[@]}"; do
  index_args+=(--hostile-index "$idx")
done

label_args=()
for label in "${HOSTILE_INDEX_LABELS[@]}"; do
  label_args+=(--hostile-index-label "$label")
done

apptainer exec \
  "${bind_args[@]}" \
  "$IMAGE" \
  clean-one-sample \
    --r1 "$r1" \
    --r2 "$r2" \
    --sample "$sample" \
    --outdir "$OUTDIR" \
    --threads "$SLURM_CPUS_PER_TASK" \
    "${index_args[@]}" \
    "${label_args[@]}"
