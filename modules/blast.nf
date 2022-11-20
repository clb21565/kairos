process blastdb {
	publishDir "${params.outdir}/blastdb"
	input:
	file fasta
	output:
	path 'Merged*',			emit:Merged
	"""
	makeblastdb -in ${fasta} -input_type fasta -dbtype nucl -parse_seqids -out Merged -title Merged -blastdb_version 5
	"""
}
