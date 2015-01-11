AGI-Bio
=======

Prototype project utilizing the OpenCog framework for genomic
research. In particular it aims at experimenting with cognitive
synergy between MOSES, PLN and other OpenCog components.

Requirements
------------

- OpenCog https://github.com/opencog/opencog

Description
-----------

-- moses-scripts -- scripts for importing MOSES models into the atomspace
   and applying PLN

-- knowledge-import -- scripts for converting external knowledge bases into
   scheme files for importing into the atomspace

-- bioscience - code to be built and run with the cogserver
  

Note from Nil: I don't know what's the right way to organize the
folders, I just added my work under moses-scripts, although those
scripts cover in fact more than MOSES.

Note from Eddie: Not sure what's the best way to organize the folders
either. In particular, the best way to organize the code to be built and
run with the cogserver, which at present consists of just the custom atom 
types. Currently I have instructions in the readme to copy the directory 
to the opencog root dir. But then this will need to be redone any time 
there are updates to this code in the repo.
