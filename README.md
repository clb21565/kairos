# HGT-support

hgt-support is a pipeline for detecting horizontal gene transfer and distinguishing misassemblies from genuine structural variation in metagenome assemblies. At present, it has three major modules:

***HGT-support derep-detect***

***HGT-support assess***

Currently draft versions of the hgt-support derep-detect and support pipeline are implemented in nextflow.

## HGT-support derep-detect

For a set of contigs, identify identical open reading frames (orfs). Contigs with identical orfs but different taxonomic assignments are putative horizontal gene transfers. Optionally, quantify the number of dereplicated contexts of shared orfs. 

We define putative horizontal gene transfers as contigs with shared genes but different taxonomic assignments. For example, two contigs sharing an idential arg ( $arg_x$ ) would have an HGT under the following conditions: 

User is required to provide taxonomic assignments. I typically use mmseqs taxonomy with gtdb as the underlying taxonomic database.

nextflow HGTsp_dd.nf --input test.fasta --outdir testrun

nextflow HGTsp_as.nf --input test.fasta --outdir testrun --interleaved_fastq test1.fq.gz test2.fq.gz test3.fq.gz --sample_metadata test_metadata.tsv

Visualization is performed using clinker. Note it becomes difficult to visualize many contigs at once. 

## HGT-support assess

For a set of potential hgts or recombination events, determine the presence/absence in metagenomes by aligning to distinguishing boundary regions extracted from contigs.
