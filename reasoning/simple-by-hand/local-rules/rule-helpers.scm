(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog rule-engine))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cog-apply-rule
;
; Utility function to do a one-step inference via the URE using a particular
; rule on specified atoms.
;
; Requires that the applicable scheme rule file (i.e., from
; opencog/reasoning/pln/rules) has been loaded.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (cog-apply-rule rule atoms)
    (define temp-rbs)
    (define URE-inheritance)
    (define rules)

    ; Do URE configuration for the rule
    (load-from-path "utilities.scm")
    (load-from-path "av-tv.scm")
    (load-from-path "rule-engine-utils.scm")

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Define temporary PLN rule-based system ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Delete any previous rule associations with temp-rbs
    ; First need to delete the top level SetLinks
    ; Using ConceptNode here rather than temp-rbs variable, b/c for some reason
    ; cog-delete sets temp-rbs to an undefined handle
    (for-each cog-delete (cog-get-root (ConceptNode "temp-pln")))
    ; then can delete the MemberLinks
    (for-each cog-delete (cog-incoming-set (ConceptNode "temp-pln")))

    (set! temp-rbs (ConceptNode "temp-pln"))

    (set! URE-inheritance
        (InheritanceLink
           temp-rbs
           (ConceptNode "URE")
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Associate rules to PLN ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; rule needs to eather be string with rule name or (Node "rule-name")
    (if (string? rule)
        (set! rule (Node rule)))

    ; List the rules and their weights.
    (set! rules (list (list rule 1)))

    ; Associate rules to PLN
    (ure-add-rules temp-rbs rules)

    ;;;;;;;;;;;;;;;;;;;;;
    ;; Other paramters ;;
    ;;;;;;;;;;;;;;;;;;;;;

    ; Termination criteria parameters
    (ure-set-num-parameter temp-rbs "URE:maximum-iterations" 1)

    ; Attention allocation (0 to disable it, 1 to enable it)
    (ure-set-fuzzy-bool-parameter temp-rbs "URE:attention-allocation" 0)

    ; atoms variable needs to be a SetLink
    (if (list? atoms)
        (set! atoms (SetLink atoms)))
    (if (not (equal? (cog-type atoms) 'SetLink))
        (set! atoms (SetLink atoms)))

    (cog-fc atoms temp-rbs atoms)
)

(define (cog-apply-rule-test)
    (define atoms (list
        (InheritanceLink (ConceptNode "A" (stv .3 1))
            (ConceptNode "B" (stv .3 1)))
        (InheritanceLink (ConceptNode "B") (ConceptNode "C" (stv .3 1)))))
    (load-from-path "rules/deduction.scm")
    (display "doing deduction rule\n")
    (display (cog-apply-rule "pln-rule-deduction" atoms))
    (load-from-path "rules/induction-rule.scm")
    (display "doing irrelevant rule\n")
    (display (cog-apply-rule "pln-rule-induction-inheritance" atoms))
)
(cog-apply-rule-test)


; Returns members of set S that are defined via a SetLink or through MemberLinks
(define (get-set-members S)
    ; todo: filter out low tv members?
    (if (equal? (cog-type S) 'SetLink)
        (cog-outgoing-set S)
        (cog-outgoing-set
            (cog-bind
                (BindLink
                    (VariableList
                        (VariableNode "$x"))
                    (MemberLink
                        (VariableNode "$x")
                        S)
                    (VariableNode "$x"))))))


(define (cog-get-supersets A)
    ; TODO: do we also need to deal with SetLinks here? I don't think we do
    (display "in cog-get-supersets")
    (display-atom "arg" A)
(let ((result
    (cog-outgoing-set
        (cog-bind
            (BindLink
                (VariableList
                    (VariableNode "$B")
                )
                (ChoiceLink
                    ;(MemberLink
                    ;    A
                    ;    (VariableNode "$B")
                    ;)
                    (SubsetLink
                        A
                        (VariableNode "$B")
                    )
                    (SubsetLink
                        (SetLink
                            A
                        )
                        (VariableNode "$B")
                    )
                )
                (VariableNode "$B")
            )
        )
    )
    )) result )
)

; Assumed here is that A is a set that contains GeneNode members via MemberLinks
; TODO: this creates very large sets (about 26K?), any way to get around that?
;       or maybe it's not really a problem
;
(define (create-not-gene-set A)
    (display-atom "(create-not-gene-set A)" A)
    (cog-new-link 'SetLink (lset-difference equal? (cog-get-atoms 'GeneNode)
        (get-set-members A))))


; apply AttractionRule with no VariableNodes
(define (pln-attraction-rule-no-variables subsetAB subsetNotAB)
    (define attractionAB)
    ;(display "(pln-attraction-rule-no-variables subsetAB subsetNotAB)")
    (set! attractionAB (AttractionLink
                            (list-ref (cog-outgoing-set subsetAB) 0)
                            (list-ref (cog-outgoing-set subsetAB) 1)))
    (pln-formula-attraction attractionAB subsetAB subsetNotAB))

