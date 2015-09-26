(use-modules (opencog))
(use-modules (opencog query))


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
(define (create-not-gene-set A)
    (cog-new-link 'SetLink (lset-difference equal? (cog-get-atoms 'GeneNode)
        (get-set-members A))))

