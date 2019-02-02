__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"

# The following script imports Biogrid interaction of Human genes from thebiogrid.com

# Requires: BIOGRID-ORGANISM-Homo_sapiens-3.5.168.tab2.txt 

# from https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.168/BIOGRID-ORGANISM-3.5.168.tab2.zip

# Or any of the latest version with the same type 

import pandas as pd
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO

if not os.path.isfile('BIOGRID-ORGANISM-Homo_sapiens-3.5.168.tab2.txt'):

	# Get the latest zip file first, and import the specific file (Homo_sapiens) 

	thefile = urlopen("https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.168/BIOGRID-ORGANISM-3.5.168.tab2.zip")
	extracted_files = ZipFile(BytesIO(thefile.read()))
	data = pd.read_csv(extracted_files.open('BIOGRID-ORGANISM-Homo_sapiens-3.5.168.tab2.txt'), low_memory=False, delimiter='\t') 
else:
	data = pd.read_csv("BIOGRID-ORGANISM-Homo_sapiens-3.5.168.tab2.txt", low_memory=False, delimiter='\t')

with open('biogrid_gene_gene.scm','a') as f:

    for i in range(len(data)):

        if not pd.isnull(data.iloc[i]['Official Symbol Interactor A']) and not pd.isnull(data.iloc[i]['Official Symbol Interactor B']):
            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "interacts_with")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + data.iloc[i]['Official Symbol Interactor A'] +'")\n'+
                            '(GeneNode "'+ data.iloc[i]['Official Symbol Interactor B'] +'")))\n')
		
	    # The relationship should be undirected (both way) 
            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "interacts_with")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + data.iloc[i]['Official Symbol Interactor B'] +'")\n'+
                            '(GeneNode "'+ data.iloc[i]['Official Symbol Interactor A'] +'")))\n')

	    # We can take advantage of finding the Gene entez ID information here
            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "has_entrez_id")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + data.iloc[i]['Official Symbol Interactor A'] +'")\n'+
                            '(ConceptNode "'+ str(data.iloc[i]['Entrez Gene Interactor A']) +'")))\n')

            f.write('(EvaluationLink\n'+ 
                      '(PredicateNode "has_entrez_id")\n'+
                        '(ListLink \n'+
                            '(GeneNode "' + data.iloc[i]['Official Symbol Interactor B'] +'")\n'+
                            '(ConceptNode "'+ str(data.iloc[i]['Entrez Gene Interactor B']) +'")))\n') 
  
