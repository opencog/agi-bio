from opencog.atomspace import AtomSpace, types
from opencog.scheme_wrapper import load_scm, scheme_eval, scheme_eval_h

class Reasoner:
    DEFAULT_ROUNDS = 100

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
        print "entering Reasoner::do_one_steps()   source_name: " + source_name

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

        self.known = set(self.a.get_incoming(source.h))
        print "Previously Known: {}".format(len(self.known))
        for atom in self.known:
            print atom


        scheme = "(cog-fc-em ({} \"{}\") cpolicy)".format(
                                        source_type_str,source_name)
        print "\ndoing " + scheme

        done = False;
        i = 0;
        num_conclusions = prev_num_conclusions = 0
        while not done and i < rounds:
            conclusions = scheme_eval_h(self.a,scheme)
            conclusions = set(self.a[conclusions].out);
            num_conclusions = len(conclusions)
            print "\nStep {} Conclusions: {}".format(i,num_conclusions)
            # for conclusion in conclusions:
            #     # if not ("VariableNode" in str(conclusion)):
            #     print conclusion
            if num_conclusions == prev_num_conclusions:
                done = True
            i += 1
            prev_num_conclusions = num_conclusions


        conclusions = conclusions - self.known

        # filter out VariableNodes
        # TODO: Probably should do this based on types rather than by the string
        conclusions = [conclusion for conclusion in conclusions
                       if not ("VariableNode" in str(conclusion))]

        print "New conclusions:\n"
        for conclusion in conclusions:
            # if not ("VariableNode" in str(conclusion)):
            print conclusion




        print "# of steps: {}".format(i-1)
        print "Previously known relationships: {}".format(len(self.known))
        print "Inferred relationships: {}".format(len(conclusions))


        print "\n\nEnd do_one_steps()"