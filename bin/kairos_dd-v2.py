##### hgt-support | a lightweight tool for analyzing putative horizontal gene transfer events in metagenomic data 
##### author: connor brown 

import argparse

parser=argparse.ArgumentParser(description='| HGT-support derep-detect | dereplicate contigs based on open reading frames and generate dereplicated overlaps')
parser.add_argument("--max_overlap",type=float,default=1,required=False,help="maximum proportion of shared orfs to consider two contigs as duplicates")
parser.add_argument("--minimum_orfs",type=int,default=2,required=False,help="minimum number of orfs to submit contig to context analysis")
parser.add_argument("--input_clust_file",type=str,required=True,help="Input cluster tsv file of form: cluster_rep cluster_member")
parser.add_argument("--out_prefix", type=str,default="DerepDetect", required=False,help="output file prefix")

args=parser.parse_args()
import pandas as pd
from itertools import combinations
import numpy as np
import os
import re

PCs=pd.read_csv(args.input_clust_file,sep="\t",header=None)
def extractDeduplicatedOverlaps(protein_clusters,minORFs,maxPercentShared):
    protein_clusters.columns=["cluster_rep","cluster_member"]
    protein_clusters["memberContig"]=protein_clusters['cluster_member'].apply(lambda r: '_'.join(r.split('_')[:-1]))
    protein_clusters["repContig"]=protein_clusters['cluster_rep'].apply(lambda r: '_'.join(r.split('_')[:-1]))
    protein_clusters["orfN"]=protein_clusters['cluster_member'].apply(lambda r: '_'.join(r.split('_')[-1:]))
    protein_clusters["orfN"]=protein_clusters["orfN"].astype(int)
    annotated_protein_clusters=protein_clusters # Keep the protein_clusters data frame for printing. 

    N_StartingContigs=len(protein_clusters["memberContig"].unique())
    StartingContigs=protein_clusters["memberContig"].unique()

    totalCounts=(protein_clusters.groupby("memberContig").count().reset_index())[["memberContig","cluster_member"]]
    totalCounts.columns=["contig","total_orfs"]
    totalCounts=totalCounts[totalCounts["total_orfs"]>=minORFs] # Remove contigs below a certain size. 

    N_Remaining_After_ORF_Filt=len(totalCounts["contig"].unique()) 
    Remaining_After_ORF_Filt=totalCounts["contig"].unique()
    N_Filtered_Contigs=N_StartingContigs-N_Remaining_After_ORF_Filt

    forAllvAll=annotated_protein_clusters[annotated_protein_clusters["memberContig"].isin(Remaining_After_ORF_Filt)]
    allvall=pd.merge(forAllvAll,forAllvAll,left_on="cluster_rep",right_on="cluster_rep")

    co_occur_cts=(allvall[["memberContig_x","memberContig_y","cluster_rep"]].groupby(["memberContig_x","memberContig_y"]).count()).reset_index()
    co_occur_cts=co_occur_cts[co_occur_cts["memberContig_x"]!=co_occur_cts["memberContig_y"]]
    co_occur_cts.columns=["memberContig_x","memberContig_y","co_occur_cts"]
    Singlets=pd.Series(Remaining_After_ORF_Filt)[~pd.Series(Remaining_After_ORF_Filt).isin(co_occur_cts["memberContig_x"])]
    N_Singlets=len(Singlets.unique())
    N_Contigs_After_Merge=N_Remaining_After_ORF_Filt-N_Singlets
    
    overlaps=(pd.merge(co_occur_cts,totalCounts,left_on="memberContig_x",right_on="contig"))[["memberContig_x","memberContig_y","co_occur_cts","total_orfs"]]
    overlaps=(pd.merge(overlaps,totalCounts,left_on="memberContig_y",right_on="contig"))[["memberContig_x","memberContig_y","co_occur_cts","total_orfs_x","total_orfs_y"]]
    overlaps.columns=["contig1","contig2","co_occur_cts","total_orfs_ctg1","total_orfs_ctg2"]
    overlaps["smallest_contig_orfCts"]=overlaps[['total_orfs_ctg1','total_orfs_ctg2']].min(axis=1)
    
    ORFs=allvall[["memberContig_x","memberContig_y","orfN_x","orfN_y"]]
    ORFs.columns=["contig1","contig2","identical_orf_position_contig1","identical_orf_position_contig2"]
    ORFs=ORFs[ORFs["contig1"]!=ORFs["contig2"]]
    ORFs["contig_pair"]=ORFs["contig1"]+"_AND_"+ORFs["contig2"]
    overlaps=pd.merge(overlaps,ORFs[["contig1","contig2","identical_orf_position_contig1","identical_orf_position_contig2"]],how="left",left_on=["contig1","contig2"],right_on=["contig1","contig2"])
    # produce overlap data frame for gene sharing analysis:
    deduplicated_overlaps=overlaps[overlaps["co_occur_cts"]<maxPercentShared*overlaps["smallest_contig_orfCts"]]#Dataframe containing instances where non-duplicate level overlaps are occurring between contigs. The contigs1/2 may be redundant with respect to the entire set of input; that is sorted out through representative selection below.
    
    # deduplicate duplicate-level tigs. 
    redundant_tigs=overlaps[overlaps["co_occur_cts"]>=maxPercentShared*overlaps["smallest_contig_orfCts"]]
    
    # accounting
    ContigsWithOverlaps=pd.concat([overlaps["contig1"],overlaps["contig2"]]).unique() # Contigs with orfs shared by other contigs. 
    N_ContigsWithOverlaps=len(pd.concat([overlaps["contig1"],overlaps["contig2"]]).unique())
    RedundantTigs=pd.concat([redundant_tigs["contig2"],redundant_tigs["contig1"]]).unique() # Contigs with duplicate-level overlap (defined by maxOverlap)
    N_RedundantTigs=len(pd.concat([redundant_tigs["contig2"],redundant_tigs["contig1"]]).unique())
    NonRedundant_Overlap=(pd.concat([deduplicated_overlaps["contig1"],deduplicated_overlaps["contig2"]]).unique()) # These are ALL contigs with non-duplicate level overlap, includes redundant tigs per above. 
    N_NonRedundant_Overlap=len(pd.concat([deduplicated_overlaps["contig1"],deduplicated_overlaps["contig2"]]).unique())
    NonRedundantTigs=pd.concat([deduplicated_overlaps["contig1"],deduplicated_overlaps["contig2"]])# These are ALL contigs with non-duplicate level overlaps that DO NOT have some other duplicate-level match. 
    NonRedundantTigs=NonRedundantTigs[~NonRedundantTigs.isin(RedundantTigs)]
    N_NonRedundantTigs=len(NonRedundantTigs[~NonRedundantTigs.isin(RedundantTigs)].unique())
    
    dd_summary=(" ... deduplicated overlaps predicted successfully." + "\n" + "input contigs: " + str(N_StartingContigs) + "\n" + "contigs passing size filtering: "+ str(N_Remaining_After_ORF_Filt) + "\n" + "contigs filtered: "+ str(N_Filtered_Contigs) + "\n" + "singlet contigs: " + str(N_Singlets) + "\n" + "contigs submitted to overlap analysis: " + str(N_Contigs_After_Merge) + "\n" + "non-redundant contigs: " + str(N_NonRedundantTigs) + "\n" + "redundant contigs: " + str(N_RedundantTigs)+ "\n" +  "contigs with overlaps: " + str(N_ContigsWithOverlaps) + "\n"+ "contigs deduplicated overlaps (pre-clustering): " + str(N_NonRedundantTigs) + "\n")
    
    return(deduplicated_overlaps,redundant_tigs,dd_summary)

