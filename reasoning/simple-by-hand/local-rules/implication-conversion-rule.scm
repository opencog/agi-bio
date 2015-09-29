; =============================================================================
; ImplicationConversionRule
;
; IntensionalImplication
;       A
;       B
; |-
; Implication
;   A
;   B
;
; will need to add for extensional mixed implication conversion also
; use same rule for inheritance conversion? note: this is an inheritance rule,
; but it requres both a subset and intensionalinher as input
; -----------------------------------------------------------------------------

(define pln-rule-intensional-implication-conversion
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (IntensionalImplicationLink
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-implication-conversion")
            (ListLink
                (IntensionalImplicationLink
                    (VariableNode "$A")
                    (VariableNode "$B"))
                (ImplicationLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))


(define (pln-formula-implication-conversion iiAB iAB)
    (cog-set-tv!
        iAB
        (pln-forumula-implication-conversion-side-effect-free iiAB iAB)))

(define (pln-forumula-implication-conversion-side-effect-free iiAB iAB)
    (cog-tv iiAB))

; Name the rule
(define pln-rule-intensional-implication-conversion-name
    (Node "pln-rule-intensional-implication-conversion"))
(DefineLink pln-rule-intensional-implication-conversion-name
    pln-rule-intensional-implication-conversion)