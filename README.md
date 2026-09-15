Apptainer implementation of fastp + hostile for metagenomic preprocessing.

Install/setup:

git clone https://github.com/aforestsomewhere/vision1-fastp-hostile

cd vision1-fastp-hostile

cp /data/databases_food/fastp-hostile.sif .

scripts/make-config-env

scripts/make-samples-tsv /data/Food/analysis/RXXXX_YYY/Katie/fastq/ samples.tsv

#if your files are all in one folder, run this script to create a new folder of symlinks with one folder per sample
scripts/restructure-sample-folders /data/Food/analysis/RXXXX_YYY/Katie/fastq/ /data/Food/analysis/RXXXX_YYY/Katie/fastq/folders/

#need to make folders prior to slurm batching
mkdir -p logs results

#sample commands

#get number of samples
N=$(($(wc -l < samples.tsv) - 1))

#array job
sbatch --array=1-"$N"%4 \
  scripts/clean-array-slurm \
  "$(realpath samples.tsv)" \
  "$(realpath results)"  \
  "$(realpath config/my_run.env)" \
  "$(realpath scripts/clean-one-sample)"
