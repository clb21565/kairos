input = file(params.input)
outprefix = 'smalltest'
workdir = file(params.outdir)
bin = file('.')

log.info """\
         h g t s u p p o r t - an N F   P I P E L I N E
==================================================================================================
 Input: ${input}	
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
include { mmseqs_prots } from './modules/mmseqs_prots'
include { support_derep } from './modules/pyscript'

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
}

workflow {
	 flow1(input)
	 flow2(orf,flow1.out)
	 flow3(flow2.out)
	 py = Channel.fromPath('./bin/hgt_support_derep.py')
	 flow4(py,flow3.out,outprefix)
}
