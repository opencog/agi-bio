__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"

# The following script imports the following files from Small molecule database at http://smpdb.ca/

	#1 Metabolite names linked to SMPDB pathways CSV (includes KEGG and ChEBI IDs)	
	#2 Protein names linked to SMPDB pathways CSV (includes UniProt IDs)

# Requires: smpdb_metabolites.csv.zip
#	    smpdb_proteins.csv.zip

# from 	http://smpdb.ca/downloads/smpdb_metabolites.csv.zip
# 	http://smpdb.ca/downloads/smpdb_proteins.csv.zip


import pandas as pd
import os
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO

def import_metabolites():
    # smpdb metabolites
    exists_chebi = False

    if not "smpdb_metabolites.csv.zip" in os.listdir(os.getcwd()):

        print("Started downloading smpdb_metabolites.csv")

        print("This file sized 159 MB, it will take some time to download \n" +
              "If you prefer to download it your self, download it here \n" +
              "http://smpdb.ca/downloads/smpdb_metabolites.csv.zip \n" +
              "Make sure you placed the file in the same directory this script is \n")

        smpdb_chebi_zip = urlopen("http://smpdb.ca/downloads/smpdb_metabolites.csv.zip")
        smpdb_chebi_extracted = ZipFile(BytesIO(smpdb_chebi_zip.read()))
        pathway_chebi = smpdb_chebi_extracted.namelist()

        print("Done")

    else:
        ZipFile("smpdb_metabolites.csv.zip").extractall("smpdb_chebi")
        pathway_chebi = os.listdir(os.getcwd()+"/smpdb_chebi")
        exists_chebi = True
     
    print("Started importing all files (counted 48687) of smpdb_metabolites")

    with open("smpdb_chebi.scm", 'a') as f:
        for filename in pathway_chebi:
            if exists_chebi is True:
                data = pd.read_csv("smpdb_chebi/"+filename, low_memory=False)
            else:
                data = pd.read_csv(smpdb_chebi_extracted.open(filename), low_memory=False)
            for r,c in data.iterrows():
                    f.write('(MemberLink\n' + 
                              '(MoleculeNode "' +'ChEBI:'+ str(data.iloc[r]['ChEBI ID']) +'")\n'+
                              '(ConceptNode '+ '"' + str(data.iloc[r]['SMPDB ID']) +'")\n)')
                    f.write('(EvaluationLink\n'+'(PredicateNode "has_name")\n'+
                            '(ListLink \n'+
                            '(MoleculeNode "'+'ChEBI:'+ str(data.iloc[r]['ChEBI ID']) +'")\n' +
                            '(ConceptNode "'+ str(data.iloc[r]['IUPAC']) +'")))\n\n')
                    break
            print("Imported "+filename)
            break

    print("Done. Check smpdb_chebi.scm")

def import_proteins():
    # smpdb Proteins

    exists_prot = False

    if not "smpdb_proteins.csv.zip" in os.listdir(os.getcwd()):
        print("Started downloading smpdb_proteins.csv")

        print("This file sized 28 MB, it will take some time to download \n" +
              "If you prefer to download it your self, download it here \n" +
              "http://smpdb.ca/downloads/smpdb_proteins.csv.zip \n" +
              "Make sure you placed the file in the same directory this script is \n")

        smpdb_prot_zip = urlopen("http://smpdb.ca/downloads/smpdb_proteins.csv.zip")
        smpdb_prot_extracted = ZipFile(BytesIO(smpdb_prot_zip.read()))
        pathway_prot = smpdb_prot_extracted.namelist()

        print("Done")

    else:
        ZipFile("smpdb_proteins.csv.zip").extractall("smpdb_prot")
        pathway_prot = os.listdir(os.getcwd()+"/smpdb_prot")
        exists_prot = True

    print("Started importing all files of smpdb_proteins")

    with open("smpdb_protein.scm", 'a') as f:
        for filename in pathway_prot:
            if exists_prot is True:
                data = pd.read_csv("smpdb_prot/"+filename, low_memory=False)
            else:
                data = pd.read_csv(smpdb_prot_extracted.open(filename), low_memory=False)
            for r,c in data.iterrows():
                    f.write('(EvaluationLink\n'+
                            '(PredicateNode "expresses")\n'+
                            '(ListLink \n'+
                            '(GeneNode '+ '"' + str(data.iloc[r]['Gene Name']) +'")\n' +
                            '(MoleculeNode "'+'Uniprot:'+ str(data.iloc[r]['Uniprot ID']) +'")))\n\n')
                    f.write('(MemberLink\n' +
                              '(GeneNode "' + str(data.iloc[r]['Gene Name']) +'")\n'+
                              '(ConceptNode '+ '"' + str(data.iloc[r]['SMPDB ID']) +'")\n)')
                    f.write('(MemberLink\n' +
                              '(MoleculeNode "' +'Uniprot:'+ str(data.iloc[r]['Uniprot ID']) +'")\n'+
                              '(ConceptNode '+ '"' + str(data.iloc[r]['SMPDB ID']) +'")\n)')
                    f.write('(EvaluationLink\n'+
                            '(PredicateNode "has_name")\n'+
                            '(ListLink \n'+
                            '(ConceptNode '+ '"' + data.iloc[r]['SMPDB ID'] +'")\n' +
                            '(ConceptNode "'+ data.iloc[r]['Pathway Name'] +'")))\n\n')
                    f.write('(EvaluationLink\n'+'(PredicateNode "has_name")\n'+
                            '(ListLink \n'+
                            '(MoleculeNode "'+'Uniprot:'+ str(data.iloc[r]['Uniprot ID']) +'")\n' +
                            '(ConceptNode "'+ data.iloc[r]['Protein Name'] +'")))\n\n')
                    break
            print("Imported "+filename)
            break

    print("Done. Check smpdb_protein.scm")

## Import them
if __name__ == "__main__":
	print("Import the following files from Small molecule database \n" +
	      "Press M to import Metabolite names linked to SMPDB pathways \n"+
	      "Press P to import Protein names linked to SMPDB pathways \n"+
	      "Press B for both\n")
	option = input()
	if option == "P" or option == "p":
		import_proteins()
	elif option == "M" or option == "m":
		import_metabolites()
	elif option == "B" or option == "b":
		import_proteins()
		import_metabolites()
	else:
	    print("Incorect option, Try again")


