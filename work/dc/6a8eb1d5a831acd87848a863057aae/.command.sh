#!/bin/bash -ue
mmseqs easy-cluster orfs.faa protclusts99 protclust99.tmp --min-seq-id 0.99 -c 0.3 --cov-mode 1
