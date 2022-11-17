# hgt-support

Scripts: https://github.com/clb21565/hgt_support/blob/main/scripts/descriptions.MD

Description:

hgt-support is a pipeline for detecting horizontal gene transfer and distinguishing misassemblies from genuine structural variation in metagenome assemblies. At present, it has three major modules:

***hgt-support derep-detect***

***hgt-support visualize***

***hgt-support support***

Currently draft versions of the hgt-support derep-detect and support pipeline are implemented in nextflow.

## hgt-support derep-detect

For a set of contigs, identify identical open reading frames (orfs). Contigs with identical orfs but different taxonomic assignments are putative horizontal gene transfers. Optionally, quantify the number of dereplicated contexts of shared orfs. 

Default settings are listed in parentheses
1. Predict open reading frames using prodigal (2) (-p meta)

2. Cluster open reading frames using mmseqs (1) (coverage of ≥30% and identity of ≥99 %)

3. Cluster contigs by proportion of shared open reading frames (minimum of 50% by default)

4. Contigs with ≥50% shared orfs  relative to the smaller contig (i.e., $\frac{n_{shared}} {min(n_{contig1} , n_{contig2})} \geq$ 50%) are likely duplicates. 

5. Clusters are dereplicated and the member with the largest number of orfs is selected as the representative. In the rare case of ties, one of the tied cluster members are randomly selected. The number of contexts ascribed to a gene is thus the number of dereplicated contigs with the gene.   

We define putative horizontal gene transfers as contigs with shared genes but different taxonomic assignments. For example, two contigs sharing an idential arg ( $arg_x$ ) would have an HGT under the following conditions: 

>$contig_1 \in contig_1,taxa_1,arg_x$
>
>$contig_2 \in contig_2,taxa_2,arg_x$
>
>$hgt_{1,2} = contig_1 \notin  contig_2 =taxa_1,taxa_2$


User is required to provide taxonomic assignments. I typically use mmseqs taxonomy with gtdb as the underlying taxonomic database.

## hgt-support support

For a set of potential hgts or recombination events, determine the presence/absence in metagenomes by aligning to distinguishing loci in assemblies.

1. Deduplicated contigs are aligned to one another using minimap2 (-x asm5 -X)

2. Edge regions, defined by coordinates of (alignment-start ± length l and alignment-end ± length l, default of 75 bp) are written to bedfiles that are then sorted, clustered, and extracted from the contigs using bedtools

3. Edges are dereplicated using mmseqs (identity ≥99% and coverage = 88%)
Short reads are mapped to the dereplicated edges using salmon and the presence/absence of each region of variation are assessed by counting the number of reads mapping to each locus passing quality filtering (100 bp minimum alignment length, i.e., samtools view -m 00) 

4. By default, a minimum of one read is taken as evidence of the locus being present. The minimum alignment setting of 100 bp ensures that at least 25 bp of the unique portion of the locus is present. 

5. Results of the reads mapping are summarized using samtools coverage (using default parameters). 

6. Reads mapping results are extended to apply also to edge cluster members by combining the output of samtools coverage with the edge cluster table.

7. The presence/absence of structural variations are determined by counting the proportion of distinguishing loci detected to total distinguishing loci in the contig (≥90% of distinguishing loci must be detected). 
