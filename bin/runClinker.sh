#!/bin/bash
samples=*.o
for sample in $samples; do clinker ${sample}/clusters/*.gbk -i 0.3 -p ${sample}.html -mo ${sample}.mat; done

mv *txt.o store/
mv *txt.o.mat
