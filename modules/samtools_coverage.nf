process coverage {
	publishDir "${params.outdir}/results"
	input:
	path bam
	output:
	path '*.coverage.tsv',		emit: cov_df
	path '*',			emit: x
	"""
	
	samtools coverage ${bam} > ${bam}.coverage.tsv
	"""
}
//source activate hgt_support