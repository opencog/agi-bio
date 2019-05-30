#!/usr/bin/env python2.7
# Script to convert MSigDB to atomspace representation in scheme
# Requires: file msigdb_v6.1.xml, http://software.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/6.1/msigdb_v6.1.xml
# you have to register your email address to get access!

import datetime
from xml.dom import minidom

GeneSet = "msigdb_v6.1.xml"
sc_filename= GeneSet.split('.xml')[0]
fields= []

#read msigdb
xmldoc = minidom.parse(GeneSet)
msigdb_info = xmldoc.getElementsByTagName('MSIGDB')
genelist = xmldoc.getElementsByTagName('GENESET')

version = msigdb_info[0].attributes["VERSION"].value.encode('ascii','ignore')

# function writes Inheritance link, Evaluationlike and memLink in a file
def inLink(node1 ,node2):
            f.write("(InheritanceLink \n")
	    f.write("\t (ConceptNode \"" + "GeneSet: "+ node1 + "\")\n")
	    f.write("\t (ConceptNode \""+ node2 + "\")\n")
	    f.write(")\n\n")

def evaLink(predicate , node1,node1_type, node2,node2_type):
            f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + predicate + "\")\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t("+node1_type+" \"" + "GeneSet: "+ node1 + "\")\n")
	    f.write("\t\t("+node2_type+" \"" + node2 + "\")\n")
	    f.write("\t )\n")
	    f.write(")\n\n")

def memLink(members,geneset):
           f.write("(MemberLink \n")
	   f.write("\t\t(GeneNode \"" + members + "\")\n")
	   f.write("\t\t(ConceptNode \"" + "GeneSet: "+ geneset + "\"))\n")

# function to write scheme file with description
def scheme_des_writer(fields):

        scheme_writer(fields)
        count = 0
        for s in genelist:
	 if  not(not (s.attributes["DESCRIPTION_BRIEF"].value).encode('ascii','ignore')):
	    node1_type = "ConceptNode"
	    node2_type = "PhraseNode"
	    PredicateNode = "brief_description_of"
	    evaLink(PredicateNode,(s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\'),node1_type,(s.attributes["DESCRIPTION_BRIEF"].value).encode('ascii','ignore').replace('\\', '\\\\'),node2_type)


	 if  not(not (s.attributes["DESCRIPTION_FULL"].value).encode('ascii','ignore')):
	    node1_type = "ConceptNode"
	    node2_type = "PhraseNode"
	    PredicateNode = "full_description_of"
	    evaLink(PredicateNode, (s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\'),node1_type,(s.attributes["DESCRIPTION_FULL"].value).encode('ascii','ignore').replace('\\', '\\\\'),node2_type)
         count = count + 1
         #if count % 27 == 0:
	  #f.write("(set! count (count-all))\n")
	  #f.write("(display count)\n")
	  #f.write("(display message)\n")

####
#If the user press "D" , scheme file with description generated else the description fields will not be included.
value = raw_input("Press D to generate scheme file with description or press Enter. \n")
if value == "D":
  fields.extend(["STANDARD_NAME", "HISTORICAL_NAMES","ORGANISM", "DESCRIPTION_BRIEF", "DESCRIPTION_FULL", "MEMBERS_SYMBOLIZED"])
  sc_filename = sc_filename + "_verbose.scm"
  f = open(sc_filename, 'a')

  #f.write("(clear)\n")
  f.write("(define start_time (current-time))\n")

  scheme_des_writer(fields)
  f.write("(define end_time (current-time))\n")

  #f.write("(define elapsed_time (round (/ (- end_time start_time) 60.0)))\n")
  f.write("(define elapsed_time (/ (- end_time start_time) 60.0))\n")
  f.write("(set! count (count-all))\n")
  f.write("(display count)\n")
  f.write("(display message)\n")

  f.write("(display \"Atom loading End in ..\")\n")
  f.write("(display elapsed_time)\n")
  f.write("(display \" minutes\\n\")\n")
  f.close()

elif not(value):
  fields.extend(["STANDARD_NAME", "HISTORICAL_NAMES","ORGANISM","MEMBERS_SYMBOLIZED"])
  sc_filename = sc_filename + ".scm"
  f = open(sc_filename, 'a')

  #f.write("(clear)\n")
  f.write("(define start_time (current-time))\n")

  scheme_writer(fields)
  f.write("(define end_time (current-time))\n")
  #f.write("(define elapsed_time (round (/ (- end_time start_time) 60.0)))\n")
  f.write("(define elapsed_time (/ (- end_time start_time) 60.0))\n")

  f.write("(set! count (count-all))\n")
  f.write("(display count)\n")
  f.write("(display message)\n")

  f.write("(display \"Atom loading End in ..\")\n")
  f.write("(display elapsed_time)\n")
  f.write("(display \" minutes\\n\")\n")

  f.close()
else:
  print "wrong choice"
