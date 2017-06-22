#!/usr/bin/env python2.7
# Python script used to generate scheme file from Aging-Mythelation_Geneset. 
# Requires: file mmc4.xlsx

import xlrd
book = xlrd.open_workbook('mmc4.xlsx')
f_mmc4 = open('mmc4.scm', 'a')

#define functions 

def inLink(node1 ,node2):
            f_mmc4.write("(InheritanceLink \n")
	    f_mmc4.write("\t (ConceptNode \""+ node1 + "\")\n")
	    f_mmc4.write("\t (ConceptNode \""+ node2 + "\")\n")
	    f_mmc4.write(")\n\n")

def evaLink(predicate , node1,node1_type, node2,node2_type):
            f_mmc4.write("(EvaluationLink \n")
	    f_mmc4.write("\t (PredicateNode \"" + predicate + "\")\n")
	    f_mmc4.write("\t (ListLink \n")
	    f_mmc4.write("\t\t("+node1_type+" \"" + "MSigDB_GeneSet: "+ node1 + "\")\n")
	    f_mmc4.write("\t\t("+node2_type+" \"" + node2 + "\")\n")
	    f_mmc4.write("\t )\n")
	    f_mmc4.write(")\n\n")

def memLink(members):
            f_mmc4.write("(MemberLink \n")  
	    f_mmc4.write("\t\t(GeneNode \"" + members + "\")\n") 
	    f_mmc4.write("\t\t(ConceptNode \"" + "Aging-Mythelation_GeneSet" + "\"))\n")

# write output file 

f_mmc4.write("(define count (count-all))\n")
f_mmc4.write("(define message (string-append \" Atoms loaded \" \"\\n\"))\n")
f_mmc4.write("(display count)\n")
f_mmc4.write("(display message)\n")
f_mmc4.write("(define start_time (current-time))\n")

inLink("Aging-Mythelation_Geneset", "Geneset")
evaLink("organism", "Aging-Mythelation_Geneset","ConceptNode", "Homo sapiens", "ConceptNode")
evaLink("source_PubMedID", "Aging-Mythelation_Geneset","ConceptNode", "23177740", "NumberNode")
evaLink("brief_description_of", "Aging-Mythelation_Geneset","ConceptNode", "Genes Associated with Aging in Both the Methylome and th Transcript.", "PhraseNode")

# lop through file

worksheets = book.sheet_names()
for name in worksheets:
  sheet = book.sheet_by_name(name)	
  rows = sheet.nrows
  curr_row = 0
  while curr_row < rows:
    memLink(((sheet.row(curr_row)[0]).value).encode('ascii','ignore')) 
    curr_row =curr_row + 1

# calculate time elapsed 

f_mmc4.write("(set! count (count-all))\n")
f_mmc4.write("(display count)\n")
f_mmc4.write("(display message)\n")

f_mmc4.write("(define end_time (current-time))\n")
f_mmc4.write("(define elapsed_time (round (/ (- end_time start_time) 60.0)))\n")
f_mmc4.write("(display \"Atom loading End in ..\")\n")
f_mmc4.write("(display elapsed_time)\n")
f_mmc4.write("(display \" minutes\\n\")\n")

#close files 

f_mmc4.close()
