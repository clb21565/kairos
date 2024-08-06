process coverage {
	publishDir "${params.outdir}/results"
	input:
	path bam
	output:
	path '*.coverage.tsv',		emit: cov_df
	path '*',			emit: x
	"""
	for bam_file in ${bam}; do
        base=\$(basename \${bam_file} .bam)
        samtools coverage \${bam_file} > \${base}.coverage.tsv
    done
	"""
}
//source activate hgt_support
//samtools coverage ${bam} > ${bam}.coverage.tsv