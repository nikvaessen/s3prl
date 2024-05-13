DIR=$(realpath "$1")
LR="$2"

# default LR if not given
if [[ -z "$2" ]]; then
    echo "specify learning rate"
    exit 1
fi

JOBNAME=$(basename "$DIR")

# find "$DIR" -name "*000000050000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-050k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
# find "$DIR" -name "*000000150000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-150k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
# find "$DIR" -name "*000000250000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-250k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
# find "$DIR" -name "*000000350000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-350k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;

find "$DIR" -name "*000000100000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-100k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
find "$DIR" -name "*000000200000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-200k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
find "$DIR" -name "*000000300000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-300k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
find "$DIR" -name "*000000400000*" -exec sbatch --time=0-12 --array=0,4,7,10-15,18-21 slurm_snellius.sbatch "$JOBNAME"-400k-nanow2v2-13w-"$LR" nanow2v2 {} "$LR" \;
