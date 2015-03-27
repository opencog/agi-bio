"""
Relationship mining functionality for the opencog bio project: https://github.com/opencog/agi-bio

Requires that the following KB scheme files have been loaded in to the atomspace:
    agi-bio/knowledge-import/scheme/GO_new.scm'
    agi-bio/knowledge-import/scheme/GO_annotation.scm'

Usage:
Make sure this file is somewhere the cogserver can find it: http://wiki.opencog.org/w/Python#MindAgents_in_Python

opencog> loadpy bio
  No subclasses of opencog.cogserver.MindAgent found.
  Python Requests found: SubsetMinersubset_miner.
opencog> bio.subset-miner

Code cleanup and documentation to come ...
"""

__author__ = 'eddie'

import opencog.cogserver
from opencog.atomspace import AtomSpace, TruthValue, types, get_type_name, is_defined, add_type
from opencog.scheme_wrapper import load_scm, scheme_eval, scheme_eval_h, __init__
from opencog.bindlink import bindlink

import numpy as np
import pickle
import time
import os
os.system('export GUILE_AUTO_COMPILE=0')

SMALL_RUN = False
SMALL_RUN = True

V = VERBOSE = False
T = TIME = True

DEFAULT_TV_COUNT = 1000

SUBSET_LINK_TV_STRENGTH_CUTOFF = .5  # within interval (0,1
IMPORTANCE_SCORE_PERCENTILE_CUTOFF = .5  # within interval (0,1)



if SMALL_RUN:
    SUBSET_LINK_TV_STRENGTH_CUTOFF = 0

if SMALL_RUN:
    SET_MEMBERS_FILE = 'set_members_small.txt'
    SUBSET_VALUES_FILE = 'subset_values_small.txt'
    SUBSET_VALUES_PICKLE_FILE = 'subset_values_pickle_small.p'
    SUBSET_SCHEME_FILE = 'subset_relationships_small.scm'

else:
    SET_MEMBERS_FILE = 'set_members.txt'
    SUBSET_VALUES_FILE = 'subset_values.txt'
    SUBSET_VALUES_PICKLE_FILE = 'subset_values_pickle.p'
    SUBSET_SCHEME_FILE = 'subset_relationships.scm'


if SMALL_RUN:
    kb_files = [
        '/home/opencog/agi-bio/knowledge-import/scheme/GO_1K.scm'
        ,'/home/opencog/agi-bio/knowledge-import/scheme/GO_ann1K.scm'
    ]
else:
    kb_files = (
        '/home/opencog/agi-bio/knowledge-import/scheme/GO_new.scm'
        ,'/home/opencog/agi-bio/knowledge-import/scheme/GO_annotation.scm'
    )

scheme_files = ['opencog/atomspace/core_types.scm',
                'opencog/scm/utilities.scm'

                ,'bioscience/types/bioscience_types.scm'

                ,'/home/opencog/agi-bio/eddie/bio_scheme.scm'
                ]

scheme_files.extend(kb_files)


class subset_miner(opencog.cogserver.Request):

    def run(self,args,atomspace):
        print 'received request SubsetMiner ' + str(args)
        bio = Bio(atomspace)
        bio.atomspace = bio.a = atomspace

        if args:
            if args[0]=='test':
                bio.atomspace.clear()

                bio.a.add_node(types.ConceptNode, "yippers!")

            elif args[0]=='generate_subsets_from_pickle':
                bio.unpickle_subset_values()
                bio.create_subset_links()

            elif args[0]=='run':
                bio.do_full_mining(args)

            else:
                print args[0] + ' command not found'

        else:
            bio.do_full_mining(args)


# this is a just convenience class to create a cogserver command in a format consistent with the other commands
# class subset_miner(SubsetMiner):
#     pass


