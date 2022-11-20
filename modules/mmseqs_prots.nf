process mmseqs_prots {
        publishDir "${params.outdir}/intermediate_files"
        input:
        file faa
        output:
	path '*protclusts99_cluster.tsv*',	emit : tsv
        path '*',      				emit : prots
        """
        mmseqs easy-cluster $faa protclusts99 protclust99.tmp --min-seq-id 0.99 -c 0.3 --cov-mode 1
        """
}
