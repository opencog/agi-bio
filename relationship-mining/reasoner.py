from opencog.atomspace import AtomSpace, types
from opencog.scheme_wrapper import load_scm, scheme_eval, scheme_eval_h

VERBOSE = True
RESULTS2FILE = True

OUT_FILE = 'single_source_results.txt'

class Reasoner:
    DEFAULT_ROUNDS = 5



    

    def __init__(self, atomspace=None):
        print "Reasoner::__init__"
        if not atomspace:
            print "WARNING: creating new AtomSpace()"
            atomspace = AtomSpace()
        self.a = self.atomspace = atomspace
        #hmmmm.. is this needed? not sure where it came from
        #__init__(self.atomspace)


    # def contains_varnodes(self,atom):
    #     if atom.is_link():
    #         scheme = "(cog-get-all-nodes {})".format(atom)
    #         print "scheme: " + scheme
    #         h = scheme_eval_h(self.a,scheme)
    #         print h
    #
    #         # for d in descendents:
    #         #     print d



    # TODO: add source_type argument, just using GeneNode for now
    def do_one_steps(self, source_name, source_type_str='GeneNode', rounds=DEFAULT_ROUNDS):
        print "entering Reasoner::do_one_steps()   source_name: " + source_name \
            + "   rounds: " + str(rounds)

        # remove enclosing quotations if they exist
        if source_name.startswith('"') and source_name.endswith('"'):
            source_name = source_name[1:-1]

        source_type = types.__dict__.get(source_type_str)
        print "source_type: {}".format(source_type)
        if source_type is None:
            print "Unknown type: {}".format(source_type_str)
            return

        source = self.a.get_atoms_by_name(source_type,source_name)

        if len(source)==0:
            print "{} with name {} not found".format(source_type_str,source_name)
            return

        # only using the first source here, though potential there could be > 1
        source = source[0]
        print "source: {}".format(source)

        self.known = accum_known = set(self.a.get_incoming(source.h))
        self.known = self.filter_out_variablenodes(self.known)
        print "Previously Known: {}".format(len(self.known))
        if VERBOSE:
            for atom in self.known:
                print atom


        scheme = "(cog-fc-bio ({} \"{}\") biorules)".format(
                                        source_type_str,source_name)
        print "\ndoing " + scheme

        done = False;
        i = 0;
        num_conclusions = prev_n_novel_conclusions = 0
        while not done and i < rounds:
            conclusions = scheme_eval_h(self.a,scheme)
            conclusions = set(self.a[conclusions].out)
            print ("conclusions atoms: {}".format(len(conclusions)))
            conclusions = self.filter_out_variablenodes(conclusions)
            print ("conclusions post-filter: {}".format(len(conclusions)))
            num_conclusions = len(conclusions)
            novel_conclusions = conclusions - accum_known
            n_novel_conclusions = len(novel_conclusions)
            accum_known = accum_known.union(novel_conclusions)
            print "\nStep {} generated conclusions: {}     novel conclusions: {}".format(
                i,num_conclusions,n_novel_conclusions)
            #print "novel conclusions: \n" + str(novel_conclusions)

            # this doesn't work when we are doing 1 rule per step
            if prev_n_novel_conclusions==0 and n_novel_conclusions==0:
                done = True
            print "prev==0: {}  novel==0:{}   done: {}".format(prev_n_novel_conclusions==0,
                                                               n_novel_conclusions==0,done)
            i += 1
            prev_num_conclusions = novel_conclusions


        conclusions = conclusions - self.known
        # this is being done at each step now
        #conclusions = self.filter_out_variablenodes(conclusions)

        if VERBOSE:
            print "New conclusions:\n"
            for conclusion in conclusions:
                # if not ("VariableNode" in str(conclusion)):
                print conclusion

        if RESULTS2FILE:
            with open(OUT_FILE,'w') as f:
                for conclusion in conclusions:
                    f.write(str(conclusion))




        print "\n# of steps: {}".format(i-1)
        print "Previously known relationships (filtered): {}".format(len(self.known))
        print "Inferred relationships (filtered): {}".format(len(conclusions))


        print "\n\nEnd do_one_steps()"

    def filter_out_variablenodes(self,list):
        # TODO: Probably should do this based on types rather than by the string
        list = [atom for atom in list
                       if not ("VariableNode" in str(atom))]
        return set(list)
