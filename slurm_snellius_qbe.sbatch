#!/usr/bin/env bash
#SBATCH --job-name=superb-qbe
#SBATCH --output=slurm-%A-%a.out
#SBATCH --error=slurm-%A-%a.err

#SBATCH --array=0-12

#SBATCH --partition=gpu

#SBATCH --gres=gpu:1
#SBATCH --time=2:00:00

# load modules virtual environment
source "$HOME"/bin/load-modules

# run superb benchmark
bash superb_run_qbe.sh "$@" "$SLURM_ARRAY_TASK_ID"
