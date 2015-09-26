; cog-create-intensional-links.scm
; Implements approach of directly evaluating truth values of
; (IntensionalImplication A B) and (IntensionalSimilarity A B) described here:
; http://wiki.opencog.org/wikihome/index.php/Direct_Evaluation_of_Intensional_Links

(use-modules (srfi srfi-1))  ; for support of lset-union and lset-intersection

(load "utilities.scm")
(load "local-rules/rule-helpers.scm")
(load "local-rules/subset-direct-evaluation-rule.scm")
(load-from-path "rules/attraction-rule.scm")

(define (cog-create-intensional-links A B)
    (define attractionLinksA)
    (define attractionLinksB)

    (display "cog-create-intensional-links A B")
    (display-atom "A" A)
    (display-atom "B" B)

    ; Create ASSOC/AttractionLinks for common relationships of the forms:
    ; (Inheritance A B), (EvaluationLink A Z), (EvaluationLink Z (A, B)), and
    ; (EvaluationLink Z (B, A))

    ; initial we will start just with links L of the form (Subset A B)
    ; get all supersets of $A and $B
    ; TODO: what about heirarchical ancestor categories in, e.g., Gene Ontology?
    (let*
        ((superA (cog-get-supersets A))
         (superB (cog-get-supersets B))
         (superA-length (length superA))
         (superB-length (length superB))
         (superUnion-length (length (lset-union equal? superA superB)))
         (superIntersection (lset-intersection equal? superA superB))
         (superIntersection-length (length superIntersection))
        )
        (display-label "superA-length" superA-length)
        (display-label "superB-length" superB-length)
        (display-label "superUnion-length" superUnion-length)
        (display-label "superIntersection" superIntersection)

        (display-label "superInersection length" superIntersection-length)

        ;(map (lambda(x) display(x)) superIntersection)

        (display "\nsetting attraction links\n")

        (set! attractionLinksA
            (map make-attraction-from-subsets
                 (make-list superIntersection-length A) superIntersection
            )
        )
        (set! attractionLinksB
            (map make-attraction-from-subsets
                 (make-list superIntersection-length B) superIntersection
            )
        )

        (display-atom "attractinLinksA" attractionLinksA)
        (display-atom "attractinLinksB" attractionLinksB)



        (stv 1 1) ;temporary
     )
)

; TODO: this is specialized for gene sets currently -- need to generalize
(define (make-attraction-from-subsets A B)
    (define subsetAB)
    (define NotA)
    (define subsetNotAB)

    (display "(make-attraction-from-subsets A B)")
    (display-atom "A" A)
    (display-atom "B" B)

    ; Starting with full evaluation from scratch - later can add option to use
    ; subset links that already exist.
    ; Assumed here is that A is a set that contains GeneNode members
    (set! subsetAB (subset-direct-evaluation A B))
    (set! NotA (create-not-gene-set A))
    (set! subsetNotAB (SubsetLink (NotLink A) B
        (pln-formula-subset-direct-evaluation-side-effect-free NotA B)))

    ; Use the AttractionRule to create the AttractionLink
    ;
    (subsetNotAB) ;temp
)


;;;;;;;;;;;;;;;;;;;;;;;;
(use-modules (opencog))
(use-modules (opencog query))

(define (test)
    ;(load "simple-inference.scm")
    (load "background-knowledge.scm")

    (cog-create-intensional-links L PLAU)
)
(test)



