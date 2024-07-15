#!/bin/bash
#SBATCH -t 140:00:70
#SBATCH -n 128
#SBATCH -N 1
#SBATCH -p normal_q
#SBATCH -A prudenlab

input_contigs='absolute path/to/contigs.fna'
taxa_df='absolute path/to/taxa.tsv'
outdir='user-selected out directory'

target_db='absolute path/to/targetdb.fna'
mge_db='absolute path/to/mge_db.fna'

nextflow kairos-dd-haoqiu2.nf --max_cpus 128 --max_overlap 0.5 --input_contigs $input_contigs --taxa_df $taxa_df --outdir $outdir --target_database $target_db --MGE_database $mge_db --num_chunks 16
