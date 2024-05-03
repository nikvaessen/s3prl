#!/usr/bin/env bash

# set arguments
NAME="$1"
UPSTREAM="$2"
UPSTREAM_PATH="$3"

if [ -z "$4" ]; then
    LR=$4
fi

case $SLURM_ARRAY_TASK_ID in
    0)
        if [ "$LR" == "wavlm" ]; then
            just downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-4
        elif [ -n "$LR" ]; then
            just downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::phoneme-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    1)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-4
        elif [ -n "$LR" ]; then
            just downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speech-recognition "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    2)
        if [ "$LR" == "wavlm" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH" "$LR"
        else
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" es "$UPSTREAM_PATH"
        fi
        ;;
    3)
        if [ "$LR" == "wavlm" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH" "$LR"
        else
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" ar "$UPSTREAM_PATH"
        fi
        ;;
    4)
        if [ "$LR" == "wavlm" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH" "$LR"
        else
            just downstream::ood-asr-cv "$NAME" "$UPSTREAM" zh-CN "$UPSTREAM_PATH"
        fi
        ;;
    5)
        if [ "$LR" == "wavlm" ]; then
            just downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::ood-asr-SBCSAE "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    6)
        if [ "$LR" == "wavlm" ]; then
            just downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 1e-5
        elif [ -n "$LR" ]; then
            just downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::keyword-spotting "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    7)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 2e-1
        elif [ -n "$LR" ]; then
            just downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speaker-identificaton "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    8)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-5
        elif [ -n "$LR" ]; then
            just downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speaker-verification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    9)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 2e-3
        elif [ -n "$LR" ]; then
            just downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speaker-diarization "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    10)
        if [ "$LR" == "wavlm" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold1 "$UPSTREAM_PATH"
        fi
        ;;
    11)
        if [ "$LR" == "wavlm" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold2 "$UPSTREAM_PATH"
        fi
        ;;
    12)
        if [ "$LR" == "wavlm" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold3 "$UPSTREAM_PATH"
        fi
        ;;
    13)
        if [ "$LR" == "wavlm" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold4 "$UPSTREAM_PATH"
        fi
        ;;
    14)
        if [ "$LR" == "wavlm" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::emotion-recognition "$NAME" "$UPSTREAM" fold5 "$UPSTREAM_PATH"
        fi
        ;;
    15)
        if [ "$LR" == "wavlm" ]; then
            just downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-5
        elif [ -n "$LR" ]; then
            just downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::intent-classification "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    16)
        if [ "$LR" == "wavlm" ]; then
            just downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 2e-4
        elif [ -n "$LR" ]; then
            just downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::slot-filling "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    17)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 1e-3
        elif [ -n "$LR" ]; then
            just downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speech-translation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    18)
        if [ "$LR" == "wavlm" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM1 "$UPSTREAM_PATH"
        fi
        ;;
    19)
        if [ "$LR" == "wavlm" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEM2 "$UPSTREAM_PATH"
        fi
        ;;
    20)
        if [ "$LR" == "wavlm" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF1 "$UPSTREAM_PATH"
        fi
        ;;
    21)
        if [ "$LR" == "wavlm" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH" 1e-4
        elif [ -n "$LR" ]; then
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH" "$LR"
        else
            just downstream::voice-conversion "$NAME" "$UPSTREAM" TEF2 "$UPSTREAM_PATH"
        fi
        ;;
    22)
        if [ "$LR" == "wavlm" ]; then
            just downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-4
        elif [ -n "$LR" ]; then
            just downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::source-separation "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;
    23)
        if [ "$LR" == "wavlm" ]; then
            just downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" 5e-4
        elif [ -n "$LR" ]; then
            just downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LR"
        else
            just downstream::speech-enhancement "$NAME" "$UPSTREAM" "$UPSTREAM_PATH"
        fi
        ;;

    *)
        echo "No command specified for task ID $SLURM_ARRAY_TASK_ID"
        ;;
esac
