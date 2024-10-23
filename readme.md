# experiments data quality

tasks:
asr (1)
asr-zh (4)
er (10-14)
sv (8)


## baseline

```
sbatch --array=1,4,8,10-14 slurm_snellius.sbatch dq-baseline nanow2v2 /gpfs/work2/0/rus22022/wav2sr/ssl/sweep/2024-06-11---13-47-16/1/checkpoints/step_0400000.val-loss_11378.98.best.ckpt 1e-4 
```