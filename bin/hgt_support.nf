#!/usr/bin/env nextflow

/* 
 * hgt-support pipeline input parameters 
 */
params.reads = "$projectDir/reads/*_{1,2}.fq"
params.contigs = "$projectDir/contigs/HGTcontigs.fasta"
params.out_prefix = "$projectDir/hgt_support_"
params.p_clust_id_value="0.99"
params.p_clust_coverage_value="0.3"

log.info """\
         h g t s u p p o r t - an N F   P I P E L I N E
         ===================================
 reads: ${params.reads}
 contigs: ${params.contigs}
 protein identity cut-off for clustering: ${params.p_clust_id_value}
 protein coverage cut-off for clustering: ${params.p_clust_coverage_value}         
 out_prefix: ${params.out_prefix}
         """
         .stripIndent()

 /*
 * define the `pProdigal` process that creates a set of open reading frames
 * from a set of contigs
 */
        process generateORFs {

                input:
                path contigs from params.contigs
                output:
                stdout
                script:
                """
                grep -c ">" $contigs  
                """}
input_ch = Channel.fromPath(params.contigs)

workflow runBois {generateORFs(input_ch)}
(base) [clb21565@calogin1 hgt_support]$ more hgt_support.nf 
#!/usr/bin/env nextflow

/* 
 * hgt-support pipeline input parameters 
 */
params.reads = "$projectDir/reads/*_{1,2}.fq"
params.contigs = "$projectDir/contigs/HGTcontigs.fasta"
params.out_prefix = "$projectDir/hgt_support_"
params.p_clust_id_value="0.99"
params.p_clust_coverage_value="0.3"

log.info """\
         h g t s u p p o r t - an N F   P I P E L I N E
         ===================================
 reads: ${params.reads}
 contigs: ${params.contigs}
 protein identity cut-off for clustering: ${params.p_clust_id_value}
 protein coverage cut-off for clustering: ${params.p_clust_coverage_value}         
 out_prefix: ${params.out_prefix}
         """
         .stripIndent()

 /*
 * define the `pProdigal` process that creates a set of open reading frames
 * from a set of contigs
 */
        process generateORFs {

                input:
                path contigs from params.contigs
                output:
                stdout
                script:
                """
                grep -c ">" $contigs  
                """}
input_ch = Channel.fromPath(params.contigs)

workflow runBois {generateORFs(input_ch)}
workflow{runBois()}
workflow.onComplete { log.info ( workflow.success ? "it did the thing\n":"it did not do the thing\n" )}
