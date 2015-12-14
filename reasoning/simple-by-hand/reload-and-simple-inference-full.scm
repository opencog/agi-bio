; Loads biospace and calls simple-inference-full.scm

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load "utilities.scm")

(display "Loading reduced biospace... \n")
(load "load-reduced-biospace.scm")

(load "simple-inference-full.scm")



