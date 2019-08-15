__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script maps Uniprot to GO 
# Requires:  goa_human_isoform_valid.gaf
# source: http://current.geneontology.org/annotations/goa_human_isoform.gaf.gz

import os
import wget
import gzip

# Define helper functions 

def inherit(node1, node2):
    return ""+'\n(MemberLink \n'+ node1 +'\n'+ node2 +')\n'

lines = []
if not os.path.isfile('goa_human_isoform_valid.gaf'):
    print("Downloading dataset.txt")
    dataset_url = "http://current.geneontology.org/annotations/goa_human_isoform.gaf.gz"
    lines = gzip.open(wget.download(dataset_url)).readlines()
    print("Done")
else:
    lines = open('goa_human_isoform_valid.gaf').readlines()

with open("uniprot2GO.scm", 'w') as f:
    for i in lines:
        if 'UniProtKB' in i:
            f.write(inherit('(MoleculeNode "'+ 'Uniprot:'+i.split('\t')[1] + '")', '(ConceptNode "' + i.split('\t')[4] + '")'))