class Bio:

    def __init__(self,atomspace=None):
        if not atomspace:
            atomspace = AtomSpace()
        self.a = self.atomspace = atomspace
        __init__(self.atomspace)

        '''
        In order to run this outside of the cogserver, the below required adding the add_type python binding in cython,
        which i have not yet requested to be pulled to the project repo.
        See https://github.com/opencog/agi-bio/tree/master/bioscience for instructions on how to add the custom bio
        atom types and use config to load when the cogserver starts up
        '''
        if not is_defined('GeneNode'):
            types.GeneNode = add_type(types.ConceptNode,'GeneNode')
        if not is_defined('ProteinNode'):
            types.ProteinNode = add_type(types.ConceptNode,'ProteinNode')

        # geneset members cache
        self.set_members_dict = {}

        # member genesets cache
        self.member_sets_dict = {}

        # subset relationship truth value dictionary cache
        self.subset_values = {}

        # dict of importance score for a generated relationship link
        self.relationship_importance_score = {}

        self.scheme_loaded = False

    def do_full_mining(self,args=None):
        print "Initiate bio.py mining"

        # self.load_scheme()

        print "Initial number of atoms in atomsapce: " + str(self.a.size())

        self.populate_genesets_with_descendent_members()

        self.calc_geneset_subset_truth_values()

        self.create_subset_links()

        self.pickle_subset_valuesv()

        print "Completed bio relationship mining."


    def get_GO_nodes(self):
        # save nodes as handles or node objects?

        goterms = scheme_eval_list(self.atomspace,'(cog-bind pattern_match_go_terms)')
        # goterms = scheme_eval_h(self.atomspace,'(cog-bind pattern_match_go_terms)')
        # goterms = self.atomspace[goterms].out

        # print "\nGO nodes: "
        # print self.goterms
        self.goterms = goterms #probably can remove this but helpful for debugging
        return goterms

    def load_scheme(self):
        print "Loading scheme files"
        if T:
            start = time.clock()
        for item in scheme_files:
            print "  Loading scheme file: " + item
            if not load_scm(self.atomspace, item):
                print "***  Error loading scheme file: " + item + "  ***"

        self.scheme_load_time = int(time.clock() - start)
        print 'Scheme file loading completed in ' + str(self.scheme_load_time) + " seconds\n"

        self.scheme_loaded = True



    def populate_genesets_with_descendent_members(self):
        print "Populating gene sets with descendent members"
        start = time.clock()
        self.go_term_node = self.a.get_atoms_by_name(types.ConceptNode,'GO_term')[0]
        # print self.go_term_node

        go_terms = set(self.get_GO_nodes())

        unprocessed_sets = go_terms
        #print goterms
        print "number of gene sets: " + str(len(unprocessed_sets))

        while len(unprocessed_sets) > 0:
            geneset = unprocessed_sets.pop()
            if V:
                print "\n=== Popped " + geneset.name + " from unprocessed list ==="

            self.add_members_from_children(geneset,unprocessed_sets)

        self.populate_time = int(time.clock() - start)
        print "Completed populating sets with descendent members in " + str(self.populate_time) + " seconds\n"



    def add_members_from_children(self,geneset,unprocessed_sets):
        if V:
            print "\nAdding members from children for " + geneset.name
        children = scheme_eval_list(self.a,'(get_inheritance_child_nodes "' + geneset.name + '")')
        if self.go_term_node in children:
            children.remove(self.go_term_node)
        #print "children: "
        #print children

        if len(children) == 0:
            if V:
                print "no kids for " + geneset.name
                print geneset.name + " members: "; print sorted_atom_names(self.get_members_of(geneset))
            return

        members = self.get_members_of(geneset)
        if V:
            print "pre-members "+geneset.name+": "; print sorted_atom_names(members)
            print "\n" + geneset.name + " children categories: " + sorted_atom_names(children)  #" ".join([child.name for child in children])

        for child in children:
            if V:
                "print unioning members of child " + child.name
            child_members = self.get_members_of(child)

            if child not in unprocessed_sets:
                self.add_members_from_children(child,unprocessed_sets)
            else:
                if V:
                    print "child " + child.name + " had already been processed"
                    print child.name + " members: "; print sorted_atom_names(child_members) #" ".join([member.name for member in child_members])
            # print "members for child " + child.name + ": "
            # print child_members
            members = members.union(child_members)

        self.set_members_dict[geneset] = members
        if V:
            print "\npost members " + geneset.name + ":"; print sorted_atom_names(members)

    def get_members_of(self,geneset):
        #cache members of geneset
        if geneset not in self.set_members_dict:
            bindlink_query = \
                '''
                (BindLink
                    (VariableNode "$member")
                    (ImplicationLink
                        (MemberLink
                            (VariableNode "$member")
                            (ConceptNode {0}))
                        (VariableNode "$member")))
            '''.format('"'+geneset.name+'"')
            bindlink_h = scheme_eval_h(self.atomspace, bindlink_query)
            results_h = bindlink(self.a,bindlink_h)
            genes = self.set_members_dict[geneset] = set(atoms_in_listlink_h(self.a,results_h))

            # or, using scheme (cog-bind) method
            #self.set_members_dict[geneset] = set(scheme_eval_list(self.a,'(get_members_of "' + geneset.name + '")'))
        else:
            genes = self.set_members_dict[geneset]
        return genes



    def persist_set_members(self):
        # import pickle
        # #pickle.dump(self.set_members_dict,open('set_members.txt','wb'),protocol=-1)
        # pickle.dump(self.set_members_dict,open('set_members.txt','wb'))

        import json
        # f = open('set_members.json','wb')
        # f2 = open('set_members_2.json','wb')
        with open(SET_MEMBERS_FILE,'wb') as f:
            # jsonDict = {}
            i = 0
            for key in self.set_members_dict:
                # jsonDict[key.name] = list(self.set_members_dict[key])
                f.write(key.name + ":\n" + " ".join([gene.name for gene in self.set_members_dict[key]]) + "\n\n")



                if i < 20:
                    print key.name + "\n" + ' '.join([gene.name for gene in self.set_members_dict[key]]) + "\n\n"
                    i = i+1


        # json.dump(jsonDict,f2) # TypeError: set([]) is not JSON serializable  and TypeError: (GeneNode ... is not JSON serializable
        # f2.close()
        # f.write(json.dumps(jsonDict))  #TypeError: set([]) is not JSON serializable
        # f.close()


    def get_total_number_of_GeneNodes(self):
        # if not hasattr()
        num = len(self.a.get_atoms_by_type(types.GeneNode))
        print "Total number of genes: " + str(num)
        return num


    def calc_geneset_subset_truth_values(self):
        print "Calculating gene category subset truth values"
        start = time.clock()
        goterms = self.get_GO_nodes()
        num_sets = len(goterms)
        total_num_genes = float(self.get_total_number_of_GeneNodes())
        i = 0
        for setA in goterms:
            # print "\n===== getting genes for " + setA.name
            genesA = self.set_members_dict.get(setA)
            if genesA:
                for gene in genesA:
                    # print "\nprocessing " + gene.name + ". getting related genesets"
                    related_genesets = self.get_genesets_for_gene(gene)
                    # print "related genesets: " + " ".join([set.name for set in related_genesets])
                    for setB in related_genesets:
                        if setA==setB:
                            pass
                        set_pair = (setA,setB)
                        if set_pair not in self.subset_values:
                            # print "calculating values for: " + set_pair
                            genesB = self.get_members_of(setB)
                            intersectionAB = genesA.intersection(genesB)
                            numA = len(genesA)
                            numB = len(genesB)
                            numAiB = float(len(intersectionAB))
                            subAB_strength = numAiB/numA
                            subBA_strength = numAiB/numB


                            if subAB_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF \
                                    or subBA_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                # calc importance as P(A|B)/P(A)-1  (iow, [P(A|B)-P(A)] / P(A) )
                                # importance is same for subset A B and subset B A so only need to calc once
                                importance = subBA_strength/(numA/total_num_genes) - 1

                                # pa = numA/total_num_genes
                                # print pa

                                # for debugging:
                                # print setA.name + ' size: ' + str(numA) + '    total N: ' + str(int(total_num_genes)) \
                                #     + '     P(A): ' + str(numA/total_num_genes)
                                # print "importance score: " + str(importance) + "\n"

                            if subAB_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                self.subset_values[(setA,setB)] = subAB_strength
                                self.relationship_importance_score[(setA,setB)] = importance


                            if subBA_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                self.subset_values[(setB,setA)] = subBA_strength
                                self.relationship_importance_score[(setB,setA)] = importance

                        #else:
                            # print set_pair + " has already been processed"

            i = i+1
            if i % 100==0:
                timing = int((time.clock() - start) / 60)
                if timing != 0:
                    set_per_min = i / timing
                    remaining_sets = num_sets - i
                    remaining_time = remaining_sets / set_per_min
                    # total_est = num_sets / set_per_min
                    total_est = timing + remaining_time
                else:
                    total_est = 'thinking about it...'
                print "processed " + str(i) + ' sets of ' + str(num_sets) + ' in ' + str(timing) + ' minutes.' \
                      + ' Total estimated: ' + str(total_est) + ' minutes'
                      # + ' Estimated remaining: ' + str(remaining_time) + ' minutes' \
                      # + '  (Total est: ' + str(timing+remaining_time)


            # timing = int(time.clock()-start)
            # print "\nprocessed " + str(i) + ' sets of ' + str(num_sets) + ' in ' + str(timing) + ' seconds'


        self.subset_time = int(time.clock() - start)
        print 'Gene category Subset truth values completed in ' + str(self.subset_time) + " seconds"
        print 'Created {:,} subset relationships.'.format(len(self.subset_values))
        print "\nSubset value percentiles: " + str(np.percentile(self.subset_values.values(),range(10,100,10))) + "\n"
        print "Subset importance score percentile: {0}\n".format(
            [int(x) for x in np.percentile(self.relationship_importance_score.values(),range(10,100,10))])

        # perist results to file
        f = open(SUBSET_VALUES_FILE,'wb')
        i = 0
        for key in self.subset_values:
            name1, name2 = [node.name for node in key]
            f.write(name1+'-'+name2 + ' ' + str(self.subset_values[key]) + ' ' + \
                    str(int(self.relationship_importance_score[key])) + "\n")

            # print the first N to console
            # if i < 10:
            #     print 'Subset ' + str(key) + ": " + str(self.subset_values[key]) + "\n"
            #     i = i+1
        f.close()


    def create_subset_links(self):
        num_subsets = len(self.subset_values)
        # print "relationship_importannce_scores.values(): {0}".format(self.relationship_importance_score.values())
        # print "importance score cuttoff percentile: {0}".format(IMPORTANCE_SCORE_PERCENTILE_CUTOFF)
        importance_cuttoff = np.percentile(self.relationship_importance_score.values(),IMPORTANCE_SCORE_PERCENTILE_CUTOFF*100)
        # print "importance cuttoff: {0}".format(importance_cuttoff)
        print "Creating subset links. Found " + str(num_subsets) + " new subset relationships."
        print "TV.strength cuttoff value: {0}".format(SUBSET_LINK_TV_STRENGTH_CUTOFF)
        print "Filtering found relationships with importance score cuttoff {0} ({1}th percentile)".format(
            importance_cuttoff,int(IMPORTANCE_SCORE_PERCENTILE_CUTOFF*100)
        )
        subset_relationships = []
        start = time.clock()
        i = 1
        created_count = 0
        for set_pair in self.subset_values:
            if i % 1000000==0:
                self.link_creation_time = int((time.clock()-start)/60)
                print "processed " + str(i) + ' subset relationships of ' + str(num_subsets) + ' in ' \
                      + str(self.link_creation_time) + ' minutes'
            importance_score = self.relationship_importance_score[set_pair]
            if importance_score < importance_cuttoff:
                continue
            setA, setB = set_pair
            ABstrength = self.subset_values[set_pair]
            tv = TruthValue(ABstrength,DEFAULT_TV_COUNT)
            link = self.a.add_link(types.SubsetLink,(setA,setB),tv)
            subset_relationships.append(link)

            created_count = created_count + 1
            i = i+1

        self.link_creation_time = int(time.clock()-start)
        print "completed creating subsets in " + str(self.link_creation_time) + " seconds"
        print "{0} SubSet relationships created".format(created_count)

        # write to scheme file:
        f = open(SUBSET_SCHEME_FILE,'wb')
        for link in subset_relationships:
            f.write(str(link)+"\n")
        f.close()



    def get_genesets_for_gene(self,gene):
        if gene in self.member_sets_dict:
            genesets = self.member_sets_dict[gene]
        else:
            genesets = self.member_sets_dict[gene] = scheme_eval_list(self.a,'(get_sets_for_member "' + gene.name + '")')
        if V:
            print "genesets for gene " + gene.name + ": " + str(genesets)
        return genesets

    # atoms don't support pickling (yet), so converting key to string based on node names (key: node1-node2)
    def pickle_subset_valuesv(self):
        subset_valuesv2 = {}
        for set_pair in self.subset_values:
            name1,name2 = [node.name for node in set_pair]
            key = name1+'-'+name2
            subset_valuesv2[key] = self.subset_values[set_pair]

        pickle.dump(subset_valuesv2,open(SUBSET_VALUES_PICKLE_FILE,'wb'))

    def unpickle_subset_values(self):
        if not self.scheme_loaded:
            self.load_scheme()
        print "unpickling subset values..."
        start = time.clock()
        subset_values2 = pickle.load(open(SUBSET_VALUES_PICKLE_FILE,'rb'))
        end = time.clock()

        # print some out for a look
        # for i in range(10):
        #     key = subset_values2.keys()[i]
        #     print key + ' ' + str(subset_values2[key])

        print 'completed unpickling in ' + str(end-start) + ' seconds'

        print "converting to atom pair key format..."
        start = time.clock()
        subset_values = self.subset_values = {}
        for key in subset_values2:
            if subset_values2[key] >= SUBSET_LINK_TV_STRENGTH_CUTOFF:
                name1,name2 = key.split('-')
                n1 = self.a.get_atoms_by_name(types.ConceptNode,name1)[0]
                n2 = self.a.get_atoms_by_name(types.ConceptNode,name2)[0]
                subset_values[(n1,n2)] = subset_values2[key]

        print "converted to atom pair key format in " + str(time.clock()-start) + ' seconds'

        # print some out
        # for i in range(10):
        #     key = subset_values.keys()[i]
        #     print str(key) + ' ' + str(subset_values[key])






