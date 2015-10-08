; Background knowledge for simple bio inference example

(define gene-strength .00001)
(define gene-confidence .9)
(define gene-concept-strength .001)
(define gene-concept-confidence .9)

(GeneNode "PLAU" (stv gene-strength gene-confidence))
(GeneNode "L" (stv gene-strength gene-confidence))
(GeneNode "Q" (stv gene-strength gene-confidence))

(define PLAU (GeneNode "PLAU"))
(define L (GeneNode "L"))
(define setPLAU (SetLink PLAU))
(define setL (SetLink L))

;(PredicateNode "Gene-PLAU-overexpressed-in" (stv .5  1))
;(PredicateNode "Gene-L-overexpressed-in" (stv .5  1))
(make-overexpression-predicate (GeneNode "PLAU"))
;(make-overexpression-predicate (GeneNode "L"))  ; don't need this here i think

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement general rule to specify LSObserv members imply longlived
; implementing specifically for PLAU for the demo

(PredicateNode "LongLived" (stv .25  9))

;(ImplicationLink
;    (PredicateNode "Gene-PLAU-overexpressed-in")
;    (PredicateNode "LongLived") (stv .2 .7))

; todo: What should the tv for these implications be
(IntensionalImplicationLink
    (PredicateNode "Gene-PLAU-overexpressed-in")
    (PredicateNode "LongLived") (stv .2 .7))

(ConceptNode "GO_A" (stv gene-concept-strength gene-concept-confidence))
(ConceptNode "GO_B" (stv gene-concept-strength gene-concept-confidence))
(ConceptNode "GO_C" (stv gene-concept-strength gene-concept-confidence))

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

 (MemberLink (stv 1 1)
    (GeneNode "Q")
    (ConceptNode "GO_B"))

  (MemberLink (stv 1 1)
      (GeneNode "L")
      (ConceptNode "GO_D"))


; GO_A: PLAU, L
; GO_B: PLAU, L, Q
; GO_C: PLAU
; GO_D: L


; todo: no IntensionalEquivalenceLink - add to atomspace/opencog/atomspace/atom_types.script ?

; Domain particular knowledge/rule: If 2 genes are similar overexpression in one
; implies overexpression in the other.
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

