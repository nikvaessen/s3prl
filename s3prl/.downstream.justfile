set dotenv-load

# folders for librispeech
data-dir := "${SUPERB_DATA}"
exp-dir  := "${SUPERB_EXPERIMENTS}"

# common settings
num-workers := "$(($(nproc)-1))"
default-num-layers := "12"
fp16 := 'True'
path := '/dev/null'

# default LR values
lr2 := "1e-2"
lr3 := "1e-3"
lr4 := "1e-4"

phoneme-recognition experiment-name upstream upstream-path=path learning-rate=lr2:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/pr
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -c downstream/ctc/libriphone.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/ls100h,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.pr.txt
    cat $RUN_DIR/evaluate.pr.txt

speech-recognition experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/asr
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d asr -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.libri_root={{data-dir}}/ls100h,,\
    config.downstream_expert.datarc.bucket_file={{data-dir}}/ls100h/len_for_bucket,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -t "test-clean" -e $RUN_DIR/dev-clean-best.ckpt > $RUN_DIR/evaluate.asr.txt
    cat $RUN_DIR/evaluate.asr.txt

ood-asr-cv experiment-name upstream lang upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    # lang can be one of es, ar, zh-CN
    printf "es\nar\nzh-CN\n" | grep --line-regexp -q '{{lang}}'

    RUN_DIR={{exp-dir}}/{{experiment-name}}/asr-ood/{{lang}}
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
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
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.ood-asr.{{lang}}.txt
    cat $RUN_DIR/evaluate.ood-asr.{{lang}}.txt


ood-asr-SBCSAE experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/asr-ood/sbcsae
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
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
    mkdir -p $RUN_DIR

    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.ood-asr.sbcsae.txt
    cat $RUN_DIR/evaluate.ood-asr.sbcsae.txt

keyword-spotting experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/ks
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d speech_commands -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.speech_commands_root={{data-dir}}/speech-commands/train,,\
    config.downstream_expert.datarc.speech_commands_test_root={{data-dir}}/speech-commands/test,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.ks.txt
    cat $RUN_DIR/evaluate.ks.txt

    # write SLURM log files to $RUN_DIR

query-by-example-spoken-term-detection experiment-name upstream upstream-path=path num-layers=default-num-layers:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/qbe
    mkdir -p $RUN_DIR

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # predicting
    for layer in $(seq 1 {{num-layers}}); do
        echo "layer: $layer with {{num-workers}} workers"

        # dev
        python3 run_downstream.py \
        -d quesst14_dtw \
        -m evaluate -u {{upstream}} -k {{upstream-path}} \
        -t "dev" \
        -l ${layer} \
        -p $RUN_DIR/exp_${layer}_dev \
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
        -l ${layer} \
        -p $RUN_DIR/exp_${layer}_test \
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
        ./score-TWV-Cnxe.sh RUN_DIR//exp_${layer}_dev groundtruth_quesst14_dev -10

        # test
        ./score-TWV-Cnxe.sh $RUN_DIR/exp_${layer}_test groundtruth_quesst14_eval -10
     done

speaker-identificaton experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/sid
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d voxceleb1 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.sid.txt
    cat $RUN_DIR/evaluate.sid.txt

speaker-verification experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/asv
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d sv_voxceleb1 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/vc1,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    ./downstream/sv_voxceleb1/test_expdir.sh $RUN_DIR {{data-dir}}/vc1 > $RUN_DIR/evaluate.asv.txt
    cat $RUN_DIR/evaluate.asv.txt

speaker-diarization experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/sd
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d diarization -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.loaderrc.train_dir={{data-dir}}/librimix-sd/train,,\
    config.downstream_expert.loaderrc.dev_dir={{data-dir}}/librimix-sd/dev,,\
    config.downstream_expert.loaderrc.test_dir={{data-dir}}/librimix-sd/test,,\
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    #test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/best-states-dev.ckpt

    # score
    ./downstream/diarization/score.sh $RUN_DIR {{data-dir}}/librimix-sd/test > $RUN_DIR/evaluate.sd.txt
    cat $RUN_DIR/evaluate.sd.txt

