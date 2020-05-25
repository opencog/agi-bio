;; ***** NOTE *****
;; I am switching over to do a batch mode scheme function/command rather than as
;; a general pln rule.  cog-create-intensional-similarity-link.scm

; =============================================================================
; IntensionalSimilarityEvaluationRule
;
; AndLink
;   A
;   B
; |-
; IntensionalSimilarityLink
;   A
;   B
;
; -----------------------------------------------------------------------------

(define pln-rule-intensional-similarity-direct-evaluation
    (BindLink
    ;(VariableList
        ;(TypedVariableLink
        ;   (VariableNode "$A")
        ;   (TypeChoice
        ;      (TypeNode "GeneNode")
        ;      (TypeNode "ConceptNode")))
        ;(TypedVariableLink
        ;   (VariableNode "$B")
        ;   (TypeChoice
        ;      (TypeNode "GeneNode")
        ;      (TypeNode "ConceptNode"))))

        (VariableList
            ;(TypedVariableLink
                (VariableNode "$A")
            ;    (TypeNode "GeneNode"))
            ;(TypedVariableLink
                (VariableNode "$B")
            ;    (TypeNode "GeneNode"))
        )
        (AndLink
            (VariableNode "$A")
            (VariableNode "$B")
            (NotLink
                (EqualLink
                    (VariableNode "$A")
                    (VariableNode "$B")
                )
            )
        )
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-intensional-similarity-direct-evaluation")
            (ListLink
                (VariableNode "$A")
                (VariableNode "$B")
                (IntensionalSimilarityLink
                    (VariableNode "$A")
                    (VariableNode "$B")
                )
            )
        )
    )
)

(define (pln-formula-intensional-similarity-direct-evaluation A B AB)
    (display "in main formula\n")
    (cog-set-tv!
        AB (pln-formula-intensional-similarity-direct-evaluation-side-effect-free A B AB)
    )
)

(define (pln-formula-intensional-similarity-direct-evaluation-side-effect-free A B AB)
    (load-from-path "rules/attraction-rule.scm")
    ; (define pre-superA (cog-get-supersets A))

    (define AttractionLinksA)
    (define AttractionLinksB)

    (display "in 2nd formula\n")
    (display-atom "A" A)
    (display-atom "B" B)
    ; Forumula is based on: http://wiki.opencog.org/wikihome/index.php/Direct_Evaluation_of_Intensional_Links
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

        (set! attractionLinksA
            (map (make-attraction-link
                 (make-list superIntersection-length A) superIntersection)
            )
        )
        (set! attractionLinksB
            (map (make-attraction-link
                 (make-list superIntersection-length B) superIntersection)
            )
        )




        (stv 1 1) ;temporary
     )
)

; TODO: this is specialized for genes currently -- need to generalize
; TODO: and it's bound to helper functions in simple-inference.scm:
(define (make-attraction-link A B)




(define (cog-get-supersets A)
    ; TODO: do we also need to deal with SetLinks here? I don't think we do
    (display "in cog-get-supersets")
    (display-atom "arg" A)
(let ((result
    (cog-outgoing-set
        (cog-bind
            (BindLink
                (VariableList
                    (VariableNode "$B")
                )
                (ChoiceLink
                    ;(MemberLink
                    ;    A
                    ;    (VariableNode "$B")
                    ;)
                    (SubsetLink
                        A
                        (VariableNode "$B")
                    )
                    (SubsetLink
                        (SetLink
                            A
                        )
                        (VariableNode "$B")
                    )
                )
                (VariableNode "$B")
            )
        )
    )
    )) result )
)

(define (cog-get-supersets2 A)
    (cog-bind
        (BindLink
            (VariableNode "$B")
            (OrLink
                (MemberLink
                    A
                    (VariableNode "$B"))
                (SubsetLink
                    A
                    (VariableNode "$B")))
            (VariableNode "$B"))))


; Direct function to call when evaluating for specific sets (because can't use
; the PM when no variables in the pattern)
(define (intensional-similarity-direct-evaluation A B)
    (pln-formula-intensional-similarity-direct-evaluation A B
        (IntensionalSimilarityLink A B))
)



; Name the rule
(define pln-rule-intensional-similarity-direct-evaluation-name
  (Node "pln-rule-intensional-similarity-direct-evaluation"))
(DefineLink
  pln-rule-intensional-similarity-direct-evaluation-name
  pln-rule-intensional-similarity-direct-evaluation)

