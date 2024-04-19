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

# setup the librispeech dataset
librispeech:
    #!/usr/bin/env bash
    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/LibriSpeech

    # create symlink
    ln -s {{adf-work-dir}}/librispeech/extract/LibriSpeech {{superb-data-dir}}/LibriSpeech

    # setup data
    cd adf
    just --unstable librispeech::download librispeech::extract

    # create bucket file for asr fine-tuning
    cd ..
    echo "0 3 5" | python3 s3prl/preprocess/generate_len_for_bucket.py -i {{superb-data-dir}}/LibriSpeech -o {{superb-data-dir}}/LibriSpeech -a .flac --n_jobs $(nproc)

speech-commands:
    #!/usr/bin/env bash
    # setup paths
    mkdir -p {{superb-data-dir}}
    rm -f {{superb-data-dir}}/speech-commands

    # create symlink
    ln -s {{adf-work-dir}}/speech-commands/extract/ {{superb-data-dir}}/speech-commands

    # setup data
    cd adf
    just --unstable speech-commands::setup


