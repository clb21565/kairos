params.input_contigs = file(params.input_contigs)
params.input_reads = file(params.input_reads)
params.outdir = file(params.outdir)
params.outprefix = params.outprefix
//params.edge_length = val(params.edge_length)
bin = file('./bin')

nextflow.enable.dsl=2

include { minimap2 } from './modules/minimap'
include { cut } from './modules/cut'
include { extract_edges } from './modules/extract_edges_py'
include { bedget } from './modules/bedgetfasta'
include { mmseqs_edges } from './modules/mmseqs_edges'
include { index } from './modules/salmon_index'
include { edge_detect } from './modules/edge_detect-v2'
include { calc_window_props } from './modules/calculate_window_props.nf'

// all v. all mapping with minimap2
workflow flow1 {
         take:
         data
         main:
         minimap2(data)
         emit:
         minimap2.out.tmp

}

// reformat output 
workflow flow2 {
         take:
         data1
         data2
         main:
         cut(data1,data2)
         emit:
         cut.out.paf

}

// extract edges 
workflow flow3 {
         take:
         data1
         data2
         data3
         main:
         extract_edges(data1,data2,data3)
         emit:
         extract_edges.out.bed

}

// get windows from fasta
workflow flow4 {
         take:
         data1
         data2
         main:
         bedget(data1,data2)
         emit:
         bedget.out.cbed

}

// cluster windows
workflow flow5 {
         take:
         data
         main:
         mmseqs_edges(data)
         emit:
         mmseqs_edges.out.edge_reps
	 mmseqs_edges.out.edge_clusts
}

// salmon index clustered windows
workflow flow6 {
        take:
        data
        main:
        index(data)
        emit:
        index.out.x
}

workflow count_windows {
	take:
	pyscript
	edge_clusters
	sample
	sample_name
	main:
	calc_window_props(pyscript,edge_clusters,sample,sample_name)	
	emit:
	calc_window_props.out.result
}


workflow {    

//Take the contigs, identify window regions, then create salmon index of the windows.
	input_contigs=Channel.fromPath(params.input_contigs)
	flow1(input_contigs)
	flow2(flow1.out,input_contigs)
	py = Channel.fromPath(bin/'extract_window_regions_2.1.py')
	flow3(py,flow2.out,params.outprefix)
	flow4(flow3.out,input_contigs)
        flow5(flow4.out)
	
	index_ch=flow6(flow5.out[0])
	//clusters=flow5(flow5.out.edge_clusts)
	text_file=params.input_reads  
    	index_ch.view { "$it" }
//Read the input file and create a channel for sample labels and path
	sample_info_ch = Channel.fromPath(text_file)
    	.splitCsv(header: false, sep: '\t')
      	.map { row -> tuple(row[0], file(row[1])) }
    
//Split the channel into two separate channels for sample_label and sample_path	
	sample_label_ch = sample_info_ch.map { it[0] }
	sample_path_ch = sample_info_ch.map { it[1] }
	index_str=index_ch.combine(sample_label_ch)
	index=index_str.map { it[0] }
	edge_detect(sample_label_ch, sample_path_ch,index)
//Integrate coverage dataframes with edge clusters and write out files. 
	py2 = Channel.fromPath(bin/'get_props.py')
	pystr=py2.combine(sample_label_ch)
	py2f=pystr.map { it[0] }
	py2f.view { "$it" }		
	count_windows(py2f,flow5.out[1].combine(sample_label_ch).map{ it[0] },edge_detect.out[0].combine(sample_label_ch).map{ it[0] },sample_label_ch)
	
}
