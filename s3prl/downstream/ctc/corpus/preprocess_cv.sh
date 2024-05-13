#!/bin/bash
set -e

cv_root=$1 # common voice 7.0 dataset location
data_root=$2  # path to save data
lang=$3 # which language to pre-process (es/zh-CN/ar)

# create TSV file for train/dev/test split
echo " == processing language ${lang} =="
python3 common_voice_preprocess.py \
    --root "${cv_root}" \
    --lang "$lang" \
    --out "${data_root}"

# downsample all files in TSV file
for set in train dev test
do
    echo " == downsampling language ${lang} (${set}) =="
    python3 downsample_cv.py \
        --root "${cv_root}"/"${lang}"/clips \
        --tsv "${data_root}"/"${lang}"/${set}.tsv
done
