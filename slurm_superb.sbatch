#!/usr/bin/env bash
#SBATCH --job-name=superb
#SBATCH --output=superb_%A_%a.out
#SBATCH --error=superb_%A_%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-24

#SBATCH --partition=das
#SBATCH --account=das
#SBATCH --qos=das-preempt

#SBATCH --mem=20G
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --time=72:00:00

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
    LR=1e-5
else
    LR=$5
fi

# activate virtual environment
source .venv/bin/activate

case $SLURM_ARRAY_TASK_ID in
    0)
        just --unstable downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    1)
        just --unstable downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    2)
        just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH" "$LR"
        ;;
    3)
        just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH" "$LR"
        ;;
    4)
        just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH" "$LR"
        ;;
    5)
        just --unstable downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    6)
        just --unstable downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    7)
        just --unstable downstream::query-by-example-spoken-term-detection "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$NUM_LAYERS"
        ;;
    8)
        just --unstable downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    9)
        just --unstable downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    10)
        just --unstable downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    11)
        just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH" "$LR"
        ;;
    12)
        just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH" "$LR"
        ;;
    13)
        just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH" "$LR"
        ;;
    14)
        just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH" "$LR"
        ;;
    15)
        just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH" "$LR"
        ;;
    16)
        just --unstable downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    17)
        just --unstable downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    18)
        just --unstable downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    19)
        just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH" "$LR"
        ;;
    20)
        just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH" "$LR"
        ;;
    21)
        just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH" "$LR"
        ;;
    22)
        just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH" "$LR"
        ;;
    23)
        just --unstable downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    24)
        just --unstable downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        ;;
    *)
        echo "No command specified for task ID $SLURM_ARRAY_TASK_ID"
        ;;
esac
