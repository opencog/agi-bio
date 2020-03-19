(use-modules (opencog))

(define knowledge-dir "/home/eddie/opencog/bio-data/scheme-representations/")
(define subgraph-dir (string-append knowledge-dir "subgraphs/"))

(define (loadf f)
    (load (string-append knowledge-dir f)))
(define (loadsub f) (load (string-append subgraph-dir f)))



(define (set-tvs-for-type strength confidence type)
    (let ([atoms (cog-get-atoms type)])
       (for-each (lambda (atom)
            (cog-set-tv! atom (cog-new-stv strength confidence)))
            atoms)))

; set the truth value for GeneNodes
(define (set-gene-tvs strength confidence)
    (set-tvs-for-type strength confidence 'GeneNode))
""
(define (set_gene_tvs strength confidence)
    (let ([genes (cog-get-atoms 'GeneNode)])
       (for-each (lambda (gene)
            (cog-set-tv! gene (cog-new-stv strength confidence)))
            genes)))
""

;set truth values for all ConceptNodes
(define (set-concept-tvs strength confidence)
    (set-tvs-for-type strength confidence 'ConceptNode))
""
(define (set_concept_tvs strength confidence)
    (let ([nodes (cog-get-atoms 'ConceptNode)])
        (for-each (lambda (node)
            (cog-set-tv! node (cog-new-stv strength confidence)))
            nodes)))
""

;set default truth values for all GeneNodes or all ConceptNodes
(define (set-default-gene-tvs) (set-gene-tvs .00001 .9))
(define (set-default-concept-tvs) (set-concept-tvs .001 .9))

(define (set-bio-tvs)
    (set-default-gene-tvs)
    (set-default-concept-tvs))


;(loadf "GO_1K.scm")
;(loadf "GO_ann_1K.scm")
(define start (current-time))
(display "loading GO categories... ")
(loadf "GO.scm")
(display (- (current-time) start)) (display " seconds\n")
(set! start (current-time))
(display "loading GO gene annotations... ")
(loadf "GO_annotation.scm")
(display (- (current-time) start)) (display " seconds\n")
(display "loading Lifespan Oberservation Genes...\n")
(loadf "Lifespan-observations_2015-02-21.scm")

(set-bio-tvs)