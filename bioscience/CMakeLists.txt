
# Build C++ code for Bioscience atom-types.
ADD_SUBDIRECTORY (types)

ADD_GUILE_MODULE (FILES
	bioscience.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog"
)
