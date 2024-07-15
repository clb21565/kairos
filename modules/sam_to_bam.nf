process sam_to_bam {
	 publishDir "${params.outdir}/intermediate_files"
	 input:
	 file sam
	 path gz
	 output:
	 path '*.sorted.bam',	emit:sorted_bam
	 path '*',	emit:x
	 """
	 
	 samtools view -S -b ${sam} | samtools sort -o edges_${gz}.sorted.bam
	 
	 """
}
//source activate hgt_support