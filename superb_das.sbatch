#!/usr/bin/env bash
#SBATCH --job-name=superb
#SBATCH --output=slurm-%A-%a.out
#SBATCH --error=slurm-%A-%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-23

#SBATCH --partition=das
#SBATCH --account=das
#SBATCH --qos=das-large
#SBATCH --exclude=cn104

#SBATCH --mem=39GB
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00

# check cmd arguments are given
if [ -z "$1" ]; then
    echo 'please provide "$NAME" in $1'
    exit 1
fi
if [ -z "$2" ]; then
    echo 'please provide "$UPSTREAM" in $2'
    exit 1
fi
if [ -z "$3" ]; then
    echo 'please provide "$UPSTREAM_PATH" in $4'
    exit 1
fi

# set arguments
NAME="$1"
UPSTREAM="$2"
UPSTREAM_PATH="$3"

# default LR if not given
if [[ -n "$4" ]]; then
    LR=$4
fi

# activate virtual environment
source .venv/bin/activate

# set path to out and err file
export SLURM_OUT_FILE=$PWD/slurm-"$SLURM_JOB_ID"-"$SLURM_ARRAY_TASK_ID".out
export SLURM_ERR_FILE=$PWD/slurm-"$SLURM_JOB_ID"-"$SLURM_ARRAY_TASK_ID".err

# run superb benchmark
bash superb_run_with_learning_rate.sh "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"