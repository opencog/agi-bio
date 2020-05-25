"""
Relationship mining functionality for the opencog bio project:
https://github.com/opencog/agi-bio

Requires that the following KB scheme files have been loaded into the atomspace:
    agi-bio/knowledge-import/scheme/GO_new.scm'
    agi-bio/knowledge-import/scheme/GO_annotation.scm'

Usage:
Add this directory to your PYTHONPATH
or otherwise make sure this file is somewhere the cogserver can find it:
http://wiki.opencog.org/w/Python#MindAgents_in_Python

opencog> loadpy bio
  No subclasses of opencog.cogserver.MindAgent found.
  Python Requests found: miner

# to load default scheme init and knowledge base files
opencog> bio.miner load_scheme

# to run the miner
opencog> bio.miner run

Code cleanup and documentation to come ...
"""

# TODO: proper logging
# TODO: code cleanup and documentation
# TODO: tv certainty vs count
# TODO: failure recovery (e.g., when GO not loaded in atomspace)
# TODO: help documentation (e.g., for cogserver command)

__author__ = 'eddie'

import opencog.cogserver
from opencog.atomspace import AtomSpace, TruthValue, types, get_type_name # , \
    #is_defined, add_type
from opencog.scheme_wrapper import load_scm, scheme_eval, scheme_eval_h, \
    __init__
from opencog.bindlink import bindlink

from utilities import load_scheme_files
import subgraph

import reasoner
reload(reasoner)
from reasoner import Reasoner


import numpy as np
import pickle
import time
import os

os.system('export GUILE_AUTO_COMPILE=0')

SMALL_RUN = False
# SMALL_RUN = True


V = VERBOSE = False
T = TIME = True

DEFAULT_TV_COUNT = 1000

SUBSET_LINK_TV_STRENGTH_CUTOFF = .5  # within interval (0,1
IMPORTANCE_SCORE_PERCENTILE_CUTOFF = .5  # within interval (0,1)

KB_SCHEME_DIR = '../agi-bio/scheme-representation/'

if SMALL_RUN:
    SUBSET_LINK_TV_STRENGTH_CUTOFF = 0
    IMPORTANCE_SCORE_PERCENTILE_CUTOFF = 0


if SMALL_RUN:
    GO_FILE = 'GO_1K.scm'
    GO_ANN_FILE = 'GO_annotation.scm'
    GO_ANN_FILE = 'GO_ann_1K.scm'

    SET_MEMBERS_FILE = 'set_members_small.txt'
    SUBSET_VALUES_FILE = 'subset_values_small.txt'
    SUBSET_VALUES_PICKLE_FILE = 'subset_values_pickle_small.p'
    SUBSET_SCHEME_FILE = 'subset_relationships_small.scm'

else:
    GO_FILE = 'GO.scm'
    GO_ANN_FILE = 'GO_annotation.scm'
    # GO_ANN_FILE = 'GO_ann_1.scm'

    SET_MEMBERS_FILE = 'set_members.txt'
    SUBSET_VALUES_FILE = 'subset_values.txt'
    SUBSET_VALUES_PICKLE_FILE = 'subset_values_pickle.p'
    SUBSET_SCHEME_FILE = 'subset_relationships.scm'

SCHEME_INIT_FILES = ['opencog/atomspace/core_types.scm',
                     'opencog/scm/utilities.scm',
                     'bioscience/types/bioscience_types.scm',
                     '../agi-bio/relationship_mining/bio_scheme.scm'
                    ]

KB_FILES = [
            KB_SCHEME_DIR + GO_FILE
            , KB_SCHEME_DIR + GO_ANN_FILE
]


class miner(opencog.cogserver.Request):
    def run(self, args, atomspace):
        print 'received request miner ' + str(args)
        bio = Bio(atomspace)
        bio.atomspace = bio.a = atomspace

        if args:
            arg = args[0]
            print "arg: {0}".format(arg)

            if arg == 'clear':
                bio.atomspace.clear()

            elif arg == 'run':   # default
                bio.do_full_mining(args)

            elif arg == 'load_scheme':
                bio.load_scheme()

            elif arg == 'create_subgraph':
                if len(args) > 1:
                    bio.create_connected_subgraph(args[1])
                else:
                    bio.create_connected_subgraph()

            elif arg == 'load_scheme_init':
                bio.load_scheme_init_files()

            elif arg == 'load_scheme_knowledge_files':
                bio.load_scheme_knowledge_files()

            elif args[0] == 'generate_subsets_from_pickle':
                bio.unpickle_subset_values()
                bio.create_subset_links()


            else:
                print args[0] + ' command not found'

        else:
            bio.do_full_mining(args)




