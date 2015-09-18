;Simple example of bio-inference using PLN by hand.

(use-modules (opencog))
(use-modules (opencog rule-engine))

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

; atomspace populating helpers
(define knowledge-dir "../../../bio-data/scheme-representations/")
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
    (set_default_gene_tvs)
    (set_default_concept_tvs))


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
(define (set_default_gene_tvs) (set_gene_tvs .00001 .9))
(define (set_default_concept_tvs) (set_concept_tvs .001 .9))

(define (display-atom label atom)
    (display label)(display ": ")(display atom))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the atomspace and rules ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(loadf "Lifespan-observations_2015-02-21.scm")
;(set_bio_tvs)

(load "background-knowledge.scm")
(load "pln-config.scm")
(load "substitute.scm")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the reasoning begin ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (1) Apply Member2SubsetRule, to get:
;
;  Subset (SetLink (GeneNode "L"))  (ConceptNode "GO_A")
;  Subset (SetLink (GeneNode "PLAU"))  (ConceptNode "GO_A")

;(cog-bind pln-rule-member-to-subset)
; This gets us extra results, namely for the pln rules also, so let's add
; substitution of source atoms before applying the rule

(define subst-map (make-hash-table 2))
; cog-bind with no variables doesn't seem to return anything
;(hash-set! subst-map (VariableNode "$X") (GeneNode "L"))
(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
(define grounded-member-to-subset
    (substitute pln-rule-member-to-subset subst-map))
;(display "grounded-member-to-subset: ")(display grounded-member-to-subset)
(define m2s (cog-bind grounded-member-to-subset))
(display "m2s: ")(display m2s)


;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
;      (SetLink (av 0 0 0)
;         (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   )
;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
;      (SetLink (av 0 0 0)
;         (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   )



; (2) apply subset-inversion-evaluation-rule(?), to get:
;
;  Subset  GO_A  (SetLink (GeneNode L))
;  Subset  GO_A  (SetLink (GeneNode PLAU))

; use the subset direct eval function (without PM because no variables)
(define subAL (subset-direct-evaluation (ConceptNode "GO_A") (SetLink (GeneNode "L"))))
(define subAPLAU (subset-direct-evaluation (ConceptNode "GO_A") (SetLink (GeneNode "PLAU"))))
(display-atom "subAL" subAL)
(display-atom "subAPLAU" subAPLAU)

; let's test out the PM version
; ... later ;)

;(SubsetLink (stv 0.33333334 0) (av 0 0 0)
;   (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   (SetLink (av 0 0 0)
;      (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;)
;(SubsetLink (stv 0.33333334 0) (av 0 0 0)
;   (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   (SetLink (av 0 0 0)
;      (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;)

;(define subst-map (make-hash-table 2))
;(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
;(hash-set! subst-map (VariableNode "$B") (SetLink (GeneNode "L")))
;;(define subst-pairs (list (list (VariableNode "$A") (ConceptNode "GO_A"))
;;                          (list (VariableNode "$B") (SetLink (GeneNode "L")))))
;(define grounded-subset-evaluation
;    (substitute pln-rule-subset-direct-evaluation subst-map))
;;    (substitute pln-rule-subset-direct-evaluation subst-pairs))
;(display "before first bind\n")
;(display grounded-subset-evaluation)
;(cog-bind pln-rule-subset-direct-evaluation)
;(cog-bind grounded-subset-evaluation)
;(display "after first bind\n")


; (3) Calculate not-subset-direct-evaulation, to get:
;
;  Subset (NotLink GO_A)  (SetLink (Gene L))
;  Subset (NotLink GO_A)  (SetLink (Gene PLAU))




; (4) Apply AttractionRule to get:
;
;  AttractionLink GO_A (SetLink (GeneNode L))
;  AttractionLink GO_A (SetLink (GeneNode PLAU))


; (5) Apply IntensionalSimilarityEvaluationRule, to get:

;  InstensionalSimilarityLink (SetLink (Gene L)) (SetLink (Gene PLAU))




