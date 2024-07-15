process minimap2 {
	publishDir "${params.outdir}/intermediate_files"
	input:
	file sample
	output:
	path '*',		emit:tmp
	"""
	
	minimap2 -x asm5 -X ${sample} ${sample} -N 5000 -o ${sample}.tmp
	"""
}
//source activate hgt_support