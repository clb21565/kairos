#!/bin/bash
#SBATCH -t 140:00:70
#SBATCH -n 1
#SBATCH -p k80_q
#SBATCH -A prudenlab
#SBATCH -N 1

source activate biopy 
#Merged in function below = blastdb

function extractFa(){
n=$(basename "$1")
blastdbcmd -entry_batch $1 -db Merged > $1.tmp
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' < $1.tmp > $1.tmp1
tail -n +2 "$1.tmp1" > $1.fasta

}

export -f extractFa
find . -maxdepth 1 -type f -name "*.txt" | parallel -j 32 extractFa {}

rm *.txt.tmp*
rm *.txt