#!/usr/bin/env python2.7
# Script to convert MSigDB to atomspace representation in scheme
# Requires: file msigdb_v5.0.xml, http://www.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/5.0/msigdb_v5.0.xml
# Note: also works with msigdb_v4.0.xml, http://www.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/4.0/msigdb_v4.0.xml
# Outputs scheme file to use for atomspace import
# Added creation date, MSigDB version, and MSigDB fields included
# Option to creat MSigDB scheme with or with out Description fields

import datetime
from xml.dom import minidom

GeneSet = "msigdb_v6.0.xml"
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
	    f.write("\t (ConceptNode \"" + "MSigDB_GeneSet: "+ node1 + "\")\n")
	    f.write("\t (ConceptNode \""+ node2 + "\")\n")
	    f.write(")\n\n")
def evaLink(predicate , node1,node1_type, node2,node2_type):
            f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + predicate + "\")\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t("+node1_type+" \"" + "MSigDB_GeneSet: "+ node1 + "\")\n")
	    f.write("\t\t("+node2_type+" \"" + node2 + "\")\n")
	    f.write("\t )\n")
	    f.write(")\n\n")
def memLink(members,geneset):
           f.write("(MemberLink \n")
	   f.write("\t\t(GeneNode \"" + members + "\")\n")
	   f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ geneset + "\"))\n")

#function to write scheme file without description

def scheme_writer(fields):

  f.write(";Build Date: " + msigdb_info[0].attributes["BUILD_DATE"].value.encode('ascii','ignore')+ "\n")
  f.write(";MsigDB Version: "+ version + "\n")
  f.write(";MsigDB fields included: " + ', '.join(fields) + "\n\n")

  f.write("(define count (count-all))\n")
  f.write("(define message (string-append \" Atoms loaded \" \"\\n\"))\n")
  f.write("(display count)\n")
  f.write("(display message)\n")

  f.write("(InheritanceLink \n")
  f.write("\t (ConceptNode \"" + "MSigDB_GeneSet" + "\")\n")
  f.write("\t (ConceptNode \"" + "GeneSet" + "\")\n")
  f.write(")\n\n")

  f.write("(InheritanceLink \n")
  f.write("\t (ConceptNode \""+ "MsigDB_GeneSet_v"+version+ "\")\n")
  f.write("\t (ConceptNode \"" + "MSigDB_GeneSet" + "\")\n")
  f.write(")\n\n")
  #loop in genesets
  count = 0
  for s in genelist :

	if  not(not (s.attributes["STANDARD_NAME"].value).encode('ascii','ignore')):

            inLink((s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\') , "MsigDB_GeneSet_v"+version)

	if  not(not (s.attributes["ORGANISM"].value).encode('ascii','ignore')):
            node1_type = "ConceptNode"
            node2_type = "ConceptNode"
            PredicateNode = "organism"
	    evaLink(PredicateNode ,(s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\') ,node1_type, (s.attributes["ORGANISM"].value).encode('ascii','ignore').replace('\\', '\\\\'), node2_type)

	if  not(not (s.attributes["HISTORICAL_NAMES"].value).encode('ascii','ignore')):
	    node1_type = "ConceptNode"
            node2_type = "WordNode"
	    PredicateNode = "historical_name_of"
            evaLink(PredicateNode, (s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\'),node1_type,(s.attributes["HISTORICAL_NAMES"].value).encode('ascii','ignore').replace('\\', '\\\\'), node2_type )

	if  not(not (s.attributes["MEMBERS_SYMBOLIZED"].value).encode('ascii','ignore')):
	    for memebers in [x.strip() for x in ((s.attributes["MEMBERS_SYMBOLIZED"].value).encode('ascii','ignore')).split(',')]:
		memLink(memebers, (s.attributes["STANDARD_NAME"].value).encode('ascii','ignore').replace('\\', '\\\\'))
        count = count + 1
        #if count % 27 == 0:
	 #f.write("(set! count (count-all))\n")
	 #f.write("(display count)\n")
	 #f.write("(display message)\n")
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
