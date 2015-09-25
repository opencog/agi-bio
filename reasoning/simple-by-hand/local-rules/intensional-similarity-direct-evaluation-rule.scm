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
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B")
        )
        (AndLink
            (VariableNode "$A")
            (VariableNode "$B")
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
   ; (define pre-superA (cog-get-supersets A))

    (display "in 2nd formula\n")
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
         (superA-length (length (superA)))
         (superB-length (length (superB)))
         (superUnion-length (length (lset-union (superA superB))))
         (superIntersection (lset-intersection (superA superB)))
        )
        (display-atom "superA-length" superA-length)
        (display-atom "superB-length" superB-length)
        (display-atom "superUnion-length" superUnion-length)
        (display-atom "superIntersection" superIntersection)

        (stv 1 1) ;temporary
     )
)

(define (cog-get-supersets A)
    ; TODO: do we also need to deal with SetLinks here? I don't think we do
    (display "in cog-get-supersets")
    (display-atom "arg A" A)
(let ((result
    (cog-bind
        (BindLink
            (VariableList
                (VariableNode "$B")
            )
            (ChoiceLink
                (MemberLink
                    A
                    (VariableNode "$B")
                )
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

