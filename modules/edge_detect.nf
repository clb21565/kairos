process edge_detect {
	publishDir "${params.outdir}/intermediate_files"
	input:
	path gz
	file index
	output:
	path '*working.sam',		emit:working_sam
	path '*',			emit:x
	"""
	for file in ${gz}; do
        base=\$(basename \${file} .fastq.gz)
        salmon quant --minAssignedFrags 1 -i ${index} -l A -r \${file} -o salmon-result_\${base}.working --writeMappings -p 1 > \${base}.working.sam
    done
	"""
}
//source activate salmon
//salmon quant --minAssignedFrags 1 -i ${index} -l A -r ${gz} -o salmon-result_${gz}.working --writeMappings -p 1 > ${gz}.working.sam