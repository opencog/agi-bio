#!/usr/bin/env python2.7

# Go Annotation to atomspace representation in scheme
# Requires: file gene_association.goa_ref_human.gz from http://geneontology.org/gene-associations/gene_association.goa_ref_human.gz


f = open('goa_human.gaf')
lines = f.readlines()
line_no = []

with open('goa_human.gaf') as  f:  
 for num, line in enumerate(f , 1):
  if "UniProtKB" in line :
      line_no.append(num)

lines_annotate = lines[line_no[0] -1 : len(lines)]

###### function to write on file

def memberLink(gene, goID, qualifier):
    if qualifier == 'NOT':
        f_annotation.write("(MemberLink (stv 0.0 1.0)\n")
    else:
        f_annotation.write("(MemberLink\n")
    f_annotation.write("\t(GeneNode \"" + gene + "\")\n")
    f_annotation.write("\t(ConceptNode \"GO:" + goID + "\"))\n")

# previous representation with evaluation link
# using memberlink representation above now instead
def evaLink(node1 , node2, qualifier):
    if qualifier == 'NOT' :
	f_annotation.write("(EvaluationLink (stv 0.0 0.0)\n")
    else :
    	f_annotation.write("(EvaluationLink \n")
    f_annotation.write("\t (PredicateNode \""+ "annotation"+ "\")\n")
    f_annotation.write("\t (ListLink \n")
    f_annotation.write("\t\t (GeneNode"  + " \"" + node1 + "\")\n")
    f_annotation.write("\t\t (ConceptNode" + " \"GO:" + node2 + "\")\n")
    f_annotation.write("\t )\n")
    f_annotation.write(")\n\n")


#open file to write
f_annotation = open('GO_annotation.scm', 'a')

#add GOC Validation Date
f_annotation.write(";"+((lines[0]).split('!')[1]).split('$')[0]+ "\n")
f_annotation.write(";"+((lines[1]).split('!')[1]).split('$')[0]+ "\n\n")

#loop through lines
for l in lines_annotate:
    db_object_symbol =l.split('\t')[2]
    go_id = (l.split('\t')[4]).split(':')[1]
    qualifier = l.split('\t')[3]
    memberLink(db_object_symbol,go_id,qualifier)
    #evaLink(db_object_symbol,go_id, qualifier)

#close files
f.close()
f_annotation.close()