emotion-recognition experiment-name upstream fold upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/er
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d emotion -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR/{{fold}} \
    -c downstream/emotion/config.yaml \
    -o \
    config.downstream_expert.datarc.test_fold={{fold}},,\
    config.downstream_expert.datarc.root={{data-dir}}/iemocap,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/{{fold}}/dev-best.ckpt > $RUN_DIR/{{fold}}/evaluate.er.txt
    cat $RUN_DIR/{{fold}}/evaluate.er.txt

intent-classification experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/ic
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d fluent_commands -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.file_path={{data-dir}}/fluent,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.ic.txt
    cat $RUN_DIR/evaluate.ic.txt

slot-filling experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/sf
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d ctc -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -c downstream/ctc/snips.yaml \
    -o \
    config.downstream_expert.corpus.path={{data-dir}}/snips,,\
    config.downstream_expert.corpus.num_workers={{num-workers}},,\
    config.downstream_expert.text.slots_file={{data-dir}}/snips/slots.txt,,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e$RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.sf.txt
    cat $RUN_DIR/evaluate.sf.txt

speech-translation experiment-name upstream upstream-path=path learning-rate=lr3:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/st
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    #train
    python3 run_downstream.py \
    -d speech_translation -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/dev-best.ckpt > $RUN_DIR/evaluate.st.txt
    cat $RUN_DIR/evaluate.st.txt

voice-conversion experiment-name upstream tgt-spk upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    # tgt-spk can be one of TEF1, TEF2, TEM1, TEM2
    printf "TEF1\nTEF2\nTEM1\nTEM2\n" | grep --line-regexp -q '{{tgt-spk}}'

    RUN_DIR={{exp-dir}}/{{experiment-name}}/vc/{{tgt-spk}}
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d a2o-vc-vcc2020 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.trgspk={{tgt-spk}},,\
    config.downstream_expert.datarc.data_root={{data-dir}}/vcc2020/data,,\
    config.downstream_expert.datarc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    ./downstream/a2o-vc-vcc2020/decode.sh \
        {{data-dir}}/vcc2020/models/pwg_task1 \
        $RUN_DIR \
        {{tgt-spk}} {{data-dir}}/vcc2020/data > $RUN_DIR/evaluate.vc.{{tgt-spk}}.txt

    cat $RUN_DIR/evaluate.vc.{{tgt-spk}}.txt

source-separation experiment-name upstream upstream-path=path learning-rate=lr3:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/ss
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d separation_stft2 -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -c downstream/separation_stft2/configs/cfg.yaml \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/best-states-dev.ckpt > $RUN_DIR/evaluate.ss.txt
    cat $RUN_DIR/evaluate.ss.txt

speech-enhancement experiment-name upstream upstream-path=path learning-rate=lr4:
    #!/usr/bin/env bash
    RUN_DIR={{exp-dir}}/{{experiment-name}}/se
    mkdir -p $RUN_DIR
    echo "learning rate: {{learning-rate}}" > $RUN_DIR/learning_rate.txt

    # write SLURM log files to $RUN_DIR
    if [[ ! -z "${SLURM_OUT_FILE+x}" ]]; then ln -s $SLURM_OUT_FILE $RUN_DIR/$(basename $SLURM_OUT_FILE); fi
    if [[ ! -z "${SLURM_ERR_FILE+x}" ]]; then ln -s $SLURM_ERR_FILE $RUN_DIR/$(basename $SLURM_ERR_FILE); fi

    # train
    python3 run_downstream.py \
    -d enhancement_stft -a \
    -m train -u {{upstream}} -k {{upstream-path}} \
    -c downstream/enhancement_stft/configs/cfg_voicebank.yaml \
    -p $RUN_DIR \
    -o \
    config.downstream_expert.loaderrc.num_workers={{num-workers}},,\
    config.runner.fp16={{fp16}},,\
    config.optimizer.lr={{learning-rate}}

    # test
    python3 run_downstream.py -m evaluate -e $RUN_DIR/best-states-dev.ckpt > $RUN_DIR/evaluate.se.txt
    cat $RUN_DIR/evaluate.se.txt