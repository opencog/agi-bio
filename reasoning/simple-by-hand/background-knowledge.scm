; Background knowledge for simple bio inference example

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement SchemaNode "makeOverExpressionPredicate"
; implementing specifically for PLAU for the demo
(ImplicationLink
    (PredicateNode "Gene_PLAU_overexpressed")
    (PredicateNode "LongLived"))

(GeneNode "PLAU" (stv .00001 1))
(GeneNode "L" (stv .00001 1))

(ConceptNode "GO_A" (stv .001 1))

(MemberLink
    (GeneNode "PLAU")
    (ConceptNode "GO_A"))

(MemberLink
    (GeneNode "L")
    (ConceptNode "GO_A"))


; Domain particular knowledge/rule: if 2 genes have similar properties, over-
; expression of one implies overexpression of the other
; todo: implement makeOverepxressionPred schema node
; using particular genes for the demo for now
(ImplicationLink
    (IntensionalSimilarityLink
        (GeneNode "PLAU")
        (GeneNode "L"))
    (IntensionalEquivalenceLink
        (PredicateNode "Gene_PLAU_overexpressed")
        (PredicateNode "Gene_L_overexpressed")))

; todo: no IntensionalEquivalenceLink - add to atomspace/opencog/atomspace/atom_types.script ?





