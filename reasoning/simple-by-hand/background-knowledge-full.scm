; Background knowledge for simple bio inference on full biospace

""
(define gene-strength .00001)
(define gene-confidence .9)
(define gene-concept-strength .001)
(define gene-concept-confidence .9)
""


;(define PLAU (GeneNode "PLAU"))
;(define setPLAU (SetLink PLAU))

(define long-gene (GeneNode "TBK1"))
;(define long-gene (GeneNode "PRKCA"))
(define long-set (SetLink long-gene))

;(define target (GeneNode "MOCOS"))
;(define target (GeneNode "RYR1"))
(define target (GeneNode "LY96"))
;(define target (GeneNode "ADCY9"))

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement general rule to specify LSObserv members imply longlived
; implementing specifically for PLAU for the demo

(PredicateNode "LongLived" (stv .15  .8))

; Todo: Should the following be intensional or mixed?
;(ImplicationLink
;      (ExecutionOutputLink
;          (GroundedSchemaNode "scm: make-over-expression-predicate")
;          (GeneNode "PLAU"))
;      (PredicateNode "LongLived") (stv .2 .7))

; Intensional version of the above
; todo: What should the tv for these implications be
(define long-gene-implies-ll (IntensionalImplicationLink
    ;(QuoteLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
                long-gene))

     ;(stv .5 .7))
    (PredicateNode "LongLived") (stv .5 .7)))

(display-var "long-gene-implies-ll" long-gene-implies-ll)

; Gene Similarity Variant Rule
; Todo: create ImplicationLink version to use when InstantiationRule is ready
; Domain particular knowledge/rule: If 2 genes are similar and one has a variant
; that implies a phenotype, then the other has a variant that implies the
; phenotype.
; BINDLINK VERSION FOR PATTERN MATCHER
(define gene-similarity-variant-rule
    (BindLink
        (VariableList
            (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "GeneNode"))
            (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "GeneNode"))
            (VariableNode "$P")) ;the phenotype
        (AndLink
            (ChoiceLink
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))
                (IntensionalSimilarityLink
                    (VariableNode "$Y")
                    (VariableNode "$X")))
            (IntensionalImplicationLink
                (ExecutionOutputLink
                    (GroundedSchemaNode "scm: make-contains-significant-variant-predicate")
                    (ListLink
                        (VariableNode "$X")))
                (VariableNode "$P")))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: create-variant-implies-phenotype")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))
                (VariableNode "$P")))))


; Gene Similarity Variant Rule
; Todo: create ImplicationLink version to use when InstantiationRule is ready
; Domain particular knowledge/rule: If 2 genes are similar and one has a variant
; that implies a phenotype, then the other has a variant that implies the
; phenotype.
; IMPLICATION VERSION FOR INSTANTIATION RULE
(define gene-similarity-variant-implication
    (ImplicationLink
        (VariableList
            (TypedVariableLink
                (VariableNode "$X")
                (TypeNode "GeneNode"))
            (TypedVariableLink
                (VariableNode "$Y")
                (TypeNode "GeneNode"))
            (VariableNode "$P")) ;the phenotype
        (AndLink
            (ChoiceLink
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))
                (IntensionalSimilarityLink
                    (VariableNode "$Y")
                    (VariableNode "$X")))
            (IntensionalImplicationLink
                (ExecutionOutputLink
                    (GroundedSchemaNode "scm: make-contains-significant-variant-predicate")
                    (ListLink
                        (VariableNode "$X")))
                (VariableNode "$P")))
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: create-variant-implies-phenotype")
            (ListLink
                (VariableNode "$X")
                (VariableNode "$Y")
                (IntensionalSimilarityLink
                    (VariableNode "$X")
                    (VariableNode "$Y"))
                (VariableNode "$P")))))


(define (create-variant-implies-phenotype X Y XY P)
    (ImplicationLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-contains-significant-variant-predicate")
            (ListLink Y))
        P
        (stv (cog-stv-strength XY) (* .8 cog-stv-confidence XY))))






(define los (lifespan-observation-increased-members))
(define known-longevity-genes (list
    (GeneNode "CETP" (stv .0001 .9))))
(define long-genes (append los known-longevity-genes))
