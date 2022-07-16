
DECLARE_GUILE_CONFIG_TARGET(SCM_CONFIG "opencog bio-config" "BIO_TEST")

# Build C++ code for Bioscience atom-types.
ADD_SUBDIRECTORY (types)

IF (HAVE_CYTHON)
	ADD_SUBDIRECTORY (cython)
ENDIF (HAVE_CYTHON)

# Bogus boilerplate for unit-testing. This should be automated.
WRITE_GUILE_CONFIG(
	${GUILE_BIN_DIR}/opencog/bio-config.scm
	SCM_CONFIG TRUE
)

WRITE_GUILE_CONFIG(
	${GUILE_BIN_DIR}/opencog/bio-config-installable.scm
	SCM_CONFIG FALSE
)

INSTALL(
	FILES ${GUILE_BIN_DIR}/opencog/bio-config-installable.scm
	DESTINATION ${GUILE_SITE_DIR}/opencog
	RENAME bio-config.scm
)

ADD_GUILE_MODULE (FILES
	bioscience.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/bioscience"
)
