process pprodigal {
	publishDir "${params.outdir}/orfs"
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
//source activate hgt_support