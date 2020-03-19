; =============================================================================
; SingletonSimilarityRule
;
; IntensionalSimilarity
;   SetLink
;       A
;   SetLink
;       B
; |-
; IntensionalSimilarity
;   A
;   B
;
; -----------------------------------------------------------------------------

(define pln-rule-singleton-similarity
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B"))
        (IntensionalSimilarityLink
            (SetLink
                (VariableNode "$A"))
            (SetLink
                (VariableNode "$B")))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: pln-formula-singleton-similarity")
            (ListLink
                (IntensionalSimilarityLink
                    (SetLink
                        (VariableNode "$A"))
                    (SetLink
                        (VariableNode "$B")))
                (IntensionalSimilarityLink
                    (VariableNode "$A")
                    (VariableNode "$B"))))))


(define (pln-formula-singleton-similarity singletonAB AB)
    (cog-set-tv!
        AB
        (pln-forumula-singleton-similarity-side-effect-free singletonAB AB)))

(define (pln-forumula-singleton-similarity-side-effect-free singletonAB AB)
    (stv (cog-stv-strength singletonAB) (cog-stv-confidence singletonAB)))

; Name the rule
(cog-name-rule "pln-rule-singleton-similarity")
;(define pln-rule-singleton-similarity-name (Node "pln-rule-singleton-similarity"))
;(DefineLink pln-rule-singleton-similarity-name pln-rule-singleton-similarity)