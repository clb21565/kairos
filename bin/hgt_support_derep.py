##### hgt-support | a lightweight tool for analyzing putative horizontal gene transfer events in metagenomic data 
##### author: connor brown 
import re
import argparse
#import pandas as pd
#from itertools import combinations
#import numpy as np
#import os

parser=argparse.ArgumentParser(description='| hgt_support_derep | dereplicate contigs based on open reading frames and generate dereplicated overlaps')
parser.add_argument("--max_overlap",type=float,required=True,help="maximum proportion of shared orfs to consider two contigs as duplicates")
parser.add_argument("--input_clust_file",type=str,required=True,help="Input cluster tsv file of form: cluster_rep cluster_member")
parser.add_argument("--out_prefix", type=str, required=True,help="output file prefix")

args=parser.parse_args()
import pandas as pd
from itertools import combinations
import numpy as np
import os


PCs=pd.read_csv(args.input_clust_file,sep="\t",header=None)

#from a clustered set of proteins, find minimum and maximum orf positions for a set of contigs representing first/last orf edges. 
#def annotateClusterDf(protein_clusters):
#    protein_clusters.columns=["cluster_rep","cluster_member"]
#    protein_clusters["memberContig"]=protein_clusters['cluster_member'].apply(lambda r: '_'.join(r.split('_')[:-1]))
#    protein_clusters["repContig"]=protein_clusters['cluster_rep'].apply(lambda r: '_'.join(r.split('_')[:-1]))
#    protein_clusters["orfN"]=protein_clusters["cluster_member"].str.extract("_seq_(.*?)$")
#    protein_clusters["orfN"]=protein_clusters["orfN"].astype(int)    
#    annotated_df=protein_clusters    
#    return(annotated_df)

#def findORFedges(annotated_df):
#    annotated_df=(annotated_df[["memberContig","orfN"]].drop_duplicates().reset_index())[["memberContig","orfN"]]
#    df_1=(annotated_df.groupby('memberContig').max().reset_index())[["memberContig","orfN"]]
#    df_2=(annotated_df.groupby('memberContig').min().reset_index())[["memberContig","orfN"]]
#    df_1.columns=["memberContig","end_edge"]
#    df_2.columns=["memberContig","start_edge"]
#    edges_out=pd.merge(df_1,df_2,left_on="memberContig",right_on="memberContig")
#    return(edges_out)

# filter out those with more than maxPercentShared% shared ORFs. 
def orf_based_contig_deduplication(protein_clusters,maxPercentShared,outPrefix):
    protein_clusters.columns=["cluster_rep","cluster_member"]
    protein_clusters["memberContig"]=protein_clusters['cluster_member'].apply(lambda r: '_'.join(r.split('_')[:-1]))
    protein_clusters["repContig"]=protein_clusters['cluster_rep'].apply(lambda r: '_'.join(r.split('_')[:-1]))
    #protein_clusters["orfN"]=protein_clusters["cluster_member"].str.extract("_seq_(.*?)$")
   # protein_clusters["orfN"]=protein_clusters["cluster_member"].str.split("_")[:1]
    protein_clusters["orfN"]=protein_clusters['cluster_member'].apply(lambda r: '_'.join(r.split('_')[-1:]))
    protein_clusters["orfN"]=protein_clusters["orfN"].astype(int)
    annotated_df=protein_clusters

    totalCounts=(protein_clusters.groupby("memberContig").count().reset_index())[["memberContig","cluster_member"]]
    totalCounts.columns=["contig","total_orfs"]

    allvall=pd.merge(annotated_df,annotated_df,left_on="cluster_rep",right_on="cluster_rep").drop_duplicates()
    co_occur_cts=allvall[["memberContig_x","memberContig_y","cluster_rep"]].groupby(["memberContig_x","memberContig_y"]).count()
    co_occur_cts=co_occur_cts.reset_index()
    co_occur_cts.columns=["memberContig_x","memberContig_y","co_occur_cts"]
    co_occur_cts=co_occur_cts[co_occur_cts["memberContig_x"]!=co_occur_cts["memberContig_y"]]

    overlaps=(pd.merge(co_occur_cts,totalCounts,left_on="memberContig_x",right_on="contig"))[["memberContig_x","memberContig_y","co_occur_cts","total_orfs"]]
    overlaps=(pd.merge(overlaps,totalCounts,left_on="memberContig_y",right_on="contig"))[["memberContig_x","memberContig_y","co_occur_cts","total_orfs_x","total_orfs_y"]]
    overlaps.columns=["contig1","contig2","co_occur_cts","total_orfs_ctg1","total_orfs_ctg2"]
    overlaps["smallest_contig_orfCts"]=overlaps[['total_orfs_ctg1','total_orfs_ctg2']].min(axis=1)

    ORFs=allvall[["memberContig_x","memberContig_y","orfN_x","orfN_y"]].drop_duplicates()
    ORFs.columns=["contig1","contig2","identical_orf_position_contig1","identical_orf_position_contig2"]
    ORFs=ORFs[ORFs["contig1"]!=ORFs["contig2"]]
    ORFs["contig_pair"]=ORFs["contig1"]+"_AND_"+ORFs["contig2"]


    overlaps["contig_pair"]=overlaps["contig1"]+"_AND_"+overlaps["contig2"]
    overlaps=pd.merge(overlaps,ORFs[["contig_pair","identical_orf_position_contig1","identical_orf_position_contig2"]],left_on="contig_pair",right_on="contig_pair")
    overlaps["identical_orf_position_contig1"]=overlaps["contig1"]+"_"+overlaps["identical_orf_position_contig1"].astype(str)
    overlaps["identical_orf_position_contig2"]=overlaps["contig2"]+"_"+overlaps["identical_orf_position_contig2"].astype(str)
    #maxPercentShared=0.5 # Test

    deduplicated_tigs=overlaps[overlaps["co_occur_cts"]<maxPercentShared*overlaps["smallest_contig_orfCts"]]
    redundant_tigs=overlaps[overlaps["co_occur_cts"]>=maxPercentShared*overlaps["smallest_contig_orfCts"]]

    deduplicated_tigs_FN=outPrefix+"_deduplicated_overlaps"
    annotatedClustsFN=outPrefix+"_annotated_protein_clusters"
    redundantContigsFN=outPrefix+"_redundant_contig_pairs"
    #edgesFN=outPrefix+"_contig_orf_edges"

    deduplicated_tigs.to_csv("{}.csv".format(deduplicated_tigs_FN),index=False)
    annotated_df.to_csv("{}.csv".format(annotatedClustsFN),index=False)
    redundant_tigs.to_csv("{}.csv".format(redundantContigsFN),index=False)

    #edges_out.to_csv("{}.csv".format(edgesFN),index=False)    
    return("deduplication of contigs complete")

orf_based_contig_deduplication(PCs,args.max_overlap,args.out_prefix)

