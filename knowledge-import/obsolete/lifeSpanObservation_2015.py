#!/usr/bin/env python2.7
# Python script used to generate scheme file from Lifespan - observations_2015-02-21_Geneset which mapped to Human homologue lifespan_HumanHomolog.csv
# 2474 atoms total

import pandas

INCREASED_NAME = "Lifespan_Observations_Increased_GeneSet"
DECREASED_NAME = "Lifespan_Observations_Decreased_GeneSet"

input_dataset = pandas.read_csv('lifespan_HumanHomolog.csv', sep="," , usecols=(2,3)) # read 'lifespanEffect','symbol' columns 

# open output file 

f_out = open('Lifespan-observations_2015-02-21.scm', 'a')

#define functions 

def inLink(node1 ,node2):
            f_out.write("(InheritanceLink \n")
	    f_out.write("\t (ConceptNode \""+ node1 + "\")\n")
	    f_out.write("\t (ConceptNode \""+ node2 + "\")\n")
	    f_out.write(")\n\n")

def memLink(member, lifespanEffect):
            f_out.write("(MemberLink \n")  
	    f_out.write("\t\t(GeneNode \"" + member + "\")\n") 
	    f_out.write("\t\t(ConceptNode \"" + lifespanEffect + "\"))\n")

# write output file 

f_out.write("(define count (count-all))\n")
f_out.write("(define message (string-append \" Atoms loaded \" \"\\n\"))\n")
f_out.write("(display count)\n")
f_out.write("(display message)\n")

inLink(INCREASED_NAME, "Geneset")
inLink(DECREASED_NAME, "Geneset")

f_out.write("""
(EvaluationLink
    (PredicateNode "promotes")
    (ListLink
        (ConceptNode "{}")
        (ConceptNode "Longevity)))\n
""".format(INCREASED_NAME))

f_out.write("""
(EvaluationLink
    (PredicateNode "inhibits")
    (ListLink
        (ConceptNode "{}")
        (ConceptNode "Longevity)))\n
""".format(DECREASED_NAME))


# loop through file

for i in range(0,len(input_dataset)):
 if (not(isinstance(input_dataset['lifespanEffect'][i] ,  float))  and not(isinstance(input_dataset['hgnc_symbol'][i] ,  float))):
   if (input_dataset['lifespanEffect'][i] == "increased"):
    memLink(input_dataset['hgnc_symbol'][i],"Lifespan_Observations_Increased_GeneSet") 
   else:
    memLink(input_dataset['hgnc_symbol'][i],"Lifespan_Observations_Decreased_GeneSet")
   

f_out.write("(set! count (count-all))\n")
f_out.write("(display count)\n")
f_out.write("(display message)\n")

#close files 
f_out.close()
