__author__ = 'eddie'

import opencog.cogserver as cogserver
from opencog.atomspace import AtomSpace, types
# from opencog.atomspace import *
import opencog.scheme_wrapper as scheme
from opencog.scheme_wrapper import *
import opencog.bindlink as bindlink

from utilities import atoms_to_scheme_file


# import opencog.cogserver
# from opencog.atomspace import AtomSpace, TruthValue, types, get_type_name, \
#     is_defined, add_type
# from opencog.scheme_wrapper import load_scm, scheme_eval, scheme_eval_h, \
#     __init__
# from opencog.bindlink import bindlink

import numpy as np
import pickle
import time
import os

os.system('export GUILE_AUTO_COMPILE=0')

SUBGRAPH_SIZE = 1000

SUBGRAPH_FILE_NAME = 'SUBGRAPH_' + str(SUBGRAPH_SIZE) + '.scm'

SMALL_RUN = False
# SMALL_RUN = True

V = VERBOSE = False
T = TIME = True

KB_SCHEME_DIR = '../agi-bio/scheme-representation/'

if SMALL_RUN:
    GO_FILE = 'GO_1K.scm'
    GO_ANN_FILE = 'GO_ann_1K.scm'


else:
    GO_FILE = 'GO.scm'
    GO_ANN_FILE = 'GO_annotation.scm'

SCHEME_INIT_FILES = ['opencog/atomspace/core_types.scm',
                     'opencog/scm/utilities.scm',
                     'bioscience/types/bioscience_types.scm',
                     '/home/opencog/agi-bio/eddie/bio_scheme.scm'
                    ]


class SubgraphMiner:

    def __init__(self,atomspace=None):
        if not atomspace:
            atomspace = AtomSpace()
        self.a = self.atomspace = atomspace
        scheme.__init__(self.atomspace)

    def load_scheme_init(self):
        """
        Load initial scheme files into the atomspace.

        This is primarily for use when running the script standalone for
        testing,that is, without a pre-existing cogserver atomspace.
        """
        print "Loading scheme files"
        if T:
            start = time.clock()

        kb_files = [
            KB_SCHEME_DIR + GO_FILE,
            KB_SCHEME_DIR + GO_ANN_FILE,
            '../agi-bio/relationship-mining/subset_relationships.scm'
        ]

        scheme_files = SCHEME_INIT_FILES + kb_files
        for file in scheme_files:
            print "  Loading scheme file: " + file
            if not scheme.load_scm(self.atomspace, file):
                print "***  Error loading scheme file: " + file + "  ***"

        self.scheme_load_time = int(time.clock() - start)
        print 'Scheme file loading completed in ' + str(self.scheme_load_time) \
              + " seconds\n"

        self.scheme_loaded = True



    def get_connected_subgraph(self,n):
        a = self.atomspace

        print "total atomspace size = {0}".format(len(a))

        genes = a.get_atoms_by_type(types.GeneNode)
        print "found {0} genes".format(len(genes))

        atom0 = genes[0]

        print "starting with {0}".format(atom0)

        self.subgraph = subgraph = set()
        subgraph.add(atom0)

        incoming = a.get_incoming(atom0.h)


        # print "incoming for {0}".format(atom0)
        # for atom in incoming:
        #     print atom

        repeats = subgraph.intersection(incoming)
        unprocessed = set(incoming) - subgraph

        # print "=== incoming for {0} n={1}".format(atom0,len(incoming))
        # for atom in incoming:
        #     print atom
        #
        # print "=== new for {0} n={1}".format(atom0,len(unprocessed))
        # for atom in unprocessed:
        #     print atom.h

        subgraph.update(incoming)

        # print "\n\n\n======================================\nsubgraph: "
        # for atom in subgraph:
        #     print atom


        # outgoing = a.get_outgoing(atom0.h)
        #
        # print "********************* outgoing:"
        # print outgoing

        print "\n\ngoing in.."
        print "n = {0}   subgraph = {1}     unprocessed = {2}".format(n,len(subgraph),len(unprocessed))

        # i = 0
        while len(subgraph) < n and len(unprocessed) > 0: # and i < 5:
            print "pre-unprocessed = {0}     subgraph = {1} ".format(len(unprocessed),len(subgraph))
            atom = unprocessed.pop()
            print "popped atom {0}      unprocessed = {1}".format(atom,len(unprocessed))

            inbound = a.get_incoming(atom.h)
            outbound = a.get_outgoing(atom.h)

            new = set(inbound).difference(subgraph)
            new.update(set(outbound).difference(subgraph))
            print "adding {0} new atoms to subgraph".format(len(new))

            # print "found and adding {0} new atoms".format(len(new))
            # for atom in new:
            #     print atom

            # i = i+1


            subgraph.update(new)
            unprocessed.update(new)

        print "\n\n\n\n********************************************************"
        print "final subgraph = {0} atoms".format(len(subgraph))
        # for atom in subgraph:
        #     print atom



        atoms_to_scheme_file(subgraph,SUBGRAPH_FILE_NAME)





#########################################################

if __name__ == '__main__':
    sm = SubgraphMiner()
    sm.load_scheme_init()

    sm.get_connected_subgraph(SUBGRAPH_SIZE)



##########################################################
class go(cogserver.Request):
    def __init__(self):
        print "in subgraph_miner.__init__()"
        self.sm = SubgraphMiner()

    def run(self, args, atomspace):
        print 'received request subgraph_miner ' + str(args)

        if args:
            if args[0] == 'test':
                self.sm.test(args)
            elif args[0] == 'run':
                pass
            else:
                print args[0] + ' command not found'
        else:
            pass