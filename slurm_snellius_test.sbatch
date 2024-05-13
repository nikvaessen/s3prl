#!/usr/bin/env bash
#SBATCH --job-name=superb
#SBATCH --output=slurm-%A-%a.out
#SBATCH --error=slurm-%A-%a.err
#SBATCH --array=0-23

#SBATCH --partition=gpu
#SBATCH --constraint=scratch-node

#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00

# load modules and virtual environment
source "$HOME"/bin/load-modules
source .venv/bin/activate

# set data locations
export SUPERB_DATA=$TMPDIR/data
export ADF_WORK_DIR=$TMPDIR/adf/work

# Check SLURM_ARRAY_TASK_ID value and setup the correct dataset
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ] || [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
    # took around 6 minutes
    just ls100h

elif [ "$SLURM_ARRAY_TASK_ID" -eq 2 ]; then
    just _cv-v7-ood es

elif [ "$SLURM_ARRAY_TASK_ID" -eq 3 ]; then
    just _cv-v7-ood ar

elif [ "$SLURM_ARRAY_TASK_ID" -eq 4 ]; then
    just _cv-v7-ood zh-CN

elif [ "$SLURM_ARRAY_TASK_ID" -eq 5 ]; then
    just SBCDAE

elif [ "$SLURM_ARRAY_TASK_ID" -eq 6 ]; then
    just speech-commands

elif [ "$SLURM_ARRAY_TASK_ID" -eq 7 ] || [ "$SLURM_ARRAY_TASK_ID" -eq 8 ]; then
    just vc1

elif [ "$SLURM_ARRAY_TASK_ID" -eq 9 ] || [ "$SLURM_ARRAY_TASK_ID" -eq 22 ]; then
    echo 'librimix uses hard-coded paths...'
    # just librimix
    exit 1

elif [ "$SLURM_ARRAY_TASK_ID" -ge 10 ] && [ "$SLURM_ARRAY_TASK_ID" -le 14 ]; then
    # took 10 minutes
    just iemocap

elif [ "$SLURM_ARRAY_TASK_ID" -eq 15 ]; then
    just fluent

elif [ "$SLURM_ARRAY_TASK_ID" -eq 16 ]; then
    just snips

elif [ "$SLURM_ARRAY_TASK_ID" -eq 17 ]; then
    echo 'translation uses hard-coded paths...'
    # just cv-v4-translate
    exit 1

elif [ "$SLURM_ARRAY_TASK_ID" -ge 18 ] && [ "$SLURM_ARRAY_TASK_ID" -le 21 ]; then
    just vcc2020

elif [ "$SLURM_ARRAY_TASK_ID" -eq 23 ]; then
    echo 'voicebank uses hardcoded paths...'
    # just voicebank
    exit 1
else
    echo "Unknown SLURM_ARRAY_TASK_ID value: $SLURM_ARRAY_TASK_ID"
    exit 1
fi

# run superb benchmark
# bash superb_run_with_learning_rate.sh "$@"
