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

The main scripts is test.sh that runs the whole thing. You may need to
configure settings.sh, like setting your OpenCog path.

Usage is as follows:

```
mkdir <MY_EXP>
cd <MY_EXP>
../scripts/test.sh ../scripts/settings.sh
```

Additional documentation
------------------------

See file FitnessFunctions.md for a discussion of how to represent the
fitness functions in the AtomSpace.
