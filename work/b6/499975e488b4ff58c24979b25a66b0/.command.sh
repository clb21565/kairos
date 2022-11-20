#!/bin/bash -ue
mmseqs easy-cluster test contigs99 contigs99.tmp --min-seq-id 0.99 -c 0.6 --cov-mode 1
