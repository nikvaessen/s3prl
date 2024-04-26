#!/usr/bin/env bash
#SBATCH --job-name=superb_fbank
#SBATCH --output=fbank_%A_%a.out
#SBATCH --error=fbank_%A_%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-24

#SBATCH --partition=das
#SBATCH --account=das
#SBATCH --qos=das-large

#SBATCH --mem=10G
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00

# check cmd arguments are given
if [ -z "$1" ]; then
    echo 'please provide "$NAME" in $1'
    exit 1
fi

# set arguments
NAME="$1"

# activate virtual environment
source .venv/bin/activate

case $SLURM_ARRAY_TASK_ID in
    0)
        just --unstable downstream::phoneme-recognition "$NAME"
        ;;
    1)
        just --unstable downstream::speech-recognition "$NAME"
        ;;
    2)
        just --unstable downstream::ood-asr-cv "$NAME" es
        ;;
    3)
        just --unstable downstream::ood-asr-cv "$NAME" ar
        ;;
    4)
        just --unstable downstream::ood-asr-cv "$NAME" zh-CN
        ;;
    5)
        just --unstable downstream::ood-asr-SBCSAE "$NAME"
        ;;
    6)
        just --unstable downstream::keyword-spotting "$NAME"
        ;;
    7)
        just --unstable downstream::query-by-example-spoken-term-detection "$NAME" 1
        ;;
    8)
        just --unstable downstream::speaker-identificaton "$NAME"
        ;;
    9)
        just --unstable downstream::speaker-verification "$NAME"
        ;;
    10)
        just --unstable downstream::speaker-diarization "$NAME"
        ;;
    11)
        just --unstable downstream::emotion-recognition "$NAME" fold1
        ;;
    12)
        just --unstable downstream::emotion-recognition "$NAME" fold2
        ;;
    13)
        just --unstable downstream::emotion-recognition "$NAME" fold3
        ;;
    14)
        just --unstable downstream::emotion-recognition "$NAME" fold4
        ;;
    15)
        just --unstable downstream::emotion-recognition "$NAME" fold5
        ;;
    16)
        just --unstable downstream::intent-classification "$NAME"
        ;;
    17)
        just --unstable downstream::slot-filling "$NAME"
        ;;
    18)
        just --unstable downstream::speech-translation "$NAME"
        ;;
    19)
        just --unstable downstream::voice-conversion "$NAME" TEM1
        ;;
    20)
        just --unstable downstream::voice-conversion "$NAME" TEM2
        ;;
    21)
        just --unstable downstream::voice-conversion "$NAME" TEF1
        ;;
    22)
        just --unstable downstream::voice-conversion "$NAME"  TEF2
        ;;
    23)
        just --unstable downstream::source-separation "$NAME"
        ;;
    24)
        just --unstable downstream::speech-enhancement "$NAME"
        ;;
    *)
        echo "No command specified for task ID $SLURM_ARRAY_TASK_ID"
        ;;
esac
