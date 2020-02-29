__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script imports the Physical Entity (PE) Identifier mapping files from https://reactome.org/download-data

# Requires: NCBI2Reactome_PE_Pathway.txt
#	    UniProt2Reactome_PE_Pathway.txt
# 	    ChEBI2Reactome_PE_Pathway.txt

# from https://reactome.org/download/current/

import pandas as pd
import wget
import os
import sys
import metadata

# Get each of the files first

# URL's

ncbi = "https://reactome.org/download/current/NCBI2Reactome_PE_Pathway.txt"
uniprot = "https://reactome.org/download/current/UniProt2Reactome_PE_Pathway.txt"
chebi = "https://reactome.org/download/current/ChEBI2Reactome_PE_Pathway.txt"
script = "https://github.com/MOZI-AI/agi-bio/blob/master/knowledge-import/SNET/Physical%20Entity%20(PE)%20Identifier%20mapping.py"

# If you have the files downloaded, make sure the file names are the same 
# Or modify the file names in this code to match yours.

def get_data(name):

	print("Downloading the datasets, It might take a while")

	if(name in ["N", "n", "A", "a"]):
		if(not os.path.isfile('NCBI2Reactome_PE_Pathway.txt')): 
			wget.download(ncbi, "raw_data/")

	if(name in ["U", "u", "A", "a"]):
		if(not os.path.isfile('UniProt2Reactome_PE_Pathway.txt')): 
			wget.download(uniprot, "raw_data/")

	if(name in ["C", "c", "A", "a"]):
		if(not os.path.isfile('ChEBI2Reactome_PE_Pathway.txt')):
			wget.download(chebi, "raw_data/")

	print("Done")

# Helper functions for Atomese representation
 
def member(indiv, group):
	if "Uniprot" in indiv or "ChEBI" in indiv:
		return ""+"(MemberLink \n (MoleculeNode "+'"'+ indiv + '")\n' + '(ConceptNode "'+ group + '"))\n\n'
	else:
    		return ""+"(MemberLink \n (GeneNode "+'"'+ indiv + '")\n' + '(ConceptNode "'+ group + '"))\n\n'

def eva(pred, el1, el2):
    if pred == 'e':
        pred = "has_evidence_code"
    elif pred == 'l':
        pred = "has_location"
    elif pred == 'n':
        pred = "has_name"
    if "Uniprot" in el1 or "ChEBI" in el1 or "Uniprot" in el2 or "ChEBI" in el2:
    	return ""+'(EvaluationLink \n (PredicateNode "' + pred +'")\n (ListLink\n (MoleculeNode "'+ el1 + '")\n' + '(ConceptNode "'+ el2 + '")))\n\n'
    else:
    	return ""+'(EvaluationLink \n (PredicateNode "' + pred +'")\n (ListLink\n (GeneNode "'+ el1 + '")\n' + '(ConceptNode "'+ el2 + '")))\n\n'

# The column 'R_PE_name' contains the Gene Symbol and its location information, so we need to split it
# Example: A1BG [extracellular region]
# A1BG is the Gene symbol and 'extracellular region' is the gene location
# some has extra symbols which needs preprocessing e.g. CCL5(24-91) [extracellular region], p-S472-AKT3 [plasma membrane]

def find_location(PEname, filter=False):
	if "[" in PEname and "]" in PEname:
		loc = PEname[PEname.find("[")+1:PEname.find("]")]
		gene = PEname.split("[" +loc +"]")[0]
	else:
		loc = ""
		gene = PEname
	gene = gene.replace(gene[gene.find("("):PEname.find(")")+1], "").replace(")", "").replace("(","")
	if "-" in gene:
		gene = [i for i in gene.split("-") if not i.strip().isdigit()][-1]
	gene = gene.strip()
	if filter:
		return gene
	return gene,loc

# Finds the common word in a list of strings 
def findstem(arr): 
	n = len(arr) 
	s = arr[0] 
	l = len(s) 
	res = "" 
	for i in range(l): 
		for j in range( i + 1, l + 1):
			stem = s[i:j] 
			k = 1
			for k in range(1, n): 
				if stem not in arr[k]: 
					break
			if (k + 1 == n and len(res) < len(stem)): 
				res = stem 
	return res.strip()

