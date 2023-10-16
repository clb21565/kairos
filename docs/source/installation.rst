Installation
=====

.. _installation:

Kairos requires nextflow and several bioinformatics packages. The dependencies can be installed through conda, as in the following command: 

kairos (main environment)

   diamond 

   mmseqs2

   minimap2

   samtools

   bedtools

   python3/pandas

kairos-assess

   salmon 

   $ conda create -n hgt_support -c bioconda pandas hgt_support
   $ conda activate hgt_support
