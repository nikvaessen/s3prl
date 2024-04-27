set dotenv-load

# folders for librispeech
data-dir := "${SUPERB_DATA}"
exp-dir  := "${SUPERB_EXPERIMENTS}"

# common settings
num-workers := "$(($(nproc)-1))"
lr := "1e-5"
default-num-layers := "12"
fp16 := 'True'
path := '/dev/null'

phoneme-recognition experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/pr \
    -c downstream/ctc/libriphone.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/ls100h,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/pr/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/pr/superb.pr.txt
    cat {{exp-dir}}/{{experiment-name}}/pr/superb.pr.txt

speech-recognition experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d asr -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/asr \
    -o \
    config.downstream_expert.datarc.libri_root={{data-dir}}/ls100h,,\
    config.downstream_expert.datarc.bucket_file={{data-dir}}/ls100h/len_for_bucket,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -t "test-clean" -e {{exp-dir}}/{{experiment-name}}/asr/dev-clean-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr/superb.asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr/superb.asr.txt

ood-asr-cv experiment-name upstream lang upstream-path=path learning-rate=lr:
    # lang can be one of es, ar, zh-CN
    printf "es\nar\nzh-CN\n" | grep --line-regexp -q '{{lang}}'

    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}} \
    -c downstream/ctc/cv_config/cv_{{lang}}.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/cv-v7-ood/cv-corpus-7.0-2021-07-21/{{lang}}/clips,,\
    config.downstream_expert.corpus.train=[\"{{data-dir}}/cv-v7-ood/{{lang}}/train.tsv\"],,\
    config.downstream_expert.corpus.test=[\"{{data-dir}}/cv-v7-ood/{{lang}}/dev.tsv\"],,\
    config.downstream_expert.corpus.dev=[\"{{data-dir}}/cv-v7-ood/{{lang}}/test.tsv\"],,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}}/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr-ood/superb.{{lang}}.ood-asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr-ood/superb.{{lang}}.ood-asr.txt

ood-asr-SBCSAE experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/asr-ood/SBCSAE \
    -c downstream/ctc/sbcsae.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/SBCSAE/wav,,\
    config.downstream_expert.corpus.train=[\"{{data-dir}}/SBCSAE/tsv/train.tsv\"],,\
    config.downstream_expert.corpus.test=[\"{{data-dir}}//SBCSAE/tsv/dev.tsv\"],,\
    config.downstream_expert.corpus.dev=[\"{{data-dir}}//SBCSAE/tsv/test.tsv\"],,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/asr-ood/SBCSAE/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/asr-ood/superb.sbcsae.ood-asr.txt
    cat {{exp-dir}}/{{experiment-name}}/asr-ood/superb.sbcsae.ood-asr.txt

keyword-spotting experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d speech_commands -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/ks \
    -o \
    config.downstream_expert.datarc.speech_commands_root={{data-dir}}/speech-commands/train,,\
    config.downstream_expert.datarc.speech_commands_test_root={{data-dir}}/speech-commands/test,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ks/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ks/superb.ks.txt
    cat {{exp-dir}}/{{experiment-name}}/ks/superb.ks.txt

query-by-example-spoken-term-detection experiment-name upstream upstream-path=path num-layers=default-num-layers:
    #!/usr/bin/env bash
    # predicting
    for layer in $(seq 1 {{num-layers}}); do
        echo "layer: $layer with {{num-workers}} workers"
        # dev
        # -u hubert -l ${layer} \
        python3 run_downstream.py \
        -d quesst14_dtw \
        -m evaluate -u {{upstream}} -k {{upstream-path}} \
        -t "dev" \
        -p {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev \
        -o \
        "config.downstream_expert.dtwrc.dist_method=cosine,,\
        config.downstream_expert.max_workers={{num-workers}},,\
        config.downstream_expert.datarc.num_workers={{num-workers}},,\
        config.downstream_expert.datarc.dataset_root={{data-dir}}/quesst14"

        # test
        python3 run_downstream.py \
        -d quesst14_dtw \
        -m evaluate -u {{upstream}} -k {{upstream-path}} \
        -t "test" \
        -p {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test \
        -o \
        "config.downstream_expert.dtwrc.dist_method=cosine,,\
        config.downstream_expert.max_workers={{num-workers}},,\
        config.downstream_expert.datarc.num_workers={{num-workers}},,\
        config.downstream_expert.datarc.dataset_root={{data-dir}}/quesst14"
    done

    # scoring
    cd {{data-dir}}/quesst14/scoring/
    for layer in $(seq 1 {{num-layers}}); do
        # dev
        ./score-TWV-Cnxe.sh {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev groundtruth_quesst14_dev -10 > {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev/superb.qbe.txt
        cat {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_dev/superb.qbe.txt

        # test
        ./score-TWV-Cnxe.sh {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test groundtruth_quesst14_eval -10 > {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test/superb.qbe.txt
        cat {{exp-dir}}/{{experiment-name}}/qbe/exp_${layer}_test/superb.qbe.txt
     done

speaker-identificaton experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d voxceleb1 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/sid \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sid/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/sid/superb.sid.txt
    cat {{exp-dir}}/{{experiment-name}}/sid/superb.sid.txt

speaker-verification experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d sv_voxceleb1 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/asv \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    ./downstream/sv_voxceleb1/test_expdir.sh {{exp-dir}}/{{experiment-name}}/asv {{data-dir}}/vc1 > {{exp-dir}}/{{experiment-name}}/asv/superb.asv.txt
    cat {{exp-dir}}/{{experiment-name}}/asv/superb.asv.txt

speaker-diarization experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d diarization -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/sd \
    -o \
    config.downstream_expert.loaderrc.train_dir={{data-dir}}/librimix-sd/train,,\
    config.downstream_expert.loaderrc.dev_dir={{data-dir}}/librimix-sd/dev,,\
    config.downstream_expert.loaderrc.test_dir={{data-dir}}/librimix-sd/test,,\
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    #test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sd/best-states-dev.ckpt

    # score
    ./downstream/diarization/score.sh {{exp-dir}}/{{experiment-name}}/sd {{data-dir}}/librimix-sd/test > {{exp-dir}}/{{experiment-name}}/sd/superb.sd.txt
    cat {{exp-dir}}/{{experiment-name}}/sd/superb.sd.txt

emotion-recognition experiment-name upstream fold upstream-path=path learning-rate=lr:
    #!/usr/bin/env bash
    python3 run_downstream.py \
    -d emotion -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/er/{{fold}} \
    -c downstream/emotion/config.yaml \
    -o \
    config.downstream_expert.datarc.test_fold={{fold}},,\
    config.downstream_expert.datarc.root={{data-dir}}/iemocap,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/er/{{fold}}/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/er/{{fold}}/superb.er.txt
    cat {{exp-dir}}/{{experiment-name}}/er/{{fold}}/superb.er.txt

intent-classification experiment-name upstream upstream-path=path learning-rate=lr:
    python3 run_downstream.py \
    -d fluent_commands -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/ic \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/fluent,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ic/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ic/superb.ic.txt
    cat {{exp-dir}}/{{experiment-name}}/ic/superb.ic.txt

slot-filling experiment-name upstream upstream-path=path learning-rate=lr:
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/sf \
    -c downstream/ctc/snips.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/snips,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.downstream_expert.text.slots_file={{data-dir}}/snips/slots.txt,,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/sf/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/sf/superb.sf.txt
    cat {{exp-dir}}/{{experiment-name}}/sf/superb.sf.txt

speech-translation experiment-name upstream upstream-path=path learning-rate=lr:
    python3 run_downstream.py \
    -d speech_translation -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/st \
    -o \
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/st/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/st/superb.st.txt
    cat {{exp-dir}}/{{experiment-name}}/st/superb.st.txt

voice-conversion experiment-name upstream tgt-spk upstream-path=path learning-rate=lr:
    # tgt-spk can be one of TEF1, TEF2, TEM1, TEM2
    printf "TEF1\nTEF2\nTEM1\nTEM2\n" | grep --line-regexp -q '{{tgt-spk}}'

    # train
    python3 run_downstream.py \
    -d a2o-vc-vcc2020 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p {{exp-dir}}/{{experiment-name}}/vc/{{tgt-spk}} \
    -o \
    config.downstream_expert.trgspk={{tgt-spk}},,\
    config.downstream_expert.datarc.data_root={{data-dir}}/vcc2020/data,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    ./downstream/a2o-vc-vcc2020/decode.sh \
        {{data-dir}}/vcc2020/models/pwg_task1 \
        {{exp-dir}}/{{experiment-name}}/vc/{{tgt-spk}} \
        {{tgt-spk}} {{data-dir}}/vcc2020/data > {{exp-dir}}/{{experiment-name}}/vc/{{tgt-spk}}/superb.vc.{{tgt-spk}}.txt

    cat {{exp-dir}}/{{experiment-name}}/vc/{{tgt-spk}}/superb.vc.{{tgt-spk}}.txt

source-separation experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d separation_stft2 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -c downstream/separation_stft2/configs/cfg.yaml \
    -p {{exp-dir}}/{{experiment-name}}/ss \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/ss/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/ss/superb.ss.txt
    cat {{exp-dir}}/{{experiment-name}}/ss/superb.ss.txt

speech-enhancement experiment-name upstream upstream-path=path learning-rate=lr:
    # train
    python3 run_downstream.py \
    -d enhancement_stft -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -c downstream/enhancement_stft/configs/cfg_voicebank.yaml \
    -p {{exp-dir}}/{{experiment-name}}/se \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e {{exp-dir}}/{{experiment-name}}/se/dev-best.ckpt > {{exp-dir}}/{{experiment-name}}/se/superb.se.txt
    cat {{exp-dir}}/{{experiment-name}}/se/superb.se.txt
