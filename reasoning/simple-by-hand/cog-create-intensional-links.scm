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
    (define ASSOC_sum)
    (define tv-strength)

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

        (set! attractionLinksA
            (map-in-order make-attraction-via-subsets
                 superIntersection (make-list superIntersection-length A)
            )
        )
        (set! attractionLinksB
            (map-in-order make-attraction-via-subsets
                 superIntersection (make-list superIntersection-length B)
            )
        )
        (display-atom "attractinLinksA" attractionLinksA)
        (display-atom "attractinLinksB" attractionLinksB)

        ; ASSOC(A,L) AND ASSOC(B,L) = min( ASSOC(A,L), ASSOC(B,L) )
        ; Todo: what confidences of the AttractionLinks?
        (set! ASSOC_sum
            (fold (lambda(attractA attractB previous_sum)
                    (+ previous_sum
                       (min (cog-stv-strength attractA)
                            (cog-stv-strength attractB))
                    )
                   )
                   0
                   attractionLinksA
                   attractionLinksB
            )
        )
        (display-label "ASSOC_sum" ASSOC_sum)
        (set! tv-strength (/ ASSOC_sum superUnion-length))
        (display-label "tv-strength" tv-strength)
        ; Todo What confidence for the IntensionalSimilarityLink?
        (IntensionalSimilarityLink A B (stv tv-strength 1))

     )
)

; TODO: this is specialized for gene sets currently -- need to generalize
(define (make-attraction-via-subsets A B)
    (define subsetAB)
    (define NotA)
    (define subsetNotAB)
    (define grounded-attraction-rule)

    (display "(make-attraction-via-subsets A B)")
    (display-atom "A" A)
    (display-atom "B" B)

    ; Starting with full evaluation from scratch - later can add option to use
    ; subset links that already exist.
    ; Assumed here is that A is a set that contains GeneNode members
    (set! subsetAB (subset-direct-evaluation A B))
    (display-atom "subsetAB" subsetAB)
    ; Todo: calc of (NOT A) could be refactored outside of this function, so
    ; it's not repeated twice
    (set! NotA (create-not-gene-set A))

    (set! subsetNotAB (SubsetLink (NotLink A) B
        (pln-formula-subset-direct-evaluation-side-effect-free NotA B)))
    (display-atom "subsetNotAB" subsetNotAB)

    ;; Use the AttractionRule to create the AttractionLink
    ; Todo: ground the vars here -
    ;(set! grounded-attraction-rule
    ;    (substitute pln-rule-attraction (list (cons (VariableNode "$B") B))))
    ;(display-atom "grounded-attraction-rule" grounded-attraction-rule)
    ;;(cog-bind pln-rule-attraction)
    ;(cog-bind grounded-attraction-rule)

    ; use new command to apply attraction rule with no variables
    (pln-attraction-rule-no-variables subsetAB subsetNotAB)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (test)
    (use-modules (opencog))
    (use-modules (opencog query))
    (use-modules (opencog rule-engine))
    ;(load "simple-inference.scm")
    (load-from-path "av-tv.scm")
    (load "substitute.scm")
    (load "background-knowledge.scm")
    (load "local-rules/member-to-subset.scm")
    (cog-bind pln-rule-member-to-subset)
    (cog-create-intensional-links setL setPLAU)
)
(test)


; identify common supersets
; for each common superset L:
;       create (NOT L) ; which will be used in ASSOC calc
;       calc ASSOC(L,A)
;       calc ASSOC(L,B)
