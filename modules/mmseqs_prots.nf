process mmseqs_prots {
        publishDir "${params.outdir}/intermediate_files"
        input:
        file faa
        output:
	path '*protclusts99_cluster.tsv*',	emit : tsv
        path '*',      				emit : prots
        """
        source activate hgt_support
	mmseqs easy-cluster $faa protclusts99 protclust99.tmp --min-seq-id ${params.mmseqs_prot_id} -c ${params.mmseqs_prot_cov} --cov-mode 1
        """
}
