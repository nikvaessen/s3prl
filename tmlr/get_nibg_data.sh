rsync snel:data/superb/results/tmlr-nibg-* tmlr/results/nibg/ -aPL --exclude="*.ckpt"
find tmlr/results/nibg -type d -name "tmlr-nibg*" -exec ./grep_results.py {} \;
find tmlr/results/nibg -type f -name "results.json" -exec cat {} \; | jq -c . > tmlr/nibg.json