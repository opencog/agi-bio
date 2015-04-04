"""
Tool to create smaller subgraphs of the bio atomspace for experimentation.

Creates a connected subgraph of a given size in atoms based on an initial random
GeneNode. (Future functionality could involve supplying target genes or atoms to
expand from as input.)

Example usage:
sg = SubgraphMiner(atomspace)
sg.create_connected_subgraph(10000)

Output is a scheme file named SUBGRAPH_N.scm, where N is the size of the
subgraph in number of atoms.

This functionality can also be accessed through the bio.miner module through the 
cogserver shell:

opencog> loadpy bio
opencog> bio.miner create_connected_subgraph 10000

"""

import opencog.cogserver as cogserver
from opencog.atomspace import AtomSpace, types
import opencog.scheme_wrapper as scheme
from opencog.scheme_wrapper import *

from utilities import atoms_to_scheme_file

import os
import random

__author__ = 'eddie'

# os.system('export GUILE_AUTO_COMPILE=0')

# These nodes are excluded from graph expansion because they would not create
# meaningful connections for the purpose of experimenting.
EXCLUDED_NODES_FOR_EXPANSION = (
    'biological_process'
    , 'molecular_function'
    , 'cellular_component'
    , 'GO_term'
    , 'GO_namespace'
    , 'GO_synonym_EXACT'
    , 'GO_synonym_BROAD'
    , 'GO_synonym_RELATED'
    , 'GO_synonym_NARROW'
    , 'GO_name'
    , 'GO_alt_id'
    , 'RO_part_of'
)

DEFAULT_SUBGRAPH_SIZE = 100000

SMALL_RUN = False
# SMALL_RUN = True

V = VERBOSE = False
# T = TIME = True

# KB_SCHEME_DIR = '../agi-bio/scheme-representation/'
#
# if SMALL_RUN:
#     GO_FILE = 'GO_1K.scm'
#     GO_ANN_FILE = 'GO_ann_1K.scm'
#
#
# else:
#     GO_FILE = 'GO.scm'
#     GO_ANN_FILE = 'GO_annotation.scm'
#
# SCHEME_INIT_FILES = ['opencog/atomspace/core_types.scm',
#                      'opencog/scm/utilities.scm',
#                      'bioscience/types/bioscience_types.scm',
#                      '/home/opencog/agi-bio/eddie/bio_scheme.scm'
#                     ]


class SubgraphMiner:

    def __init__(self,atomspace=None):
        if not atomspace:
            atomspace = AtomSpace()
        self.a = self.atomspace = atomspace
        scheme.__init__(self.atomspace)

    def create_connected_subgraph(self, size=DEFAULT_SUBGRAPH_SIZE):
        print "Creating connected subgraph of {} atoms".format(size)
        a = self.atomspace
        print "total atomspace size = {0}".format(len(a))

        genes = a.get_atoms_by_type(types.GeneNode)
        # print "found {0} genes".format(len(genes))

        random_gene = genes[random.randrange(len(genes))]
        # print "starting with {0}".format(random_gene)

        self.subgraph = subgraph = set()
        subgraph.add(random_gene)

        unprocessed = set([random_gene])

        # print "\n\ngoing in.."
        # print "n = {0}   subgraph = {1}     unprocessed = {2}".format(size,len(subgraph),len(unprocessed))

        while len(subgraph) < size and len(unprocessed) > 0: # and i < 5:
            if V:
                print "unprocessed = {0}     subgraph = {1} ".format(len(unprocessed),len(subgraph))
            atom = unprocessed.pop()
            if V:
                print "popped atom {0}".format(atom)

            if atom.name in EXCLUDED_NODES_FOR_EXPANSION:
                continue

            inbound = a.get_incoming(atom.h)
            outbound = a.get_outgoing(atom.h)

            new = set(inbound).difference(subgraph)
            new.update(set(outbound).difference(subgraph))

            # print "found {:,} connected atoms, {:,} not yet in subgraph".format(
            #     len(inbound) + len(outbound), len(new)
            # )

            if (len(subgraph) + len(new)) > size:
                new = random.sample(new,size-len(subgraph))

            # print "adding {0} new atoms to subgraph".format(len(new))
            subgraph.update(new)
            unprocessed.update(new)

        # print "\n\n\n\n********************************************************"
        print "final subgraph = {0} atoms".format(len(subgraph))

        filename = "SUBGRAPH_{}.scm".format(size)
        atoms_to_scheme_file(subgraph,filename)

        print "Generated results file {}".format(filename)





#########################################################
#
# if __name__ == '__main__':
#     sm = SubgraphMiner()
#     sm.load_scheme_init()
#     sm.create_connected_subgraph()



##########################################################
# class create(cogserver.Request):
#     def __init__(self):
#         print "in subgraph_miner.__init__()"
#         self.sm = SubgraphMiner()
#
#     def run(self, args, atomspace):
#         print 'received request subgraph_miner ' + str(args)
#
#         if args:
#             if args[0] == 'test':
#                 self.sm.test(args)
#             elif args[0] == 'run':
#                 pass
#             else:
#                 print args[0] + ' command not found'
#         else:
#             pass
