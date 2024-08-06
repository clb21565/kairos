import argparse
parser=argparse.ArgumentParser(description='calculate the proportion of windows detected to total windows to answer the question: is my contig in this sample?')


parser.add_argument("--min_prop",type=float,required=True,help="minimum loci to call a contig present")
parser.add_argument("--input_clust_file",type=str,required=True,help="Input cluster tsv file of form: cluster_rep cluster_member")
parser.add_argument("--input_cov_file", type=str, required=True,help="samtools coverage file from edge mapping")
parser.add_argument("--sample_name",type=str,required=True,help="Sample name from sample metadata file")
args=parser.parse_args()

import pandas as pd

covdf=pd.read_csv(args.input_cov_file,sep="\t")
clusters=pd.read_csv(args.input_clust_file,sep="\t",header=None)
clusters.columns=["cluster_rep","cluster_member"]
clusters["contig"]=clusters["cluster_member"].str.extract("^(.*?):")
contig_cts=clusters.groupby("contig").count()[["cluster_rep"]].reset_index()
contig_cts.columns=["contig","loci_counts"]

merged=pd.merge(covdf,clusters,left_on="#rname",right_on="cluster_rep")
obs_cts=merged[merged["numreads"]>0].groupby("contig").count()[["cluster_rep"]].reset_index()
obs_cts.columns=["contig","obs_counts"]
result=pd.merge(obs_cts,contig_cts,on="contig")
result["prop_identified"]=result["obs_counts"]/result["loci_counts"]
result["sample"]=args.sample_name
result["pass_detection"]=result["prop_identified"]>args.min_prop
result.to_csv("{}.loci_detection.tsv".format(args.sample_name),sep="\t",index=False)
