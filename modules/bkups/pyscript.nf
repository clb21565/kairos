process support_derep {
	publishDir '/projects/ciwars/hgt_support/support/nextflow_pipeline/output/results'
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