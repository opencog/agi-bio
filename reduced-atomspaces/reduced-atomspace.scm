;(load "../reasoning/simple-by-hand/local-rules/rule-helpers.scm")

;; this is bio-utilities.scm now
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

(define (cog-remove-type atom-type atoms)
    (filter (lambda (atom) (not (eq? atom-type (cog-type atom)))) atoms))

;(define genes (list "ADCY9" "RYBG3" "MAGIX" "PSMD9" "RAI14" "TBC1D4"))
(define genes (list "TBC1D4" "ADCY9"))   ; "MAGIX" "PSMD9" "RAI14" "TBC1D4"))
(define gene-nodes (map GeneNode genes))

(define member-cats (fold union '() (map cog-incoming-set gene-nodes)))

(define cats (map cog-get-categories gene-nodes))

(use-modules (ice-9 common-list))
(set! cats (fold union '() cats))

(define cat-nodes (fold union '() (map cog-get-root cats)))

; keep out full category gene members to simplify and reduce crowding
;(define cat-nodes (set-difference cat-nodes (cog-filter 'MemberLink cat-nodes)))
;(define cat-nodes (filter (lambda (atom) (not (eq? 'MemberLink (cog-type atom)))) cat-nodes))
(define cat-nodes (cog-remove-type 'MemberLink cat-nodes))

; keep out search artifact setlinks
;(define cat-nodes (set-difference cat-nodes (cog-filter 'SetLink cat-nodes)))
(define cat-nodes (cog-remove-type 'SetLink cat-nodes))



