#!/bin/bash -ue
echo hello /projects/ciwars/hgt_support/support/clb/hgt_support
find -type f -name "test.fasta"
mmseqs easy-cluster test contigs99 contigs99.tmp --min-seq-id 0.99 -c 0.6 --cov-mode 1
