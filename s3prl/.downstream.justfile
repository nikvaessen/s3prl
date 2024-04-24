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
    config.downstream_expert.corpus.path={{data-dir}}/ls100h,,\
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
    config.downstream_expert.datarc.libri_root={{data-dir}}/ls100h,,\
    config.downstream_expert.datarc.bucket_file={{data-dir}}/ls100h/len_for_bucket,,\
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
    config.optimizer.lr={{learning-rate}}

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
    config.optimizer.lr={{learning-rate}}

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

query-by-example-spoken-term-detection experiment-name:
    #!/usr/bin/env bash
    layer=-1
    # dev
    python3 run_downstream.py \
    -m evaluate -u hubert -l ${layer} \
    -d quesst14_dtw -t "dev" \
    -p {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev \
    -o \
    config.downstream_expert.dtwrc.dist_method=cosine,,\
    config.downstream_expert.datarc.dataset_root={{data-dir}}/quesst14

    # TODO logic doing all layers and scoring the best one...

speaker-identificaton experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d voxceleb1 \
    -p {{exp-dir}}/{{experiment-name}}/sid \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sid/dev-best.ckpt

speaker-verification experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d sv_voxceleb1 \
    -p {{exp-dir}}/{{experiment-name}}/asv \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.optimizer.lr={{learning-rate}}

    # test
    ./downstream/sv_voxceleb1/test_expdir.sh {{exp-dir}}/{{experiment-name}}/asv {{data-dir}}/vc1

speaker-diarization experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d diarization \
    -p {{exp-dir}}/{{experiment-name}}/sd \
    -o \
    config.downstream_expert.loaderrc.train_dir={{data-dir}}/librimix-sd/train,,\
    config.downstream_expert.loaderrc.dev_dir={{data-dir}}/librimix-sd/dev,,\
    config.downstream_expert.loaderrc.test_dir={{data-dir}}/librimix-sd/test,,\
    config.optimizer.lr={{learning-rate}}

    # test
    echo 'to be implemented'

emotion-recognition experiment-name learning-rate=lr:
    #!/usr/bin/env bash
    python3 run_downstream.py \
    -m train -u fbank -d emotion \
    -p {{exp-dir}}/{{experiment-name}}/er \
    -c downstream/emotion/config.yaml \
    -o \
    config.downstream_expert.datarc.test_fold='fold1',,\
    config.downstream_expert.datarc.root={{data-dir}}/iemocap,,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/er/dev-best.ckpt

intent-classification experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d fluent_commands \
    -p {{exp-dir}}/{{experiment-name}}/ic \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/fluent,,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ic/dev-best.ckpt

slot-filling experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/sf \
    -c downstream/ctc/snips.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/snips,,\
    config.downstream_expert.text.slots_file={{data-dir}}/snips/slots.txt,,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sf/dev-best.ckpt

speech-translation experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d speech_translation \
    -p {{exp-dir}}/{{experiment-name}}/st \
    -o \
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/st/dev-best.ckpt

voice-conversion experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -d a2o-vc-vcc2020 -u fbank \
    -p {{exp-dir}}/{{experiment-name}}/vc \
    -o \
    config.downstream_expert.trgspk=TEF1,,\
    config.downstream_expert.datarc.data_root={{data-dir}}/vcc2020/data,,\
    config.optimizer.lr={{learning-rate}}

    # test
    echo 'todo'

source-separation experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py --mode train \
        -d separation_stft2 -u wav2vec2  \
        -c downstream/separation_stft2/configs/cfg.yaml \
        -p {{exp-dir}}/{{experiment-name}}/ss

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ss/dev-best.ckpt

speech-enhancement experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py --mode train \
        -d enhancement_stft -u wav2vec2  \
        -c downstream/enhancement_stft/configs/cfg_voicebank.yaml \
        -p {{exp-dir}}/{{experiment-name}}/se

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/se/dev-best.ckpt

