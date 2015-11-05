; Background knowledge for simple bio inference on full biospace

""
(define gene-strength .00001)
(define gene-confidence .9)
(define gene-concept-strength .001)
(define gene-concept-confidence .9)
""


(define PLAU (GeneNode "PLAU"))
(define setPLAU (SetLink PLAU))

;(define target (GeneNode "MOCOS"))
(define target (GeneNode "RYR1"))

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement general rule to specify LSObserv members imply longlived
; implementing specifically for PLAU for the demo

(PredicateNode "LongLived" (stv .1  .8))

; Todo: Should the following be intensional or mixed?
;(ImplicationLink
;      (ExecutionOutputLink
;          (GroundedSchemaNode "scm: make-over-expression-predicate")
;          (GeneNode "PLAU"))
;      (PredicateNode "LongLived") (stv .2 .7))

; Intensional version of the above
; todo: What should the tv for these implications be
(define plau-implies-ll (IntensionalImplicationLink
    ;(QuoteLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
                (GeneNode "PLAU")))

     ;(stv .5 .7))
    (PredicateNode "LongLived") (stv .5 .7)))

(display-var "plau-implies-ll")


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
            (GroundedSchemaNode "scm: create-overexpression-equivalance")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))))))


; IMPLICATIONLINK VERSION FOR INSTANTIATION RULE
; Domain particular knowledge/rule: If 2 genes are similar overexpression in one
; implies overexpression in the other.
(define gene-similarity2overexpression-equivalence-impl
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
            (GroundedSchemaNode "scm: create-overexpression-equivalance")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))))))




(define (create-overexpression-equivalance X Y XY)
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
        (stv (cog-stv-strength XY) (cog-stv-confidence XY))))

; can you use ExecutionOutputLink with bindlink conclusion not at top level???

