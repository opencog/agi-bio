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
are obtained by running
```
moses-scripts/export_models_and_fitness.sh 
```
on
```
oldoffvscontrolCombos.csv
oldvscontrolFeatures.csv
```
respectively (found on ai-scientist, a private email list).

2. Files
```
oldoffvscontrol-features-and-genes.scm
oldvscontrol-features-and-genes.scm
```
are obtained by running
```
moses-scripts/relate_features_and_genes.sh
```
on
```
oldoffvscontrolFeatures.csv
oldvscontrolFeatures.csv
```
respectively (found on ai-scientist, a private email list).
