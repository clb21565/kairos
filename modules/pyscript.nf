process support_derep {
	publishDir "${params.outdir}/results"
	input:
	file script
	file tsv
	val prefix
	output:
	path '*',		emit:outpre
	"""
	python $script --max_overlap 0.5 --input_clust_file $tsv --out_prefix $prefix
	"""
}
