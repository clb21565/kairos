nextflow.enable.dsl=2
input_contigs = file(params.input_contigs)
taxadf = file(params.taxa_df)
outprefix = params.outprefix 
chunk = params.num_chunks
workdir = file(params.outdir)
bin = file('.')

//input_contigs = file('/projects/ciwars/hgt_support/support/230524_new_pipeline2_new_test_data/test_multiple_read_samples/smaller.test.fasta')
//taxadf = file('/projects/ciwars/hgt_support/support/clb/kairos/tem_result')
//outprefix = 'tem_result'
//workdir = file('/projects/ciwars/hgt_support/support/clb/kairos')
//bin = file('.')

log.info """\
         kairos derep-detect | an nf pipeline
==================================================================================================
 Input: ${input_contigs}	
 Output Prefix: ${outprefix}
 Work Directory: ${workdir}
 Script Directory: ${bin}
==================================================================================================
         """
         .stripIndent()

workdir.mkdir()

intermediate = file(workdir/'intermediate_files')
blastdb = file(workdir/'blastdb')
orf = file(workdir/'orfs')
result = file(workdir/'results')
intermediate.mkdir()
blastdb.mkdir()
orf.mkdir()
result.mkdir()

include { blastdb } from './modules/blast'
include { mmseqs_contigs } from './modules/mmseqs_contigs'
include { pprodigal } from './modules/pprodigal'
include { diamond_target } from './modules/diamond_target'
include { diamond_mge } from './modules/diamond_mge'
include { mmseqs_prots } from './modules/mmseqs_prots'
include { support_derep } from './modules/pyscript'
include { detect } from './modules/pyscript_detect'


workflow flow1 {
	 take:
	 data
	 main:
	 blastdb(data)
	 mmseqs_contigs(data)
	 emit:
	 mmseqs_contigs.out.rep

}


process splitInput {
    publishDir "${workdir}/split", mode: 'copy'

    input:
    path contigs
    val num

    output:
    path 'split/*'

    script:
    """
    mkdir -p split
    split -d -n l/${num ?: 1} -a 3 $contigs split/split_
    ls -lah split/
    """
}


process ConcatenateOutputs {
    input:
    path outputs

    output:
    path 'all_orfs_combined.fasta'

    script:
    """
    cat ${outputs.join(' ')} > all_orfs_combined.fasta
    """
}


process run_prodigal {
    tag "Running Prodigal on ${file}"

    input:
    path file

    output:
    path "*.faa",			emit:orf

    script:
    """
    prodigal -q -i ${file} -a ${file.simpleName}.faa -p meta
    """
}


workflow flow2 {
	 take:
	 data1
	 main:
	 run_prodigal(data1)
	 emit:
	 run_prodigal.out.orf
}


workflow annotate_targets {
	take:
	data
	main:
	diamond_target(data)
	emit:
	diamond_target.out.DIAMOND
}


workflow annotate_MGEs {

        take:
        data
        main:
        diamond_mge(data)
        emit:
        diamond_mge.out.DIAMOND

} 


workflow flow3 {
	 take:
	 data
	 main:
	 mmseqs_prots(data)
	 emit:
	 mmseqs_prots.out.tsv
}


workflow flow4 {
	 take:
	 data1
	 data2
	 data3
	 main:
	 support_derep(data1,data2,data3)	 
	 emit:
	 support_derep.out.dd
	 support_derep.out.rd
}


workflow flow5 {
	take:
	data
	data1
	data2
	data3
	data4
	main:
	detect(data,data1,data2,data3,data4)
}


workflow {
	flow1(input_contigs)
    contigs_split_ch = splitInput(input_contigs, chunk)
    flow2_outputs = flow2(contigs_split_ch.flatten())
    prodigal_outputs = flow2_outputs.collect()
    prodigal = ConcatenateOutputs(prodigal_outputs)
	flow3(prodigal)
	derep_detect = Channel.fromPath('./bin/kairos_dd-v2.py')
	annotate_targets(prodigal) 
	annotate_MGEs(prodigal)
	flow4(derep_detect,flow3.out,outprefix)
	detect = Channel.fromPath('./bin/kairos_detect.py')
	flow5(detect,annotate_targets.out,annotate_MGEs.out,flow4.out)
}
