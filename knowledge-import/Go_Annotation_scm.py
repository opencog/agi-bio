#!/usr/bin/env python2.7

# Go Annotation to atomspace representation in scheme  
# Requires: file gene_association.goa_ref_human.gz from http://geneontology.org/gene-associations/gene_association.goa_ref_human.gz


f = open('gene_association.goa_ref_human')
lines = f.readlines()
line_no = []

with open('gene_association.goa_ref_human') as  f:  
 for num, line in enumerate(f , 1):
  if "UniProtKB" in line :
      line_no.append(num)

lines_annotate = lines[line_no[0] -1 : len(lines)]

###### function to write on file

def evaLink(node1 , node2, qualifier):
    if qualifier == 'NOT' :
	f_annotation.write("(EvaluationLink (stv 0.0 0.0)\n")
    else :
    	f_annotation.write("(EvaluationLink \n")
    f_annotation.write("\t (PredicateNode \""+ "annotation"+ "\")\n")
    f_annotation.write("\t (ListLink \n")
    f_annotation.write("\t\t (GeneNode"  + " \"" + node1 + "\")\n")
    f_annotation.write("\t\t (ConceptNode" + " \"" + node2 + "\")\n")
    f_annotation.write("\t )\n")
    f_annotation.write(")\n\n")


#open file to write 
f_annotation = open('GO_annotation.scm', 'a')

#add GOC Validation Date 
f_annotation.write(";"+((lines[0]).split('!')[1]).split('$')[0]+ "\n")
f_annotation.write(";"+((lines[1]).split('!')[1]).split('$')[0]+ "\n\n")
#f_annotation.write("(clear)\n")
f_annotation.write("(define count (count-all))\n")
f_annotation.write("(define message (string-append \" Atoms loaded \" \"\\n\"))\n")
f_annotation.write("(display count)\n")
f_annotation.write("(display message)\n")

#loop through lines 
f_annotation.write("(define start_time (current-time))\n")
for l in lines_annotate:
    db_object_symbol =l.split('\t')[2]
    go_id = (l.split('\t')[4]).split(':')[1]
    qualifier = l.split('\t')[3]
    evaLink(db_object_symbol,go_id, qualifier)
    

f_annotation.write("(define end_time (current-time))\n")
f_annotation.write("(define elapsed_time (round (/ (- end_time start_time) 60.0)))\n")
#f_annotation.write("(define elapsed_time  (/ (- end_time start_time) 60.0))\n")

f_annotation.write("(set! count (count-all))\n")
f_annotation.write("(display count)\n")
f_annotation.write("(display message)\n")

f_annotation.write("(display \"Atom loading End in ..\")\n")
f_annotation.write("(display elapsed_time)\n")
f_annotation.write("(display \" minutes\\n\")\n")


#close files
f.close()
f_annotation.close()





















