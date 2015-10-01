;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define (display-atom label atom)
    (newline)(display label)(display ": \n")(display atom))

(define (display-label label value)
    (newline)(display label)(display ": ")(display value)(newline))

(define (incoming atom)
    (cog-incoming-set atom))


(define (make-overexpression-predicate gene)
    (PredicateNode (string-append "Gene-" (cog-name gene) "-overexpressed-in")
        (stv .2 .5)))

; Question: why not use (Eval (Pred "overexpresed-in") (List gene person/organ))
; rather than gene specific predicates
