;
; URE Configuration file for PLN
;
; Before running any PLN inference you must load that file in the
; AtomSpace
;
; In order to add new rules you need to hack this file in 2 places
;
; 1. In the Load rules section, to add the file name where the rule is
; defined (see define rule-files).
;
; 2. In the Associate rules to PLN section, to add the name of the
; rule and its weight (see define rules).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load required modules and utils ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load-from-path "utilities.scm")
(load-from-path "av-tv.scm")
(load-from-path "opencog/rule-engine/rule-engine-utils.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define PLN rule-based system ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define pln-rbs (ConceptNode "PLN"))
(InheritanceLink
   pln-rbs
   (ConceptNode "URE")
)

; Define pln-fc and pln-bc for convenience 
(define (pln-fc source) (cog-fc source pln-rbs))
(define (pln-bc target) (cog-bc target pln-rbs))

;;;;;;;;;;;;;;;;
;; Load rules ;;
;;;;;;;;;;;;;;;;

; Load the rules (use load for relative path w.r.t. to that file)
;(define config-dir (dirname (current-filename)))
;(define (prepend-config-dir fp) (string-append config-dir "/" fp))
;(define rule-files (list "rules/deduction.scm"
;                         "rules/modus-ponens.scm"))
;(for-each (lambda (fp) (load (prepend-config-dir fp))) rule-files)

; Assumes that opencog/reasoning/pln is in load path
(add-to-load-path "/usr/local/share/opencog/scm/opencog/pln/")
(define rule-files (list
                         ;"rules/deduction.scm"
                         "rules/deduction-rule.scm"
                         "rules/implication-instantiation-rule.scm"
                         "rules/modus-ponens-rule.scm"
                         "rules/attraction-rule.scm"))
(for-each load-from-path rule-files)

(define local-rule-files (list  "local-rules/member-to-subset.scm"
                                "local-rules/subset-direct-evaluation-rule.scm"
                                "local-rules/singleton-similarity-rule.scm"
                                "local-rules/implication-conversion-rule.scm"
                                "local-rules/gene-similarity2overexpression-equivalence-rule.scm"
                                "local-rules/equivalence-transformation-rule.scm"))
(for-each load local-rule-files)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Associate rules to PLN ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; List the rules and their weights.
(define rules (list (list pln-rule-member-to-subset-name 1)
                    (list pln-rule-subset-direct-evaluation-name 1)
                    (list pln-rule-singleton-similarity-name 1)
                    (list pln-rule-intensional-implication-conversion-name 1)
                    (list gene-similarity2overexpression-equivalence-name 1)
                    ;(list pln-rule-deduction-name 1)
                    (list deduction-intensional-implication-rule-name 1)
                    (list implication-full-instantiation-rule-name 1)
                    (list modus-ponens-implication-rule-name 1)
                    (list attraction-rule-name 1)
                    (list pln-rule-intensional-equivalence-transformation-name
                        1)
              )
)

; Associate rules to PLN
(ure-add-rules pln-rbs rules)

;;;;;;;;;;;;;;;;;;;;;
;; Other paramters ;;
;;;;;;;;;;;;;;;;;;;;;

; Termination criteria parameters
(ure-set-num-parameter pln-rbs "URE:maximum-iterations" 20)

; Attention allocation (0 to disable it, 1 to enable it)
(ure-set-fuzzy-bool-parameter pln-rbs "URE:attention-allocation" 0)
