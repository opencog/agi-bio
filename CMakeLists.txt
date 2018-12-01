# Configure cmake
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(opencog)

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

# set datadir
IF (NOT DEFINED DATADIR)
	SET (DATADIR "${CMAKE_INSTALL_PREFIX}/share/opencog")
ENDIF (NOT DEFINED DATADIR)

include(${COGUTIL_DATA_DIR}/cmake/Summary.cmake)

# include custom opencog cmake macros
INCLUDE("${DATADIR}/cmake/OpenCogMacros.cmake")
INCLUDE("${DATADIR}/cmake/OpenCogFunctions.cmake")

# Search for required packages
FIND_PACKAGE(AtomSpace 5.0.3 CONFIG REQUIRED)
IF (ATOMSPACE_FOUND)
	MESSAGE(STATUS "AtomSpace found.")
	ADD_DEFINITIONS(-DHAVE_ATOMSPACE)
	SET(HAVE_ATOMSPACE 1)
ELSE (ATOMSPACE_FOUND)
	MESSAGE(FATAL_ERROR "AtomSpace missing: it is needed for everything!")
ENDIF (ATOMSPACE_FOUND)

# set default include paths
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}
        ${COGUTIL_INCLUDE_DIR} ${ATOMSPACE_INCLUDE_DIR})

# Configure compiler
IF (CMAKE_COMPILER_IS_GNUCXX)
	# 1) -Wno-variadic-macros is to avoid warnings regarding using
	# variadic in macro OC_ASSERT (the warning warns that this is only
	# available from C99, lol!)
	#
	# 2) -fopenmp for multithreading support
	#
	# 3) -std=gnu++0x for C++0x and GNU extensions support
	SET(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -Wno-variadic-macros -fopenmp -std=gnu++0x")
ENDIF (CMAKE_COMPILER_IS_GNUCXX)

# Adds definitions
IF (NOT DEFINED DATADIR)
	SET (DATADIR "${CMAKE_INSTALL_PREFIX}/share/opencog")
	ADD_DEFINITIONS(-DDATADIR=\\"${DATADIR}\\")
ENDIF (NOT DEFINED DATADIR)

# Configure builds
IF (HAVE_ATOMSPACE)
    ADD_SUBDIRECTORY (bioscience)
    SUMMARY_ADD("Bioscience" "Bioscience atom types" HAVE_ATOMSPACE)
ENDIF (HAVE_ATOMSPACE)

# Display summary of what is being done
SUMMARY_SHOW()
