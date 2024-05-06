#!/usr/bin/env bash
#SBATCH --job-name=superb
#SBATCH --output=slurm-%A-%a.out
#SBATCH --error=slurm-%A-%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-23

#SBATCH --partition=das
#SBATCH --account=das
#SBATCH --qos=das-preempt

#SBATCH --mem=39GB
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00

# run superb benchmark
bash superb_run_with_learning_rate.sh "$@"
