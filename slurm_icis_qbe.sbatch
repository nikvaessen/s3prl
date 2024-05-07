#!/usr/bin/env bash
#SBATCH --job-name=superb-qbe
#SBATCH --output=slurm-%A-%a.out
#SBATCH --error=slurm-%A-%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-12

#SBATCH --partition=icis
#SBATCH --account=icis
#SBATCH --qos=icis-preempt

#SBATCH --mem=39GB
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --time=2:00:00

# run superb benchmark
bash superb_run_qbe.sh "$@" "$SLURM_ARRAY_TASK_ID"
