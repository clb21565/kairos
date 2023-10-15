process diamond_target {

        publishDir "${params.outdir}/intermediate_files"

        input:

        file faa

        output:

        path '*.tsv',                 emit:DIAMOND

        """

        source activate hgt_support



diamond blastp --query-cover ${params.target_query_cover} -e ${params.target_e} --id ${params.target_id} -q ${faa} -d ${params.target_database} -k 1 --outfmt 6 qtitle stitle pident bitscore evalue -o ${params.outprefix}.targetDB.diamond.tsv



        """

}
