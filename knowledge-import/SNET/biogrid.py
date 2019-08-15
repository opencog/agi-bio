__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"

# The following script imports Biogrid interaction of Human genes from thebiogrid.com

# Requires: BIOGRID-ORGANISM-Homo_sapiens-3.5.169.tab2.txt 

# from https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.169/BIOGRID-ORGANISM-3.5.169.tab2.zip

# Or any of the latest version with the same type 

import pandas as pd
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO
import os

def checkdisc(diction, key, value):
  try:
    diction.setdefault(key,[]).append(value)
  except KeyError:
    return "key error"


if not os.path.isfile('BIOGRID-ORGANISM-Homo_sapiens-3.5.169.tab2.txt'):

	# Get the latest zip file first, and import the specific file (Homo_sapiens) 

	thefile = urlopen("https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.169/BIOGRID-ORGANISM-3.5.169.tab2.zip")
	extracted_files = ZipFile(BytesIO(thefile.read()))
	data = pd.read_csv(extracted_files.open('BIOGRID-ORGANISM-Homo_sapiens-3.5.169.tab2.txt'), low_memory=False, delimiter='\t') 
else:
	data = pd.read_csv("BIOGRID-ORGANISM-Homo_sapiens-3.5.169.tab2.txt", low_memory=False, delimiter='\t')

data = data[['Entrez Gene Interactor A',	'Entrez Gene Interactor B', 'Official Symbol Interactor A', 'Official Symbol Interactor B','Pubmed ID']]  
print("started importing")

with open('biogrid_gene_gene.scm','w') as f:
    pairs = {}
    for i in range(len(data)):
      if not pd.isnull(data.iloc[i]['Official Symbol Interactor A']) and not pd.isnull(data.iloc[i]['Official Symbol Interactor B']):
        node1 = str(data.iloc[i]['Official Symbol Interactor A']).upper()
        node2 = str(data.iloc[i]['Official Symbol Interactor B']).upper()
        interactors = node1 +':'+ node2
        pubmed = data.iloc[i]['Pubmed ID']            
        if interactors in pairs.keys():
            checkdisc(pairs, interactors, '(ConceptNode "' + 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' + str(pubmed) + '")')
        else:
            checkdisc(pairs, interactors, '(ConceptNode "' + 'https://www.ncbi.nlm.nih.gov/pubmed/?term=' + str(pubmed) + '")')
	          # The relationship should be undirected (both way) 
            f.write( '(EvaluationLink\n'+ 
                      '(PredicateNode "interacts_with")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + node2 +'")\n'+
                            '(GeneNode "'+ node1 +'")))\n' )
	          # We can take advantage of finding the Gene entez ID information here
            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "has_entrez_id")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + node1 +'")\n'+
                            '(ConceptNode "'+ "entrez:"+str(data.iloc[i]['Entrez Gene Interactor A']) +'")))\n')

            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "has_entrez_id")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + node2 +'")\n'+
                            '(ConceptNode "'+ "entrez:" + str(data.iloc[i]['Entrez Gene Interactor B']) +'")))\n') 
    
    for p in pairs.keys():
      f.write('(EvaluationLink\n'+ 
                '(PredicateNode "has_pubmedID")\n'+
                  '(ListLink \n'+            
                      '(EvaluationLink\n'+ 
                      '(PredicateNode "interacts_with")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + str(p).split(':')[0] +'")\n'+
                            '(GeneNode "'+ str(p).split(':')[1] +'")))\n' +
                      '(ListLink \n'+
                      "\n".join(set(pairs[p]))+ ')))\n')
