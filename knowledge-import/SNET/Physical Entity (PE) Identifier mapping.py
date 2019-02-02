# author: Hedra
# January 2019

# The following script imports the Physical Entity (PE) Identifier mapping files from https://reactome.org/download-data

# Requires: NCBI2Reactome_PE_Pathway.txt
#	    UniProt2Reactome_PE_Pathway.txt
# 	    ChEBI2Reactome_PE_Pathway.txt

# from https://reactome.org/download/current/

import pandas as pd
import wget
import os

# Get each of the files first

# URL's

ncbi = "https://reactome.org/download/current/NCBI2Reactome_PE_Pathway.txt"
uniprot = "https://reactome.org/download/current/UniProt2Reactome_PE_Pathway.txt"
chebi = "https://reactome.org/download/current/ChEBI2Reactome_PE_Pathway.txt"

# If you have the files downloaded, make sure the file names are the same 
# Or modify the file names in this code to match yours.

print("Downloading the datasets, It might take a while")

if(not os.path.isfile('NCBI2Reactome_PE_Pathway.txt')): 
	wget.download(ncbi)

if(not os.path.isfile('UniProt2Reactome_PE_Pathway.txt')): 
	wget.download(uniprot)

if(not os.path.isfile('ChEBI2Reactome_PE_Pathway.txt')):
	wget.download(chebi)

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
###

def import_dataset(dataset, delim):
	print("Started importing " + dataset)
	if "UniProt" in dataset or "ChEBI" in dataset:
		data = pd.read_csv(dataset, low_memory=False, delimiter=delim, names=["db_id", "R_PE_id", "R_PE_name","pathway","url","event_name", "evidence_code", "species","un1","un2","un3","un4","un5","un6"])

	else:	data = pd.read_csv(dataset, low_memory=False, delimiter=delim, names=["db_id", "R_PE_id", "R_PE_name","pathway","url","event_name", "evidence_code", "species"])

	# The third column 'R_PE_name' contains the Gene Symbol and their location information, so we need to split it
	# Example: A1BG [extracellular region]
	# A1BG is the Gene symbol and 'extracellular region' is the gene location

	new_dataframe = data['R_PE_name'].str.split("[", n = 1, expand = True)  
	new_dataframe2 = new_dataframe[0].str.split(" ", n =1, expand = True) # to get rid off the extra white space   

	# Take only symbols of Human species
	data_human = data[data['species'] == 'Homo sapiens'][['db_id','pathway','evidence_code']]

	if "NCBI" in dataset:
		sym = "gene"
	elif "UniProt" in dataset:
		sym = "uniprot"
	elif "ChEBI" in dataset:
		sym = "chebi_name"

	data_human[sym] = new_dataframe2[0]
	data_human['location'] = new_dataframe[1]

	with open(dataset+".scm", 'a') as f:
		if "NCBI" in dataset:
			for i in range(len(data_human)):
				if not data_human.iloc[i]['gene'].split("-")[-1].isdigit() and data_human.iloc[i]['gene'].split("-")[-1] != " ":
					f.write(member(data_human.iloc[i]['gene'].split("-")[-1], data_human.iloc[i]['pathway'] ))
					f.write(eva('l', data_human.iloc[i]['gene'], data_human.iloc[i]['location'].split(']')[0]))
					f.write(eva('e', data_human.iloc[i]['gene'], data_human.iloc[i]['evidence_code'])) 
					
		elif "UniProt" in dataset:
			for i in range(len(data_human)):
				f.write(member("Uniprot:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['pathway'] ))
				f.write(eva('l', "Uniprot:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['location'].split(']')[0]))
				f.write(eva('e', "Uniprot:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['evidence_code']))
				f.write(eva("n", "Uniprot:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['uniprot']))
				
		elif "ChEBI" in dataset:
			for i in range(len(data_human)):
				f.write(member("ChEBI:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['pathway'] ))
				f.write(eva("n","ChEBI:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['chebi_name'] ))
				f.write(eva('l', "ChEBI:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['location'].split(']')[0]))
				f.write(eva('e', "ChEBI:"+str(data_human.iloc[i]['db_id']), data_human.iloc[i]['evidence_code'])) 
			
	print("Done")

###
# Call the import function for each dataset as:

import_dataset('NCBI2Reactome_PE_Pathway.txt', '\t')

import_dataset('UniProt2Reactome_PE_Pathway.txt', ',')

import_dataset('ChEBI2Reactome_PE_Pathway.txt', ',')




