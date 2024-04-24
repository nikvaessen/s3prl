set dotenv-load

mod downstream 's3prl/.downstream.justfile'

# paths to data
superb-data-dir := "${SUPERB_DATA}"
adf-work-dir    := "${ADF_WORK_DIR}"

# List all recipes
default:
  @just --unstable --unsorted --list

# Install all python dependencies
install-dependencies:
    pip install -r adf/requirements.txt
    pip install -e ".[all]"

setup-data: ls100h speech-commands cv-v4-translate cv-v7-ood SBCDAE quesst14 vc1 librimix iemocap fluent snips vcc2020 voicebank

place-manual-downloads dir_with_archives:
    mkdir -p "${ADF_DOWNLOAD_DIR}"/iemocap/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/cv-v7-ood/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/cv-v4-translate/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/fluent/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/snips/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/vc1/download/
    mkdir -p "${ADF_DOWNLOAD_DIR}"/vcc2020/download/models/

    rsync {{dir_with_archives}}/IEMOCAP_full_release_withoutVideos.tar.gz "${ADF_DOWNLOAD_DIR}"/iemocap/download/
    rsync {{dir_with_archives}}/cv-corpus-7.0-2021-07-21-ar.tar.gz        "${ADF_DOWNLOAD_DIR}"/cv-v7-ood/download/
    rsync {{dir_with_archives}}/cv-corpus-7.0-2021-07-21-es.tar.gz        "${ADF_DOWNLOAD_DIR}"/cv-v7-ood/download/
    rsync {{dir_with_archives}}/cv-corpus-7.0-2021-07-21-zh-CN.tar.gz     "${ADF_DOWNLOAD_DIR}"/cv-v7-ood/download/
    rsync {{dir_with_archives}}/en.tar.gz                                 "${ADF_DOWNLOAD_DIR}"/cv-v4-translate/download/
    rsync {{dir_with_archives}}/fluent.zip                                "${ADF_DOWNLOAD_DIR}"/fluent/download/
    rsync {{dir_with_archives}}/snips.zip                                 "${ADF_DOWNLOAD_DIR}"/snips/download/
    rsync {{dir_with_archives}}/vox1_dev_wav.zip                          "${ADF_DOWNLOAD_DIR}"/vc1/download/
    rsync {{dir_with_archives}}/vox1_test_wav.zip                         "${ADF_DOWNLOAD_DIR}"/vc1/download/
    rsync {{dir_with_archives}}/hifigan_vctk+vcc2020.tar.gz               "${ADF_DOWNLOAD_DIR}"/vcc2020/download/models/
    rsync {{dir_with_archives}}/pwg_task1.tar.gz                          "${ADF_DOWNLOAD_DIR}"/vcc2020/download/models/
    rsync {{dir_with_archives}}/pwg_task2.tar.gz                          "${ADF_DOWNLOAD_DIR}"/vcc2020/download/models/

# setup the librispeech dataset
ls100h:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/ls100h

    # create symlink
    ln -s {{adf-work-dir}}/ls100h/extract/LibriSpeech {{superb-data-dir}}/ls100h

    # setup data
    cd adf
    just --unstable ls100h::setup
    cd ..

    # create bucket file for asr fine-tuning
    echo "0 3 5" | python3 s3prl/preprocess/generate_len_for_bucket.py -i {{superb-data-dir}}/ls100h -o {{superb-data-dir}}/ls100h -a .flac --n_jobs $(nproc)


speech-commands:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/speech-commands

    # create symlink
    ln -s {{adf-work-dir}}/speech-commands/extract/ {{superb-data-dir}}/speech-commands

    # setup data
    cd adf
    just --unstable speech-commands::setup
    cd ..

cv-v7-ood:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/cv-v7-ood

    # create symlink
    ln -s {{adf-work-dir}}/cv-v7-ood/extract/ {{superb-data-dir}}/cv-v7-ood

    # setup data
    cd adf
    just --unstable cv-v7-ood::setup
    cd ..

    # pre-process data
    cd s3prl/downstream/ctc/corpus/
    bash preprocess_cv.sh {{superb-data-dir}}/cv-v7-ood/cv-corpus-7.0-2021-07-21 {{superb-data-dir}}/cv-v7-ood
    cd ../../../

SBCDAE:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/SBCSAE

    # create symlink
    ln -s {{adf-work-dir}}/SBCSAE/extract/ {{superb-data-dir}}/SBCSAE

    # setup data
    cd adf
    just --unstable SBCSAE::setup
    cd ..

