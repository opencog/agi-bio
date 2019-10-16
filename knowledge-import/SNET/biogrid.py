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
import sys
import metadata

def checkdisc(diction, key, value):
  try:
    diction.setdefault(key,[]).append(value)
  except KeyError:
    return "key error"

def import_data_from_web(version):
  if version:
    thefile = urlopen('https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-'+ version +'/BIOGRID-ORGANISM-'+ version +'.tab2.zip')
    extracted_files = ZipFile(BytesIO(thefile.read()))
    dataset = 'BIOGRID-ORGANISM-Homo_sapiens-'+ version +'.tab2.txt'
    data = pd.read_csv(extracted_files.open(dataset), low_memory=False, delimiter='\t')
  else:
    thefile = urlopen('https://downloads.thebiogrid.org/Download/BioGRID/Latest-Release/BIOGRID-ORGANISM-LATEST.tab2.zip')
    extracted_files = ZipFile(BytesIO(thefile.read()))
    dataset = [i for i in extracted_files.namelist() if "BIOGRID-ORGANISM-Homo_sapiens" in i][0]
    version = dataset.split('-')[-1].replace(".tab2.txt", "")
    data = pd.read_csv(extracted_files.open(dataset), low_memory=False, delimiter='\t')
  import_data(data, dataset, version)
  data.to_csv("raw_data/"+dataset, sep='\t',index=False)

def import_local_data(file):
  path = os.path.abspath(file)
  if os.path.isfile(path):
    data = pd.read_csv(path, low_memory=False, delimiter='\t')
    version = file.split('-')[-1].replace(".tab2.txt", "")
    import_data(data, path, version)

def import_data(data, source, version):
  data = data[['Entrez Gene Interactor A',	'Entrez Gene Interactor B', 'Official Symbol Interactor A', 'Official Symbol Interactor B','Pubmed ID']]  
  print("started importing")
  if not os.path.exists(os.path.join(os.getcwd(), 'dataset')):
    os.makedirs('dataset')
  with open('dataset/biogrid_gene_gene_'+version+'.scm','w') as f:
      pairs = {}
      entrez = []
      for i in range(len(data)):
        if not pd.isnull(data.iloc[i]['Official Symbol Interactor A']) and not pd.isnull(data.iloc[i]['Official Symbol Interactor B']):
          node1 = str(data.iloc[i]['Official Symbol Interactor A']).upper()
          node2 = str(data.iloc[i]['Official Symbol Interactor B']).upper()
          if node1 > node2:
            interactors = node1 +':'+ node2
          else:
            interactors = node2 +':'+ node1
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
              if not node1 in entrez:
                f.write('(EvaluationLink\n'+ 
                            '(PredicateNode "has_entrez_id")\n'+
                              '(ListLink \n'+
                                  '(GeneNode "' + node1 +'")\n'+
                                  '(ConceptNode "'+ "entrez:"+str(data.iloc[i]['Entrez Gene Interactor A']) +'")))\n')
                entrez.append(node1)

              if not node2 in entrez:
                f.write('(EvaluationLink\n'+ 
                          '(PredicateNode "has_entrez_id")\n'+
                            '(ListLink \n'+
                                '(GeneNode "' + node2 +'")\n'+
                                '(ConceptNode "'+ "entrez:" + str(data.iloc[i]['Entrez Gene Interactor B']) +'")))\n') 
                entrez.append(node2)

      number_of_genes = []
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
        number_of_genes.append(str(p).split(':')[0])
        number_of_genes.append(str(p).split(':')[1])
  
  number_of_interactions = 2*len(set(pairs.keys()))
  script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/biogrid.py"
  metadata.update_meta("Biogrid:"+version, source,script,genes=str(len(set(number_of_genes))),interactions=str(number_of_interactions))
  print("Done, check"+'dataset/biogrid_gene_gene_'+version+'.scm')
if __name__ == "__main__":
    if len(sys.argv)>1:
      dataset_path = sys.argv[1]
      import_local_data(dataset_path)
    else:
      print("Imports interaction between genes (Homo_sapiens) from thebiogrid.com")
      version = input("Enter A version number or Hit Enter key to get the latest:\n")
      import_data_from_web(version)
    