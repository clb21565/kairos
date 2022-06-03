#!/bin/bash

samples=`ls *.txt.fasta | awk '{split($_,x,".txt.fasta"); print x[1]}'`
for sample in ${samples}; do minimap2 -x asm5 -X ${sample}.txt.fasta ${sample}.txt.fasta -N 5000 -o ${sample}.tmp; cut -f 1-12 ${sample}.tmp > ${sample}.paf; rm ${sample}.tmp;  done