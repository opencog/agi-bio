; Gene similarity to overexpression rule
; Domain particular knowledge/rule: If 2 genes are similar overexpression in one
; implies overexpression in the other.
; BINDLINK VERSION FOR PATTERN MATCHER
(define gene-similarity2overexpression-equivalence
    (BindLink
        (VariableList
            (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "GeneNode"))
            (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "GeneNode")))
        (IntensionalSimilarityLink
            (VariableNode "$X")
            (VariableNode "$Y"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: create-overexpression-equivalence")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))))))

#!
; IMPLICATIONLINK VERSION FOR INSTANTIATION RULE
; Domain particular knowledge/rule: If 2 genes are similar overexpression in one
; implies overexpression in the other.
(define gene-similarity-implies-overexpression-equivalence
    (ImplicationLink
        (VariableList
            (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "GeneNode"))
            (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "GeneNode")))
        (IntensionalSimilarityLink
            (VariableNode "$X")
            (VariableNode "$Y"))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: create-overexpression-equivalence")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))))))
!#



(define (create-overexpression-equivalence X Y XY)
    (IntensionalEquivalenceLink
        ;(QuoteLink

            (ExecutionOutputLink
                (GroundedSchemaNode "scm: make-overexpression-predicate")
                (ListLink
                    X))

        ;(stv .5 .7));
        ;(QuoteLink

            (ExecutionOutputLink
                (GroundedSchemaNode "scm: make-overexpression-predicate")
                (ListLink
                    Y))

        ;(stv .5 .7))
        (stv (cog-stv-strength XY) (cog-stv-confidence XY)))
)

; can you use ExecutionOutputLink with bindlink conclusion not at top level???


; Name the rule
(cog-name-rule "gene-similarity2overexpression-equivalence")