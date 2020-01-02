# imports mapping from Gene to RNA transcribes into atomese
# Requires: file GCF_000001405.25_GRCh37.p13_feature_table.txt from ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.25_GRCh37.p13/
import wget
import gzip
import os
import metadata
import pandas as pd

source = "ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.25_GRCh37.p13/GCF_000001405.25_GRCh37.p13_feature_table.txt.gz"

def expres(predicate, node1, node2):
    return ""+'\n(EvaluationLink \n'+'(PredicateNode "'+ predicate +'")\n'+'(ListLink \n'+ node1 +'\n'+ node2 +'))\n'

dataset = "GCF_000001405.25_GRCh37.p13_feature_table.txt.gz"
if not dataset in os.listdir("raw_data/"):
	wget.download(source, "raw_data")

data = pd.read_csv("raw_data/"+dataset, sep="\t",dtype=str)
col = ["product_accession","name","symbol"]
data = data[col].dropna()

print("Started importing")
rnas = []
genes = []
with open("dataset/noncodingRNA.scm", 'w') as f:
    for i in range(len(data)):
        rna = data.iloc[i]["product_accession"].split(".")[0]
        gene = data.iloc[i]["symbol"]
        name = data.iloc[i]["name"]
        rnas.append(rna)
        genes.append(gene)
        f.write(expres("transcribed_to", '(GeneNode "{}")'.format(gene), '(MoleculeNode "{}")'.format(rna)))
        f.write(expres("has_name", '(MoleculeNode "{}")'.format(rna), '(ConceptNode "{}")'.format(name)))

version = dataset.split(".")[1]
script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/noncodingRNA.py"

metadata.update_meta("noncodingRNA:{}".format(version),dataset,script,genes=len(set(genes)),ncrna=len(set(rnas)))

print("Done")