#
# Master Bioscience CMake file.
#
# General organization:
# -- check for different compilers, OS'es
# -- search for various required & optional libraries/tools
# -- decide what to build based on above results.
# -- configure various config files.
# -- print pretty summary
#
# cogutils already requires 2.8.12.2, so may as well ask for that.
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12.2)

PROJECT(agi-bio)

# Default build type.
IF (CMAKE_BUILD_TYPE STREQUAL "")
   SET(CMAKE_BUILD_TYPE Release)
ENDIF (CMAKE_BUILD_TYPE STREQUAL "")

MESSAGE(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

ADD_DEFINITIONS(-DPROJECT_SOURCE_DIR="${CMAKE_SOURCE_DIR}"
                -DPROJECT_BINARY_DIR="${CMAKE_BINARY_DIR}")

# ===============================================================
# Search for required packages.
# Listed in alphabetical order, except that CogUtils comes first,
# because it supplies the various FindXXX macros.

# Cogutil
FIND_PACKAGE(CogUtil 2.0.1 CONFIG REQUIRED)
IF (COGUTIL_FOUND)
	MESSAGE(STATUS "CogUtil version ${COGUTIL_VERSION} found.")
	ADD_DEFINITIONS(-DHAVE_COGUTIL)
	SET(HAVE_COGUTIL 1)
ELSE (COGUTIL_FOUND)
	MESSAGE(FATAL_ERROR "CogUtil missing: it is needed!")
ENDIF (COGUTIL_FOUND)

# add the 'cmake' directory from cogutil to search path
list(APPEND CMAKE_MODULE_PATH  ${COGUTIL_DATA_DIR}/cmake)

include(OpenCogGccOptions)
include(OpenCogLibOptions)
include(Summary)

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

# ----------------------------------------------------------
# Guile and Python

include(OpenCogFindGuile)
include(OpenCogFindPython)

# -------------------------------------------------
# Include configuration.

# Set default include paths.
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}
	${COGUTIL_INCLUDE_DIR}
	${ATOMSPACE_INCLUDE_DIR})

# Macros that define how atom types get declared.
IF (NOT DEFINED ATOMSPACE_DATA_DIR)
   SET (ATOMSPACE_DATA_DIR "${COGUTIL_DATA_DIR}")
ENDIF (NOT DEFINED ATOMSPACE_DATA_DIR)

INCLUDE("${ATOMSPACE_DATA_DIR}/cmake/OpenCogMacros.cmake")
INCLUDE("${ATOMSPACE_DATA_DIR}/cmake/OpenCogGuile.cmake")
INCLUDE("${ATOMSPACE_DATA_DIR}/cmake/OpenCogCython.cmake")

# -------------------------------------------------
# Install configuration

include(OpenCogInstallOptions)

ADD_CUSTOM_TARGET(uninstall
	COMMAND bash -c "cat install_manifest.txt | xargs rm -f"
	VERBATIM
	COMMENT "Uninstalling OpenCog Bioscience ..."
)

# ==========================================================
# Decide what to build, based on the packages found.

# Configure builds
IF (HAVE_ATOMSPACE)
	ADD_SUBDIRECTORY (bioscience)
ENDIF (HAVE_ATOMSPACE)

# Display summary of what is being done
SUMMARY_ADD("Bioscience" "Bioscience atom types" HAVE_ATOMSPACE)
SUMMARY_SHOW()
