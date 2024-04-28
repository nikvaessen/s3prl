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
    LR=$5
fi

# activate virtual environment
source .venv/bin/activate

case $SLURM_ARRAY_TASK_ID in
    0)
        if [ -n "$LR" ]; then
            just --unstable downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    1)
        if [ -n "$LR" ]; then
            just --unstable downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    2)
        if [ -n "$LR" ]; then
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH"
        fi
        ;;
    3)
        if [ -n "$LR" ]; then
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH"
        fi
        ;;
    4)
        if [ -n "$LR" ]; then
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH"
        fi
        ;;
    5)
        if [ -n "$LR" ]; then
            just --unstable downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    6)
        if [ -n "$LR" ]; then
            just --unstable downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    7)
        just --unstable downstream::query-by-example-spoken-term-detection "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$NUM_LAYERS"
        ;;
    8)
        if [ -n "$LR" ]; then
            just --unstable downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    9)
        if [ -n "$LR" ]; then
            just --unstable downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    10)
        if [ -n "$LR" ]; then
            just --unstable downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    11)
        if [ -n "$LR" ]; then
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH"
        fi
        ;;
    12)
        if [ -n "$LR" ]; then
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH"
        fi
        ;;
    13)
        if [ -n "$LR" ]; then
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH"
        fi
        ;;
    14)
        if [ -n "$LR" ]; then
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH"
        fi
        ;;
    15)
        if [ -n "$LR" ]; then
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH"
        fi
        ;;
    16)
        if [ -n "$LR" ]; then
            just --unstable downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    17)
        if [ -n "$LR" ]; then
            just --unstable downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    18)
        if [ -n "$LR" ]; then
            just --unstable downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    19)
        if [ -n "$LR" ]; then
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH"
        fi
        ;;
    20)
        if [ -n "$LR" ]; then
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH"
        fi
        ;;
    21)
        if [ -n "$LR" ]; then
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH"
        fi
        ;;
    22)
        if [ -n "$LR" ]; then
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH"
        fi
        ;;
    23)
        if [ -n "$LR" ]; then
            just --unstable downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    24)
        if [ -n "$LR" ]; then
            just --unstable downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just --unstable downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    *)
        echo "No command specified for task ID $SLURM_ARRAY_TASK_ID"
        ;;
esac
