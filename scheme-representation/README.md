# Scheme Representation

This folder contains a set of pre-generated scheme files, readily
loadable into the AtomSpace.

## Usage

You load all the files under this directory by running

```bash
$ ./load-scheme-representation.sh
```

## How to regenerate the files

### MOSES

* Files
```
oldoffvscontrol-models-and-fitness.scm
oldvscontrol-models-and-fitness.scm
```
are obtained by running respectively
```
moses-scripts/export_models_and_fitness.sh oldoffvscontrolCombos.csv
moses-scripts/export_models_and_fitness.sh oldvscontrolFeatures.csv
```

* Files
```
oldoffvscontrol-features-and-genes.scm
oldvscontrol-features-and-genes.scm
```
are obtained by running respectively
```
moses-scripts/relate_features_and_genes.sh oldoffvscontrolFeatures.csv
moses-scripts/relate_features_and_genes.sh oldvscontrolFeatures.csv
```
