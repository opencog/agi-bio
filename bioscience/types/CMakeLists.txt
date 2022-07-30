
OPENCOG_ADD_ATOM_TYPES(atom_types.script
	atom_types.h
	atom_types.definitions
	atom_types.inheritance
	bioscience_types.scm
	bioscience_types.pyx
)
ADD_CUSTOM_TARGET(bioscience_atom_types DEPENDS atom_types.h)

# The atom_types.h file is written to the build directory
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})

ADD_LIBRARY (bioscience-types SHARED
	BioScienceTypes.cc
)

# Without this, parallel make will race and crap up the generated files.
ADD_DEPENDENCIES(bioscience-types bioscience_atom_types)

TARGET_LINK_LIBRARIES(bioscience-types
	${ATOMSPACE_atomtypes_LIBRARY}
)

INSTALL (TARGETS bioscience-types
	LIBRARY DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

ADD_GUILE_EXTENSION(SCM_CONFIG bioscience-types "opencog-ext-path-bio")

INSTALL (FILES
	${CMAKE_CURRENT_BINARY_DIR}/atom_types.h
	DESTINATION "include/opencog/bioscience/types"
)

INSTALL (FILES
	${CMAKE_CURRENT_BINARY_DIR}/bioscience_types.scm
	DESTINATION "${GUILE_SITE_DIR}/opencog/bioscience/types"
)
