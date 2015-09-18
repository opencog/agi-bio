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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the atomspace and rules ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(loadf "Lifespan-observations_2015-02-21.scm")
;(set_bio_tvs)

(load "background-knowledge.scm")
(load "pln-config.scm")
(load "substitute.scm")

; apply member-to-subset-rule
;(cog-bind pln-rule-member-to-subset)
; This gets us extra results, namely for the pln rules also, so let's add
; substitution of source atoms before applying the rule
;
; Subset  SetLink GeneNode L   ConceptNode "GO_A"
; Subset  SetLink GeneNode PLAU   ConceptNode "GO_A"


; what we really want though is
; (Subset GO_A (SetLink (Gene G)))  ==> % of GO_A in singleton G = 1 / size(GO_A)
; (Subset GO_A (SetLink (Gene PLUA)))
(define subst-map (make-hash-table 2))
(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
(hash-set! subst-map (VariableNode "$B") (SetLink (GeneNode "L")))
(define grounded-subset-evaluation
    (substitute pln-rule-subset-direct-evaluation subst-map))
;(display "before first bind\n")
;(display grounded-subset-evaluation)
;(cog-bind pln-rule-subset-direct-evaluation)
;(cog-bind grounded-subset-evaluation)
;(display "after first bind\n")

; use the subset direct eval function (without PM)
(subset-direct-evaluation (ConceptNode "GO_A") (SetLink (GeneNode "L")))
