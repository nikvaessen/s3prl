#!/usr/bin/env bash

rsync -aPmL "$1" "$2" \
--include="*/" \
--include="slurm*.out" --include="slurm*.err" \
--include="evaluate.*.txt" \
--include="score.out" \
--include="learning_rate.txt" \
--exclude="*"