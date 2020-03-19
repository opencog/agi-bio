; =============================================================================
; MemberToSubsetRule
;
; MemberLink
;   X
;   A
; |-
; SubsetLink
;   SetLink
;     X
;   A
;
; -----------------------------------------------------------------------------

(define pln-rule-member-to-subset
    (BindLink
        (VariableList
            (VariableNode "$X")
            (VariableNode "$A"))
        (MemberLink
            (VariableNode "$X")
            (VariableNode "$A"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-member-to-subset")
            (ListLink
                (MemberLink
                    (VariableNode "$X")
                    (VariableNode "$A"))
                (SubsetLink
                    (SetLink
                        (VariableNode "$X"))
                    (VariableNode "$A"))))))

(define (pln-formula-member-to-subset MXA SXA)
    (cog-set-tv!
        SXA
        (pln-formula-member-to-subset-side-effect-free MXA)))

(define (pln-formula-member-to-subset-side-effect-free MXA)
    (cog-tv MXA))

; =============================================================================

; Name the rule
(cog-name-rule "pln-rule-member-to-subset")
;(define pln-rule-member-to-subset-name (Node "pln-rule-member-to-subset"))
;(DefineLink pln-rule-member-to-subset-name pln-rule-member-to-subset)
