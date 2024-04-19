set dotenv-load

# folders for librispeech
data-dir := "${SUPERB_DATA}"
exp-dir  := "${SUPERB_EXPERIMENTS}"

# common settings
num-workers := "$(($(nproc)-1))"
lr := "1e-5"

phoneme-recognition experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/pr \
    -c downstream/ctc/libriphone.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/LibriSpeech,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/pr/dev-best.ckpt

speech-recognition experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d asr \
    -p {{exp-dir}}/{{experiment-name}}/asr \
    -o \
    config.downstream_expert.datarc.libri_root={{data-dir}}/LibriSpeech,,\
    config.downstream_expert.datarc.bucket_file={{data-dir}}/LibriSpeech/len_for_bucket,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}},,\
    config.runner.total_steps=300,,\
    config.runner.eval_step=100

    # test
    python3 run_downstream.py -m evaluate -t "test-clean" -e {{exp-dir}}/{{experiment-name}}/asr/dev-clean-best.ckpt

ood-speech-recognition:
    echo 'to be implemented'

keyword-spotting experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d speech_commands \
    -p {{exp-dir}}/{{experiment-name}}/ks \
    -o \
    config.downstream_expert.datarc.speech_commands_root={{data-dir}}/speech-commands/train,,\
    config.downstream_expert.datarc.speech_commands_test_root={{data-dir}}/speech-commands/test,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}},,\
    config.runner.total_steps=300,,\
    config.runner.eval_step=100

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ks/dev-best.ckpt

query-by-example-spoken-term-detection:
    echo 'to be implemented'

speaker-identificaton:
    echo 'to be implemented'

speaker-verification:
    echo 'to be implemented'

speaker-diarization:
    echo 'to be implemented'

emotion-recognition:
    echo 'to be implemented'

intent-classification:
    echo 'to be implemented'

slot-filling:
    echo 'to be implemented'

speech-translation:
    echo 'to be implemented'

voice-conversion:
    echo 'to be implemented'

speech-separation:
    echo 'to be implemented'

speech-enhancement:
    echo 'to be implemented'

