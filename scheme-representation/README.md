Scheme Representation
=====================

This folder contains a set of pre-generated scheme files, readily
loadable into the AtomSpace.

MOSES
-----

1. Files
```
oldoffvscontrol-models-and-fitness.scm
oldvscontrol-models-and-fitness.scm
```
are obtained by running respectively
```bash
moses-scripts/export_models_and_fitness.sh oldoffvscontrolCombos.csv
moses-scripts/export_models_and_fitness.sh oldvscontrolFeatures.csv
```
The files are on ai-scientist, a private email list.
2. Files
```
oldoffvscontrol-features-and-genes.scm
oldvscontrol-features-and-genes.scm
```
are obtained by running respectively
```bash
moses-scripts/relate_features_and_genes.sh oldoffvscontrolFeatures.csv
moses-scripts/relate_features_and_genes.sh oldvscontrolFeatures.csv
```
The files are found on ai-scientist, a private email list.
