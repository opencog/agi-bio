;Simple example of bio-inference using PLN by hand.

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load "utilities.scm")

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

; let's just apply general rule for now even though it gives extras
(define m2s (cog-bind pln-rule-member-to-subset))

;; Applying ungrounded rule gets us extra results, namely for the pln rules
;; also, so let's add substitution of source atoms before applying the rule
;(define subst-map (make-hash-table 2))
;; cog-bind with no variables doesn't seem to return anything
;;(hash-set! subst-map (VariableNode "$X") (GeneNode "L"))
;(hash-set! subst-map (VariableNode "$A") (ConceptNode "GO_A"))
(define substitutions
    (list
        ; cog-bind with no variables doesn't seem to return anything, so need to
        ; leave one of the variables in and not substitute
        (cons (VariableNode "$X") (GeneNode "L"))
        ;(cons (VariableNode "$A") (ConceptNode "GO_A"))
    )
)
;;(display-label "substitutions" substitutions)
;(define grounded-member-to-subset
;    (substitute pln-rule-member-to-subset substitutions))
;;(display "grounded-member-to-subset: ")(display grounded-member-to-subset)
;(define m2s (cog-bind grounded-member-to-subset))

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
;;(define subst-pairs (list (cons (VariableNode "$A") (ConceptNode "GO_A"))
;;                          (cons (VariableNode "$B") (SetLink (GeneNode "L")))))
;(define grounded-subset-evaluation
;    (substitute-with-map pln-rule-subset-direct-evaluation subst-map))
;;    (substitute pln-rule-subset-direct-evaluation subst-pairs))
;(display "before first bind\n")
;(display grounded-subset-evaluation)
;(cog-bind pln-rule-subset-direct-evaluation)
;(cog-bind grounded-subset-evaluation)
;(display "after first bind\n")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; In place of steps 3-5 below, we will replace with step B that uses the command
; (cog-create-intensional-links L PLAU), which entails the steps 3-5, but does
; the evaluation in "batch" mode, i.e., by considering all the sets that
; these genes are members of.) We can come back to how to do the same using
; general PLN rules if that makes sense.
;
; One of the main issues to be resolved is how to define (Not ConceptNode S), in
; general, which seems to me to be domain specific. Perhaps different
; category/set types can specify formulas to used that define what
; (Not Category_of_Type_X) is.
;
; In the present context, we are defining (Not Gene_Category_S) to be all the
; genes in the system that are not members of S.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (B) Create intensional inheritance between L and PLAU, using
; cog-create-intensional-links command to get:
;
; IntensionalInheritanceLink L PLAU
;
; Note: This step replaces previous steps 3-5 (placed at the end of the file),
; which are no longer being used. This command internally carries out steps 3-5
; for all categories that the genes are members of.
; The cog-create-intensional-links command does the following:
; Todo: <fill in>

(define IS-L-PLAU (cog-create-intensional-links
                    (SetLink (GeneNode "L")) (SetLink (GeneNode "PLAU")))
)
(display-atom "IS-L-PLAU" IS-L-PLAU)

(display "\n\n==================================================================\n")


(define

; (3) Calculate not-subset-direct-evaulation, to get:
; Note: this step not needed when using batch command
; (cog-create-intensional-links L PLAU)
;
;  Subset (NotLink GO_A)  (SetLink (Gene L))
;  Subset (NotLink GO_A)  (SetLink (Gene PLAU))
;
; Assuming here that (NotLink GO_A) is equivalent to the set of all genes not in
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
; then use some sort of equivalence rule like equivalence-subset-substitution-rule?:
(load "local-rules/equivalence-subset-substitution-rule.scm")
(define notGO_A-subsets (cog-bind equivalence-subset-substitution-rule))
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

(define attraction-links (cog-bind pln-rule-attraction))
(display-atom "attraction-links" attraction-links)

;   (AttractionLink (stv 0.33333334 0.99999964) (av 0 0 0)
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;      (SetLink (av 0 0 0)
;         (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;   )
;   (AttractionLink (stv 0.33333334 0.99999964) (av 0 0 0)
;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
;      (SetLink (av 0 0 0)
;         (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
;      )
;   )




; (5) Apply IntensionalSimilarityEvaluationRule, to get:

;  InstensionalSimilarityLink (SetLink (Gene L)) (SetLink (Gene PLAU))


;(load "local-rules/intensional-similarity-direct-evaluation-rule.scm")
;(define islink (cog-bind pln-rule-intensional-similarity-direct-evaluation))
;(display-atom "islink" islink)

