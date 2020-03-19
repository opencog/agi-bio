; Loads biospace and calls simple-inference-full.scm

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load "utilities.scm")

(display "Loading reduced biospace... \n")
(load "load-reduced-biospace.scm")
;(load "reduced-biospace-LY96-TBK1.scm")

(load "simple-inference-full.scm")
