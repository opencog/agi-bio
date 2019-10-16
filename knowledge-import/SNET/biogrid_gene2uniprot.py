__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script imports the biogrid_genes mapped to their coding uniprots though biogrid_id  

# Requires: uniprot to biogrid_id mapping file uniprot2biogrid.csv and
# Biogrid gene symbold to biogrid_id mapping file gene2biogrid.csv (run biogrid_genes.py to get this file)

import pandas as pd
import sys
import math
from collections import defaultdict
import metadata
import os

script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/biogrid_gene2uniprot.py"

def to_atomese(data):
    print("importing the data")
    df = data.dropna()
    genes = []
    proteins = []
    if not os.path.exists(os.path.join(os.getcwd(), 'dataset')):
        os.makedirs('dataset')
    with open("dataset/biogridgene2uniprot.scm", 'w') as f:
        for i in range(df.shape[0]):
            gene = df.iloc[i]['gene_symbol'].upper()
            biogrid_id = str(df.iloc[i]['biogrid_id'])
            prot = df.iloc[i]['uniprot']
            if gene and biogrid_id and prot:
                if gene not in genes:
                    genes.append(gene)
                if prot not in proteins:
                    proteins.append(prot)
                print("Prot: {0} Biogrid_id: {1} and gene: {2}".format(prot, biogrid_id, gene))
                f.write(
                '(EvaluationLink \n'+
                '(PredicateNode "expresses")\n'+
                    '(ListLink \n' +
                    '(GeneNode "'+ gene +'")\n' +
                    '(MoleculeNode "Uniprot:'+ prot +'")))\n\n' +
                '(EvaluationLink \n' +
                '(PredicateNode "has_biogridID")\n'+
                    '(ListLink \n' +
                    '(MoleculeNode "Uniprot:'+ prot +'")\n'+
                    '(ConceptNode "Bio:'+biogrid_id+'")))\n\n'+
                '(EvaluationLink \n' +
                '(PredicateNode "has_biogridID")\n'+
                    '(ListLink \n' +
                    '(GeneNode "'+ gene +'")\n'+
                    '(ConceptNode "Bio:'+biogrid_id+'")))\n\n')
    metadata.update_meta("Biogrid-Gene2uniprot:latest", 
        "uniprot2biogrid.csv, gene2biogrid.csv",script,genes=str(len(genes)),prot=len(proteins))
 
if __name__ == "__main__":
    print("imports the biogrid_genes mapped to their coding uniprots though biogrid_id\n")
    try:
        bio = pd.read_csv("raw_data/gene2biogrid.csv", sep="\t")
        uniprot = pd.read_csv("raw_data/uniprot2biogrid.csv", sep=",")
    except:
        print('''
        Requires: uniprot to biogrid_id mapping file uniprot2biogrid.csv and
        Biogrid gene symbold to biogrid_id mapping file gene2biogrid.csv 
        (run biogrid_genes.py to get gene2biogrid.csv)''')
    for i in range(uniprot.shape[0]):
        biogrid_id = uniprot.iloc[i]['biogrid']
        prot = uniprot.iloc[i]['uniprot']
        # some uniprots has morethan one biogrid ID separated by comma
        for b in biogrid_id.split(","):
                bio.loc[bio['biogrid_id']==int(b), 'uniprot'] = prot
    to_atomese(bio)
    print("Done, check dataset/biogridgene2uniprot.scm")
