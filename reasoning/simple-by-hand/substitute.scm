;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; substitute.scm
;
; Utility to substitute atoms in a graph according to given mapping of atoms
; to be substituted.
;
; Usage
;(define term pln-rule-member-to-subset)
;(define subst-pairs (list
;                        (cons (VariableNode "$A") (ConceptNode "apple"))))
;(substitute term subst-pairs)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (substitute term substitution-pairs)
    (define num-pairs)
    (define subst-map)
    ; make the substitution map
    (set! num-pairs (length substitution-pairs))
    (set! subst-map (make-hash-table num-pairs))
    ;(display-label "subst-map" subst-map)
    ;(display-label "num-pairs" num-pairs)
    (for-each (lambda(map pair) (hash-set! map (car pair) (cdr pair)))
              (make-list num-pairs subst-map) substitution-pairs
    )
    ;(display "map populated\n")
    (substitute-with-map term subst-map)
)



(define (substitute-with-map term subst-map)
    (define outgoing #f)
    ;(display "substitute-with-map() term: ")(display term)
    ;(display "subst-map: ")(display subst-map)(newline)
    (cond
          ; handle term is in substitution map
          ((hash-ref subst-map term) (begin
                ;(display "pre-outgoing: ")(display outgoing)(newline)
                (set! outgoing (hash-ref subst-map term))
                ;(display "outgoing: ")(display outgoing)
          ))

          ; handle term is a link
          ((> (length (cog-outgoing-set term)) 0) (begin
            ;(display "link")(newline)
            ;(set! outgoing (cog-new-link (cog-type term) (cog-outgoing-set term)))
            ;(set! outgoing (substitute-with-map (list-ref (cog-outgoing-set term) 1) subst-map))
             (let ((subterms (map substitute-with-map (cog-outgoing-set term)
                        (make-list (length (cog-outgoing-set term)) subst-map))))

                    ; if term is VariableList, remove any concept nodes from list
                    (if (eq? (cog-type term) 'VariableList)
                        (begin
                            ;(display "--- found VariableList ---\n")
                            ;(display subterms)(newline)
                            ;(for-each (lambda(x)
                            ;    (display x)(display " -type-> ")(display (cog-type x))(newline)
                            ;    (display (eq? (cog-type x) 'VariableNode)) (newline))
                            ;    subterms)
                            (set! subterms (filter (lambda(x) (eq? (cog-type x) 'VariableNode))
                                            subterms))
                        ))
                    ;(display "subterms: ")(display subterms)(newline)
                    ;(display "link type: " ) (display (cog-type term))(newline)
                    (if (and (eq? (cog-type term) 'VariableList)
                            (null-list? subterms))
                        (set! outgoing #nil)
                        (set! outgoing (cog-new-link (cog-type term) subterms)))
             )
          ))

          ; handle term is a node (or empty link)
          ((= (length (cog-outgoing-set term)) 0) (begin
                ;(display "node")(newline)(display term)
                (set! outgoing term)
                ;(display "outgoing: " )(display outgoing)
           ))
    )
    ;(display "post-outgoing: ")(display outgoing)(newline)
    outgoing
)






