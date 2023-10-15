process support_derep {
	publishDir "${params.outdir}/results"
	input:
	file script
	file tsv
	val prefix
	output:
	path '*',		emit:outpre
	path '*_deduplicated_overlaps.tsv',	emit:dd
	path '*_redundant_overlaps.tsv',	emit:rd	
	"""
	source activate hgt_support
	python $script --max_overlap ${params.max_overlap} --input_clust_file $tsv --out_prefix $prefix
	"""
}
