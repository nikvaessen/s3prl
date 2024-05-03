#!/usr/bin/env bash
#SBATCH --job-name=superb
#SBATCH --output=superb_%A_%a.out
#SBATCH --error=superb_%A_%a.err

#SBATCH --array=0-24

#SBATCH --partition=gpu

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
    echo 'please provide "$NUM_LAYERS" in $3'
    exit 1
fi
if [ -z "$4" ]; then
    echo 'please provide "$UPSTREAM_PATH" in $4'
    exit 1
fi

# set arguments
NAME="$1"
UPSTREAM="$2"
NUM_LAYERS="$3"
UPSTREAM_PATH="$4"

# default LR if not given
if [ -z "$5" ]; then
    LR=$5
fi

# activate virtual environment
source $HOME/bin/load-modules
source .venv/bin/activate

# run superb benchmark
bash superb_run.sh "$NAME" "$UPSTREAM" "$NUM_LAYERS" "$UPSTREAM_PATH" "$LR"