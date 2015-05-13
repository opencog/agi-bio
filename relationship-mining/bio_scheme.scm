(ConceptNode "hello world")


; atomspace populating helpers
(define knowledge-dir "/home/opencog/bio-data/scheme-representations/")

(define (loadf f) (load (string-append knowledge-dir f)))

(define (loadGO1K) (loadf "subgraphs/subgraph_1K_GO.scm"))
(define (load1K) (loadf "subgraphs/subgraph_1K.scm"))

; general utility shortcuts and helpers
(define count count-all)
(define prt cog-prt-atomspace)



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
                    (VariableNode "$member")
                    (ConceptNode setname))
                (VariableNode "$member")))))


(define (get_sets_for_member membername)
    (cog-bind
        (BindLink
            (VariableNode "$setname")
            (ImplicationLink
                (MemberLink
                    (GeneNode membername)
                    (VariableNode "$setname"))
                (VariableNode "$setname")))))




(define (test something)
    (display something))



