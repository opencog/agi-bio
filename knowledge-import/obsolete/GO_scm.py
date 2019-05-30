#!/usr/bin/env python2.7
# 2017-12-03
# Script to convert go.obo to atomspace representation in scheme
# Requires: file go.obo from http://www.berkeleybop.org/ontologies/go.obo


f = open('go.obo')
lines = f.readlines()

# store line of number --- "[Terms]" and [Typedef]
line_no = []

with open('go.obo') as  f:
    for num, line in enumerate(f, 1):
        if "[Term]" in line or "[Typedef]" in line:
            line_no.append(num)

line_no.sort()
# print len(line_no)

# function to write on file
def inLink(node1 , node2):
    f_go.write("(InheritanceLink \n")
    f_go.write("\t (ConceptNode \"" + node1 + "\")\n")
    f_go.write("\t (ConceptNode \""+ node2 + "\")\n")
    f_go.write(")\n\n")
#
def evaLink(predicateName ,node1 , node2 , node1_type, node2_type):
    f_go.write("(EvaluationLink \n")
    f_go.write("\t (PredicateNode \"" + predicateName + "\")\n")
    f_go.write("\t (ListLink \n")
    f_go.write("\t\t (" + node1_type + " \"" + node1 + "\")\n")
    f_go.write("\t\t (" + node2_type + " \"" + node2 + "\")\n")
    f_go.write("\t )\n")
    f_go.write(")\n\n")
#
def go_term(idd):
    inLink(idd,"GO_term")

def go_name(idd, name):
    evaLink("GO_name", idd, name, "ConceptNode", "ConceptNode")

def go_namespace(idd, namespace):
    evaLink("GO_namespace", idd, namespace ,"ConceptNode", "ConceptNode")

def go_definition(idd, definition):
    evaLink("GO_definition", idd, definition ,"ConceptNode", "ConceptNode")
# def go_synonyms(idd,synonyms,synonym_type):
#     evaLink(("GO_synonym_" +synonym_type),idd ,synonyms, "ConceptNode", "ConceptNode")

def go_isa(idd, isa_id):
    inLink(idd, isa_id)
#
def go_altid(idd, alt_id):
    evaLink("GO_alt_id", idd, alt_id, "ConceptNode", "ConceptNode")

def go_relationship(idd,relate_id, relation_type):
    evaLink(("GO_" + relation_type), idd, relate_id, "ConceptNode" , "ConceptNode")

# open file to write
f_go = open('GO.scm', 'a')

# once for the whole DB

# inLink("GO_synonym_EXACT","GO_synonym")
# inLink("GO_synonym_BROAD","GO_synonym")
# inLink("GO_synonym_NARROW","GO_synonym")
# inLink("GO_synonym_RELATED","GO_synonym")
#
i = 0
# partition each line and call functions
while i < len(line_no):
    if i + 1 == len(line_no):
        part = lines[line_no[i] : len(lines)]
    else:
        part = lines[line_no[i] : line_no[i+1] - 1]
    test = [l.partition(':') for l in part]
    k = 0
    rel_typeno = 0
#    synonym = []
#    synonym_type = []
    is_a = []
    alt_id =[]
    relationship = []
    relationship_type= []
    idd =""
    name= ""
    namespace=""
    obsolete =""
    while k < len(test):
        if (test[k][0] == 'is_obsolete'):
            obsolete = (test[k][2].partition('\n')[0]).partition(' ')[2].replace('\\', '\\\\')
        elif (test[k][0] == 'id'):
            idd = (test[k][2].partition('\n')[0]).partition(' ')[2].replace('\\', '\\\\')
        elif (test[k][0] == 'name'):
            name = (test[k][2].partition('\n')[0]).partition(' ')[2].replace('\\', '\\\\')
        elif (test[k][0] == 'namespace'):
            namespace = (test[k][2].partition('\n')[0]).partition(' ')[2].replace('\\', '\\\\')
        elif(test[k][0] == 'def'):
            definition = (test[k][2].partition('\n')[0]).partition(' ')[2].split('"',2)[1].replace('\\', '\\\\')
        # elif (test[k][0] == 'synonym'):
        #     synonym.append(((test[k][2].partition('\n')[0]).partition(' ')[2]).split('"',2)[1].replace('\\', '\\\\').strip())
        #     synonym_type.append((((test[k][2].split('"',2))[2].partition('[]')[0]).partition(" ")[2]).partition(" ")[0].replace('\\', '\\\\'))
        elif (test[k][0] == 'alt_id'):
            alt_id.append((test[k][2].partition('\n')[0]).partition(' ')[2].replace('\\', '\\\\'))
        elif (test[k][0] == 'relationship'):
            relationship_type.append((((test[k][2].partition('\n')[0]).partition('GO')[0]).split(' ')[1]).replace('\\', '\\\\'))
            while rel_typeno < len(relationship_type):
                relationship.append((((test[k][2].partition('\n')[0]).partition(relationship_type[rel_typeno])[2]).partition('!')[0]).partition(' ')[2].replace('\\', '\\\\').strip())
                rel_typeno = rel_typeno + 1
        elif (test[k][0] == 'is_a'):
            is_a.append(((test[k][2].partition('\n')[0]).partition('!')[0]).partition(' ')[2].replace('\\', '\\\\').strip())

        k = k +1
    if (obsolete != 'true'):
        go_term(idd)
        go_name(idd, name)
        go_namespace(idd, namespace)
        go_definition(idd, definition)
        # if len(synonym) != 0:
        #     sy_len = 0
        #     while sy_len < len(synonym):
        #         go_synonyms(idd, synonym[sy_len], synonym_type[sy_len])
        #         sy_len = sy_len + 1
        if len(is_a) != 0:
            isa_len = 0
            while isa_len < len(is_a):
                go_isa(idd, is_a[isa_len])
                isa_len = isa_len + 1
        # if len(alt_id) != 0:
        #     altid_len = 0
        #     while altid_len < len(alt_id):
        #         go_altid(idd, alt_id[altid_len])
        #         altid_len = altid_len + 1
        if len(relationship) != 0:
            parts_len = 0
            while parts_len < len(relationship):
                go_relationship(idd, relationship[parts_len], relationship_type[parts_len])
                parts_len = parts_len + 1
    i= i + 1
f_go.close()
