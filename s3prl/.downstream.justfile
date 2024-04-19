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
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -t "test-clean" -e {{exp-dir}}/{{experiment-name}}/asr/dev-clean-best.ckpt

ood-speech-recognition experiment-name learning-rate=lr:
    #!/usr/bin/env bash
    just -f .downstream.justfile _ood-asr-cv {{experiment-name}} es {{learning-rate}}
    just -f .downstream.justfile _ood-asr-cv {{experiment-name}} ar {{learning-rate}}
    just -f .downstream.justfile _ood-asr-cv {{experiment-name}} zh {{learning-rate}}
    just -f .downstream.justfile _ood-asr-SBCSAE {{experiment-name}} {{learning-rate}}

_ood-asr-cv experiment-name lang learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}} \
    -c downstream/ctc/cv_config/cv_{{lang}}.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/common-voice/cv-corpus-7.0-2021-07-21/{{lang}}/clips,,\
    config.downstream_expert.corpus.train=[\"{{data-dir}}/common-voice/{{lang}}/train.tsv\"],,\
    config.downstream_expert.corpus.test=[\"{{data-dir}}/common-voice/{{lang}}/dev.tsv\"],,\
    config.downstream_expert.corpus.dev=[\"{{data-dir}}/common-voice/{{lang}}/test.tsv\"],,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}},,\
    config.runner.total_steps=1000,,\
    config.runner.eval_step=500

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}}/dev-best.ckpt

_ood-asr-SBCSAE experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/asr-ood/SBCSAE \
    -c downstream/ctc/sbcsae.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/SBCSAE/wav,,\
    config.downstream_expert.corpus.train=[\"{{data-dir}}/SBCSAE/tsv/train.tsv\"],,\
    config.downstream_expert.corpus.test=[\"{{data-dir}}//SBCSAE/tsv/dev.tsv\"],,\
    config.downstream_expert.corpus.dev=[\"{{data-dir}}//SBCSAE/tsv/test.tsv\"],,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}},,\
    config.runner.total_steps=1000,,\
    config.runner.eval_step=500

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/SBCSAE/dev-best.ckpt

keyword-spotting experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d speech_commands \
    -p {{exp-dir}}/{{experiment-name}}/ks \
    -o \
    config.downstream_expert.datarc.speech_commands_root={{data-dir}}/speech-commands/train,,\
    config.downstream_expert.datarc.speech_commands_test_root={{data-dir}}/speech-commands/test,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

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

