#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -n 32 
#SBATCH -A prudenlab
#SBATCH -p k80_q
#SBATCH -N 1


source activate mmseqs2

mmseqs easy-cluster $1 protclusts99 protclust99.tmp --min-seq-id 0.99 -c 0.3 --cov-mode 1

 

