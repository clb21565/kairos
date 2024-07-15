process sami {
	publishDir "${params.outdir}/results"
	input:
	file sort_bam
	output:
	path '*',		emit:x
	"""
	samtools index ${sort_bam}
	"""
}