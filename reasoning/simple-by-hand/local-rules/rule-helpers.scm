  "
 Helper functions for rule application

 (get-set-members set)
 (cog-get-supersets A)
 (cog-apply-rule rule atoms #:optional no-focus-set)
 (define (create-not-gene-set A)

 (cog-define-name rule-symbol-name)

 ; apply AttractionRule with no VariableNodes
 (define (pln-attraction-rule-no-variables subsetAB subsetNotAB)

"

(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog rule-engine))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (cog-define-name rule-symbol-name)
;
; Helper function for naming rules
;
; Usage:
;   (cog-define-name "pln-rule-deduction")
; produces the same result as:
;   (define pln-rule-deduction-name (Node "pln-rule-deduction"))
;   (DefineLink pln-rule-deduction-name pln-rule-deduction)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (cog-name-rule rule-symbol-name)
    (define name-append (string-append rule-symbol-name "-name"))
    (eval `(define ,(string->symbol name-append) ,(DefinedSchema rule-symbol-name))
        (interaction-environment))
    (DefineLink
        (DefinedSchema rule-symbol-name)
        (eval-string rule-symbol-name)))




;-------------------------------------------------------------------------------
(define* (cog-apply-rule rule atoms #:optional no-focus-set)
#!
 Do a one-step inference via the URE using a particular rule on specified atoms

   rule - String representation of the rule symbol name used in the rule
      definition file, e.g., "pln-rule-deduction". Aternatively, can also pass
      the rule name Node defined in the rule file, e.g., (Node "pln-rule-deduction")

   atoms - The source atom(s) used by the forward chainer for applying the rule.
      Can be a scheme list of Atoms, a SetLink containing Atoms, or an
      individual Atom. By default, these atoms will also serve as the focus set
      of the chainer, unless the optional no-focus-set parameter is set to #t.

   no-focus-set (optional) - Boolean that defaults to #f. When #t, no focus set
      is specified, and the whole atomspace is searched for additional premises
      to satisfy the rule. When #f (default) the atoms in the 'atoms' parameter
      are used as the focus set.

 Requires that the applicable scheme rule file (i.e., from
 opencog/reasoning/pln/rules) has been loaded.

 Example usage:
 (define ab (InheritanceLink (ConceptNode "a") (ConceptNode "b")))
 (define ab (InheritanceLink (ConceptNode "b") (ConceptNode "c")))
 (cog-apply-rule "pln-rule-deduction" (list ab bc))
!#
    (define temp-rbs)
    (define URE-inheritance)
    (define rules)
    (define focus-set)

    ; Do URE configuration for the rule
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
    ; rule needs to either be string with rule name or (Node "rule-symbol-name")
    (if (not (or (string? rule)
                 (and (cog-atom? rule) (equal? (cog-type rule) 'DefinedSchemaNode))))
        (begin
            (display "\n    Usage: cog-apply-rule \"quoted-rule-name\" ")
            (display "(list atom1 atom2 ...)\n\n")
            (exit)
        )
        (begin
            (if (string? rule)
                (set! rule (DefinedSchemaNode rule)))

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

            ;(display-atom "cog-apply-rule source atoms input" atoms)

            ; atoms variable needs to be a SetLink
            (if (list? atoms)
                (set! atoms (SetLink atoms)))
            (if (equal? (cog-type atoms) 'ListLink)
                (set! atoms (SetLink (cog-outgoing-set atoms))))
            (if (not (equal? (cog-type atoms) 'SetLink))
                (set! atoms (SetLink atoms)))

            (if no-focus-set
                (set! focus-set (SetLink))
                (set! focus-set atoms))
            ;(display-atom "focus-set" focus-set)

            ;(display-atom "cog-apply-rule source atoms" atoms)

            (cog-fc atoms temp-rbs focus-set)
        )
    )
)

#;
(define (cog-apply-rule-test)

    (define atoms (list
        (InheritanceLink (ConceptNode "A" (stv .3 1))
            (ConceptNode "B" (stv .3 1)))
        (InheritanceLink (ConceptNode "B") (ConceptNode "C" (stv .3 1)))))
    (load-from-path "rules/deduction.scm")
    (load-from-path "av-tv.scm")
    (display "Doing deduction rule\n")
    (display (cog-apply-rule "deduction-rule" atoms))
    (load-from-path "rules/induction-rule.scm")
    (display "Doing irrelevant rule\n")
    (display (cog-apply-rule "induction-inheritance-rule" atoms))
)
;(cog-apply-rule-test)



(define (get-set-members set)
"
 Return members of set that are defined through MemberLink relationships with
 set, or if set is a SetLink return its outgoing set.

"
    ; todo: filter out low tv members?
    (if (equal? (cog-type set) 'SetLink)
        (cog-outgoing-set set)
        (cog-outgoing-set
            (cog-bind
                (BindLink
                    (VariableList
                        (VariableNode "$x"))
                    (MemberLink
                        (VariableNode "$x")
                        set)
                    (VariableNode "$x"))))))


(define (cog-get-supersets A)
"
 Return the atoms that A is a (direct) subset of through a SubsetLink
 relationship. Also checks for cases where singleton {A} is a subset.
"
    ; TODO: do we also need to deal with SetLinks here? I don't think we do
    ;(display "in cog-get-supersets")
    ;(display-atom "arg" A)
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
;       (See Ben had a suggestion to do a new link type(?)
;
(define (create-not-gene-set A)
    ;(display-atom "(create-not-gene-set A)" A)
    (cog-new-link 'SetLink (lset-difference equal? (cog-get-atoms 'GeneNode)
        (get-set-members A))))


; apply AttractionRule with no VariableNodes
(define (pln-attraction-rule-no-variables subsetAB subsetNotAB)
    (define attractionAB)
    ;(display "(pln-attraction-rule-no-variables subsetAB subsetNotAB)")
    (set! attractionAB (AttractionLink
                            (list-ref (cog-outgoing-set subsetAB) 0)
                            (list-ref (cog-outgoing-set subsetAB) 1)))
    (attraction-formula attractionAB subsetAB subsetNotAB))
