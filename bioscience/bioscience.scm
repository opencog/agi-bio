;
; Opencog bioscience atom-types module
;

(use-modules (opencog))

(define-module (opencog bioscience))

; Load the C library that calls the classserver to load the types.
(load-extension "libbioscience-types" "bioscience_types_init")

(load "bioscience/types/bioscience_types.scm")
