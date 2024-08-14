#!/bin/bash

mkdir databases

wget https://zenodo.org/records/8280582/files/deeparg.zip?download=1
mv deeparg.zip?download=1 deeparg.zip 
unzip deeparg.zip

mv deeparg/database/v2/deeparg.fasta databases/

rm -r deeparg.zip
rm -r __MACOSX
rm -r deeparg/

wget https://zenodo.org/records/13241605/files/mobileOG-db_beatrix-1.6.All.faa?download=1
mv mobileOG-db_beatrix-1.6.All.faa?download=1 databases/mobileOG-db_beatrix-1.6.All.faa