class inference(opencog.cogserver.Request):
    def run(self, args, atomspace):
        print 'Received request inference ' + str(args)
        bio = Bio(atomspace)
        #bio.atomspace = bio.a = atomspace

        r = Reasoner(atomspace)
        r.do_one_steps(*args)


        # if args:
        #     arg = args[0]
        #     print "arg: {0}".format(arg)
        #
        #     if arg == 'clear':
        #         bio.atomspace.clear()
        #
        #     elif arg == 'run':   # default
        #         bio.do_full_mining(args)
        #
        #     elif arg == 'load_scheme':
        #         bio.load_scheme()
        #
        #     elif arg == 'create_subgraph':
        #         if len(args) > 1:
        #             bio.create_connected_subgraph(args[1])
        #         else:
        #             bio.create_connected_subgraph()
        #
        #     elif arg == 'load_scheme_init':
        #         bio.load_scheme_init_files()
        #
        #     elif arg == 'load_scheme_knowledge_files':
        #         bio.load_scheme_knowledge_files()
        #
        #     elif args[0] == 'generate_subsets_from_pickle':
        #         bio.unpickle_subset_values()
        #         bio.create_subset_links()
        #
        #
        #     else:
        #         print args[0] + ' command not found'
        #
        # else:
        #     bio.do_full_mining(args)




