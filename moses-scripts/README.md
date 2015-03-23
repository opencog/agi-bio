AGI Bio
=======

Bunch of scripts to run MOSES, pipe the models into OpenCog and apply
PLN to infer new knowledge.

Requirement
-----------

1. Download and unpack gse16717.tar.xz in the root directory.
2. Compile and install OpenCog
```
cd <OPENCOG_REPO>
mkdir build
cd build
cmake ..
make -j4 && sudo make install && sudo ldconfig
```

Usage
-----

We have several scripts here:

1. export_models_and_fitness.sh <MODEL_CSV_FILE>
to convert models and their scores into a scheme readily dumpable into
the AtomSpace

2. relate_features_and_genes.sh < <FEATURES>
to generate scheme code to relate MOSES features and their
corresponding genes

3. [OBSOLETE] test.sh, and obsolete script to experiment with MOSES
learning and PLN reasoning.. You may need to configure settings.sh,
like setting your OpenCog path.

Usage is as follows:

```
mkdir <MY_EXP>
cd <MY_EXP>
../scripts/test.sh ../scripts/settings.sh
```

Additional documentation
------------------------

See file export_models.md for a detailed discussion about how to
represent the models, their fitness functions and teir features in the
AtomSpace.
