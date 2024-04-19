#!/bin/bash
set -e

cv_root=$1 # common voice 7.0 dataset location
data_root=$2  # path to save data

for lang in es zh-CN ar
do
    echo " == processing language ${lang} =="
    python3 common_voice_preprocess.py \
        --root ${cv_root} \
        --lang $lang \
        --out ${data_root}
    
    # python3 gen_vocab.py \
    #     --input_file ${data_root}/${lang}/train.txt \
    #     --mode character \
    #     --output_file ${data_root}/${lang}/vocab.txt
    
    for set in train dev test
    do
        echo " == downsampling language ${lang} (${set}) =="
        python3 downsample_cv.py \
            --root ${cv_root}/${lang}/clips \
            --tsv ${data_root}/${lang}/${set}.tsv
    done
    echo ""
done


for lang in es zh-CN ar
do
    for tsv in train.tsv dev.tsv test.tsv
    do
        echo " == downsampling language ${lang} (${tsv}) =="
        python3 downsample_cv.py \
            --root ${cv_root}/${lang}/clips \
            --tsv ${data_root}/${lang}/${tsv}
    done
    echo ""
done
