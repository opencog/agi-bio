__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script imports the id table gene2preteinIDs.csv  
# this file is extracted using uniprotIDmap.R  

# Run uniprotIDmap.R to get entrez2uniprot.csv

# Requires: entrez2uniprot.csv


# from https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.167/BIOGRID-IDENTIFIERS-3.5.167.tab.zip

import pandas as pd
import os
import math

# Define helper functions 

def expres(predicate, node1, node2):
    return ""+'\n(EvaluationLink (stv 1 1)\n'+'(PredicateNode "'+ predicate +'")\n'+'(ListLink \n'+ node1 + node2 +'))\n'


if not "entrez2uniprot.csv" in os.listdir(os.getcwd()):
	print("Generate the entres to protein ID mapping table first \n" )

else:
    data = pd.read_csv("entrez2uniprot.csv", dtype={'uniprot': str, 'entrez': float, 'symbol': str})
    print("Started importing")
    with open("entrez_to_protein.scm", 'w') as f:
        for i in range(len(data)):
            try:
                f.write(expres("expresses", '(GeneNode '+ '"' + data.iloc[i]['symbol'] +'")\n', '(MoleculeNode "'+'Uniprot:'+ data.iloc[i]['uniprot']+'")\n'))
            except TypeError:
                continue
            if not math.isnan(data.iloc[i]['entrez']):
                f.write(expres("has_entrez_id", '(GeneNode '+ '"' + data.iloc[i]['symbol'] +'")\n', '(ConceptNode "'+'entrez:'+ str(int(data.iloc[i]['entrez']))+'")\n'))
        print("Done")
        print(math.isnan(data.iloc[0]['entrez']))

