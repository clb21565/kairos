Kairos assess
=====

.. _Kairos assess:

see :doc:`installation` for installing

.. code-block:: console

Description
------------

Kairos assess detects the presence of contigs representing structural microdiversity and/or potential HGTs and reports their presence to the user

Input
-----------

input to Kairos assess is a contigs fasta file and interleaved fastq files to be mapped

**input parameters**

* taxa_df = null 

   input taxonomy dataframe of format: contig classification
 
* input_contigs = null	
   
   input contigs in fasta format

* outprefix = 'kairos'    
   
   job title that will be used for file naming 

**clustering and window extraction parameters**

* edge_length = 75

   length in bp to extend around boundaries of alignment (window size is 2*edge_length)

* mmseqs_windows_cov = 0.88

   the mmseqs -c parameter used during window dereplication 

* mmseqs_windows_id = 0.99

   the mmseqs --id parameter used during window dereplication 

* mmseqs_windows_cov_mode = 1

   the mmseqs -c parameter used during window dereplication    

**output options**

  <work in progress>

