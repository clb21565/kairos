#!/bin/bash

#samples=`ls *.txt.fasta | awk '{split($_,x,".txt.fasta"); print x[1]}'`
#for sample in ${samples}; 
minimap2 -x asm5 -X ${1}.fasta ${1}.fasta -N 5000 -o ${1}.tmp; cut -f 1-12 ${1}.tmp > ${1}.paf; rm ${1}.tmp


#for sample in ${samples}; do python extract_window_regions.py --out_prefix ${sample} --inpaf ${sample}.paf --window_length 75; done
