#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -n 32 
#SBATCH -A prudenlab
#SBATCH -p k80_q
#SBATCH -N 1


#.contigs99_all_seqs.fasta
#source activate mmseqs2 

mmseqs easy-cluster $1 contigs99 contigs99.tmp --min-seq-id 0.99 -c 0.6 --cov-mode 1

#mmseqs easy-cluster $1 clusts99 clust99.tmp --min-seq-id 99 -c 0.3 --cov-mode 1


