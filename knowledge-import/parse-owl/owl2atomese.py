import sys
from pronto import Ontology


def to_atomese(owlfile):
    onto = Ontology(owlfile)
    with open(owlfile.split('.')[0] +'.scm', 'w') as output:
        import_terms(onto, output)
        output.write(import_meta(onto, owlfile.split('.')[0]))

def import_meta(onto, name):
    meta = "(ListLink \n"
    for k in onto.meta.keys():
        if str(','.join(onto.meta[k])):
            meta = meta + '(ConceptNode "'+ k +': ' + str(','.join(onto.meta[k])) +'")\n'
    return eva('has_metadata', '(ConceptNode "'+ name +'")', meta + ')\n')

def import_terms(onto, output):
    try:
        for term in onto.terms:
                output.write(eva("has_name", add_term_type(onto[term].id), add_term_type(onto[term].name)))
                output.write(eva("has_description", add_term_type(onto[term].id), add_term_type(str(onto[term].desc))))
                for r in onto[term].relations.keys():
                        if r.direction is 'bottomup':
                                output.write(''.join([inherit(add_term_type(onto[term].id), add_term_type(i.id)) for i in onto[term].relations[r]]))
                        elif r.direction is 'topdown':
                                output.write(''.join([inherit(add_term_type(i.id), add_term_type(onto[term].id)) for i in onto[term].relations[r]])) 
                for k in onto[term].other.keys():
                        output.write(''.join([eva(k, add_term_type(onto[term].id), add_term_type(i)) for i in onto[term].other[k]]))
                for s in onto[term].synonyms:
                        output.write(eva("has_synonyms", add_term_type(onto[term].id), add_term_type(str(s))))
    except AttributeError:
            print(term)

def add_term_type(term):
    if 'http' in term:
        term = remove_hyperlink(term)
    if '"' in term:
        term = term.replace('"', '')
    if term:
        if 'CHEBI' in term:
                return '(MoleculeNode "'+ str(term) +'")'
        else:
                return '(ConceptNode "'+ str(term) +'")'   
    else:
            return str(term)

def eva(predicate, node1, node2):
        if node1 and node2:
                if predicate == 'is_a' or predicate == 'is-a':
                        return inherit(node1, node2)
                elif predicate == 'id':
                        return ""
                else:
                        return '(EvaluationLink \n (PredicateNode "' + predicate + '")\n' + '(ListLink \n' + node1 + '\n' + node2 + '))\n\n' 
        else:
                return ""
def inherit(parent, child):
        if parent and child:
                return '(InheritanceLink \n' + child + '\n' + parent + ')\n\n' 
        else:
                return ""  

def remove_hyperlink(term):
        term = term.split('/')[-1]
        return term.replace('_', ':')

if __name__ == "__main__":
	to_atomese(sys.argv[1])
