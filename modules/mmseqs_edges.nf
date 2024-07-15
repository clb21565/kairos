process mmseqs_edges {
	publishDir "${params.outdir}"
	input:
	file fasta
	output:
	path '*_rep_seq.fasta',		emit:edge_reps
	"""
	
	mmseqs easy-cluster $fasta edges99 edges99.tmp --min-seq-id 0.99 -c 0.88 --cov-mode 1
	"""
}
//source activate hgt_support