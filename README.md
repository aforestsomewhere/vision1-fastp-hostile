# Apptainer implementation of fastp + hostile for metagenomic preprocessing.

## Install/setup:

```shell
git clone https://github.com/aforestsomewhere/vision1-fastp-hostile
cd vision1-fastp-hostile
cp /data/databases_food/fastp-hostile.sif .
```

Generate your config file and samples.tsv
```shell
scripts/make-config-env
scripts/make-samples-tsv /data/Food/analysis/RXXXX_YYY/Katie/fastq/ samples.tsv
```

If your files are all in one folder, run this script to create a new folder of symlinks with one folder per sample
```shell
scripts/restructure-sample-folders /data/Food/analysis/RXXXX_YYY/Katie/fastq/ /data/Food/analysis/RXXXX_YYY/Katie/fastq/folders/
```
Need to make folders prior to slurm batching, and obtain the number of samples to process
```shell
mkdir -p logs results
N=$(($(wc -l < samples.tsv) - 1))
```

Running as a SLURM array
```shell
sbatch --array=1-"$N"%4 \
  scripts/clean-array-slurm \
  "$(realpath samples.tsv)" \
  "$(realpath results)"  \
  "$(realpath config/my_run.env)" \
  "$(realpath scripts/clean-one-sample)"
```
