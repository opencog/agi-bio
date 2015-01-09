#from xml to scheme
#MSigDB 

from xml.dom import minidom
xmldoc = minidom.parse('msigdb_v4.0.xml')
genelist = xmldoc.getElementsByTagName('GENESET') 

fields = ["STANDARD_NAME", "HISTORICAL_NAMES","ORGANISM", "DESCRIPTION_BRIEF", "DESCRIPTION_FULL", "MEMBERS_SYMBOLIZED"]
f = open('MSigDB.scm', 'a')

f.write("(InheritanceLink \n")
f.write("\t (ConceptNode \""+ "MsigDB_GeneSet_v4.0"+ "\")\n")
f.write("\t (ConceptNode \"" + "MSigDB_GeneSet" + "\")\n")
f.write(")\n\n")


for s in genelist :
	if  not(not (genelist[1].attributes[fields[0]].value).encode('ascii','ignore')):
	    f.write("(InheritanceLink \n")
	    f.write("\t (ConceptNode \"" + "MSigDB_GeneSet: " +(s.attributes[fields[0]].value).encode('ascii','ignore') + "\")\n")
	    f.write("\t (ConceptNode \""+ "MsigDB_GeneSet_v4.0"+ "\")\n")
	    f.write(")\n\n")

	if  not(not (genelist[1].attributes[fields[2]].value).encode('ascii','ignore')):
	    f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + "organism_of" + "\"\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ (s.attributes[fields[0]].value).encode('ascii','ignore') + "\")\n")
	    f.write("\t\t(ConceptNode \"" + (s.attributes[fields[2]].value).encode('ascii','ignore') + "\"))\n")
	    f.write("\t )\n")
	    f.write(")\n\n")

	if  not(not (genelist[1].attributes[fields[1]].value).encode('ascii','ignore')):
	    f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + "historical_name_of" + "\"\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ (s.attributes[fields[0]].value).encode('ascii','ignore') + "\")\n")
	    f.write("\t\t(WordNode \"" + (s.attributes[fields[1]].value).encode('ascii','ignore') + "\"))\n")
	    f.write("\t )\n")
	    f.write(")\n\n")

	if  not(not (genelist[1].attributes[fields[3]].value).encode('ascii','ignore')):
	    f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + "brief_description_of" + "\"\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ (s.attributes[fields[0]].value).encode('ascii','ignore') + "\")\n")
	    f.write("\t\t(PhraseNode \"" + (s.attributes[fields[3]].value).encode('ascii','ignore') + "\"))\n")
	    f.write("\t )\n")
	    f.write(")\n\n")

	if  not(not (genelist[1].attributes[fields[4]].value).encode('ascii','ignore')):
	    f.write("(EvaluationLink \n")
	    f.write("\t (PredicateNode \"" + "full_description_of" + "\"\n")
	    f.write("\t (ListLink \n")
	    f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ (s.attributes[fields[0]].value).encode('ascii','ignore') + "\")\n")
	    f.write("\t\t(PhraseNode \"" + (s.attributes[fields[4]].value).encode('ascii','ignore') + "\"))\n")
	    f.write("\t )\n")
	    f.write(")\n\n")

	if  not(not (genelist[1].attributes[fields[5]].value).encode('ascii','ignore')):	    
	    for memebers in [x.strip() for x in ((s.attributes[fields[5]].value).encode('ascii','ignore')).split(',')]:
		f.write("(MemberLink \n")  
		f.write("\t\t(GeneNode \"" + memebers + "\")\n") 
		f.write("\t\t(ConceptNode \"" + "MSigDB_GeneSet: "+ (s.attributes[fields[0]].value).encode('ascii','ignore') + "\"))\n")


f.close()







