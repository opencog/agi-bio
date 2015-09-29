; Background knowledge for simple bio inference example

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement SchemaNode "makeOverExpressionPredicate"
; implementing specifically for PLAU for the demo

(ImplicationLink
    (PredicateNode "Gene-PLAU-overexpressed-in")
    (PredicateNode "LongLived") (stv .2 .7))

(IntensionalImplicationLink
    (PredicateNode "Gene-PLAU-overexpressed-in")
    (PredicateNode "LongLived") (stv .2 .7))

(GeneNode "PLAU" (stv .00001 1))
(GeneNode "L" (stv .00001 1))
(GeneNode "Q" (stv .00001 1))

(define PLAU (GeneNode "PLAU"))
(define L (GeneNode "L"))
(define setPLAU (SetLink PLAU))
(define setL (SetLink L))

(ConceptNode "GO_A" (stv .001 1))
(ConceptNode "GO_B" (stv .001 1))
(ConceptNode "GO_C" (stv .001 1))

(define GO_A (ConceptNode "GO_A"))

(MemberLink (stv 1 1)
    (GeneNode "PLAU")
    (ConceptNode "GO_A"))

(MemberLink (stv 1 1)
    (GeneNode "L")
    (ConceptNode "GO_A"))

(MemberLink (stv 1 1)
    (GeneNode "L")
    (ConceptNode "GO_B"))

(MemberLink (stv 1 1)
    (GeneNode "PLAU")
    (ConceptNode "GO_B"))

(MemberLink (stv 1 1)
    (GeneNode "PLAU")
    (ConceptNode "GO_C"))




; Using the general solution below now
; Domain particular knowledge/rule: if 2 genes have similar properties, over-
; expression of one implies overexpression of the other
; todo: implement makeOverepxressionPred schema node
; using particular genes for the demo for now
;(ImplicationLink
;    (IntensionalSimilarityLink
;        (GeneNode "PLAU")
;        (GeneNode "L"))
;    (IntensionalEquivalenceLink
;        (PredicateNode "Gene_PLAU_overexpressed-in")
;        (PredicateNode "Gene_L_overexpressed-in")))

; todo: no IntensionalEquivalenceLink - add to atomspace/opencog/atomspace/atom_types.script ?

; If 2 genes are similar overexpression in one implies overexpression in the
; other. (General version)
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

(define (create-overexpression-equivalance X Y XY)
    (IntensionalEquivalenceLink
        (make-overexpression-predicate X)
        (make-overexpression-predicate Y)
        (stv (cog-stv-strength XY) (cog-stv-confidence XY))))

; can you use ExecutionOutputLink with bindlink conclusion not at top level???

