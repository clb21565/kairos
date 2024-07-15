process extract_edges {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file py
	file paf
	val prefix
	output:
	path '*',		emit:bed
	"""
	
	python ${py} --inpaf ${paf} --out_prefix ${prefix} --extension_length ${params.edge_length}
	"""
}
//source activate hgt_support