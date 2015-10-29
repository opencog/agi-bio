(use-modules (opencog))

;(define knowledge-dir "/home/eddie/opencog/bio-data/scheme-representations/")
;(define subgraph-dir (string-append knowledge-dir "subgraphs/"))

;(define (loadf f)
;    (load (string-append knowledge-dir f)))
;(define (loadsub f) (load (string-append subgraph-dir f)))



(define (set-tvs-for-type strength confidence type)
    (let ([atoms (cog-get-atoms type)])
       (for-each (lambda (atom)
            (cog-set-tv! atom (cog-new-stv strength confidence)))
            atoms)))

; set the truth value for GeneNodes
(define (set-gene-tvs strength confidence)
    (set-tvs-for-type strength confidence 'GeneNode))

;set truth values for all ConceptNodes
(define (set-concept-tvs strength confidence)
    (set-tvs-for-type strength confidence 'ConceptNode))


;set default truth values for all GeneNodes or all ConceptNodes
(define (set-default-gene-tvs) (set-gene-tvs .00001 .9))
(define (set-default-concept-tvs) (set-concept-tvs .001 .9))

(define (set-bio-tvs)
    (set-default-gene-tvs)
    (set-default-concept-tvs))

(load "reduced-biospace.scm")

(set-bio-tvs)