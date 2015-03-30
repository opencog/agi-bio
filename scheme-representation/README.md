Scheme Representation

This folder contains a set of pre-generated scheme files, readily
loadable into the AtomSpace.

## Usage

You load all the files under this directory by running

```bash
$ export GUILE_AUTO_COMPILE=0
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

* Files
```
super-centenarian_snp.scm 
```
obtained by running
```
/opencog/build/opencog/comboreduct/main/combo-fmt-converter  perfectCombos.csv

### Scheme files generated using python scripts from knowledge-import


* Files
```
msigdb_v4.0_verbose.scm 
```
obtained by running 
python knowledge-import/MSigDB_to_scheme.py 
```

GO_new.scm
```
obtained by running 
python knowledge-import/GO_scm.py 
```

GO_annotation.scm 
```
obtained by running 
python knowledge-import/Go_Annotation_scm.py 

mmc4.scm 
```
obtained by running 
python knowledge-import/Aging-Mythelation.py 


Lifespan-observations_2015-02-21.scm
```
obtained by running 
python knowledge-import/lifeSpanObservation_2015.py
```
