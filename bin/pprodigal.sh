#!/bin/bash

cd $1

function pProdigal(){
n=$(basename "$1")
	prodigal -q -i $1 -a ${1}.faa -p meta
}
	
export -f pProdigal
	
#samples=`ls *.contigs99_rep_seq.fasta | awk '{split($_,x,".fasta.contigs99_rep_seq.fasta"); print x[1]}' | sort | uniq`
samples=*.fasta

for sample in ${samples};
do

split --additional-suffix .tmp -n 32 ${sample}
#find . -maxdepth 1 -type f -name "x*" | parallel -j 32 pProdigal{}

find . -maxdepth 1 -type f -name "x*" | parallel -j 32 pProdigal {}
cat *tmp.faa > ${sample}.faa
rm *tmp*

mv ${sample}.faa orfs.faa
done
