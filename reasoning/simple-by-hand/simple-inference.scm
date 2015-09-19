;Simple example of bio-inference using PLN by hand.

(use-modules (opencog))
(use-modules (opencog rule-engine))

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define (display-atom label atom)
    (newline)(display label)(display ": \n")(display atom))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the atomspace and rules ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(loadf "Lifespan-observations_2015-02-21.scm")
;(set_bio_tvs)

(load "background-knowledge.scm")
(load "pln-config.scm")
(load "substitute.scm")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the reasoning begin ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (1) Apply Member2SubsetRule, to get:
;
;  Subset (SetLink (GeneNode "L"))  (ConceptNode "GO_A")
;  Subset (SetLink (GeneNode "PLAU"))  (ConceptNode "GO_A")

;(cog-bind pln-rule-member-to-subset)
; This gets us extra results, namely for the pln rules also, so let's add
; substitution of source atoms before applying the rule

(define subst-map (make-hash-table 2))
; cog-bind with no variables doesn't seem to return anything
;(hash-set! subst-map (VariableNode "$X") (GeneNode "L"))
(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
(define grounded-member-to-subset
    (substitute pln-rule-member-to-subset subst-map))
;(display "grounded-member-to-subset: ")(display grounded-member-to-subset)
(define m2s (cog-bind grounded-member-to-subset))
(display "m2s: ")(display m2s)


;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
;      (SetLink (av 0 0 0)
;         (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   )
;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
;      (SetLink (av 0 0 0)
;         (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   )



; (2) apply subset-inversion-evaluation-rule(?), to get:
;
;  Subset  GO_A  (SetLink (GeneNode L))
;  Subset  GO_A  (SetLink (GeneNode PLAU))

; use the subset direct eval function (without PM because no variables)
(define subAL (inverse-subset-direct-evaluation (SetLink (GeneNode "L")) (ConceptNode "GO_A")))
(define subAPLAU (inverse-subset-direct-evaluation (SetLink (GeneNode "PLAU")) (ConceptNode "GO_A")))
(display-atom "subAL" subAL)
(display-atom "subAPLAU" subAPLAU)

; let's test out the PM version
; ... later ;)

;(SubsetLink (stv 0.33333334 0) (av 0 0 0)
;   (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   (SetLink (av 0 0 0)
;      (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;)
;(SubsetLink (stv 0.33333334 0) (av 0 0 0)
;   (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;   (SetLink (av 0 0 0)
;      (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;)

;(define subst-map (make-hash-table 2))
;(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
;(hash-set! subst-map (VariableNode "$B") (SetLink (GeneNode "L")))
;;(define subst-pairs (list (list (VariableNode "$A") (ConceptNode "GO_A"))
;;                          (list (VariableNode "$B") (SetLink (GeneNode "L")))))
;(define grounded-subset-evaluation
;    (substitute pln-rule-subset-direct-evaluation subst-map))
;;    (substitute pln-rule-subset-direct-evaluation subst-pairs))
;(display "before first bind\n")
;(display grounded-subset-evaluation)
;(cog-bind pln-rule-subset-direct-evaluation)
;(cog-bind grounded-subset-evaluation)
;(display "after first bind\n")


; (3) Calculate not-subset-direct-evaulation, to get:
;
;  Subset (NotLink GO_A)  (SetLink (Gene L))
;  Subset (NotLink GO_A)  (SetLink (Gene PLAU))
;
; Assuming here that (NotLink GO_A) is equivalent to the set of all links not in
; GO_A
;

(define not-GO_A-set
    (cog-new-link 'SetLink (lset-difference equal? (cog-get-atoms 'GeneNode)
        (get-set-members (ConceptNode "GO_A")))))
(display-atom "not-GO_A-set" not-GO_A-set)

(EquivalenceLink (stv 1 1)
    (NotLink (ConceptNode "GO_A"))
    not-GO_A-set)

(define sub-notGO_A-L
    (subset-direct-evaluation not-GO_A-set (SetLink (GeneNode "L"))))
(define sub-notGO_A-PLAU
    (subset-direct-evaluation not-GO_A-set (SetLink (GeneNode "PLAU"))))
(display-atom "sub-notGO_A-L" sub-notGO_A-L)

;(SubsetLink (stv 0 0.99999982) (av 0 0 0)
;   (SetLink (av 0 0 0)
;      (GeneNode "Q" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;   (SetLink (av 0 0 0)
;      (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;   )
;)

; now we need to substitute in (NotLink GO_A)
; then use some sort of equivalence rule like?:
(define notlink-substitution-rule
  (BindLink
    (VariableList
        (VariableNode "$A")
        (VariableNode "$B")
        (VariableNode "$C"))
    (AndLink
       (EquivalenceLink
            (NotLink (VariableNode "$A"))
            (VariableNode "$B"))
       (SubsetLink
            (VariableNode "$B")
            (VariableNode "$C")))
    (ExecutionOutputLink
        (GroundedSchemaNode "scm: pln-formula-notlink-substitution-rule")
        (ListLink
           (EquivalenceLink
                (NotLink (VariableNode "$A"))
                (VariableNode "$B"))
           (SubsetLink
                (VariableNode "$B")
                (VariableNode "$C"))
           (SubsetLink
                (NotLink (VariableNode "$A"))
                (VariableNode "$C"))))))

(define (pln-formula-notlink-substitution-rule notAB BC notAC)
    ;(display "foruma-notlink-subst-rule\n")
    ;(display-atom "notAB" notAB)
    ;(display-atom "BC" BC)
    ;(display-atom "notAC" notAC)
    (cog-set-tv! notAC
        (pln-formula-notlink-substitution-rule-side-effect-free notAB BC)))

(define (pln-formula-notlink-substitution-rule-side-effect-free notAB BC)
    ; todo: what to do about confidences?
    (let
        ((snotAB (cog-stv-strength notAB))
         (cnotAB (cog-stv-confidence notAB))
         (sBC (cog-stv-strength BC))
         (cBC (cog-stv-confidence BC)))
        ;(display "snotAB: ")(display snotAB)(newline)
        ;(display "cnotAB: ")(display cnotAB)(newline)
        (stv (* snotAB sBC) (* cnotAB cBC))))

(define notGO_A-subsets (cog-bind notlink-substitution-rule))
(display-atom "notGO_A-subsets" notGO_A-subsets)

;   (SubsetLink (stv 0 0.99999964) (av 0 0 0)
;      (NotLink (av 0 0 0)
;         (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;      )
;      (SetLink (av 0 0 0)
;         (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;   )
;   (SubsetLink (stv 0 0.99999964) (av 0 0 0)
;      (NotLink (av 0 0 0)
;         (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;      )
;      (SetLink (av 0 0 0)
;         (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;   )


; (4) Apply AttractionRule to get:
;
;  AttractionLink GO_A (SetLink (GeneNode L))
;  AttractionLink GO_A (SetLink (GeneNode PLAU))


; (5) Apply IntensionalSimilarityEvaluationRule, to get:

;  InstensionalSimilarityLink (SetLink (Gene L)) (SetLink (Gene PLAU))




