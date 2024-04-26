set dotenv-load

# folders for librispeech
data-dir := "${SUPERB_DATA}"
exp-dir  := "${SUPERB_EXPERIMENTS}"

# common settings
num-workers := "$(($(nproc)-1))"
lr := "1e-5"
default-num-layers := "12"

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
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/pr/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/pr/superb.pr.txt
    cat {{exp-dir}}/{{experiment-name}}/pr/superb.pr.txt

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
    python3 run_downstream.py -m evaluate -t "test-clean" -e {{exp-dir}}/{{experiment-name}}/asr/dev-clean-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr/superb.asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr/superb.asr.txt

ood-asr-cv experiment-name lang learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}} \
    -c downstream/ctc/cv_config/cv_{{lang}}.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/cv-v7-ood/cv-corpus-7.0-2021-07-21/{{lang}}/clips,,\
    config.downstream_expert.corpus.train=[\"{{data-dir}}/cv-v7-ood/{{lang}}/train.tsv\"],,\
    config.downstream_expert.corpus.test=[\"{{data-dir}}/cv-v7-ood/{{lang}}/dev.tsv\"],,\
    config.downstream_expert.corpus.dev=[\"{{data-dir}}/cv-v7-ood/{{lang}}/test.tsv\"],,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}}/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr-ood/superb.{{lang}}.ood-asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr-ood/superb.{{lang}}.ood-asr.txt

ood-asr-SBCSAE experiment-name learning-rate=lr:
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
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/SBCSAE/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr-ood/superb.sbcsae.ood-asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr-ood/superb.sbcsae.ood-asr.txt

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
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ks/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ks/superb.ks.txt
    cat {{exp-dir}}/{{experiment-name}}/ks/superb.ks.txt

query-by-example-spoken-term-detection experiment-name num-layers=default-num-layers:
    #!/usr/bin/env bash
    # predicting
    for layer in $(seq 1 {{num-layers}}); do
        echo "layer: $layer with {{num-workers}} workers"
        # dev
        # -u hubert -l ${layer} \
        python3 run_downstream.py \
        -m evaluate -u fbank -d quesst14_dtw \
        -t "dev" \
        -p {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev \
        -o \
        "config.downstream_expert.dtwrc.dist_method=cosine,,\
        config.downstream_expert.max_workers={{num-workers}},,\
        config.downstream_expert.datarc.dataset_root={{data-dir}}/quesst14"

        # test
        python3 run_downstream.py \
        -m evaluate -u fbank -d quesst14_dtw \
        -t "test" \
        -p {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test \
        -o \
        "config.downstream_expert.dtwrc.dist_method=cosine,,\
        config.downstream_expert.max_workers={{num-workers}},,\
        config.downstream_expert.datarc.dataset_root={{data-dir}}/quesst14"
    done

    # scoring
    cd {{data-dir}}/quesst14/scoring/
    for layer in $(seq 1 {{num-layers}}); do
        # dev
        ./score-TWV-Cnxe.sh {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev groundtruth_quesst14_dev -10

        # test
        ./score-TWV-Cnxe.sh {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test groundtruth_quesst14_eval -10
     done

speaker-identificaton experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d voxceleb1 \
    -p {{exp-dir}}/{{experiment-name}}/sid \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sid/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/sid/superb.sid.txt
    cat {{exp-dir}}/{{experiment-name}}/sid/superb.sid.txt

speaker-verification experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -u fbank -d sv_voxceleb1 \
    -p {{exp-dir}}/{{experiment-name}}/asv \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
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
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    #test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sd/best-states-dev.ckpt

    # score
    ./downstream/diarization/score.sh {{exp-dir}}/{{experiment-name}}/sd {{data-dir}}/librimix-sd/test

emotion-recognition experiment-name fold learning-rate=lr:
    #!/usr/bin/env bash
    python3 run_downstream.py \
    -m train -u fbank -d emotion \
    -p {{exp-dir}}/{{experiment-name}}/er/{{fold}} \
    -c downstream/emotion/config.yaml \
    -o \
    config.downstream_expert.datarc.test_fold={{fold}},,\
    config.downstream_expert.datarc.root={{data-dir}}/iemocap,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/er/{{fold}}/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/er/{{fold}}/superb.er.txt
    cat {{exp-dir}}/{{experiment-name}}/er/{{fold}}/superb.er.txt

intent-classification experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d fluent_commands \
    -p {{exp-dir}}/{{experiment-name}}/ic \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/fluent,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ic/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ic/superb.ic.txt
    cat {{exp-dir}}/{{experiment-name}}/ic/superb.ic.txt

slot-filling experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d ctc \
    -p {{exp-dir}}/{{experiment-name}}/sf \
    -c downstream/ctc/snips.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/snips,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.downstream_expert.text.slots_file={{data-dir}}/snips/slots.txt,,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sf/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/sf/superb.sf.txt
    cat {{exp-dir}}/{{experiment-name}}/sf/superb.sf.txt

speech-translation experiment-name learning-rate=lr:
    python3 run_downstream.py \
    -m train -u fbank -d speech_translation \
    -p {{exp-dir}}/{{experiment-name}}/st \
    -o \
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/st/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/st/superb.st.txt
    cat {{exp-dir}}/{{experiment-name}}/st/superb.st.txt

voice-conversion experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py \
    -m train -d a2o-vc-vcc2020 -u fbank \
    -p {{exp-dir}}/{{experiment-name}}/vc \
    -o \
    config.downstream_expert.trgspk=TEF1,,\
    config.downstream_expert.datarc.data_root={{data-dir}}/vcc2020/data,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    # TODO VC test
    echo 'to be implemented'

source-separation experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py --mode train \
    -d separation_stft2 -u fbank  \
    -c downstream/separation_stft2/configs/cfg.yaml \
    -p {{exp-dir}}/{{experiment-name}}/ss \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ss/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ss/superb.ss.txt
    cat {{exp-dir}}/{{experiment-name}}/ss/superb.ss.txt

speech-enhancement experiment-name learning-rate=lr:
    # train
    python3 run_downstream.py --mode train \
    -d enhancement_stft -u fbank  \
    -c downstream/enhancement_stft/configs/cfg_voicebank.yaml \
    -p {{exp-dir}}/{{experiment-name}}/se \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/se/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/se/superb.se.txt
    cat {{exp-dir}}/{{experiment-name}}/se/superb.se.txt
