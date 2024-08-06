process mmseqs_edges {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file fasta
	output:
	tuple path('*rep_seq.fasta'), path('*.tsv'), emit:mmseq
	"""
	mmseqs easy-cluster $fasta edges99 edges99.tmp --min-seq-id ${params.mmseqs_windows_id} -c ${params.mmseqs_windows_cov} --cov-mode ${params.mmseqs_windows_cov_mode}
	"""
}
//source activate hgt_support
