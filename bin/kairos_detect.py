import argparse

parser=argparse.ArgumentParser(description='detect, score and write potential HGTs')

parser.add_argument("--MGE_dmnd",type=str,required=False,help="mge database results for scoring")
parser.add_argument("--target_dmnd",type=str,required=True,help="target gene database results for scoring")
parser.add_argument("--overlap_results",type=str,required=True,help="results of overlap analysis (non-redundant")
parser.add_argument("--overlap_results_red",type=str,required=True,help="results of overlap analysis (redundant")
parser.add_argument("--max_dist",type=int,required=False,default=5000,help="maximum distance for calling a gene mobile") 
parser.add_argument("--min_orfs_in_contig", type=int,required=True,default=1,help="minimum number of orfs to be considered for HGT detection")
parser.add_argument("--out_prefix", type=str,default="kairos_dd", required=False,help="output file prefix")
parser.add_argument("--taxa_df",type=str,required=True,
	help="taxonomy data frame -- first two columns needs to be taxa and classification in gtdb style (domain;phylum;class;order;family;genus;species)")

args=parser.parse_args()

def extractProdigalMetadata(df):
    df.columns=["Query Title","stitle","pident","bitscore","evalue"]
    df['Contig/ORF Name'] = df["Query Title"].str.split(' ').str[0]
    df['ORF_Start_Stop_Strands'] = df['Query Title'].str.extract(r'\#.*?(.*?)# ID=')
    df['ORF_Start'] = df['ORF_Start_Stop_Strands'].str.split(' # ').str[0].astype(int)
    df['ORF_End'] = df['ORF_Start_Stop_Strands'].str.split(' # ').str[1].astype(int)
    df['Sense or Antisense Strand'] = df['ORF_Start_Stop_Strands'].str.split(' # ').str[2]
    df['Prodigal ID'] = df['Query Title'].str.extract(r'\#.*?ID=(.*?);')   
    df['Prodigal Designated Contigs'] = df['Prodigal ID'].str.split('_').str[0]
    df['Unique_ORF'] = df['Prodigal ID'].str.split('_').str[1]
    df['Partial Tag'] = df['Query Title'].str.extract(r'\;partial=(.*?);')
    df['Start Codon'] = df['Query Title'].str.extract(r'\;start_type=(.*?);')
    df['RBS Motif'] = df['Query Title'].str.extract(r'\;rbs_motif=(.*?);')
    df['RBS Spacer'] = df['Query Title'].str.extract(r'\;rbs_spacer=(.*?);')
    df['GC Content'] = df['Query Title'].str.extract(r'\;gc_cont=(.*?)$')
    df['Specific Contig'] = df['Contig/ORF Name'].apply(lambda r: '_'.join(r.split('_')[:-1]))
    return(df)
	
import pandas as pd
import re
import os
import numpy as np
mge_dmnd_out=extractProdigalMetadata(pd.read_csv(args.MGE_dmnd,sep="\t",header=None))
target_dmnd_out=extractProdigalMetadata(pd.read_csv(args.target_dmnd,sep="\t",header=None))
mge_dmnd_out["center_position"]=abs(mge_dmnd_out["ORF_Start"]-mge_dmnd_out["ORF_End"])
target_dmnd_out["center_position"]=abs(target_dmnd_out["ORF_Start"]-target_dmnd_out["ORF_End"])
co_occurences=pd.merge(target_dmnd_out,mge_dmnd_out,on="Specific Contig",suffixes=["_target","_MGE"])
co_occurences["co_occur_dist"]=co_occurences["center_position_MGE"]-co_occurences["center_position_target"]
close_enough=co_occurences[co_occurences["co_occur_dist"] < args.max_dist]

taxonomy=pd.read_csv(args.taxa_df,header=None,sep="\t")
taxonomy.columns=["contig","lineage"]
md=taxonomy["lineage"].str.split(";",expand=True)
md.columns=["domain","phylum","class","order","family","genus","species"]
taxa=pd.concat([md,taxonomy],axis=1)

redundant=pd.read_csv(args.overlap_results,sep="\t")
nonredundant=pd.read_csv(args.overlap_results_red,sep="\t")
merged=pd.concat([nonredundant,redundant])
nhgt=pd.merge(merged,taxa,left_on="contig1",right_on="contig")
nhgt=pd.merge(nhgt,taxa,left_on="contig2",right_on="contig",suffixes=["_contig1","_contig2"])


def writeHGTdf(lvl,min_orfs):
	lvltigstr1=lvl+"_contig1"
	lvltigstr2=lvl+"_contig2"

	hgt=nhgt[(nhgt[lvltigstr1]!=nhgt[lvltigstr2]) & (nhgt[lvltigstr1]!=None) & (nhgt[lvltigstr2]!=None) & (nhgt["smallest_contig_orfCts"] > min_orfs)]
	hgt=hgt[(hgt[lvltigstr1].notna())&(hgt[lvltigstr2].notna())]
	print(len(hgt))
	if len(hgt) == 0:

		summary=str("no {} level HGTs detected".format(lvl))
		ovs=open("{}_hgt_log.txt".format(lvl),"w")
		ovs.writelines(summary)
		ovs.close()

	else: 

		HGT_df=hgt[["contig1","contig2",lvltigstr1,lvltigstr2,"lineage_contig1","lineage_contig2","identical_orf_position_contig1","identical_orf_position_contig2"]].drop_duplicates()
		HGT_df['mobile_target_gene']=np.where((HGT_df['identical_orf_position_contig1'].isin(close_enough["Contig/ORF Name_target"])) | ((HGT_df['identical_orf_position_contig2'].isin(close_enough["Contig/ORF Name_target"]))), 1,0)
		HGT_df['mge_hgt']=np.where((HGT_df['identical_orf_position_contig1'].isin(mge_dmnd_out["Contig/ORF Name"])) | ((HGT_df['identical_orf_position_contig2'].isin(mge_dmnd_out["Contig/ORF Name"]))), 1,0)
		HGT_df['target_hgt']=np.where((HGT_df['identical_orf_position_contig1'].isin(target_dmnd_out["Contig/ORF Name"])) | ((HGT_df['identical_orf_position_contig2'].isin(target_dmnd_out["Contig/ORF Name"]))), 1,0)
	
		outstr=str("{}-level HGTs predicted".format(lvl))
	
		HGT_df.to_csv("{}_HGT.csv".format(lvl))

		return(outstr)	


writeHGTdf("phylum",args.min_orfs_in_contig)
writeHGTdf("class",args.min_orfs_in_contig)
writeHGTdf("order",args.min_orfs_in_contig)
writeHGTdf("family",args.min_orfs_in_contig)
writeHGTdf("genus",args.min_orfs_in_contig)	
writeHGTdf("species",args.min_orfs_in_contig)
