;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define (display-atom label atom)
    (newline)(display label)(display ": \n")(display atom))

(define (display-label label value)
    (newline)(display label)(display ": ")(display value)(newline))

(define (incoming atom)
    (cog-incoming-set atom))