###### Utils ########
def scheme_eval_list(atomspace,scheme):
    results = scheme_eval_h(atomspace,scheme)
    return atomspace[results].out

def atoms_in_listlink_h(atomspace,h):
    return atomspace[h].out

def sorted_atom_names(atoms):
    return " ".join(sorted([gene.name for gene in atoms]))



################

# import pickle
# set_members = pickle.load(open('set_members.txt','rb'))
# keys = set_members.keys
# values = set_members.values
# for k in range(10):
#     print keys[k] + ": " + " ".join([gene.name for gene in set_members[keys[k]]])


if __name__=='__main__':

    bio = Bio()

    bio.do_full_mining()

    # bio.load_scheme()
    # print "number of atoms: " + str(bio.a.size())
    #
    #
    # bio.populate_genesets_with_descendent_members()
    #
    # bio.calc_geneset_subset_truth_values()
    #
    # bio.pickle_subset_valuesv2()

    # bio.unpickle_subset_values()


    # bio.create_subset_links()

    print "\n========================================================="
    print "final number of atoms in atomspace: " + str(bio.a.size())
    if hasattr(bio,'scheme_load_time'): print "loaded scheme files in " + str(bio.scheme_load_time) + " seconds"
    if hasattr(bio,'populate_time'): print "populated genesets with descendent members in " + str(bio.populate_time) \
                                           + " seconds"
    if hasattr(bio,'subset_time'): print "calculated subset truth values in " + str(bio.subset_time) + " seconds"
    if hasattr(bio,'link_creation_time'): print "completed creating subsets in " + str(bio.link_creation_time) + " seconds"

