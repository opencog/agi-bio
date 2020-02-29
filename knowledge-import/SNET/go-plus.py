# Script to convert go-plus csv to atomspace representation in scheme
# Requires: file go-plus from https://bioportal.bioontology.org/ontologies/GO-PLUS

import re
import wget
import metadata
import os
import pandas as pd

def get_term(class_id):
    if str(class_id) == "nan":
        term = class_id
    else:
        term = class_id.split("/")[-1]
        if term[:2] == "GO":
            term = term.replace("_",":")
    return term

def evaLink(term1 , term2, predicate):
    if not (str(term1) == "nan" or str(term2) == 'nan'):
        return("(EvaluationLink \n" +
            "\t (PredicateNode \""+ predicate + "\")\n" +
            "\t (ListLink \n" +
            "\t\t (ConceptNode"  + " \"" + term1 + "\")\n" +
            "\t\t (ConceptNode" + " \"" + term2 + "\")))\n" )
    else:
        return ""

source = "https://bioportal.bioontology.org/ontologies/GO-PLUS"
source_csv = "https://gitlab.com/opencog-bio/pln_mozi/blob/master/raw_data/GO-PLUS.csv.gz"

if not os.path.exists("raw_data/GO-PLUS.csv.gz"):
    dataset = wget.download(source_csv, "raw_data")
df = pd.read_csv("raw_data/GO-PLUS.csv.gz", dtype=str)
columns = ["Class ID","Obsolete","negatively regulated by","negatively regulates", "positively regulated by", "positively regulates", "regulated by", "regulates", "has part", "part of"]

df = df[columns]

with open("dataset/Go-Plus.scm","w") as f:
    for i in range(len(df)):
        term = get_term(df.iloc[i]["Class ID"])
        obsolete = df.iloc[i]["Obsolete"]
        if obsolete == "false" and "GO" in term:
            f.write(evaLink(term, get_term(df.iloc[i]["negatively regulates"]), "GO_negatively_regulates"))
            f.write(evaLink(term, get_term(df.iloc[i]["positively regulates"]), "GO_positively_regulates"))
            f.write(evaLink(term, get_term(df.iloc[i]["regulates"]), "GO_regulates"))
            f.write(evaLink(term, get_term(df.iloc[i]["has part"]), "GO_has_part"))
            f.write(evaLink(term, get_term(df.iloc[i]["part of"]), "GO_part_of"))
            f.write(evaLink(get_term(df.iloc[i]["negatively regulated by"]), term, "GO_negatively_regulates"))
            f.write(evaLink(get_term(df.iloc[i]["positively regulated by"]), term, "GO_positively_regulates"))
            f.write(evaLink(get_term(df.iloc[i]["regulated by"]), term, "GO_positively_regulates"))
            
