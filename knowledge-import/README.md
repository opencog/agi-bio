knowledge-import
----------------
Scripts for converting Bio knowledge bases into scheme files for importing into  atomspace

Description
-----------

```
MSigDB_to_scheme.py
```
Script for converting [Molecular signatures database (MSigDB)](http://software.broadinstitute.org/gsea/msigdb/index.jsp) from [msigdb_v6.0.xml](http://software.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/6.0/msigdb_v6.0.xml) to Atomspace representation scheme file.

```
GO_scm.py
```
Script convert Human ontology, [go.obo](http://purl.obolibrary.org/obo/go.obo), from http://geneontology.org/page/download-ontology to scheme file.

```
Go_Annotation_scm.py
```
Script to generate atomspace representation of Human gene annotation from http://geneontology.org/gene-associations/goa_human.gaf.gz.

```
Aging-Mythelation.py
```
Script read Aging-Mythelation_Geneset dataset, mmc4.xls, and rewrite it in to scheme file.

```
lifeSpanObservation_2015.py
```
Script to convert Human homologue genes from csv dump of Lifespan observations DB  equivalent atomspace representation.  The current raw version of the cvs file is [here](http://lifespandb.sageweb.org/search?format=csv)
but `lifespan_observation_to_human_homologue.R`  is broken.

```
SifToScheme.py
```
Script to convert PathwayCommons v9 sif files to scheme using
`RulesOfTranslation.txt`

```
load_atoms.py
```
This python script load all bio scheme files from docker container set for loading these scheme files in Hetzner server. In order to use this one needs to have acess to the server. once login to the server run the folllowing commands

	$ docker exec -i -t bio_cogserver bash
	$ cd /home/doc
	$ python load_atoms.py
	 once all batasets are loadded one can use the following command to access the running cogserver
	$ rlwrap nc localhost 17001
	 to exit from the cogserver
	$ ctrl c
	 to exit from the container
	$ exit
