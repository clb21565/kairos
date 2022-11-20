#!/bin/bash -ue
makeblastdb -in input.1 -input_type fasta -dbtype nucl -parse_seqids -out Merged -title Merged -blastdb_version 5
