#!/bin/bash -ue
echo hello /projects/ciwars/hgt_support/support/clb/hgt_support
mmseqs easy-cluster test.fasta contigs99 contigs99.tmp --min-seq-id 0.99 -c 0.6 --cov-mode 1
