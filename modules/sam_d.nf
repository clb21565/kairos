process samd {
	publishDir "${params.outdir}/results"
	input:
	file sort_bam
	file gz
	output:
	path '*working.depth',			emit:work_depth
	path '*',				emit:x
	"""
	samtools depth ${sort_bam} > ${gz}.working.depth
	"""
}