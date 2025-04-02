CYTHON_ADD_MODULE_PYX(bioscience
       bioscience-types 
)

INCLUDE_DIRECTORIES(
        ${Python3_INCLUDE_DIRS}
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
)

ADD_LIBRARY(bioscience
	SHARED
        bioscience.cpp
)

TARGET_LINK_LIBRARIES(bioscience
	bioscience-types
	${ATOMSPACE_LIBRARIES}
	${Python3_LIBRARIES}
)

SET_TARGET_PROPERTIES(bioscience PROPERTIES
        PREFIX ""
        OUTPUT_NAME bioscience)

### install the modules ###
INSTALL(TARGETS
        bioscience
        DESTINATION "${PYTHON_DEST}")


