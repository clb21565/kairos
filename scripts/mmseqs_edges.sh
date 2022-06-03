#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -n 32 
#SBATCH -A prudenlab
#SBATCH -p k80_q
#SBATCH -N 1

mmseqs easy-cluster $1 edges99 edges99.tmp --min-seq-id 0.99 -c 0.88 --cov-mode 1
