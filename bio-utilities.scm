(use-modules (opencog query))

(define (cog-get-categories A)
"
 Return the atoms that A is a member of through a MemberLink relationship.
"
    (let ((result
        (cog-outgoing-set
            (cog-bind
                (BindLink
                    (VariableList
                        (VariableNode "$B")
                    )
                    (MemberLink
                        A
                        (VariableNode "$B")
                    )
                    (VariableNode "$B")
                )
            )
        )
        )) result )
)


(define (cog-get-memberlinks-for-element A)
"
 Return the MemberLinks where A is the element in the set
"
    (let ((result
        (cog-outgoing-set
            (cog-bind
                (BindLink
                    (VariableList
                        (VariableNode "$B")
                    )
                    (MemberLink
                        A
                        (VariableNode "$B")
                    )
                    (MemberLink
                        A
                        (VariableNode "$B")
                    )
                )
            )
        )
        ))
        result )
)
