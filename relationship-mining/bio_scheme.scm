; paths used in this code assume this file is loaded via the cogserver
; TODO: make paths friendly for loading file through guile

;(ConceptNode "bio_scheme.scm")

; workaround b/c add-to-path in opencog.scm is not getting loaded
(add-to-load-path "/usr/local/share/opencog/scm")

(add-to-load-path "/home/eddie/opencog/opencog/opencog/reasoning/pln/")

(add-to-load-path "/home/eddie/opencog/agi-bio/eddie/visualizer-dev/")
;(add-to-load-path "/home/eddie/opencog/bio-data/scheme-representations/")



; pln rule configuration file
(load "../../opencog/bio-ure-config.scm")

; Todo: removing because of issue in pln-config, but this might be needed
;(load-from-path "pln-config.scm")

(define dkc1 (GeneNode "DKC1"))

; pln/ure helpers
;(define cpolicy "opencog/reasoning/bio_cpolicy.json")

; atomspace populating helpers
(define knowledge-dir "../../bio-data/scheme-representations/")
(define subgraph-dir (string-append knowledge-dir "subgraphs/"))

(define (loadf f)
    (load (string-append knowledge-dir f)))
(define (loadsub f) (load (string-append subgraph-dir f)))

(define (loadGO1K)
    (loadf "subgraphs/subgraph_1K_GO.scm")
    (set_bio_tvs))
(define (load1K)
    (loadf "subgraphs/subgraph_1K.scm")
    (set_bio_tvs))

(define (set_bio_tvs)
    (default_gene_tvs)
    (default_concept_tvs))

(define (load-bio-rules) (load "../bio-ure-config.scm"))

; general utility shortcuts and helpers
(define countall count-all)
(define prt cog-prt-atomspace)



; set the truth value for GeneNodes
(define (set_gene_tvs strength confidence)
    (let ([genes (cog-get-atoms 'GeneNode)])
       (for-each (lambda (gene)       
            (cog-set-tv! gene (cog-new-stv strength confidence))) 
            genes)))

;set truth values for all ConceptNodes
(define (set_concept_tvs strength confidence)
    (let ([nodes (cog-get-atoms 'ConceptNode)])
        (for-each (lambda (node)
            (cog-set-tv! node (cog-new-stv strength confidence)))
            nodes)))


;set default truth values for all GeneNodes or all ConceptNodes
(define (default_gene_tvs) (set_gene_tvs .00001 .9))
(define (default_concept_tvs) (set_concept_tvs .001 .9))



; one-step inference forward chaining algo
; first we could get the incoming links to source and save those as "known"
(define (do_one_steps source)
    (do ((i 1 (1+ i)))
        ((> i 100))
      (cog-fc-em source cpolicy)))
; then we could filter out the previously known to get the "new" knowledge



; one-step inference forward chaining algo with default
(define (do_one_steps_def)
    (do_one_steps (GeneNode "SHANK2")))


(define pattern_match_go_terms
    (BindLink
        (VariableNode "$go")
        (ImplicationLink
            (InheritanceLink
                (VariableNode "$go")
                (ConceptNode "GO_term"))
            (VariableNode "$go"))))

(define (loadtemp)
  (load "temp.scm"))

#|             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

|#         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;(define (test something)
;    (display something))

;(define (set-genenode-tvs)
;    (define genenodes (cog-get-atoms 'GeneNode))
