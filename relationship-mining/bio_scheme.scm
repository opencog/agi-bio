(ConceptNode "hello world")





(define pattern_match_go_terms
    (BindLink
        (VariableNode "$go")
        (ImplicationLink
            (InheritanceLink
                (VariableNode "$go")
                (ConceptNode "GO_term"))
            (VariableNode "$go"))))



(define get_go_terms
    (cog-outgoing-set (cog-bind pattern_match_go_terms)))



(define (get_inheritance_child_nodes parent)
    (cog-bind
        (BindLink
            (ListLink
                (VariableNode "$child"))
            (ImplicationLink
                ;(AndLink
                    (InheritanceLink
                        (VariableNode "$child")
                        (ConceptNode parent))
                ;    (NotLink
                ;        (EquivalenceLink
                ;            (VariableNode "$child")
                ;            (ConceptNode "GO_term"))))
                (VariableNode "$child")))))




(define (get_members_of setname)
    (cog-bind
        (BindLink
            (VariableNode "$member") 
            (ImplicationLink
                (MemberLink
                    (ConceptNode setname)
                    (VariableNode "$member"))
                (VariableNode "$member")))))


(define (get_sets_for_member membername)
    (cog-bind
        (BindLink
            (VariableNode "$setname")
            (ImplicationLink
                (MemberLink
                    (VariableNode "$setname")
                    (GeneNode membername))
                (VariableNode "$setname")))))




(define (test something)
    (display something))
