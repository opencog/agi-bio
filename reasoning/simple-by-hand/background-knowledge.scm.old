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

; overexpression of members of LifespanObservationIncrease imply longlived
; todo: implement general rule to specify LSObserv members imply longlived
; implementing specifically for PLAU for the demo

(PredicateNode "LongLived" (stv .25  .8))

; Todo: Should the following be intensional or mixed?
;(ImplicationLink
;      (ExecutionOutputLink
;          (GroundedSchemaNode "scm: make-over-expression-predicate")
;          (GeneNode "PLAU"))
;      (PredicateNode "LongLived") (stv .2 .7))

; todo: What should the tv for these implications be
(define plau-implies-ll (IntensionalImplicationLink
    ;(QuoteLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
                (GeneNode "PLAU")))

     ;(stv .5 .7))
    (PredicateNode "LongLived") (stv .2 .7)))

(display-var "plau-implies-ll")

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


; Domain particular knowledge/rule: If 2 genes are similar, overexpression in one
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

; Domain particular knowledge/rule: If 2 genes are similar overexpression in one
; implies overexpression in the other.
; IMPLICATIONLINK VERSION FOR INSTANTIATION RULE
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



