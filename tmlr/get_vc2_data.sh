mkdir -p tmlr/results/vc2
rsync snel:data/superb/results/tmlr-vc2-* tmlr/results/vc2/ -aPL --exclude="*.ckpt"
find tmlr/results/vc2 -type d -name "tmlr-vc2*" -exec ./grep_results.py {} \;
find tmlr/results/vc2 -type f -name "results.json" -exec cat {} \; | jq -c . > tmlr/vc2.json