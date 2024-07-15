process cut {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file tmp
	file name
	output:
	path '*',		emit:paf
	"""
	cut -f 1-12 ${tmp} > ${name}.paf
	"""
}
