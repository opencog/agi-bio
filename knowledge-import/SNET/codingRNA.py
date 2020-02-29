# Maps genes to ensembl transcripts and to uniprot ids
# Requires: 
    # ftp://ftp.ensembl.org/pub/grch37/release-98/tsv/homo_sapiens/Homo_sapiens.GRCh37.85.uniprot.tsv.gz 
    # ensemble gene to hgnc symbol mapping from https://www.genenames.org/download/custom/ 
 
import wget
import gzip
import os
import metadata
import pandas as pd

def expres(predicate, node1, node2):
    return ""+'\n(EvaluationLink \n'+'(PredicateNode "'+ predicate +'")\n'+'(ListLink \n'+ node1 +'\n'+ node2 +'))\n'

source = "ftp://ftp.ensembl.org/pub/grch37/release-98/tsv/homo_sapiens/Homo_sapiens.GRCh37.85.uniprot.tsv.gz"
dataset = "Homo_sapiens.GRCh37.85.uniprot.tsv.gz"
if not dataset in os.listdir("raw_data/"):
	wget.download(source, "raw_data")

data = pd.read_csv("raw_data/"+dataset, sep="\t",dtype=str)
mapping_data = pd.read_csv("raw_data/symbol2entrez_mapping.txt", sep="\t")
# Approved symbol	Ensembl gene ID
data.rename(columns = {'gene_stable_id':'Ensembl gene ID'}, inplace = True) 

col = ["Ensembl gene ID","transcript_stable_id","xref"]
data = data[col]

df = data.join(mapping_data.set_index('Ensembl gene ID'), on='Ensembl gene ID')
df = df.dropna()
print("\nStarted importing\n")
rnas = []
genes = []
proteins = []
with open("dataset/codingRNA.scm", 'w') as f:
    for i in range(len(df)):
        rna = df.iloc[i]["transcript_stable_id"]
        gene = df.iloc[i]['Approved symbol']
        prot = df.iloc[i]["xref"]
        rnas.append(rna)
        genes.append(gene)
        proteins.append(prot)
        if gene:
            f.write(expres("transcribed_to", '(GeneNode "{}")'.format(gene), '(MoleculeNode "{}")'.format(rna)))
        if rna:
            f.write(expres("translated_to", '(MoleculeNode "{}")'.format(rna), '(MoleculeNode "Uniprot:{}")'.format(prot)))

version = dataset.split(".")[1]
script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/codingRNA.py"

metadata.update_meta("codingRNA:{}".format(version),dataset,script,genes=len(set(genes)),rna=len(set(rnas)))

print("Done")