process diamond_mge {

        publishDir "${params.outdir}/intermediate_files"

        input:

        file faa

        output:

        path '*.tsv',                 emit:DIAMOND

        """

        source activate hgt_support



diamond blastp -e ${params.MGE_e} --id ${params.MGE_id} -q ${faa} -d ${params.MGE_database} -k 1 --outfmt 6 qtitle stitle pident bitscore evalue -o ${params.outprefix}.MGE.diamond.tsv



        """

}
