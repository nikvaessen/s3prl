# complete --array=0,1,4,8,10-14,15

ARRAY='0,1,4,8,10-14,15'
ARRAY='15'

# 5 min
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-050k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0050000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-100k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0100000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-150k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0150000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-200k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0200000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-250k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0250000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-300k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0300000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-350k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0350000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-5min-400k nanow2v2_large ~/data/nanow2v2/extra/large/5min/step_0400000.progress.ckpt 1e-4

# 40 min
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-40min-050k nanow2v2_large ~/data/nanow2v2/extra/large/40min/step_0050000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-40min-100k nanow2v2_large ~/data/nanow2v2/extra/large/40min/step_0100000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-40min-150k nanow2v2_large ~/data/nanow2v2/extra/large/40min/step_0150000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-40min-200k nanow2v2_large ~/data/nanow2v2/extra/large/40min/step_0200000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-large-40min-250k nanow2v2_large ~/data/nanow2v2/extra/large/40min/step_0250000.progress.ckpt 1e-4
