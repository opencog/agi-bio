#!python
#cython: language_level=3

from opencog.atomspace import get_refreshed_types
from opencog.utilities import add_node, add_link


cdef extern :
    void bioscience_types_init()


bioscience_types_init()
types = get_refreshed_types() 

include "bioscience/types/bioscience_types.pyx"
