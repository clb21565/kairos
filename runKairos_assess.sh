#!/bin/bash
contigs='absolutepathto/test.fasta'
samples='samples.tsv'
nextflow kairos-assess.nf --input_contigs $contigs --input_reads $samples --outdir test --outprefix test
