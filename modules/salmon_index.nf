process index {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file fasta
	output:
	path "*",		emit: x
	"""
		
	salmon index -i representative_windows_salmon-index -t ${fasta}
	"""
}
//source activate salmon
