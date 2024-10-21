rsync snel:data/superb/results/tmlr-vc2-* tmlr/results/vc2/ -aPL --exclude="*.ckpt"
find tmlr/results/vc2 -type d -name "tmlr-vc2*" -exec ./grep_results.py {} \;