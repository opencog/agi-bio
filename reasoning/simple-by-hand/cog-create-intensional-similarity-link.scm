; cog-create-intensional-links.scm
; Implements approach of directly evaluating truth values of
; (IntensionalImplication A B) and (IntensionalSimilarity A B) described here:
; http://wiki.opencog.org/wikihome/index.php/Direct_Evaluation_of_Intensional_Links

(define verbose #f)
; check for global VERBOSE setting
;(if (and (defined? 'VERBOSE) (eq? VERBOSE #t))
;    (set! verbose #t))

(use-modules (srfi srfi-1))  ; for support of lset-union and lset-intersection

(load "utilities.scm")
(load "local-rules/rule-helpers.scm")
(load "local-rules/subset-direct-evaluation-rule.scm")
(load-from-path "rules/attraction-rule.scm")

(define (cog-create-intensional-similarity-link A B)
    (define attractionLinksA)
    (define attractionLinksB)
    (define ASSOC_sum)
    (define tv-strength)

    (if verbose (display "cog-create-intensional-similarity-link"))
    (if verbose (display-atom "A" A))
    (if verbose (display-atom "B" B))

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
        (if verbose (display-label "superA" superA))
        (if verbose (display-label "superB" superB))
        (if verbose (display-label "superA-length" superA-length))
        (if verbose (display-label "superB-length" superB-length))
        (if verbose (display-label "superIntersection" superIntersection))
        (if verbose (display-label "superInersection length" superIntersection-length))
        (if verbose (display-label "superUnion-length" superUnion-length))

        (if verbose (display
        ;    "\nCreating inverse relationships SubsetAB and SubsetNotAB\n\n")
            "\nCreating relationships SubsetAB and SubsetNotAB\n\n"))
        (set! attractionLinksA
            (map-in-order make-attraction-via-subsets
                 ;superIntersection (make-list superIntersection-length A)
                 (make-list superIntersection-length A) superIntersection
            )
        )
        (set! attractionLinksB
            (map-in-order make-attraction-via-subsets
                 ;superIntersection (make-list superIntersection-length B)
                 (make-list superIntersection-length B) superIntersection
            )
        )
        (if verbose (display-atom "attractionLinksA" attractionLinksA))
        (if verbose (display-atom "attractionLinksB" attractionLinksB))

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
        (if verbose (display-label "ASSOC_sum" ASSOC_sum))
        (set! tv-strength (/ ASSOC_sum superUnion-length))
        (if verbose (display-label "tv-strength" tv-strength))
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
    (define all-genes)
    ;(define num-genes)
    (define sizeB)
    (define sNotAB)

    ;(if verbose (display "(make-attraction-via-subsets A B)"))
    ;(if verbose (display-atom "A" A))
    ;(if verbose (display-atom "B" B))

    ; Starting with full evaluation from scratch - later can add option to use
    ; subset links that already exist.
    ; Assumed here is that A is a set that contains GeneNode members
    ; Todo: How to handle creation of (NOT A) to avoid this assumption above
    (set! subsetAB (subset-direct-evaluation A B))
    ;(display-atom "subsetAB" subsetAB)
    (if verbose (display subsetAB))

#!  ; i believe the following from previous arg order is no longer relevant
    ; Todo: calc of (NOT A) could be refactored outside of this function, so
    ; it's not repeated twice
    ; Hack: Since if B is a member of A, we know that (Subset NotA B) will have
    ; tv = 0 since we know B will not be a member of NotA. So instead of the
    ; 2 lines, which are taking a lot of time, we can directly set
    ; (Subset NotA B) to tv 0
    ;(set! NotA (create-not-gene-set A))
    ;(set! subsetNotAB (SubsetLink (NotLink A) B
    ;    (pln-formula-subset-direct-evaluation-side-effect-free NotA B)))
    (set! subsetNotAB (SubsetLink (NotLink A) B (stv 0 1)))
    ;(if verbose (display-atom "subsetNotAB" subsetNotAB)
    (if verbose (display subsetNotAB))
!#

    ; Create Subset notA B
    ; plan a - compute directly based on category membership size
    ; For present purposes where subsetNotAB is (Subset (Not {Gene}) GO), this
    ; would be the % of all genes-1 that are in the GO cat, or P(GO|~Gene), or
    ; (|GO|-1) / (|all genes|-1)
    ; Todo: this should only be done once and stored/cached somewhere - perhaps
    ; in the atomspace?
    ; num-genes is now set when biospace is loaded
    ;(set! num-genes (length (cog-get-atoms 'GeneNode)))
    (set! sizeB (length (get-set-members B)))
    (if verbose (display-label "sizeB" sizeB))
    (set! sNotAB (/ (- sizeB 1.0) (- num-genes 1)))
    (if verbose (display-label "sNotAB" sNotAB))
    ; Since we are using a reduced atomspace, I will use P(B) for the
    ; strength value, so it will be closer to what we will expect with the whole
    ; atomspace.
    (set! subsetNotAB (SubsetLink (NotLink A) B (stv sNotAB 1)))
    ;(set! subsetNotAB (SubsetLink (NotLink A) B (cog-tv B)))
    (if verbose (display subsetNotAB))

    #! ;--------------
    ; plan b - use the subset-direct-eval-rule
    ; Thhis approach is more compute expensive but perhaps more generalizable
    ; okay def too expensive, going back to plan a
    ; Todo: getting all genes should be done once and stored/cached:
    (set! all-genes (SetLink (cog-get-atoms 'GeneNode)))
    (set! NotA (SetLink (delete A (cog-outgoing-set all-genes))))
    (set! subsetNotAB (subset-direct-evaluation NotA B))
    (if verbose (display subsetNotAB))
    !#

    ;; Use the AttractionRule to create the AttractionLink
    ; Todo: ground the vars here -
    ;(set! grounded-attraction-rule
    ;    (substitute attraction-rule (list (cons (VariableNode "$B") B))))
    ;(display-atom "grounded-attraction-rule" grounded-attraction-rule)
    ;;(cog-bind pln-rule-attraction)
    ;(cog-bind grounded-attraction-rule)

    ; Use new command to apply attraction rule with no variables
    (pln-attraction-rule-no-variables subsetAB subsetNotAB)

    ; Or instead of above if we don't want to have a special "no variables"
    ; function for the rule, could do something like;
    ;(pln-formula-attraction subsetAB subsetNotAB (AttractionLink A B))
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
    ;(cog-create-intensional-link setL setPLAU)
    (cog-create-intensional-links setL long-set)
)
;(test)


; identify common supersets
; for each common superset L:
;       create (NOT L) ; which will be used in ASSOC calc
;       calc ASSOC(L,A)
;       calc ASSOC(L,B)
