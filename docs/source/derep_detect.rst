derep-detect
=====
Installation
=====

.. _derep-detect:

hgt-support requires nextflow and several bioinformatics packages. The dependencies can be installed through conda, as in the following command: 

.. code-block:: console

   $ conda create -n hgt_support -c bioconda pandas hgt_support
   $ conda activate hgt_support
.. dereplicate contigs by detecting identical orfs in contigs:

dereplicate contigs by detecting identical orfs in contigs
------------
The first module of hgt-support enables the detection of overlapping genes and the quantification of unique genetic contexts of these genes. Hgt-support derep-detect identifies identical orfs in contigs and assesses their redundancy based on the proportion of orfs that are shared to those that are unique (see methods). Putative HGTs are those events where identical orfs occur in two contigs with differing taxonomic assignment. The contig-centred approach has advantages and drawbacks. For example, metagenome assembled genome (MAG)-based methods will better ensure the taxonomic inferences and, theoretically, could provide a nearly database-independent assessment of taxonomic differences through independent phylogenomic analyses. However, it remains very difficult to correctly bin contigs derived from the accessory (i.e., strain specific) genome due to differences in the coverage profiles incurred by metagenomes with co-occurring microbial strains.  Further, the accessory genome of many bacterial species would include genes most likely to be exchanged by HGT. Thus, using contig taxonomic assignments eliminates this loss of information. On the other hand, taxonomic information contained in contigs can be misleading due to the mosaic nature of bacterial genomes. A potential compromise to explore is using information from MAGs to guide the taxonomic classification of the contig. This would best be explored with a validation dataset including species of ground truth. 

Default settings are listed in parentheses

1. Predict open reading frames using prodigal (2) (-p meta)

2. Cluster open reading frames using mmseqs (1) (coverage of ≥30% and identity of ≥99 %)

3. Cluster contigs by proportion of shared open reading frames (minimum of 50% by default)

4. Contigs with ≥50% shared orfs  relative to the smaller contig (i.e., $\frac{n_{shared}} {min(n_{contig1} , n_{contig2})} \geq$ 50%) are likely duplicates. 

5. Clusters are dereplicated and the member with the largest number of orfs is selected as the representative. In the rare case of ties, one of the tied cluster members are randomly selected. The number of contexts ascribed to a gene is thus the number of dereplicated contigs with the gene.   

We define putative horizontal gene transfers as contigs with shared genes but different taxonomic assignments. For example, two contigs sharing an idential arg ( $arg_x$ ) would have an HGT under the following conditions: 

>$contig_1 \in taxa_1,arg_x$
>
>$contig_2 \in taxa_2,arg_x$
>
>$hgt_{1,2} = contig_1 \notin  contig_2 =taxa_1,taxa_2$

To run derep-detect:

.. code-block:: console

   (.venv) $ nextflow runHGTsp_dd.nf --input data.fasta --outdir outdir 


