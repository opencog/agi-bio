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
