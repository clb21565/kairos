process pprodigal {
	publishDir '/projects/ciwars/hgt_support/support/nextflow_pipeline/output/orfs'
	input:
	path orfs
	path fasta
	output:
	path '*',			emit:orf
	"""
	cp $fasta $orfs
	prodigal -q -i $fasta -a ${orfs}.faa -p meta
	"""
}