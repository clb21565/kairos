### Here are scripts for the draft pipeline of hgt-support ### 

https://github.com/clb21565/hgt_support/tree/main/scripts

1. runHGTsp1.sh 

this is the main script for running from contigs --> to deduplicated overlaps between contigs. Variables have to be set in the script as of right now. 

2. mmseqs_taxonomy.sh

this would be applied to the contigs one is putting into the pipeline 

3. mmseqs_contigs.sh

used internally by runHGTsp1.sh

4. mmseqs_prots.sh

used internally by runHGTsp1.sh

5. mmseqs_edges.sh

used to dereplicate extracted edges following all v all mapping 

6. pprodigal.sh

used internally by runHGTsp1.sh

7. hgt_support_derep.py

used internally by runHGTsp1.sh; this is where we separate contigs with n% overlaps as redundant or not

8. extract_window_regions_2.1.py

this is used to make bed files for bedgetfasta.sh, happens after all v all mapping
9. p_salmon.sh

this is a parallelized version of salmon quant steps that can take up to 128 input samples at once (for tinkercliffs). large references might fail

10. minimap_all_v_all.sh

all v all alignment step

11. makingGBKs.sh

this runs prokka on a set of contigs and then produces a separate folder with gbks for passing to clinker for visualization

12. runClinker.sh

this runs clinker on a set of gbk files for visualization. note these two scripts (11,12) are really just for visualizing specific contig sets and shouldn't be run on the whole dataset. 

13. bedgetfasta.sh

this is how we get the edge fasta files from the output produced by extract window regions py script

14. get_regions.sh

this runs extract windows regions py script with some default parameters