def clusterTigs(redundant_tigs):
    # Identify representative contigs based on n orfs and then random indexing. 
    biggerContigs=(redundant_tigs[redundant_tigs["total_orfs_ctg1"]>=redundant_tigs["total_orfs_ctg2"]])["contig1"]
    smallerContigs=(redundant_tigs[redundant_tigs["total_orfs_ctg1"]<redundant_tigs["total_orfs_ctg2"]])["contig1"]
    equalContigs=(redundant_tigs[redundant_tigs["total_orfs_ctg1"]==redundant_tigs["total_orfs_ctg2"]])["contig1"]

    #Size selected representatives are those orfs in the biggerContigs df and not the smallerContigs df.  
    ss_representatives=biggerContigs[~biggerContigs.isin(smallerContigs)]
    N_ss_representatives=len(ss_representatives.unique())
    representatives_no_ties=ss_representatives[~ss_representatives.isin(equalContigs)]

    finished_reps=representatives_no_ties.drop_duplicates()
    finished_reps=redundant_tigs[redundant_tigs["contig1"].isin(finished_reps)][["contig1","contig2"]].drop_duplicates()
    finished_reps.columns=["cluster_rep","cluster_member"]

    done=pd.concat([finished_reps["cluster_rep"],finished_reps["cluster_member"]])
    done.drop_duplicates()

    redundant_tigs_STORE=redundant_tigs # DO NOT RERUN!
    
    #At this stage, we've removed those sequences that can be dereplicated by size. 

    redundant_tigs_1=redundant_tigs[~redundant_tigs["contig1"].isin(done)]
    redundant_tigs_1=redundant_tigs_1[~redundant_tigs_1["contig2"].isin(done)]

    equaltigs=redundant_tigs_1[redundant_tigs_1["total_orfs_ctg1"]==redundant_tigs_1["total_orfs_ctg2"]]

    to_pick_at_random=pd.concat([equaltigs["contig1"],equaltigs["contig2"]],axis=0)

    idx=pd.DataFrame(to_pick_at_random).drop_duplicates().reset_index()[[0]].reset_index()
    idx.columns=["index","contig"]
    indexed=pd.merge(redundant_tigs_1,idx,left_on="contig1",right_on="contig").drop(columns="contig")
    indexed=pd.merge(indexed,idx,left_on="contig2",right_on="contig",suffixes=["_1","_2"])#.drop(columns="contig")

    d1=indexed[indexed["index_1"]>=indexed["index_2"]]
    d2=indexed[indexed["index_1"]<indexed["index_2"]]

    reps=d1[~d1["contig1"].isin(d2["contig1"])][["contig1","contig2"]]
    reps.columns=["cluster_rep","cluster_member"]

    final_reps_o=pd.concat([reps,finished_reps])
    final_reps_o=redundant_tigs_STORE[redundant_tigs_STORE["contig1"].isin(final_reps_o["cluster_rep"])]

    final_reps_o=final_reps_o[["contig1","contig2"]].drop_duplicates()

    represented=pd.concat([final_reps_o["contig1"],final_reps_o["contig2"]]).unique()
    redundant_tigs_1=redundant_tigs_1[~redundant_tigs_1["contig2"].isin(represented)]

    final_reps_o.columns=["cluster_rep","cluster_member"]

    d1_1=redundant_tigs_1[redundant_tigs_1["total_orfs_ctg1"]>redundant_tigs_1["total_orfs_ctg2"]]
    d1_2=redundant_tigs_1[redundant_tigs_1["total_orfs_ctg1"]<redundant_tigs_1["total_orfs_ctg2"]]

    do=d1_1[~d1_1["contig1"].isin(d1_2["contig1"])]
    do=do[["contig1","contig2"]]
    do.columns=["cluster_rep","cluster_member"]

    output=pd.concat([do,final_reps_o])
    
    tmp=output[["cluster_rep"]].drop_duplicates()
    tmp["cluster_member"]=tmp["cluster_rep"]
    output=pd.concat([tmp,output])
    N_Cluster_Reps=len(output["cluster_rep"].unique())
    N_Cluster_Members=len(output["cluster_member"].unique())
    N_Final_Cluster_Assignments=len(pd.concat([output["cluster_rep"],output["cluster_member"]]).unique())
    
    summary=("...contigs clustered successfully"+"\n"
             +"size-selected representatives: "+ str(N_ss_representatives)+ "\n"
             +"final cluster representatives: "+ str(N_Cluster_Reps) + "\n" 
             +"final cluster members: "+ str(N_Cluster_Members) + "\n"
             +"n contigs represented: "+str(N_Final_Cluster_Assignments))

    return(output,summary)

