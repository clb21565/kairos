process samv {
	 publishDir "${params.outdir}/results"
	 input:
	 file sam
	 file gz
	 output:
	 path '*bam',	emit:workingBam
	 path '*',	emit:x
	 """
	 samtools view -S -b ${sam} > ${gz}.working.bam
	 """
}