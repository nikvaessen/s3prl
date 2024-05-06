#!/usr/bin/env bash

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
    echo 'please provide "$UPSTREAM_PATH" in $3'
    exit 1
fi
if [ -z "$4" ]; then
    echo 'please provide "$LAYER_NUM" in $4'
    exit 1
fi

# set arguments
NAME="$1"
UPSTREAM="$2"
UPSTREAM_PATH="$3"
LAYER_NUM=$4

# set path to out and err file
export SLURM_OUT_FILE=$PWD/slurm-"$SLURM_ARRAY_JOB_ID"-"$SLURM_ARRAY_TASK_ID".out
export SLURM_ERR_FILE=$PWD/slurm-"$SLURM_ARRAY_JOB_ID"-"$SLURM_ARRAY_TASK_ID".err

# activate virtual environment
source .venv/bin/activate

# run command
just downstream::query-by-example-spoken-term-detection "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LAYER_NUM"