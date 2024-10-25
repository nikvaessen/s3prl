mkdir -p tmlr/results/large
rsync snel:data/superb/results/tmlr-large-* tmlr/results/large/ -aPL --exclude="*.ckpt"
find tmlr/results/large -type d -name "tmlr-large*" -exec ./grep_results.py {} \;
find tmlr/results/large -type f -name "results.json" -exec cat {} \; | jq -c . > tmlr/large.json