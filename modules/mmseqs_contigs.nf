process mmseqs_contigs {
        publishDir "${params.outdir}/intermediate_files"
        input:
        file fasta
        output:
	path 'contigs99_rep_seq.fasta',		emit : rep
        path 'contigs99*',      		emit : contigs99
        """
        echo hello $PWD
	mmseqs easy-cluster $fasta contigs99 contigs99.tmp --min-seq-id 0.99 -c 0.6 --cov-mode 1
        """
}
