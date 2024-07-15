process sams {
	publishDir "${params.outdir}/results"
	input:
	file working_bam
	file gz
	output:
	path '*working.sorted.bam',		emit:sort_bam
	path '*',				emit:x
	"""
	samtools sort ${working_bam} -o ${gz}.working.sorted.bam
	"""
}