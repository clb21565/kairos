process calc_window_props {

        publishDir "${params.outdir}/results"

        input:
        file py
        file edge_clusters
	file sample_coverage
        val sample_name
        
	output:
        path '*',               emit:result
        
	"""
        python ${py} --min_prop ${params.minimum_proportion_windows} --input_clust_file $edge_clusters --input_cov_file $sample_coverage --sample_name $sample_name
        """


}
