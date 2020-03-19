(define RESULTS-FILE "atom-results.txt")

(use-modules (srfi srfi-1))  ; for support of lset-union and lset-intersection

(define (expand-n-hops atom n)
    (define neighbors
        (lset-union equal? (cog-get-root atom) (cog-outgoing-set atom)))
        ;(lset-union equal? (cog-incoming-set atom) (cog-outgoing-set atom)))
    ;neighbors

    ;(with-output-to-file "ouput.txt" ((lambda) (display neighbors)))

    ;(call-with-output-file "output.txt"
    ;  (lambda (output-port)
    ;    ;(display neighbors output-port)
    ;    (for-each (lambda (atom) (display atom output-port)) neighbors)
    ;  ))

    neighbors

)

(define (expand-atom-within-set atom atomset hops)
    (lset-union equal? atomset (expand-n-hops atom hops)))

(define (collapse-atom-within-set atom atomset)
    (define neighbors
        (lset-union equal? (cog-incoming-set atom) (cog-outgoing-set atom)))
    (display neighbors)
    (lset-difference equal? atomset neighbors))


(define (write-atoms-to-file atoms filename)
    (call-with-output-file filename
      (lambda (output-port)
        ;(display atoms output-port)
        (for-each (lambda (atom) (display atom output-port)) atoms)
      )))

(define (write-atoms atoms)
    (write-atoms-to-file atoms RESULTS-FILE))

(define n1 (GeneNode "EDEM3"))
(define n2 (ConceptNode "MSigDB_GeneSet: V$TEL2_Q6"))

(define atomset '())
;(define atomset (list n1))
;(write-atoms-to-file results RESULTS-FILE)

(define (load-atomset-to-viz-atomspace)
    (system "./load-results.sh"))

(define (expand atom)
    (define results (expand-atom-within-set atom atomset 1))
    (write-atoms results)
    (set! atomset results)
    (load-atomset-to-viz-atomspace))

(define (collapse atom)
    (define results (collapse-atom-within-set atom atomset))
    (write-atoms results)
    (set! atomset results)
    (load-atomset-to-viz-atomspace))

; This doesn't work if the handle is coming from the visualizer atomspace--would
; need to grab the atom from viz atomspae first, which possibly could do thru
; telnet.
(define (expand-id handle)
    (expand (cog-atom handle)))

(define (collapse-id handle)
    (collapse (cog-atom handle)))




(define (step1)
    ;(expand n1)
    (define results (expand-atom-within-set n1 atomset 1))
    (write-atoms results)
    (set! atomset results)
    (load-atomset-to-viz-atomspace)

)

(define (step2)
    (define results (expand-atom-within-set n2 atomset 1))
    (write-atoms results)
    (set! atomset results)
)

(define (step3)
    (define results (collapse-atom-within-set
        (ConceptNode "MSigDB_GeneSet: V$TEL2_Q6") atomset))
    (write-atoms results)
    (set! atomset results)
)


