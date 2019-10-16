__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script maps Uniprot to GO 
# Requires:  goa_human_isoform_valid.gaf
# source: http://current.geneontology.org/annotations/goa_human_isoform.gaf.gz

import os
import wget
import gzip
import metadata

# Define helper functions 

def inherit(node1, node2):
    return ""+'\n(MemberLink \n'+ node1 +'\n'+ node2 +')\n'
dataset_url = "http://current.geneontology.org/annotations/goa_human_isoform.gaf.gz"
lines = []
prot = []
go = []
if not os.path.isfile('raw_data/goa_human_isoform_valid.gaf'):
    print("Downloading dataset")
    lines = gzip.open(wget.download(dataset_url, "raw_data/")).readlines()
    lines = [l.decode("utf-8") for l in lines]
else:
    lines = open('raw_data/goa_human_isoform_valid.gaf').readlines()

with open("dataset/uniprot2GO.scm", 'w') as f:
    print("\nStarted importing")
    for i in lines:
        if 'UniProtKB' in i:
            f.write(inherit('(MoleculeNode "'+ 'Uniprot:'+i.split('\t')[1] + '")', '(ConceptNode "' + i.split('\t')[4] + '")'))
            prot.append(i.split('\t')[1])
            go.append(i.split('\t')[4])
script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/uniprot2GO.py"
metadata.update_meta("GO_Annotation:latest", dataset_url,script,prot=len(set(prot)), goterms={"go-terms":len(set(go))})
print("Done, check dataset/uniprot2GO.scm")