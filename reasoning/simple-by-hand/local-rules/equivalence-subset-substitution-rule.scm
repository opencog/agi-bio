; =============================================================================
; GeneralSimilaritySubstitutionRule
; (could combine with equivalence by using an or link in the premise
;
; AndLink
;   Equivalance
;       A
;       B
;   LinkType
;       B
;       C
; |-
; LinkType
;   A
;   C
;
; (looks a similar pattern as inference or abduction depending on which var in subset is used)

; i think this pattern will work for notlinks as well
(define pln-rule-equivalence-subset-substitution
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B")
            (VariableNode "$C")
        )
        (AndLink
            ; how to deal with the other direction here? use ORLink?
            ; but then how do you deal with that in the formula? check for confidence of 0?
            ; or could use 2 rules with SubsetLink A C in the second one, but that seems clunky
            (EquivalenceLink
                (VariableNode "$A")
                (VariableNode "$B")
            )
            (SubsetLink
                (VariableNode "$B")
                (VariableNode "$C")
            )
        )
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-equivalence-subset-substitution")
            (ListLink
                (EquivalenceLink
                    (VariableNode "$A")
                    (VariableNode "$B")
                )
                (SubsetLink
                    (VariableNode "$B")
                    (VariableNode "$C")
                )
                (SubsetLink
                    (VariableNode "$A")
                    (VariableNode "$C")
                )
            )
        )
    )
)

(define (pln-formula-equivalence-subset-substitution AB BC AC)
    (display "formula-equiv-subs-subst-rule\n")
    (display-atom "AB" AB)
    (display-atom "BC" BC)
    (display-atom "AC" AC)
    (cog-set-tv! AC
        (pln-formula-equivalence-subset-substitution-side-effect-free AB BC)
    )
)

(define (pln-formula-equivalence-subset-substitution-side-effect-free AB BC)
    (display "pln-formula-equivalance-subset-substitution-side-effect-free\n")
    ; todo: how to best handle confidence
    (let
        ((sAB (cog-stv-strength AB))
         (cAB (cog-stv-confidence AB))
         (sBC (cog-stv-strength BC))
         (cBC (cog-stv-confidence BC)))
        (display "sAB: ")(display sAB)(newline)
        (display "cAB: ")(display cAB)(newline)
        (stv (* sAB sBC) (* cAB cBC))
    )
)

; Name the rule
(cog-name-rule "pln-rule-equivalance-subset-substitution")