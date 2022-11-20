process blastdb {
	publishDir '/projects/ciwars/hgt_support/support/nextflow_pipeline/output/blastdb'
	input:
	file fasta
	output:
	path 'Merged*',			emit:Merged
	"""
	makeblastdb -in ${fasta} -input_type fasta -dbtype nucl -parse_seqids -out Merged -title Merged -blastdb_version 5
	"""
}