def import_dataset(dataset, delim):
	print("Started importing " + dataset)
	if "UniProt" in dataset or "ChEBI" in dataset:
		data = pd.read_csv(dataset, low_memory=False, delimiter=delim, names=["db_id", "R_PE_id", "R_PE_name","pathway","url","event_name", "evidence_code", "species","un1","un2","un3","un4","un5","un6"])

	else:	
		data = pd.read_csv(dataset, low_memory=False, delimiter=delim, names=["db_id", "R_PE_id", "R_PE_name","pathway","url","event_name", "evidence_code", "species"])
	
	# Take only symbols of Human species
	data_human = data[data['species'] == 'Homo sapiens'][['db_id','R_PE_name','pathway']]
	if not os.path.exists(os.path.join(os.getcwd(), 'dataset')):
		os.makedirs('dataset')
	with open("dataset/"+dataset.split("/")[-1]+".scm", 'w') as f:
		if "NCBI" in dataset:
			genes = []
			pathways = []
			db_ids = {}
			for i in range(len(data_human)):
				gene, location = find_location(data_human.iloc[i]['R_PE_name'])
				pathway = data_human.iloc[i]['pathway']
				db_id = data_human.iloc[i]['db_id']
				# If a gene symbol is not one word, collect all gene symbols of the same db_id
				# and find the common word in the list (which is the gene symbol in most cases)
				# e.g "proKLK5" "KLK5" "propeptide KLK5"
				if len(gene.split(" ")) >1:
					if db_id in db_ids.keys():
						gene = db_ids[data_human.iloc[i]['db_id']]
					else:
						gene_symbols = data_human[data_human['db_id']==db_id]['R_PE_name'].values
						gene_symbols = [find_location(i, True) for i in gene_symbols]
						if len(set(gene_symbols)) > 1:
							stemed = findstem(gene_symbols)
						else:
							stemed = gene_symbols[-1]

						if not (stemed.isdigit() and stemed in ["", " "] and len(stemed) == 1):
							db_ids.update({db_id:stemed})
						gene = stemed
				if not gene.isdigit() and not len(gene) == 1 and not gene in ["", " "]:
					f.write("(AndLink\n")
					f.write(member(gene, pathway))
					f.write(eva('l', gene, location))
					f.write(")\n")
					if not gene in genes:
						genes.append(gene)
					if not pathway in pathways:
						pathways.append(pathway) 
			version = "NCBI2reactome_pathway_mapping:latest"
			num_pathways = {"Reactome Pathway": len(pathways)}
			metadata.update_meta(version,ncbi,script,genes=len(genes),pathways=num_pathways)
		elif "UniProt" in dataset:
			molecules = []
			pathways = []
			for i in range(len(data_human)):
				prot = str(data_human.iloc[i]['R_PE_name'])
				loc = prot[prot.find("[")+1:prot.find("]")]
				prot_name = prot.split("[" +loc +"]")[0]
				pathway = data_human.iloc[i]['pathway']
				protein = [i for i in str(data_human.iloc[i]['db_id']).split("-") if not i.strip().isdigit()][-1]
				f.write("(AndLink\n")
				f.write(member("Uniprot:"+str(protein), pathway))
				f.write(eva('l', "Uniprot:"+str(protein), loc))
				f.write(")\n")
				if not protein in molecules:
					molecules.append(protein)
					f.write(eva("n", "Uniprot:"+str(protein), prot_name))
				if not pathway in pathways:
					pathways.append(pathway)
			version = "Uniprot2reactome_pathway_mapping:latest"
			num_pathways = {"Reactome Pathway": len(pathways)}
			metadata.update_meta(version,ncbi,script,prot=len(molecules),pathways=num_pathways)
		elif "ChEBI" in dataset:
			molecules = []
			pathways = []
			for i in range(len(data_human)):
				chebi = str(data_human.iloc[i]['R_PE_name'])
				loc = chebi[chebi.find("[")+1:chebi.find("]")]
				chebi_name = chebi.split("[" +loc +"]")[0].replace('"',"")
				chebi_id = str(data_human.iloc[i]['db_id'])
				pathway = data_human.iloc[i]['pathway']
				f.write("(AndLink \n")
				f.write(member("ChEBI:"+chebi_id, pathway))
				f.write(eva('l', "ChEBI:"+chebi_id, loc))
				f.write(")\n")
				if not chebi_id in molecules:
					molecules.append(chebi_id)
					f.write(eva("n","ChEBI:"+chebi_id, chebi_name))
				if not pathway in pathways:
					pathways.append(pathway)
			version = "Chebi2reactome_pathway_mapping:latest"
			num_pathways = {"Reactome Pathway": len(pathways)}
			metadata.update_meta(version,ncbi,script,chebi=len(molecules),pathways=num_pathways)
	print("Done")

if __name__ == "__main__":
	print('''Import the following files from https://reactome.org 
	      "Press N to import NCBI2Reactome_PE_Pathway 
	      "Press U to import UniProt2Reactome_PE_Pathway 
	      "Press C to import ChEBI2Reactome_PE_Pathway 
	      "Press A for All \n''')

	option = input()
	if option == "N" or option == "n":
		get_data(option)
		import_dataset('raw_data/NCBI2Reactome_PE_Pathway.txt', '\t')

	elif option == "U" or option == "u":
		get_data(option)
		import_dataset('raw_data/UniProt2Reactome_PE_Pathway.txt', '\t')

	elif option == "C" or option == "c":
		get_data(option)
		import_dataset('raw_data/ChEBI2Reactome_PE_Pathway.txt', '\t')

	elif option == "A" or option == "a":
		get_data(option)
		import_dataset('raw_data/NCBI2Reactome_PE_Pathway.txt', '\t')

		import_dataset('raw_data/UniProt2Reactome_PE_Pathway.txt', '\t')

		import_dataset('raw_data/ChEBI2Reactome_PE_Pathway.txt', '\t')
	else:
	    print("Incorect option, Try again")






