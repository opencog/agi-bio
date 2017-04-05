; =============================================================================
; EquivalenceTransformationRule
;
; EquivalenceLink
;   A
;   B
; |-
; AndLink
;   ImplicationLink
;       A
;       B
;   ImplicationLink
;       B
;       A
;
; Due to pattern matching issues, currently the file has been divided into 3
; parts, each pertaining to different links. The rules are :-
;       pln-rule-equivalence-transformation
;       pln-rule-intensional-equivalence-transformation
;       pln-rule-extensional-equivalence-transformation
;

; -----------------------------------------------------------------------------

(define equivalence-transformation-rule
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (EquivalenceLink
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: equivalence-transformation-formula")
            (ListLink
                (AndLink
                    (ImplicationLink
                        (VariableNode "$A")
                        (VariableNode "$B"))
                    (ImplicationLink
                        (VariableNode "$B")
                        (VariableNode "$A")))
                (EquivalenceLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))


(define (equivalence-transformation-formula AII EV)
    (let (
            (IAB (gar AII))
            (IBA (gdr AII)))
         (cog-set-tv!
            IAB
            (equivalence-transformation-side-effect-free-formula IAB EV))
         (cog-set-tv!
            IBA
            (equivalence-transformation-side-effect-free-formula IBA EV))
    AII))

(define (equivalence-transformation-side-effect-free-formula IAB EV)
    (let* (
            (A (gar IAB))
            (B (gdr IAB))
            (sA (cog-stv-strength A))
            (sB (cog-stv-strength B))
            (sEV (cog-stv-strength EV))
            (sIAB (/ (* (+ 1 (/ sB sA)) sEV) (+ 1 sEV))))
        ;(display "\n---\nequivalence-tranformation-formula\n")
        ;(display-label "IAB" IAB)
        ;(display-label "EV" EV)
        ;(display-label "A" A)
        ;(display-label "B" B)
        ;(display-label "sA" sA)
        ;(display-label "sB" sB)
        ;(display-label "sEV" sEV)
        ;(display-label "sIAB" sIAB)

        (stv sIAB (cog-stv-confidence EV))))

; Name the rule
(define equivalence-transformation-rule-name
  (DefinedSchemaNode "equivalence-transformation-rule"))
(DefineLink
  equivalence-transformation-rule-name
  equivalence-transformation-rule)



;------------------------------------------------------------------------------
; IntensionalEquivalance version
;
(define pln-rule-intensional-equivalence-transformation
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (IntensionalEquivalenceLink
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: equivalence-transformation-formula")
            (ListLink
                (AndLink
                    (IntensionalImplicationLink
                        (VariableNode "$A")
                        (VariableNode "$B"))
                    (IntensionalImplicationLink
                        (VariableNode "$B")
                        (VariableNode "$A")))
                (IntensionalEquivalenceLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))

; Name the rule
(define pln-rule-intensional-equivalence-transformation-name
  (DefinedSchemaNode "pln-rule-intensional-equivalence-transformation"))
(DefineLink
  pln-rule-intensional-equivalence-transformation-name
  pln-rule-intensional-equivalence-transformation)


; ExtensionalEquivalanceTransformationRule
;
(define pln-rule-extensional-equivalence-transformation
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExtensionalEquivalenceLink
            (VariableNode "$A")
            (VariableNode "$B"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: equivalence-transformation-formula")
            (ListLink
                (AndLink
                    (ExtensionalImplicationLink
                        (VariableNode "$A")
                        (VariableNode "$B"))
                    (ExtensionalImplicationLink
                        (VariableNode "$B")
                        (VariableNode "$A")))
                (ExtensionalEquivalenceLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))

; Name the rule
(define pln-rule-extensional-equivalence-transformation-name
  (DefinedSchemaNode "pln-rule-extensional-equivalence-transformation"))
(DefineLink
  pln-rule-extensional-equivalence-transformation-name
  pln-rule-extensional-equivalence-transformation)