#bio.persist_set_members()


# bio.atomspace.print_list()



# goterms = scheme_eval(bio.atomspace,'(cog-bind pattern_match_go_terms)')
#print goterms

#print scheme_eval(bio.atomspace,'(get_members_of)')

#print scheme_eval(bio.atomspace,'(testing)')




# print "\nGO terms in processing set:"
# print bio.goterms

# print "(cog-prt-atomspace): ****************************"
# print scheme_eval(bio.atomspace,"(cog-prt-atomspace)")




# print "********************************* print_list(): ***************************************************************"
# bio.atomspace.print_list() # weird shit is happening with the output when i use this,
#                            # e.g., missing lines in subsequent output, weird formatting of Links









#a.print_list()

# a = scheme_eval(atomspace,'(+ 1 1)')
# print a
# b = scheme_eval_h(atomspace,'(+ 1 1)')
# print b


# print a.get_atoms_by_type(types.EvaluationLink)


# goterms = scheme_eval_h(atomspace,'(cog-bind pattern_match_go_terms)')
# goterms = a[goterms].out

# print "goterms type:"
# print type(goterms)
# print goterms




#a.print_list()

#print goterms.out

# str_res = scheme_eval(atomspace,'(cog-bind pattern_match_go_terms)')
#
# print result
# print
# print atomspace[result]
#
# print; print; print;
# print "string result: " + str_res

# print "atomspace.get_atoms_by_type: "
# print atomspace.get_atoms_by_type(types.ConceptNode)



