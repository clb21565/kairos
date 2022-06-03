#!/bin/bash
#SBATCH -t 140:00:00
#SBATCH -p normal_q
#SBATCH -A prudenlab
#SBATCH -N 1 
#SBATCH -n 128

#mmseqs databases UniRef50 ur50 tmp
#mmseqs databases UniProtKB/Swiss-Prot mmseqDb.UR50 o:UniRef50.db


#mmseqs easy-taxonomy ctg.fna ur50 outtest tmp --lca-mode 4
#mmseqs easy-taxonomy -s 4 --split-memory-limit 500G firsttig.txt.fa ur50 result tmp
#samples=`ls *.fa | awk '{split($_,x,".fa"); print x[1]}' | sort | uniq`
#samples=*gz
#for sample in $samples
#do
samples='220427_contigs_with_annotation_targets.txt.fasta'
#GTDB='/work/cascades/clb21565/WW_Analysis/databases/mmseqsDB/test3/gtdb'
#SP='/work/cascades/clb21565/WW_Analysis/databases/mmseqsDB/swp/swissprotDB'
GTDB='/projects/ciwars/gtdb/test3/gtdb'
mmseqs createdb $samples contigs
mmseqs taxonomy contigs $GTDB assignments tmpFolder --tax-lineage 1 --majority 0.5 --vote-mode 1 --lca-mode 3 --orf-filter 1
mmseqs createtsv contigs assignments assignRes2.tsv

#mmseqs easy-taxonomy -s 4 mobileARGctgs.fna $GTDB sample.mmseqs.gtdb.result tmp
#awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $sample.fa > ${sample}.coded.fa

#done
