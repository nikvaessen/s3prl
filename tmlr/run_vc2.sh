# complete --array=0,1,4,8,10-14,15

#ARRAY='0,1,4,8,10-14,15'
#ARRAY='1,8,15'
ARRAY='11,14'

# 5 min
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-5min-100k nanow2v2 ~/data/nanow2v2/extra/vc2/5min/step_0100000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-5min-200k nanow2v2 ~/data/nanow2v2/extra/vc2/5min/step_0200000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-5min-300k nanow2v2 ~/data/nanow2v2/extra/vc2/5min/step_0300000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-5min-400k nanow2v2 ~/data/nanow2v2/extra/vc2/5min/step_0400000.progress.ckpt 1e-4

# 10 min
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-10min-100k nanow2v2 ~/data/nanow2v2/extra/vc2/10min/step_0100000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-10min-200k nanow2v2 ~/data/nanow2v2/extra/vc2/10min/step_0200000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-10min-300k nanow2v2 ~/data/nanow2v2/extra/vc2/10min/step_0300000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-10min-400k nanow2v2 ~/data/nanow2v2/extra/vc2/10min/step_0400000.progress.ckpt 1e-4

# 40 min
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-40min-050k nanow2v2 ~/data/nanow2v2/extra/vc2/40min/step_0050000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-40min-100k nanow2v2 ~/data/nanow2v2/extra/vc2/40min/step_0100000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-40min-200k nanow2v2 ~/data/nanow2v2/extra/vc2/40min/step_0200000.progress.ckpt 1e-4
#sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-40min-300k nanow2v2 ~/data/nanow2v2/extra/vc2/40min/step_0300000.progress.ckpt 1e-4
sbatch --array=$ARRAY slurm_snellius.sbatch tmlr-vc2-40min-400k nanow2v2 ~/data/nanow2v2/extra/vc2/40min/step_0400000.progress.ckpt 1e-4
