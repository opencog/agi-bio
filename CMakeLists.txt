# Configure cmake
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(agi-bio)

# ===============================================================
# Configure compiler
IF (CMAKE_COMPILER_IS_GNUCXX)
	# 1) -Wno-variadic-macros is to avoid warnings regarding using
	# variadic in macro OC_ASSERT (the warning warns that this is only
	# available from C99, lol!)
	#
	# 2) -fopenmp for multithreading support
	#
	# 3) -std=gnu++0x for C++0x and GNU extensions support
	SET(CMAKE_C_FLAGS "-Wall -fPIC -O3 -g -fstack-protector")
	SET(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -Wno-variadic-macros -fopenmp -std=gnu++0x")
ENDIF (CMAKE_COMPILER_IS_GNUCXX)

# Add definitions
IF (NOT DEFINED DATADIR)
	SET (DATADIR "${CMAKE_INSTALL_PREFIX}/share/opencog")
	ADD_DEFINITIONS(-DDATADIR=\\"${DATADIR}\\")
ENDIF (NOT DEFINED DATADIR)

# ===============================================================
# Search for required packages.
# Listed in alphabetical order, except that CogUtils comes first,
# because it supplies the various FindXXX macros.

# Cogutil
FIND_PACKAGE(CogUtil 2.0.1 CONFIG REQUIRED)
IF (COGUTIL_FOUND)
    MESSAGE(STATUS "CogUtil found.")
    ADD_DEFINITIONS(-DHAVE_COGUTIL)
    SET(HAVE_COGUTIL 1)
ELSE (COGUTIL_FOUND)
    MESSAGE(FATAL_ERROR "CogUtil missing: it is needed for everything!")
ENDIF (COGUTIL_FOUND)

# add the 'cmake' directory from cogutil to search path
list(APPEND CMAKE_MODULE_PATH  ${COGUTIL_DATA_DIR}/cmake)

# ------------------------------------------------------------
# The atomspace is required.

FIND_PACKAGE(AtomSpace 5.0.3 CONFIG REQUIRED)
IF (ATOMSPACE_FOUND)
	MESSAGE(STATUS "AtomSpace found.")
	ADD_DEFINITIONS(-DHAVE_ATOMSPACE)
	SET(HAVE_ATOMSPACE 1)
ELSE (ATOMSPACE_FOUND)
	MESSAGE(FATAL_ERROR "AtomSpace missing: it is needed!")
ENDIF (ATOMSPACE_FOUND)

# ===============================================================

# Set default include paths.
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}
        ${COGUTIL_INCLUDE_DIR} ${ATOMSPACE_INCLUDE_DIR})

# Include macros for defining new atom types.
INCLUDE("${DATADIR}/cmake/OpenCogMacros.cmake")
INCLUDE("${DATADIR}/cmake/OpenCogFunctions.cmake")

# Configure builds
include(${COGUTIL_DATA_DIR}/cmake/Summary.cmake)
IF (HAVE_ATOMSPACE)
    ADD_SUBDIRECTORY (bioscience)
    SUMMARY_ADD("Bioscience" "Bioscience atom types" HAVE_ATOMSPACE)
ENDIF (HAVE_ATOMSPACE)

# Display summary of what is being done
SUMMARY_SHOW()
