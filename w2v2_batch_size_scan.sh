DIR=$(realpath "$1")
LR="$2"

# default LR if not given
if [[ -z "$2" ]]; then
    echo "specify learning rate"
    exit 1
fi

JOBNAME=$(dirname "$DIR")

find "$DIR" -name "*000000050000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-050k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000100000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-100k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000150000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-150k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000200000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-200k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000250000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-250k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000300000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-300k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000350000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-350k-"$LR" wav2vec2_custom {} "$LR" \;
find "$DIR" -name "*000000400000*" -exec echo sbatch --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-400k-"$LR" wav2vec2_custom {} "$LR" \;
