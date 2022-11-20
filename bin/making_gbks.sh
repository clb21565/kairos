#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -p k80_q
#SBATCH -A prudenlab
#SBATCH -N 1 
#SBATCH -n 32
#proteins='/work/cascades/clb21565/WW_Analysis/hsp/MGE_analysis/context_analysis/reassembly_workdir/clinkers/myxos.txt.fasta'
#proteins='/work/cascades/clb21565/WW_Analysis/hsp/MGE_analysis/context_analysis/reassembly_workdir/clinkers/annotationdb.faa'
samples=`ls *.fasta | awk '{split($_,x,".fa"); print x[1]}' | sort | uniq`

for sample in $samples
do 
mkdir ${sample}.o
#tr "\t" "\n" < ${sample}.fasta > ${sample}.fna

split -l 2 ${sample}.fasta
Xs=x*

for X in ${Xs}; do cp "$X" "${sample}.o/$(head -1 "$X" | sed 's/>//g' | sed 's/ //g')"; done


#mv ${sample}_ctg* ${sample}.o

cd ${sample}.o 


#psamples=`ls *_ctg | awk '{split($_,x,".summary.csv"); print x[1]}' | sort | uniq`
#psamples=*_ctg* 

psamples=*

for psample in $psamples; do prokka --metagenome --mincontiglen 1500 --prefix ${psample}.prokka --metagenome --fast --cpus 32 ${psample}; done

mkdir clusters
pcsamples=*.prokka
for pcsample in $pcsamples; do cp ${pcsample}/*.gbk clusters/; done 

cd ..
done

#; mv ${sample}_ctg* ${sample}.o; for sample in $samples; do prodigal -p meta -i ${sample} -a ${sample}.faa -f gbk -o ${sample}.gbk ; done
