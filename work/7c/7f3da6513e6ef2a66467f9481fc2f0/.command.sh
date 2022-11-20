#!/bin/bash -ue
cp contigs99_rep_seq.fasta orfs
prodigal -q -i contigs99_rep_seq.fasta -a orfs.faa -p meta
