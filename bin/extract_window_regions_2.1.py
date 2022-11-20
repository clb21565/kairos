import re
import argparse
#import pandas as pd
parser=argparse.ArgumentParser(description='extract windows around the boundaries of contig alignments')
parser.add_argument("--inpaf", type=str, required=True,help="paf file from aligner")
parser.add_argument("--extension_length", type=int, required=True,help="number of bp forward and back to extract from alignment boundaries")
parser.add_argument("--out_prefix",type=str,required=True,help="outprefix for comparison files")
args=parser.parse_args()


import pandas as pd
def getExtensionRegions(pafdf,EDGELEN,outprefix):
	pafdf=pd.read_csv(pafdf,sep="\t",header=None)
	pafdf.columns=["contiga","a_len","a_start","a_end","strand","contigb","b_len","b_start","b_end","nmatch","alen","mapq"]
	pafdf=pafdf[pafdf["alen"]>1000]
	pafdf=pafdf[pafdf["nmatch"]>=0.50*pafdf["alen"]]

	pafdf["a_END_END"]=pafdf["a_end"]-EDGELEN
	pafdf["a_END_START"]=pafdf["a_end"]+EDGELEN

	pafdf["a_START_START"]=pafdf["a_start"]-EDGELEN
	pafdf["a_START_END"]=pafdf["a_start"]+EDGELEN

	pafdf=pafdf[pafdf["a_len"]>=pafdf["a_END_START"]]
	pafdf=pafdf[pafdf["a_START_START"]>=1]

	pafdf["b_END_START"]=pafdf["b_end"]-EDGELEN
	pafdf["b_END_END"]=pafdf["b_end"]+EDGELEN

	pafdf["b_START_START"]=pafdf["b_start"]-EDGELEN
	pafdf["b_START_END"]=pafdf["b_start"]+EDGELEN

	pafdf=pafdf[pafdf["b_len"]>=pafdf["b_END_END"]]
	pafdf=pafdf[pafdf["b_START_START"]>=1]

	a1_out=pafdf[["contiga","a_START_START","a_START_END"]].reset_index()
	b1_out=pafdf[["contigb","b_START_START","b_START_END"]].reset_index()

	a2_out=pafdf[["contiga","a_END_END","a_END_START"]].reset_index()
	b2_out=pafdf[["contigb","b_END_START","b_END_END"]].reset_index()

	a1_out.columns=["rownum","contig","start","end"]
	b1_out.columns=["rownum","contig","start","end"]
	a2_out.columns=["rownum","contig","start","end"]
	b2_out.columns=["rownum","contig","start","end"]

	dds=tp[["contig","start","end"]].drop_duplicates()
	dds.to_csv("{}.comparisons.bed".format(outprefix),sep="\t",index=False,header=None)
	
getExtensionRegions(args.inpaf,args.window_length,args.out_prefix)
