#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -p normal_q
#SBATCH -A prudenlab
#SBATCH -N 1 
#SBATCH -n 128

readdir='/projects/ciwars/hgt_support/reads'
#readdir='/projects/ciwars/hgt_support/simulated_data_2'
workdir='/projects/ciwars/hgt_support'

cd $readdir

samples=`ls *.fq.gz | awk '{split($_,x,".fq.gz"); print x[1]}'`

#samples='HFGVI0044Q XHJCW6359E PMBNJ0338H YPQCU7286X LJSLX5580A NLQVX0980P UPKQF5024K SMRZL4770S HQATZ1945L GONKH1834E ASZUA0069S KMWIQ0712K HDRFF4542I EZZPO6467Z ZYTXN5029K SMAIH8416T UIBOQ0127Z TBBIJ6883B VVJFE8127P RBHSA3360N GXDMU2252I LSCZF6957Y RTCST0504P BDOLL5284I JUJHF9134P AYHUY2120D TFTUD9566I CVREQ2707V SNLSN1243N UCOZS4528E IUDZC4434Q ABVSK8395E JXRFG8695L SLHEZ2715P SNUEY9437E KEIHK1168I LNBYT5954Z AAOLJ3001L EWOJK0017V MRGNY0672A NQWTN3218U PPQYX0519D LZGQG4924W NEAWE3101W GTAKE7915Y LMGGV4316U DNGEE8998Y GFGIA8953L EBZCS4093H BKBAA7920Q FQLZW4300W FFXIX2867H OGYXM7861O MGTBM3934B'

#edges="edges99_rep_seq.fasta"
#edges=`ls *.comparisons.bed.fasta.edges99_rep_seq.fasta | awk '{split($_,x,".comparisons.bed.fasta.edges99_rep_seq.fasta"); print x[1]}'`
edges=`ls *.fasta | awk '{split($_,x,".fasta"); print x[1]}'`

function allele_quant(){
n=$(basename "$1")
salmon quant --minAssignedFrags 1 -i WORKING-salmon-index -l A -r ${1} -o salmon-result_${1}.working --writeMappings -p 1 > ${1}.working.sam
samtools view -m 100 -S -b ${1}.working.sam > ${1}.working.bam
samtools sort ${1}.working.bam -o ${1}.working.sorted.bam
samtools depth ${1}.working.sorted.bam > ${1}.working.depth
samtools index ${1}.working.sorted.bam
rm ${1}.working.sam
rm ${1}.working.bam

}

export -f allele_quant
#find . -maxdepth 1 -type f -name "*.final.fq.gz" | parallel -j 32 allele_quant {}
for edge in ${edges}
do
#salmon index -i WORKING-salmon-index -t ${edge}.bed.fasta
salmon index -i WORKING-salmon-index -t ${edge}.fasta
find . -maxdepth 1 -type f -name "*.fq.gz" | parallel -j 128 allele_quant {}
samples=`ls *.fq.gz | awk '{split($_,x,".fq.gz"); print x[1]}'`
for sample in ${samples}
do

mv ${sample}.fq.gz.working.sorted.bam ${sample}.${edge}.sorted.bam
mv ${sample}.fq.gz.working.sorted.bam.bai ${sample}.${edge}.sorted.bam.bai
mv ${sample}.fq.gz.working.depth ${sample}.${edge}.depth

mv salmon-result_${sample}.working

done
done
