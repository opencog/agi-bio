
# OpenCog Bioscience Code
-----------------------

Code related to the AGI-Bio project.

This directory currently contains one subdirectory:

* types - code to create custom atomspace node types for opencog bioscience
        projects

     Current custom atom types are:
       GeneNode
       ProteinNode

### Building the code
Follow the following steps, starting from this directory

```bash
cd ..
mkdir build
cd build
cmake ..
make
sudo make install
```

### Loading the biosciene atom-types.
In guile shell
```scheme
scheme@(guile-user)> (use-modules (opencog) (opencog bioscience))

scheme@(guile-user)> (Gene "that special gene")
$1 = (GeneNode "that special gene")

scheme@(guile-user)> (Protein "the expression of the special gene")
$2 = (ProteinNode "the expression of the special gene")

scheme@(guile-user)> (cog-prt-atomspace)
(GeneNode "that special gene")
(ProteinNode "the expression of the special gene")

```
