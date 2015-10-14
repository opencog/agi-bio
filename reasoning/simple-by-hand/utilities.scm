;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define (display-var label)
    (newline)(display label)(display ": \n")(display (eval-string label)))
    ;(newline))

(define (display-atom label atom)
    (newline)(display label)(display ": \n")(display atom))

(define (display-label label value)
    (newline)(display label)(display ": ")(display value)(newline))


(define (incoming atom)
    (cog-incoming-set atom))


(define (make-overexpression-predicate gene)
    (PredicateNode (string-append "Gene-" (cog-name gene) "-overexpressed-in")
        (stv .2 .5)))

#!
; Question: why not use (Eval (Pred "overexpresed-in") (List gene person/organ))
; rather than gene specific predicates
; Nil: Although it's probably hard to say which one is better, this depends on
       the inference you're building. The curried form has the advantage that it
       hides away the universal quantification, cause then you can use the
       higher order version of the ImplicationLink (i.e. over predicates rather
       than TVs).
!#

