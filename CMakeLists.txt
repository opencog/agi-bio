# Configure cmake
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(opencog)

SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/lib/")
INCLUDE("${CMAKE_SOURCE_DIR}/lib/OpenCogMacros.cmake")
INCLUDE("${CMAKE_SOURCE_DIR}/lib/Summary.cmake")

# Search for required packages
FIND_PACKAGE(AtomSpace 5.0.3 REQUIRED)
IF (ATOMSPACE_FOUND)
	MESSAGE(STATUS "AtomSpace found.")
	ADD_DEFINITIONS(-DHAVE_ATOMSPACE)
	SET(HAVE_ATOMSPACE 1)
ELSE (ATOMSPACE_FOUND)
	MESSAGE(FATAL_ERROR "AtomSpace missing: it is needed for everything!")
ENDIF (ATOMSPACE_FOUND)

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
