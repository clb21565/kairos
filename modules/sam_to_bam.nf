process sam_to_bam {
	 publishDir "${params.outdir}/intermediate_files"
	 input:
	 file sam
	 path gz
	 output:
	 path '*.sorted.bam',	emit:sorted_bam
	 path '*',	emit:x
	 """
	 for sam_file in ${sam}; do
        base=\$(basename \${sam_file} .working.sam)
        samtools view -S -b \${sam_file} | samtools sort -o edges_\${base}.sorted.bam
     done
	 """
}
//source activate hgt_support
//samtools view -S -b ${sam} | samtools sort -o edges_${gz}.sorted.bam