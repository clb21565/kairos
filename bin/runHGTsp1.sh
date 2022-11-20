#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -p normal_q
#SBATCH -A prudenlab
#SBATCH -N 1 
#SBATCH -n 128
#workdir='/work/cascades/clb21565/hgt_support/sbr_data/hgt_support1'
#input='220427_contigs_with_annotation_targets.txt.fasta'
#input='test.fasta'
#scriptdir='/work/cascades/clb21565/hgt_support/sbr_data'
#outprefix='sbrs'

input=$1
outprefix=$2
workdir='/projects/ciwars/hgt_support/mges'
scriptdir='/projects/ciwars/hgt_support'
mkdir $workdir

cp ${input} ${workdir}/

cd ${workdir}
mkdir intermediate_files
mkdir blastdb/

makeblastdb -in ${input} -input_type fasta -dbtype nucl -parse_seqids -out Merged -title Merged -blastdb_version 5
mv Merged* blastdb

# 1 cluster contigs
${scriptdir}/mmseqs_contigs.sh ${workdir}/${input}
mv *contigs99_all_seqs.fasta ${workdir}/intermediate_files/
mv *contigs99_cluster.tsv ${workdir}/intermediate_files/
cp *contigs99_rep_seq.fasta ${workdir}/intermediate_files/

mkdir ${workdir}/orfs
mv ${workdir}/contigs99_rep_seq.fasta ${workdir}/orfs

# 2 predict ORFs
${scriptdir}/pprodigal.sh ${workdir}/orfs/
${scriptdir}/mmseqs_prots.sh ${workdir}/orfs/orfs.faa
mv ${workdir}/orfs/*.fasta ${workdir}/intermediate_files/
mv ${workdir}/protclusts*.fasta ${workdir}/intermediate_files
mv ${workdir}/protclusts99_cluster.tsv intermediate_files/
python ${scriptdir}/hgt_support_derep.py --max_overlap 0.5\
	--input_clust_file ${workdir}/intermediate_files/protclusts99_cluster.tsv\
	--out_prefix ${outprefix}

mkdir results
mv $outprefix* results/ 
