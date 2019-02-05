__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script imports the id table gene2preteinIDs.csv.xz  
# this file is extracted using gene2proteinIDs.R  

# Run gene2proteinIDs.R to get gene2proteinIDs.csv.xz

# Requires: gene2proteinIDs.csv.xz


# from https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.167/BIOGRID-IDENTIFIERS-3.5.167.tab.zip

import pandas as pd
import os

# Define helper functions 

def expres(gene, prot):
    return ""+'(EvaluationLink\n'+'(PredicateNode "expresses")\n'+'(ListLink \n'+'(GeneNode '+ '"' + gene +'")\n' +'(MoleculeNode "'+'Uniprot:'+ prot +'")))\n'


if not "gene2proteinIDs.csv" in os.listdir(os.getcwd()):
	print("Generate the Gene to protein ID mapping table first \n"
	      "Run: gene2proteinIDs.R " )

else: 
	data = pd.read_csv("gene2proteinIDs.csv")
	print("Started importing")
	with open("gene_to_protein.scm", 'a') as f:
    		for i in range(len(data)):
        		f.write(expres(data.iloc[i]['OFFICIAL SYMBOL'], str(data.iloc[i]['UNIPROT_ID'])))

	print("Done")

