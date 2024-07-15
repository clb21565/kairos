process edge_detect {
	publishDir "${params.outdir}/intermediate_files"
	input:
	//path gz
	//file index
	tuple path(gz), file(index)
	output:
	path '*working.sam',		emit:working_sam
	path '*',			emit:x
	"""
	//source activate salmon
	salmon quant --minAssignedFrags 1 -i ${index} -l A -r ${gz} -o salmon-result_${gz}.working --writeMappings -p 1 > ${gz}.working.sam
	"""
}
//source activate salmon
