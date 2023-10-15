nextflow.enable.dsl=2

input_contigs = file(params.input_contigs)
taxadf = file(params.taxa_df)
outprefix = params.outprefix 
workdir = file(params.outdir)
bin = file('.')

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

workflow flow2 {
	 take:
	 data1
	 data2
	 main:
	 pprodigal(data1,data2)
	 emit:
	 pprodigal.out.orf
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
	flow2(orf,flow1.out)
	flow3(flow2.out)
	derep_detect = Channel.fromPath('./bin/kairos_dd-v2.py')
	annotate_targets(flow2.out) 
	annotate_MGEs(flow2.out) 
	flow4(derep_detect,flow3.out,outprefix)
	detect = Channel.fromPath('./bin/kairos_detect.py')
	flow5(detect,annotate_targets.out,annotate_MGEs.out,flow4.out)

}






