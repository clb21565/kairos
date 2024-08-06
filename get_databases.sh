#!/bin/bash

mkdir databases

wget https://zenodo.org/records/8280582/files/deeparg.zip?download=1
mv deeparg.zip?download=1 deeparg.zip 
unzip deeparg.zip

mv deeparg/database/v2/deeparg.fasta databases/

rm -r deeparg.zip
rm -r __MACOSX
rm -r deeparg/
