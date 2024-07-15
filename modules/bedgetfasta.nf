process bedget {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file bed
	file fasta
	output:
	path '*.bed.fasta',	emit:cbed
	path '*',		emit:files
	"""
	
	bedtools sort -i $bed > ${bed}.sorted
	bedtools cluster -i ${bed}.sorted > ${bed}.clustered
	bedtools getfasta -fi $fasta -bed ${bed}.clustered -fo ${bed}.fasta
	"""
}
//source activate hgt_support