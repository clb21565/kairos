process result {
	publishDir "${params.outdir}"
	input:
	path result
	output:
	path '*',		emit:x
	"""
	conda activate mge_tool
	samtools coverage ${result} > samtools_cov.result.tsv
	"""
}
