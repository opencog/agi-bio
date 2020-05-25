AGI-Bio
=======

Genomic and proteomic research using the OpenCog toolset.
This includes experiments in applying MOSES, PLN, pattern mining
and other OpenCog components.

The [**MOZI.AI**](https://github.com/MOZI-AI) repositories make
use of this package, and extend the current development of OpenCog-based
bioinformatics tools as [**SingularityNET**](https://singularitynet.io/)
sevices.

Building and Installing
=======================
To build the AGI-Bio code, you will need to build and install the
[OpenCog AtomSpace](https://github.com/opencog/atomspace) first.
All of the pre-requistes listed there are sufficient to also build
this project. Building is as "usual":
```
    cd to project root dir
    mkdir build
    cd build
    cmake ..
    make -j
    sudo make install
    make -j test
```

Overview
========
The directory layout is as follows:

* **[bioscience](./bioscience)** - Provides the `GeneNode` and
  `MoleculeNode` Atom types.

* **[knowledge-import](./knowledge-import)** -- scripts for importing
   external knowledge bases into the AtomSpace.

* **[moses-scripts](./moses-scripts)** -- scripts for importing MOSES
  models; such models distinguish binary phenotype categories based
  on gene expression data.
