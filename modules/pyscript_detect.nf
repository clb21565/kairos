process detect {
	publishDir "${params.outdir}/results"
	input:
	file script
	file mge_tsv
	file target_tsv
	file redundant_overlaps
	file nonredundant_overlaps
	
	output:
	path '*',		emit:outpre 
	"""
	source activate hgt_support

python $script --MGE_dmnd $mge_tsv --target_dmnd $target_tsv --overlap_results $nonredundant_overlaps --overlap_results_red $redundant_overlaps --out_prefix ${params.outprefix} --taxa_df ${params.taxa_df} --min_orfs_in_contig ${params.min_orfs}


	"""
}
