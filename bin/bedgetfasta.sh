#!/bin/bash

bedtools sort -i $1 > $1.sorted
bedtools cluster -i ${1}.sorted > ${1}.clustered
bedtools getfasta -fi $2 -bed ${1}.clustered -fo ${1}.fasta

