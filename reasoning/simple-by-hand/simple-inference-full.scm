(define VERBOSE #t)

#!
Simple example of bio-inference using PLN by hand using full biospace.

Usage:
    cd to this file's directory, run guile --no-auto-comile, 
		and then in guile scheme:
    scheme@(guile-user)> (load "load-biospace.scm")
    scheme@(guile-user)> (load "simple-inference-full.scm")

Background Knowledge:
This needs to be reworked to reflect the whole atomspace
    (IntensionalImplicationLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-over-expression-predicate")
            (GeneNode "PLAU"))
        (PredicateNode "LongLived") (stv .8 .8))

    ((MemberLink
       (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       (ConceptNode "GO:0001666" (stv 0.001 0.89999998))
    )
     (MemberLink
       (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       (ConceptNode "GO:0004252" (stv 0.001 0.89999998))
    )
    ....

We want to infer how well gene RYR1 is related to longevity based on background
knowledge. Our target conclusion is:

    ImplicationLink
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (GeneNode "RYR1"))
        (PredicateNode "LongLived")

In other words, we want to infer a relationship between Gene RYR1 and LongLived
though it's association with Gene PLAU, which is already known to be related
to longevity.
!#

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load "utilities.scm")
(load "local-rules/rule-helpers.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the atomspace knowledge and rules ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(display "Loading reduced biospace... ")
(load "load-reduced-biospace.scm")
(load "background-knowledge-full.scm")
(load "pln-config.scm")
(load "substitute.scm")
(load "cog-create-intensional-similarity-link.scm")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Inference Chain Steps                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (similarity-to-implies-longevity target long-gene)
    (define IS-sets)
    (define IS-genes)
    (define IE-over)
    (define II-over)
    (define II)
    (define II-long)


    (display (string-append "\nComputing " (cog-name target) " implies longevity based on "
        "similarity to " (cog-name long-gene) "...\n\n"))

    (if VERBOSE (display-var "long-gene-implies-ll" long-gene-implies-ll))


; (1) Apply Member2SubsetRule, to get:
;
;  Subset (SetLink (GeneNode "L"))  (ConceptNode "GO_ABC")
;  Subset (SetLink (GeneNode "PLAU"))  (ConceptNode "GO_ABC")
;  ...

    ;(display "Applying Member2Subset rule to all gene memberlinks...\n")
    ; this was taking too long against the full biospace (for develpment at least)
    ; Apply rule just to the gene MemberLinks
    ;(define gene-memberlinks
    ;    (cog-filter
    ;        'MemberLink
    ;        (append-map cog-incoming-set (cog-get-atoms 'GeneNode))
    ;    )
    ;)

    (if VERBOSE (display "Applying Member2Subset rule to longevity gene and target gene...\n"))
    (let* ((gene-memberlinks
                (cog-filter 'MemberLink
                    (append-map cog-incoming-set (list long-gene target))))

           (m2s (map cog-apply-rule
              (make-list (length gene-memberlinks) "pln-rule-member-to-subset")
              gene-memberlinks
              (make-list (length gene-memberlinks) #t))
           )
          )

        ;(if VERBOSE (display-var "gene-memberlinks" gene-memberlinks)



        ; remove inner listlinks for nicer print formatting
        (set! m2s (map (lambda(x) (list-ref (cog-outgoing-set x) 0)) m2s))
        ;(display-var "m2s" m2s)

        ;(define m2s-target (cog-incoming-set target))
        ;(display-var "m2s-target" m2s-target)
    )
#! version from overexpression branch
;(display "Applying Member2Subset rule to all gene memberlinks...\n")
; this was taking too long against the full biospace (for develpment at least)
; Apply rule just to the gene MemberLinks
;(define gene-memberlinks
;    (cog-filter
;        'MemberLink
;        (append-map cog-incoming-set (cog-get-atoms 'GeneNode))
;    )
;)

(display "Applying Member2Subset rule to longevity gene and target gene...\n")
(define gene-memberlinks
    (cog-filter 'MemberLink
    (append-map cog-incoming-set (list long-gene target))))

(display-var "gene-memberlinks")

(define m2s (map cog-apply-rule
    (make-list (length gene-memberlinks) "pln-rule-member-to-subset")
    gene-memberlinks
    (make-list (length gene-memberlinks) #t))
)
; remove inner listlinks for nicer print formatting
(set! m2s (map (lambda(x) (list-ref (cog-outgoing-set x) 0)) m2s))
(display-var "m2s")

;(define m2s-target (cog-incoming-set target))
;(display-var "m2s-target")
!#

#!
    (SubsetLink
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
       (ConceptNode "GO:0001666" (stv 0.001 0.89999998))
    )
    ...
!#

#! The following steps 2-6 occur in the cog-create-intensional-similarity-link command:

(2) Get the supersets of the target and of {PLAU} (IOW the categories they are
    members of), and the union and intersection of the supersets

    superA:
    ((ConceptNode "GO:0070062" (stv 0.001 0.89999998))
     (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
     (ConceptNode "GO:0005515" (stv 0.001 0.89999998))
     ...

    superB:
    ((ConceptNode "Lifespan_Observations_Increased_GeneSet" (stv 0.001 0.89999998))
     (ConceptNode "GO:2000097" (stv 0.001 0.89999998))
     (ConceptNode "GO:0070062" (stv 0.001 0.89999998))
     ...

    superA-length: 35

    superB-length: 22

    superIntersection:
    ((ConceptNode "GO:0070062" (stv 0.001 0.89999998))
     (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
     (ConceptNode "GO:0005515" (stv 0.001 0.89999998))
     (ConceptNode "GO:0001666" (stv 0.001 0.89999998))
    )

    superInersection length: 4

    superUnion-length: 53

;Don't think we need to do this b/c the AttractionLink args were reversed before
(3) For each common relationship (IOW for each relationship in the supersets
    intersection), create the same inverse relationship.

    (SubsetLink (stv 0.00036913992 0.99999982)
       (ConceptNode "GO:0070062" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0.00026462026 0.99999982)
       (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
    ...

;
(4) For each common relationship (LinkType {Gene} B), create (LinkType (Not {Gene}) B)
; Todo:
; I think the following may no longer be an issue since we had Attraction args
; reversed before.
; One of the main issues to be resolved is how to define (Not ConceptNode S) in
; general, which seems to me to be domain specific. Perhaps different
; category/set types can specify formulas to used that define what
; (Not Category_of_Type_X) is.
;
; In the present context, we are defining (Not Gene_Category_S) to be the set of
;  all the genes in the system that are not members of S.

    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO:0070062" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
    ...

(5) Apply the AttractionRule to make AttractionLinks for L and PLAU for each
    common relationship (IOW for each relationship in the supersets
    intersection).

    (AttractionLink (stv 0.00036913992 0.99999982)
       (ConceptNode "GO:0070062" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.00026462026 0.99999982)
       (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.00012239903 0.99999982)
       (ConceptNode "GO:0005515" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.0066666668 0.99999982)
       (ConceptNode "GO:0001666" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
    (AttractionLink (stv 0.00036913992 0.99999982)
       (ConceptNode "GO:0070062" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.00026462026 0.99999982)
       (ConceptNode "GO:0005886" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.00012239903 0.99999982)
       (ConceptNode "GO:0005515" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )
     (AttractionLink (stv 0.0066666668 0.99999982)
       (ConceptNode "GO:0001666" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )


(6) Create IntensionalSimilarityLink via direct evaluation based on
    AttractionLinks and # of members in the union of supersets
    tv.s = average(ASSOC(A,L) AND ASSOC(B,L))
           over all relationships in the union of supersets
!#

    (set! IS-sets (cog-create-intensional-similarity-link
                        (SetLink target) (SetLink long-gene)))
    (if VERBOSE (display-var "IS-sets (via create-intensional-similarity-link)" IS-sets))

#! version from overexpression branch
(define is-l-plau (cog-create-intensional-links
                    (SetLink target) (SetLink long-gene))
)
(display-var "is-l-plau")
!#

#!
    (IntensionalSimilarityLink (stv 0.00014005332 0.99999982)
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
       (SetLink
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
!#


; (7) Apply singleton-similarity-rule to get
;
; IntensionalSimilarityLink PLAU L

    (set! IS-genes
            ;(cog-bind pln-rule-singleton-similarity)
            (cog-apply-rule
                "pln-rule-singleton-similarity"
                IS-sets
                #t)
    )
    ;(set! IS-genes (gar IS-genes))
    (if VERBOSE (display-var "IS-genes (via singleton-similarity)" IS-genes))



#!
    (SetLink
       (IntensionalSimilarityLink (stv 0.00014005332 0.99999982)
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
          (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
       )
    )
!#

; (8) Apply gene-similarity2overexpression-equivalence knowledge rule to get
;
; IntensionalEquivalenceLink
;    PLAU-over-expressed
;    RYR1-over-expressed

    ; Hold off on using the full instantiation rule until the tv formula is
    ; implemented
    ;(define IE (cog-bind implication-full-instantiation-rule))

    ; for potential variant version
    ;(define IE (cog-bind gene-similarity-variant-rule))

    ;(set! IE-over (cog-bind gene-similarity2overexpression-equivalence))
    (set! IE-over (cog-apply-rule
                        "gene-similarity2overexpression-equivalence"
                        (gar IS-genes)
                        #t))
    (if VERBOSE (display-var "IE-over (via gene-similarity2overexpression-equivalence)" IE-over))

#!
   (IntensionalEquivalenceLink (stv 0.00014005332 0.99999982)
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
         )
      )
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
         )
      )
   )
   (IntensionalEquivalenceLink (stv 0.00014005332 0.99999982)
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
         )
      )
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
         )
      )
   )
!#


; (9) Apply intensional-equivalence-transformation to get
;
; IntensionalImplication
;    Exout
;        SchemaNode "make-overexperssion-predicate"
;        GeneNode "RYR1"
;     Exout
;        SchemaNode "make-overexperssion-predicate"
;        GeneNode "PLAU"
;
;Todo: check with Ben re sim2inh rule referenced in the word doc


    ;(display "-----------------\nPre-equivalence-transformation\nIE atoms:\n")
    ;(display (cog-get-atoms 'IntensionalEquivalenceLink))

    ;(let ((II (cog-bind pln-rule-intensional-equivalence-transformation)))
    ;    (display-var "II" II)
    ;)

    ; Using cog-bind here instead of cog-apply-rule because cog-fc leads to 
    ; exception "Not implemented!!" I believe because of PatternMatcher handling
    ; of the ExecutionOutputLink
    ;(set! II-over
    ;    (cog-apply-rule
    ;        "pln-rule-intensional-equivalence-transformation"
    ;        IE-over
    ;        #t))
    
    (set! II-over (cog-bind pln-rule-intensional-equivalence-transformation))
    
    (if VERBOSE (display-var
        "II-over (via intensional-equivalence-transformation)" II-over))

#!
      (IntensionalImplicationLink (stv 0.00028006741 0.99999982)
         (ExecutionOutputLink (stv 0.5 0.69999999)
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
               (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
            )
         )
         (ExecutionOutputLink (stv 0.5 0.69999999)
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
               (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
            )
         )
      )
      (IntensionalImplicationLink (stv 0.00028006741 0.99999982)
         (ExecutionOutputLink (stv 0.5 0.69999999)
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
               (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
            )
         )
         (ExecutionOutputLink (stv 0.5 0.69999999)
            (GroundedSchemaNode "scm: make-overexpression-predicate")
            (ListLink
               (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
            )
         )
      )
!#

; ** first either need to convert first Implication to IntensionalImplication
; or 2nd IntensionalImplication to Implication

; (10) Apply implication-deduction to get
;
; IntensionalImplication PredNode "Gene-L-overexpressed"  PredNode "LongLived"

    ;(define to-long-life (cog-bind pln-rule-deduction-intensional-implication))
    ;(define target-overexpressed
    ;    (ExecutionOutputLink
    ;        (GroundedSchemaNode "scm: make-overexpression-predicate")
    ;        (ListLink target)))

    ;(display "LongLife incoming: " )
    ;(display (cog-incoming-set (PredicateNode "LongLived")))

    ; set up the source link to be (Implication target long-lived(gene) )
    (let  ((slot-a-gene (gar (gdr (gar (gar (gar II-over))))) ))
        ;(display-var "slot-a-gene" slot-a-gene)
        (if (eq? slot-a-gene target)
            (set! II-over (gar (gar II-over)))
            (set! II-over (gdr (gar II-over))))
    )
    ;(display-var "II-over (post choice)" II-over)

    ; Using (PredicateNode "LongLived" as a workaround for now because using
    ; II-over as the source atom leads to "throw RuntimeException(TRACE_INFO,
    ; "Not implemented!!")"
    (set! II-long (cog-apply-rule
                        "deduction-intensional-implication-rule"
                        (PredicateNode "LongLived")
                        ;II-over
                        #t))
    (if VERBOSE (display-var
        "II-long (via deduction-intensional-implication-rule)" II-long))


#!
   (IntensionalImplicationLink (stv 0.299972 0.69999999)
      (ExecutionOutputLink (stv 0.5 0.69999999)
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
         )
      )
      (PredicateNode "LongLived" (stv 0.25 0.80000001))
   )
!#

; (11) Apply implication-conversion to get
;
; ImplicationLink
;   ExOut Schema "make-overexpression" (GeneNode L)
;   PredNode "LongLived"

    (let* ((grounded-conversion-rule
            (substitute pln-rule-intensional-implication-conversion
                (list (cons (VariableNode "$B") (PredicateNode "LongLived")))))
          ;(define conclusion (cog-bind pln-rule-intensional-implication-conversion))
          (conclusion (cog-bind grounded-conversion-rule))
         )
        (display-var
            "conclusion via intensional-implication-conversion)" conclusion)
        conclusion
    )

#!
   (ImplicationLink (stv 0.299972 0.48999998)
      (ExecutionOutputLink (stv 0.5 0.69999999)
         (GroundedSchemaNode "scm: make-overexpression-predicate")
         (ListLink
            (GeneNode "RYR1" (stv 9.9999997e-06 0.89999998))
         )
      )
      (PredicateNode "LongLived" (stv 0.25 0.80000001))
   )
!#

) ; end main similarity-to-implies-longevity function



(define round1 (similarity-to-implies-longevity target long-gene))
(display-var "round one: " round1)