PCs=pd.read_csv(args.input_clust_file,sep="\t",header=None)

deduplicated_overlaps_OUT,redundant_tigs_OUT,overlap_summary=extractDeduplicatedOverlaps(PCs,args.minimum_orfs,args.max_overlap)

output_clusters,clust_summary=clusterTigs(redundant_tigs_OUT)

ovs=open("{}_overlap_log.txt".format(args.out_prefix),"w")
ovs.writelines(overlap_summary)
ovs.close()

cs=open("{}_clustering_log.txt".format(args.out_prefix),"w")
cs.writelines(clust_summary)
cs.close()

deduplicated_overlaps_OUT.to_csv("{}_deduplicated_overlaps.tsv".format(args.out_prefix),index=False,sep="\t")
redundant_tigs_OUT.to_csv("{}_redundant_overlaps.tsv".format(args.out_prefix),index=False,sep="\t")
redundant_tigs_OUT["status"]="redundant"
deduplicated_overlaps_OUT["status"]="non-redundant"

overlap_o=pd.concat([redundant_tigs_OUT,deduplicated_overlaps_OUT]) 
overlap_o.to_csv("{}_overlap_out.tsv".format(args.out_prefix),index=False,sep="\t")

output_clusters.to_csv("{}_contig_clusters.tsv".format(args.out_prefix),index=False,sep="\t",header=None)
