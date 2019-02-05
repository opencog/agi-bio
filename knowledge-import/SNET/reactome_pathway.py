__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"

# The following script imports Reactome pathways and their relationship from https://reactome.org

# Requires: 
	# https://reactome.org/download/current/ReactomePathwaysRelation.txt
	# https://reactome.org/download/current/ReactomePathways.txt

import pandas as pd
from urllib.request import urlopen
import os

# Helper functions

def eva(name, reid):
    return ""+'(EvaluationLink \n (PredicateNode "has_name")\n (ListLink\n (ConceptNode "'+ reid + '")\n' + '(ConceptNode "'+ name + '")))\n'

def inherit(parent, child):
    return ""+"(InheritanceLink \n (ConceptNode "+ child + ")\n " + "(ConceptNode "+ parent + "))\n"

# URL

pathway_rln = "https://reactome.org/download/current/ReactomePathwaysRelation.txt"
pathway = "https://reactome.org/download/current/ReactomePathways.txt"

if not os.path.isfile('ReactomePathwaysRelation.txt'):
	print("Downloading ReactomePathwaysRelation.txt")
	pathway_relation = pd.read_csv(urlopen(pathway_rln), low_memory=False, delimiter='\t', names=["parent", "child"])
	print("Done")
else:
	pathway_relation = pd.read_csv('ReactomePathwaysRelation.txt', low_memory=False, delimiter='\t', names=["parent", "child"])  

if not os.path.isfile('ReactomePathways.txt'):
	print("Downloading ReactomePathways.txt")
	pathway_list = pd.read_csv(urlopen(pathway), low_memory=False, delimiter='\t', names=["ID", "name", "Species"])
	print("Done")
else:
	pathway_list = pd.read_csv('ReactomePathways.txt', low_memory=False, delimiter='\t', names=["ID", "name", "Species"]) 

pathway_list = pathway_list[pathway_list['Species']=='Homo sapiens'] 
max_len = max(len(pathway_list), len(pathway_relation)) 

print("Started importing")

with open("reactome.scm", 'a') as f:
    for i in range(max_len):
        try:
            f.write(eva(pathway_list.iloc[i]['name'],pathway_list.iloc[i]['ID']))
            f.write(inherit(pathway_relation.iloc[i]['parent'], pathway_relation.iloc[i]['child']))
        except IndexError:
            f.write(inherit(pathway_relation.iloc[i]['parent'], pathway_relation.iloc[i]['child']))

print("Done")

