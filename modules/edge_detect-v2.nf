process edge_detect {
    tag { sample_label }
    publishDir "${params.outdir}/intermediate_files"

    input:
    val sample_label
    path sample_path
    val index
    output:
    path "${sample_label}.out.tsv", emit: out
    path "${sample_label}.*", emit: x

    script:

    """
    salmon quant --minAssignedFrags 1 -i ${index} -l A -r ${sample_path} -o ${sample_label}.sr.working --writeMappings -p 1 | samtools view -m ${params.min_align_length} -b | samtools sort -o ${sample_label}.out.sorted.bam        

    samtools coverage ${sample_label}.out.sorted.bam -o ${sample_label}.out.tsv

    """

}
