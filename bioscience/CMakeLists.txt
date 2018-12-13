
# Build C++ code for Bioscience atom-types.
ADD_SUBDIRECTORY (types)

INSTALL (FILES
	bioscience.scm
	DESTINATION "${GUILE_SITE_DIR}/opencog"
)
