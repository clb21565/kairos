#!/bin/bash -ue
makeblastdb -in test.fasta -input_type fasta -dbtype nucl -parse_seqids -out Merged -title Merged -blastdb_version 5
