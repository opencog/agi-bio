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
(load-from-path "rule-engine-utils.scm")

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

; Assumes that local dir and opencog/reasoning/pln are in load path
(define rule-files (list "local-rules/member-to-subset.scm"
                         "local-rules/subset-direct-evaluation-rule.scm"
                         "local-rules/singleton-similarity-rule.scm"
                         "local-rules/implication-conversion-rule.scm"
                         "rules/deduction.scm"
                         "rules/modus-ponens.scm"
                         "rules/attraction-rule.scm"
                         "rules/equivalence-transformation-rule.scm"))
(for-each load-from-path rule-files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Associate rules to PLN ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; List the rules and their weights.
(define rules (list (list pln-rule-member-to-subset-name 1)
                    (list pln-rule-subset-direct-evaluation 1)
                    (list pln-rule-singleton-similarity 1)
                    (list pln-rule-intensional-implication-conversion-name 1)
                    (list pln-rule-deduction-name 1)
                    (list pln-rule-deduction-intensional-implication-name 1)
                    (list pln-rule-modus-ponens-name 1)
                    (list pln-rule-attraction-name 1)
                    (list pln-rule-intensional-equivalence-transformation 1)
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
