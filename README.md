# hgt-support

hgt-support is a pipeline for detecting horizontal gene transfer and distinguishing misassemblies from genuine structural variation in metagenome assemblies. At present, it has three major modules:

***hgt-support derep-detect***

***hgt-support visualize***

***hgt-support support***

Currently draft versions of the hgt-support derep-detect and support pipeline are implemented in nextflow.

## hgt-support derep-detect

For a set of contigs, identify identical open reading frames (orfs). Contigs with identical orfs but different taxonomic assignments are putative horizontal gene transfers. Optionally, quantify the number of dereplicated contexts of shared orfs. 

We define putative horizontal gene transfers as contigs with shared genes but different taxonomic assignments. For example, two contigs sharing an idential arg ( $arg_x$ ) would have an HGT under the following conditions: 

User is required to provide taxonomic assignments. I typically use mmseqs taxonomy with gtdb as the underlying taxonomic database.

## hgt-support support

For a set of potential hgts or recombination events, determine the presence/absence in metagenomes by aligning to distinguishing loci in assemblies.

## hgt-support visualize

For a set of contigs, visualize synteny using prokka and clinker. Warning: it becomes very hard to visualize >50 contigs. 
