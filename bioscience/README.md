
bioscience
==========

Code related to the AGI-Bio project to be built and run with the opencog server. 

This directory should be moved or copied to your opencog project root directory.

This directory currently contains one subdirectory:

-- types - code to create custom atomspace node types for opencog bioscience projects

   Current custom atom types are:
     GeneNode
     ProteinNode


Requirements
------------

- Move or copy this directory to your opencog project root directory

- Add following line to CMakeLists.txt in your opencog project root directory
  after the entry for 'ADD_SUBDIRECTORY(opencog)'.

        ADD_SUBDIRECTORY(bioscience)

- To automatically load the custom bio types module and scheme wrapper code
  when the cogserver and scheme shell are fired up, add the following to 
  lib/opencog.conf:

    In the 'MODULES' section:

        bioscience/types/libbioscience-types.so

    In the 'SCM_PRELOAD' section:

        bioscience/types/bioscience_types.scm