quesst14:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/quesst14

    # create symlink
    ln -s {{adf-work-dir}}/quesst14/extract/quesst14Database {{superb-data-dir}}/quesst14

    # setup data
    cd adf
    just --unstable quesst14::setup
    cd ..

vc1:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/vc1

    # create symlink
    ln -s {{adf-work-dir}}/vc1/extract/ {{superb-data-dir}}/vc1

    # setup data
    cd adf
    just --unstable vc1::setup
    cd ..

librimix:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/librimix-sd
    rm -f {{superb-data-dir}}/librimix-ss

    # create symlink
    ln -s {{adf-work-dir}}/librimix/extract/mix-sd/Libri2Mix/wav16k/max {{superb-data-dir}}/librimix-sd
    ln -s {{adf-work-dir}}/librimix/extract/mix-ss/Libri2Mix/ {{superb-data-dir}}/librimix-ss

    # setup data
    cd adf
    just --unstable librimix::setup
    cd ..

    # prepare separation
    rm -rf s3prl/downstream/separation_stft2/datasets/Libri2Mix

    python s3prl/downstream/separation_stft2/scripts/LibriMix/data_prepare.py \
    --part train-100 {{superb-data-dir}}/librimix-ss s3prl/downstream/separation_stft2/datasets/Libri2Mix

    python s3prl/downstream/separation_stft2/scripts/LibriMix/data_prepare.py \
    --part dev {{superb-data-dir}}/librimix-ss s3prl/downstream/separation_stft2/datasets/Libri2Mix

    python s3prl/downstream/separation_stft2/scripts/LibriMix/data_prepare.py \
    --part test {{superb-data-dir}}/librimix-ss s3prl/downstream/separation_stft2/datasets/Libri2Mix

    # setup dscore
    git clone git@github.com:nikvaessen/dscore.git s3prl/downstream/diarization/dscore

iemocap:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/iemocap

    # create symlink
    ln -s {{adf-work-dir}}/iemocap/extract/IEMOCAP_full_release {{superb-data-dir}}/iemocap

    # setup data
    cd adf
    just --unstable iemocap::setup
    cd ..

fluent:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/fluent

    # create symlink
    ln -s {{adf-work-dir}}/fluent/extract/fluent_speech_commands_dataset {{superb-data-dir}}/fluent

    # setup data
    cd adf
    just --unstable fluent::setup
    cd ..

snips:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/snips

    # create symlink
    ln -s {{adf-work-dir}}/snips/extract/SNIPS {{superb-data-dir}}/snips

    # setup data
    cd adf
    just --unstable snips::setup
    cd ..

vcc2020:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/vcv2020

    # create symlink
    ln -s {{adf-work-dir}}/vcc2020/extract/ {{superb-data-dir}}/vcc2020
    mkdir -p {{adf-work-dir}}/vcc2020/extract/

    # setup data
    cd adf
    just --unstable vcc2020::setup
    cd ..

cv-v4-translate:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/cv-v4-translate

    # create symlink
    ln -s {{adf-work-dir}}/cv-v4-translate/extract/ {{superb-data-dir}}/cv-v4-translate

    # setup data
    cd adf
    just --unstable cv-v4-translate::setup
    cd ..

    # pre-process data
    cd s3prl/downstream/speech_translation/prepare_data/
    bash prepare_covo.sh {{superb-data-dir}}/cv-v4-translate
    cd ../../../


voicebank:
    #!/usr/bin/env bash
    set -e

    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/voicebank

    # create symlink
    ln -s {{adf-work-dir}}/voicebank/extract/noisy-vctk-16k {{superb-data-dir}}/voicebank

    # setup data
    cd adf
    just --unstable voicebank::setup
    cd ..

    # prepare train, dev and test data in Kaldi format
    rm -rf s3prl/downstream/enhancement_stft/datasets/voicebank
    python s3prl/downstream/enhancement_stft/scripts/Voicebank/data_prepare.py\
        {{superb-data-dir}}/voicebank s3prl/downstream/enhancement_stft/datasets/voicebank --part train
    python s3prl/downstream/enhancement_stft/scripts/Voicebank/data_prepare.py \
        {{superb-data-dir}}/voicebank s3prl/downstream/enhancement_stft/datasets/voicebank --part dev
    python s3prl/downstream/enhancement_stft/scripts/Voicebank/data_prepare.py \
        {{superb-data-dir}}/voicebank s3prl/downstream/enhancement_stft/datasets/voicebank --part test
