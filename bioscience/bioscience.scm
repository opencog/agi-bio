;
; Opencog bioscience atom-types module
;
(define-module (opencog bioscience))

(use-modules (opencog))
(use-modules (opencog bio-config))

; Load the C library that calls the classserver to load the types.
(load-extension
	(string-append opencog-ext-path-bio "libbioscience-types")
	"bioscience_types_init")

(load-from-path "opencog/bioscience/types/bioscience_types.scm")
