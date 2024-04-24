#!/usr/bin/env bash
#SBATCH --job-name=superb_fbank
#SBATCH --output=fbank_%A_%a.out
#SBATCH --error=fbank_%A_%a.err
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --array=0-17

#SBATCH --partition=das
#SBATCH --account=das
#SBATCH --qos=das-normal

#SBATCH --mem=10G
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00

# check cmd arguments are given
if [ -z "$1" ]; then
    echo 'please provide $NAME in $1'
    exit 1
fi

# set arguments
NAME="$1"

# activate virtual environment
activate

case $SLURM_ARRAY_TASK_ID in
    0)
        just downstream::phoneme-recognition $NAME
        ;;
    1)
        just downstream::speech-recognition $NAME
        ;;
    2)
        just downstream::ood-asr-cv $NAME es
        ;;
    3)
        just downstream::ood-asr-cv $NAME ar
        ;;
    4)
        just downstream::ood-asr-cv $NAME zh
        ;;
    5)
        just downstream::ood-asr-SBCSAE $NAME
        ;;
    6)
        just downstream::keyword-spotting $NAME
        ;;
    7)
        just downstream::query-by-example-spoken-term-detection $NAME 1
        ;;
    8)
        just downstream::speaker-identificaton $NAME
        ;;
    9)
        just downstream::speaker-verification $NAME
        ;;
    10)
        just downstream::speaker-diarization $NAME
        ;;
    11)
        just downstream::emotion-recognition $NAME
        ;;
    12)
        just downstream::intent-classification $NAME
        ;;
    13)
        just downstream::slot-filling $NAME
        ;;
    14)
        just downstream::speech-translation $NAME
        ;;
    15)
        just downstream::voice-conversion $NAME
        ;;
    16)
        just downstream::source-separation $NAME
        ;;
    17)
        just downstream::speech-enhancement $NAME
        ;;
    *)
        echo "No command specified for task ID $SLURM_ARRAY_TASK_ID"
        ;;
esac