class Bio:
    def __init__(self, atomspace=None):
        if not atomspace:
            atomspace = AtomSpace()
        self.a = self.atomspace = atomspace
        #hmmmm.. is this needed? not sure where it came from
        __init__(self.atomspace)

        # To run this script outside of the cogserver required
        # adding the 'add_type' python binding in cython, which i have not yet
        # requested to be pulled to the project repo.
        # See https://github.com/opencog/agi-bio/tree/master/bioscience for
        # instructions on how to add the custom bio atom types and use config to
        # load when the cogserver starts up
        # if not is_defined('GeneNode'):
        #     types.GeneNode = add_type(types.ConceptNode, 'GeneNode')
        # if not is_defined('ProteinNode'):
        #     types.ProteinNode = add_type(types.ConceptNode, 'ProteinNode')

        # geneset (dicrect) members cache
        self.set_members_dict = {}

        # geneset members including descendents cache
        self.set_members_with_descendents_dict = {}

        # member genesets cache
        self.member_sets_dict = {}

        # subset relationship truth value dictionary cache
        self.subset_values = {}

        # dict of importance score for a generated relationship link
        self.relationship_importance_score = {}

        #dict of category ancestors
        self.category_ancestors = {}

        self.scheme_loaded = False

    def do_full_mining(self, args=None):
        print "Initiate bio.py mining"

        if not self.scheme_loaded:
            self.load_scheme()

        print "Initial number of atoms in atomsapce: {:,}".format(self.a.size())

        self.populate_genesets_with_descendent_members()
        self.persist_set_members_with_descendents()

        self.calc_probabilistic_subset_truth_values()

        self.create_subset_links()

        self.pickle_subset_valuesv()

        print "Completed bio relationship mining."


    def get_GO_nodes(self):
        # save nodes as handles or node objects?

        if not hasattr(self,'go_nodes'):

            go_term_node = self.get_go_term_node()

            # goterms = scheme_eval_list(self.atomspace,
            #                            '(cog-bind pattern_match_go_terms)')
            # print "cog-bind go terms: {0}".format(len(goterms))


            golinks = self.a.get_atoms_by_target_atom(types.InheritanceLink,go_term_node)
            goterms = set()
            for link in golinks:
                goterms.add(link.out[0])


            print "python go terms: {0}".format(len(goterms))

            # print "\nGO nodes: "
            # print self.goterms
            #self.goterms = goterms  #for debugging

            self.go_nodes = goterms

        return self.go_nodes

    def load_scheme(self):
        """
        Load initial scheme files into the atomspace.

        This is primarily for use when running the script standalone for
        testing,that is, without a pre-existing cogserver atomspace.
        """

        self.load_scheme_init_files()
        self.load_scheme_knowledge_files()

        # kb_files = KB_FILES
        #
        # scheme_files = SCHEME_INIT_FILES + kb_files
        # load_scheme_files(self.atomspace,scheme_files)
        self.scheme_loaded = True

    def load_scheme_init_files(self):
        load_scheme_files(self.atomspace,SCHEME_INIT_FILES,'scheme init files')

    def load_scheme_knowledge_files(self):
        load_scheme_files(self.atomspace,KB_FILES,'knowledge base files')


    def load_subset_rels_from_scheme(self,filepath=None):
        """
        Populates the atomspace with subset mining results saved to file from
        previous run of subset mining.

        :param filepath:
        :return:
        """
        if not filepath:
            filepath = SUBSET_SCHEME_FILE
        print "Loading subset relationships from {0}".format(filepath)
        start = time.clock()
        if not load_scm(self.atomspace,filepath):
            print "*** Error loading scheme file: {0}".format(filepath)
        else:
            print "Loaded subset relationships in {0} seconds".format(
                int(time.clock()-start)
            )

    def get_go_term_node(self):
        """
        Returns the atom (ConceptNode "GO_term")
        """
        if not hasattr(self,'go_term_node'):
            self.go_term_node = \
                self.a.get_atoms_by_name(types.ConceptNode, 'GO_term')[0]
        return self.go_term_node

    def populate_genesets_with_descendent_members(self):
        print "\nPopulating gene sets with descendent members"
        start = time.clock()
        self.go_term_node = self.get_go_term_node()
        # self.go_term_node = \
        #     self.a.get_atoms_by_name(types.ConceptNode, 'GO_term')[0]
        # print self.go_term_node

        go_terms = set(self.get_GO_nodes())

        # debugging code
        # whereru = self.a.get_atoms_by_name(types.ConceptNode,"GO:0016705")[0] #500K
        # print whereru
        # print "whereru in go_terms: {0}".format(whereru in go_terms)
        # links = self.a.get_atoms_by_target_atom(types.InheritanceLink,whereru)
        # print_atoms_in_list(links,'InheritanceLinks',whereru.name)
        # incoming = self.a.get_incoming(whereru.h)
        # print_atoms_in_list(incoming,'incoming',whereru.name)

        unprocessed_sets = go_terms
        # print goterms
        print "number of gene sets: {:,}".format(len(unprocessed_sets))

        # print (unprocessed_sets)

        # i = 0
        while len(unprocessed_sets) > 0:
            geneset = unprocessed_sets.pop()
            if V:
                print "\n=== Popped " + geneset.name + " from unprocessed list ==="

            self.add_members_from_children(geneset, unprocessed_sets)

            # i += 1
            # if i % 100 == 0:
            #     print "Unprocessed sets: {0}".format(len(unprocessed_sets))

        self.populate_time = int(time.clock() - start)
        print "Completed populating sets with descendent members in " \
              + str(self.populate_time) + " seconds"


    def get_inheritance_children_of(self,parent):
        # cache?
        inheritance_links = self.a.get_atoms_by_target_atom(types.InheritanceLink,parent)
        # print "\n\n==========================="
        # print_atoms_in_list(inheritance_links,'InheritanceLinks',parent.name)

        children = set()
        for link in inheritance_links:
            # don't add when the first item in link (child) is our parent argument
            child = link.out[0]
            if child != parent:
                children.add(child)

        # print "\n"
        # print_atoms_in_list(children,'children',parent.name)

        return children


    def add_members_from_children(self, geneset, unprocessed_sets):
        if V:
            print "\nAdding members from children for " + geneset.name

        children = self.get_inheritance_children_of(geneset)

        # if geneset.name == 'GO:0044804':
        #     print "**********  here we are"
        #     print str(geneset)


        # children = scheme_eval_list(self.a, '(get_inheritance_child_nodes "'
        #                             + geneset.name.strip() + '")')

        # if geneset.name != geneset.name.strip():
        #     print "*** found geneset with trailing space |{0}|".format(geneset.name)
        #
        #
        # if self.go_term_node in children:
        #     print "********* found a go term as a child of {0} !!! ********* ".format(
        #         geneset.name)
        #     children.remove(self.go_term_node)
        # print "children: "
        #print children

        # if len(children) == 0:
        #     if V:
        #         print "no kids for " + geneset.name
        #         print geneset.name + " members: ";
        #         print sorted_atom_names(self.get_members_of(geneset))
        #     return

        members = self.get_members_of(geneset)

        if V:
            print "pre-members " + geneset.name + ": ";
            print sorted_atom_names(members)
            print "\n" + geneset.name + " children categories: " \
                  + sorted_atom_names(
                children)  #" ".join([child.name for child in children])

        for child in children:
            if V:
                "print unioning members of child " + child.name
            child_members = self.get_members_of(child)

            if child not in unprocessed_sets:
                self.add_members_from_children(child, unprocessed_sets)
            else:
                if V:
                    print "child " + child.name + " had already been processed"
                    print child.name + " members: "
                    print sorted_atom_names(
                        child_members)  #" ".join([member.name for member in child_members])
            # print "members for child " + child.name + ": "
            # print child_members
            members = members.union(child_members)

        if V:
            print "\npost members " + geneset.name + ":";
            print sorted_atom_names(members)

        self.set_members_with_descendents_dict[geneset] = members


    def get_members_of(self,geneset):
        """
        Get (direct) members of a gene set--using python rather than pattern
        matcher (faster?).
        """
        if geneset not in self.set_members_dict:
            memberlinks = self.a.get_atoms_by_target_atom(types.MemberLink,geneset)
            # print "MemberLinks for {0}:".format(geneset.name)
            # for link in memberlinks:
            #     print link

            genes = set()
            for link in memberlinks:
                genes.add(link.out[0])
            # print_atoms_in_list(genes,'GeneNodes',geneset.name)
            self.set_members_dict[geneset] = genes

        return self.set_members_dict[geneset]


    def get_members_of_old(self, geneset):
        """
        deprecated: using python instead of pattern matcher now b/c it's faster
        """
        # cache members of geneset
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
            '''.format('"' + geneset.name.strip() + '"')
            bindlink_h = scheme_eval_h(self.atomspace, bindlink_query)
            results_h = bindlink(self.a, bindlink_h)
            genes = self.set_members_dict[geneset] \
                = set(atoms_in_listlink_h(self.a, results_h))

            # or, using scheme (cog-bind) method
            # self.set_members_dict[geneset] = set(scheme_eval_list(
            #     self.a,'(get_members_of "' + geneset.name + '")'))
        else:
            genes = self.set_members_dict[geneset]
        return genes



    def persist_set_members_with_descendents(self):
        print "Persisting set members to " + SET_MEMBERS_FILE

        # import pickle
        # #pickle.dump(self.set_members_dict,open('set_members.txt','wb'),protocol=-1)
        # pickle.dump(self.set_members_dict,open('set_members.txt','wb'))

        #import json
        # f = open('set_members.json','wb')
        # f2 = open('set_members_2.json','wb')
        with open(SET_MEMBERS_FILE, 'wb') as f:
            # jsonDict = {}
            i = 0
            for key in self.set_members_with_descendents_dict:
                # jsonDict[key.name] = list(self.set_members_dict[key])
                f.write(key.name + ":\n" + " ".join(
                    [gene.name for gene in
                     self.set_members_with_descendents_dict[key]]) + "\n\n")

                # if i < 20:
                #     print key.name + "\n" + ' '.join(
                #         [gene.name for gene in
                #          self.set_members_dict[key]]) + "\n\n"
                #     i = i + 1


                    # json.dump(jsonDict,f2) # TypeError: set([]) is not JSON serializable  and TypeError: (GeneNode ... is not JSON serializable
                    # f2.close()
                    # f.write(json.dumps(jsonDict))  #TypeError: set([]) is not JSON serializable
                    # f.close()


    def get_total_number_of_GeneNodes(self):
        num = len(self.a.get_atoms_by_type(types.GeneNode))
        print "Total number of genes: {:,}".format(num)
        return num


    def calc_probabilistic_subset_truth_values(self):
        """
        Caculates probabistic extensional inhereitance relationships based on
                set members

        Leaving in crisp ancestor-descendent relationships for now as though do
        seem to add a lot of extra links.
        # Excludes crisp ancestor-descendent category relationships since these
        # can be established through PLN inference
        """
        print "Calculating gene category subset truth values"
        start = time.clock()
        goterms = self.get_GO_nodes()
        num_sets = len(goterms)
        total_num_genes = float(self.get_total_number_of_GeneNodes())
        i = 0
        for setA in goterms:
            # print "\n===== getting genes for " + setA.name
            genesA = self.set_members_with_descendents_dict.get(setA)
            if genesA:
                for gene in genesA:
                    # print "\nprocessing " + gene.name + ". getting related genesets"
                    related_genesets = self.get_genesets_for_gene(gene)
                    # print "related genesets: " + " ".join([set.name for set in related_genesets])

                    for setB in related_genesets:
                        # Leaving in ancestor relationships for now since they
                        # don't seem to add a lot of extra links
                        # Check to see they are the same set or if one set is an
                        # ancestor of the other
                        if (
                            setA == setB
                            #         or
                            # setA in self.get_category_ancestors(setB) or
                            # setB in self.get_category_ancestors(setA)
                        ):
                            continue

                        set_pair = (setA, setB)
                        if set_pair not in self.subset_values:
                            # print "calculating values for: " + set_pair
                            genesB = self.set_members_with_descendents_dict[setB]
                            intersectionAB = genesA.intersection(genesB)
                            numA = len(genesA)
                            numB = len(genesB)
                            numAiB = float(len(intersectionAB))
                            subAB_strength = numAiB / numA
                            subBA_strength = numAiB / numB

                            if subAB_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF \
                                    or subBA_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                # calc importance as P(A|B)/P(A)-1  (iow, [P(A|B)-P(A)] / P(A) )
                                # importance is same for subset A B and subset B A so only need to calc once
                                importance = subBA_strength / (
                                    numA / total_num_genes) - 1

                                # pa = numA/total_num_genes
                                # print pa

                                # for debugging:
                                # print setA.name + ' size: ' + str(numA) + '    total N: ' + str(int(total_num_genes)) \
                                # + '     P(A): ' + str(numA/total_num_genes)
                                # print "importance score: " + str(importance) + "\n"

                            if subAB_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                self.subset_values[
                                    (setA, setB)] = subAB_strength
                                self.relationship_importance_score[
                                    (setA, setB)] = importance

                            if subBA_strength > SUBSET_LINK_TV_STRENGTH_CUTOFF:
                                self.subset_values[
                                    (setB, setA)] = subBA_strength
                                self.relationship_importance_score[
                                    (setB, setA)] = importance

                                # else:
                                # print set_pair + " has already been processed"

            i = i + 1
            if i % 1000 == 0:
                timing = int((time.clock() - start) / 60)
                if timing != 0:
                    set_per_min = i / timing
                    remaining_sets = num_sets - i
                    remaining_time = remaining_sets / set_per_min
                    # total_est = num_sets / set_per_min
                    total_est = timing + remaining_time
                else:
                    total_est = 'thinking about it...'
                print "processed " + str(i) + ' sets of ' + str(
                    num_sets) + ' in ' + str(timing) + ' minutes.' \
                      + ' Total estimated: ' + str(total_est) + ' minutes'
                # + ' Estimated remaining: ' + str(remaining_time) + ' minutes' \
                # + '  (Total est: ' + str(timing+remaining_time)


                # timing = int(time.clock()-start)
                # print "\nprocessed " + str(i) + ' sets of ' + str(num_sets) + ' in ' + str(timing) + ' seconds'

        self.subset_time = int(time.clock() - start)
        print 'Gene category Subset truth values completed in ' + str(
            self.subset_time) + " seconds"
        print 'Created {:,} subset relationships above cuttoff strength value.'.format(
            len(self.subset_values))
        print "\nSubset value percentiles: " + str(
            np.percentile(self.subset_values.values(),
                range(10, 100, 10))) + "\n"
        print "Subset importance score percentile: {0}\n".format(
            [int(x) for x in
             np.percentile(self.relationship_importance_score.values(),
                 range(10, 100, 10))])

        # perist results to file
        f = open(SUBSET_VALUES_FILE, 'wb')
        i = 0
        for key in self.subset_values:
            name1, name2 = [node.name.strip() for node in key]
            f.write(
                name1 + '-' + name2 + ' ' + str(self.subset_values[key]) + ' ' + \
                str(int(self.relationship_importance_score[key])) + "\n")

            # print the first N to console
            # if i < 10:
            # print 'Subset ' + str(key) + ": " + str(self.subset_values[key]) + "\n"
            #     i = i+1
        f.close()

    def get_category_ancestors(self,cat):
        # print "cat {0}".format(cat)
        # print "getting ancestors for {0}".format(cat.name) + '|||'

        if cat not in self.category_ancestors:

            # For some reason, atoms returning from the query have a space
            # appended to their name, so stripping it off
            atom_name = cat.name.strip()

            bindlink_query = \
                '''
                (BindLink
                    (VariableNode "$ancestor")
                    (ImplicationLink
                        (InheritanceLink
                            (ConceptNode {0})
                            (VariableNode "$ancestor"))
                        (VariableNode "$ancestor")))
                        '''.format('"' + atom_name + '"')
            # print bindlink_query

            # bindlink_h = scheme_eval_h(self.atomspace, bindlink_query)
            # results_h = bindlink(self.a, bindlink_h)
            # ancestors = direct_ancestors = atoms_in_listlink_h(self.a,results_h)

            # or, using scheme (cog-bind) method
            ancestors = direct_ancestors = set(scheme_eval_list(self.atomspace,'(cog-bind '+bindlink_query + ')'))

            # print "                direct ancestors for {0}  n = {1}".format(
            #     cat.name,len(ancestors))
            # for a in direct_ancestors:
            #     print "                            " + a.name + "==="

            for ancestor in direct_ancestors:
                ancestors = ancestors | self.get_category_ancestors(ancestor)

            self.category_ancestors[cat] = ancestors

        return self.category_ancestors[cat]


    def _get_category_ancestors_test(self):
        gos = self.get_GO_nodes()
        n = 100
        for i in range(n):
            go = gos[i]
            ancestors = self.get_category_ancestors(go)
            print "\nGO category {0} ancestors:".format(go.name)
            for a in ancestors:
                print a.name


        go = self.a.get_atoms_by_name(types.ConceptNode,'GO:0006688')[0]
        print go

        self.get_category_ancestors(go)



    def create_subset_links(self):
        num_subsets = len(self.subset_values)
        # print "relationship_importannce_scores.values(): {0}".format(self.relationship_importance_score.values())
        # print "importance score cuttoff percentile: {0}".format(IMPORTANCE_SCORE_PERCENTILE_CUTOFF)
        importance_cuttoff = np.percentile(
            self.relationship_importance_score.values(),
            IMPORTANCE_SCORE_PERCENTILE_CUTOFF * 100)
        # print "importance cuttoff: {0}".format(importance_cuttoff)
        print "Creating subset links. Found " + str(
            num_subsets) + " new subset relationships."
        print "TV.strength cuttoff value: {0}".format(
            SUBSET_LINK_TV_STRENGTH_CUTOFF)
        print "Filtering found relationships with importance score cuttoff {0} ({1}th percentile)".format(
            importance_cuttoff, int(IMPORTANCE_SCORE_PERCENTILE_CUTOFF * 100)
        )
        subset_relationships = []
        start = time.clock()
        i = 1
        created_count = 0
        for set_pair in self.subset_values:
            if i % 1000000 == 0:
                self.link_creation_time = int((time.clock() - start) / 60)
                print "processed " + str(i) + ' subset relationships of ' + str(
                    num_subsets) + ' in ' \
                      + str(self.link_creation_time) + ' minutes'
            importance_score = self.relationship_importance_score[set_pair]
            if importance_score < importance_cuttoff:
                continue
            setA, setB = set_pair
            ABstrength = self.subset_values[set_pair]
            tv = TruthValue(ABstrength, DEFAULT_TV_COUNT)
            link = self.a.add_link(types.SubsetLink, (setA, setB), tv)
            subset_relationships.append(link)

            created_count = created_count + 1
            i = i + 1

        self.link_creation_time = int(time.clock() - start)
        print "completed creating subsets in " + str(
            self.link_creation_time) + " seconds"
        print "{0} SubSet relationships created after importance score filtering".format(
            created_count)

        # write to scheme file:
        f = open(SUBSET_SCHEME_FILE, 'wb')
        for link in subset_relationships:
            f.write(str(link) + "\n")
        f.close()


    def get_genesets_for_gene(self, gene):
        if gene in self.member_sets_dict:
            genesets = self.member_sets_dict[gene]
        else:
            genesets = self.member_sets_dict[gene] = scheme_eval_list(
                self.a, '(get_sets_for_member "' + gene.name.strip() + '")')
        if V:
            print "genesets for gene " + gene.name + ": " + str(genesets)
        return genesets

    # Atoms don't support pickling (yet), so converting key to string based on
    # node names (key: node1-node2)
    def pickle_subset_valuesv(self):
        subset_valuesv2 = {}
        for set_pair in self.subset_values:
            name1, name2 = [node.name.strip() for node in set_pair]
            key = name1 + '-' + name2
            subset_valuesv2[key] = self.subset_values[set_pair]

        pickle.dump(subset_valuesv2, open(SUBSET_VALUES_PICKLE_FILE, 'wb'))

    def unpickle_subset_values(self):
        if not self.scheme_loaded:
            self.load_scheme()
        print "unpickling subset values..."
        start = time.clock()
        subset_values2 = pickle.load(open(SUBSET_VALUES_PICKLE_FILE, 'rb'))
        end = time.clock()

        # print some out for a look
        # for i in range(10):
        # key = subset_values2.keys()[i]
        #     print key + ' ' + str(subset_values2[key])

        print 'completed unpickling in ' + str(end - start) + ' seconds'

        print "converting to atom pair key format..."
        start = time.clock()
        subset_values = self.subset_values = {}
        for key in subset_values2:
            if subset_values2[key] >= SUBSET_LINK_TV_STRENGTH_CUTOFF:
                name1, name2 = key.split('-')
                n1 = self.a.get_atoms_by_name(types.ConceptNode, name1)[0]
                n2 = self.a.get_atoms_by_name(types.ConceptNode, name2)[0]
                subset_values[(n1, n2)] = subset_values2[key]

        print "converted to atom pair key format in " + str(
            time.clock() - start) + ' seconds'

        # print some out
        # for i in range(10):
        #     key = subset_values.keys()[i]
        #     print str(key) + ' ' + str(subset_values[key])


    def dump_atoms(self,atoms,filename):
        print "Writing atoms to file " + filename
        with open(filename,'wb') as f:
            for atom in atoms:
                f.write(str(atom))

    def create_connected_subgraph(self,n=10000):
        g = subgraph.SubgraphMiner(self.atomspace)
        g.create_connected_subgraph(n)


###### Utils ########
def scheme_eval_list(atomspace, scheme):
    results = scheme_eval_h(atomspace, scheme)
    return atomspace[results].out


def atoms_in_listlink_h(atomspace, h):
    return atomspace[h].out


def sorted_atom_names(atoms):
    return " ".join(sorted([gene.name for gene in atoms]))

def print_atoms_in_list(atoms,atom_name='',list_name=''):
    print "{0} in {1}:".format(atom_name,list_name)
    for atom in atoms:
        print atom



################

# import pickle
# set_members = pickle.load(open('set_members.txt','rb'))
# keys = set_members.keys
# values = set_members.values
# for k in range(10):
# print keys[k] + ": " + " ".join([gene.name for gene in set_members[keys[k]]])


if __name__ == '__main__':

    bio = Bio()

    # KB_FILES = None
    bio.load_scheme()
    # bio.do_full_mining()

    bio.load_subset_rels_from_scheme()

    bio.create_connected_subgraph()

    # bio._get_category_ancestors_test()


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
    if hasattr(bio, 'scheme_load_time'): print "loaded scheme files in " + str(
        bio.scheme_load_time) + " seconds"
    if hasattr(bio,
               'populate_time'): print "populated genesets with descendent members in " + str(
        bio.populate_time) \
                                       + " seconds"
    if hasattr(bio,
               'subset_time'): print "calculated subset truth values in " + str(
        bio.subset_time) + " seconds"
    if hasattr(bio,
               'link_creation_time'): print "completed creating subsets in " + str(
        bio.link_creation_time) + " seconds"





