; =============================================================================
; SubsetDirectEvaluationRule
;
; Should this be written like other rules to be used by chainer to be submitted
; to the pattern matcher?
; And
;   A
;   B
; |- ?
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
    ;(display "in formula side-effect-free\n")
    ;(display A)
    ;(display B)
    (let*
         ((membersA (set-members A))
          (membersB (set-members B))
          (intersectionAB (lset-intersection equal? membersA membersB))
          (sizeA (length membersA))
          (size-intersection (length intersectionAB)))
         (if (> sizeA 0)
            (stv (/ size-intersection sizeA) 1)
            (stv 0 1))))


(define (set-members S)
    (if (equal? (cog-type S) 'SetLink)
        (cog-outgoing-set S)
    ;(display "set-members cog-bind")(newline)
    (cog-outgoing-set
        (cog-bind
            (BindLink
                (VariableList
                    (VariableNode "$x"))
                (MemberLink
                    (VariableNode "$x")
                    S)
                (VariableNode "$x"))))))

; Name the rule
(define pln-rule-subset-direct-evaluation-name (Node "pln-rule-subset-direct-evaluation"))
(DefineLink pln-rule-subset-direct-evaluation-name pln-rule-subset-direct-evaluation)

; Direct function to call when evaluating with specific sets (because can't use
; the PM when no variables in the pattern)
(define (subset-direct-evaluation2  B)
    (pln-formula-subset-direct-evaluation A B (SubsetLink A B)))

; direct function - old version
(define (subset-direct-evaluation-old A B)
    (let*
         ([membersA (set-members A)]
          (membersB (set-members B))
          (intersectionAB (lset-intersection equal? membersA membersB))
          (sizeA (length membersA))
          (size-intersection (length intersectionAB)))
         (if (> sizeA 0)
            (SubsetLink A B (stv (/ size-intersection sizeA) 0))
            #nil)))
