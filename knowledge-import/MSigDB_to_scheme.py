# Script to convert MSigDB to atomspace representation in scheme

# Requires: file msigdb_v4.0.xml, from: http://purl.obolibrary.org/obo/go.obo
# Outputs scheme file to use for atomspace import

from xml.dom import minidom
xmldoc = minidom.parse('msigdb_v4.0.xml')
genelist = xmldoc.getElementsByTagName('GENESET') 

fields = ["STANDARD_NAME", "HISTORICAL_NAMES","ORGANISM", "DESCRIPTION_BRIEF", "DESCRIPTION_FULL", "MEMBERS_SYMBOLIZED"]
f = open('MSigDB.scm', 'a')

f.write("(InheritanceLink \n")
f.write("\t (ConceptNode \""+ "MsigDB_GeneSet_v4.0"+ "\")\n")
f.write("\t (ConceptNode \"" + "MSigDB_GeneSet" + "\")\n")
f.write(")\n\n")

def inLink(node1 ,node2):
            f.write("(InheritanceLink \n")
	    f.write("\t (ConceptNode \"" + "MSigDB_GeneSet: "+ node1 + "\")\n")
	    f.write("\t (ConceptNode \""+ node2 + "\")\n")
	    f.write(")\n\n")
def evaLink(predicate , node1,node1_type, node2,node2_type):
            f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + predicate + "\"\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t("+node1_type+" \"" + "MSigDB_GeneSet: "+ node1 + "\")\n")
	    f.write("\t\t("+node2_type+" \"" + node2 + "\"))\n")
	    f.write("\t )\n")
	    f.write(")\n\n")
def memLink(members,geneset):
           f.write("(MemberLink \n")  
	   f.write("\t\t(GeneNode \"" + members + "\")\n") 
	   f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ geneset + "\"))\n")

#loop in genesets

for s in genelist :
    
	if  not(not (genelist[1].attributes[fields[0]].value).encode('ascii','ignore')):
	   
            inLink((s.attributes[fields[0]].value).encode('ascii','ignore') , "MsigDB_GeneSet_v4.0")

	if  not(not (genelist[1].attributes[fields[2]].value).encode('ascii','ignore')):
            node1_type = "ConceptNode"
            node2_type = "ConceptNode"   
            PredicateNode = "organism_of"
	    evaLink(PredicateNode ,(s.attributes[fields[0]].value).encode('ascii','ignore') ,node1_type, (s.attributes[fields[2]].value).encode('ascii','ignore'), node2_type)
	    
	if  not(not (genelist[1].attributes[fields[1]].value).encode('ascii','ignore')):
	    node1_type = "ConceptNode"
            node2_type = "WordNode"  
	    PredicateNode = "historical_name_of"
            evaLink(PredicateNode, (s.attributes[fields[0]].value).encode('ascii','ignore'),node1_type,(s.attributes[fields[1]].value).encode('ascii','ignore'), node2_type )
	   
	if  not(not (genelist[1].attributes[fields[3]].value).encode('ascii','ignore')):
            node1_type = "ConceptNode"
            node2_type = "PhraseNode"  
	    PredicateNode = "brief_description_of"
	    evaLink(PredicateNode,(s.attributes[fields[0]].value).encode('ascii','ignore'),node1_type,(s.attributes[fields[3]].value).encode('ascii','ignore'),node2_type)
	    

	if  not(not (genelist[1].attributes[fields[4]].value).encode('ascii','ignore')):
            node1_type = "ConceptNode"
            node2_type = "PhraseNode"   
	    PredicateNode = "full_description_of"
	    evaLink(PredicateNode, (s.attributes[fields[0]].value).encode('ascii','ignore'),node1_type,(s.attributes[fields[4]].value).encode('ascii','ignore'),node2_type)
	    
	if  not(not (genelist[1].attributes[fields[5]].value).encode('ascii','ignore')):	    
	    for memebers in [x.strip() for x in ((s.attributes[fields[5]].value).encode('ascii','ignore')).split(',')]:
		memLink(memebers, (s.attributes[fields[0]].value).encode('ascii','ignore'))

f.close()
