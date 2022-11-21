## this is an example script for running mmseqs2 taxonomy with gtdb. need the appropriately formatted database. 

#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -p normal_q
#SBATCH -A prudenlab
#SBATCH -N 1 
#SBATCH -n 128

$sample=data.fasta
GTDB='/projects/ciwars/gtdb/test3/gtdb'
mmseqs createdb $samples contigs
mmseqs taxonomy contigs $GTDB assignments tmpFolder --tax-lineage 1 --majority 0.5 --vote-mode 1 --lca-mode 3 --orf-filter 1
mmseqs createtsv contigs assignments assignRes2.tsv
