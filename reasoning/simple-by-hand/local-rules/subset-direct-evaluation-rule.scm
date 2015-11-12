; =============================================================================
; SubsetDirectEvaluationRule
;
; Should this be written like other rules to be used by chainer to be submitted
; to the pattern matcher?
; And
;   A
;   B
; |-
; SubsetLink
;   A
;   B
;
; Calculate tv via direct evaulation based on set memberships.
; P(x in B | x in A), or IOW the % of members in A that are also in B

; -----------------------------------------------------------------------------

(define pln-rule-subset-direct-evaluation
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (AndLink
            (VariableNode "$A")
            (VariableNode "$B")
            ; Avoid forming (Subset A A)
            (NotLink
                (EqualLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-subset-direct-evaluation")
            (ListLink
                (VariableNode "$A")
                (VariableNode "$B")
                (SubsetLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))

(define (pln-formula-subset-direct-evaluation A B AB)
    ;(define tv (pln-formula-subset-direct-evaluation-side-effect-free A B AB))
    ;(display "tv: " )(display tv)(newline)
    (cog-set-tv!
        AB (pln-formula-subset-direct-evaluation-side-effect-free A B))
    )

(define (pln-formula-subset-direct-evaluation-side-effect-free A B)
    (load "rule-helpers.scm")
    ;(display "in subset-direct-eval-formula-side-effect-free\n")
    ;(display A)
    ;(display B)
    (let*
         ((membersA (get-set-members A))
          (membersB (get-set-members B))
          (display-var "membersB")
          ; todo: We could filter out low tv members of the sets above
          (intersectionAB (lset-intersection equal? membersA membersB))
          (sizeA (length membersA))
          (size-intersection (length intersectionAB)))
         (if (> sizeA 0)
            (stv (/ size-intersection sizeA) 1)
            (stv 0 1))))


; Name the rule
(cog-name-rule "pln-rule-subset-direct-evaluation")
;(define pln-rule-subset-direct-evaluation-name (Node "pln-rule-subset-direct-evaluation"))
;(DefineLink pln-rule-subset-direct-evaluation-name pln-rule-subset-direct-evaluation)

; Direct function to call when evaluating for specific sets (because can't use
; the PM when no variables in the pattern)
(define (subset-direct-evaluation A  B)
    ;(display "(subset-direct-evaluation A B)")
    ;(display-atom "A" A)
    ;(display-atom "B" B)
    (pln-formula-subset-direct-evaluation A B (SubsetLink A B)))

; TODO: Add inverse-subset-direct-evaluation-rule

; Direct function to call when evaluating for specific sets
(define (inverse-subset-direct-evaluation A  B)
    (pln-formula-subset-direct-evaluation B  A (SubsetLink B A)))