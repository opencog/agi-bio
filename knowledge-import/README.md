knowledge-import 
----------------
Scripts for converting Bio knowledge bases into scheme files for importing into  atomspace 

Description
-----------

```
MSigDB_to_scheme.py
```
Script for converting [Molecular signatures database (MSigDB)](http://www.broadinstitute.org/gsea/downloads.jsp#msigdb) from [msigdb_v5.0.xml](http://www.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/5.0/msigdb_v5.0.xml) to Atomspace representation scheme file. 

```
GO_scm.py 
```
Script convert Human ontology, [go.obo](http://www.berkeleybop.org/ontologies/go.obo), from http://www.berkeleybop.org/ontologies/ to scheme file. 

```
Go_Annotation_scm.py
```
Script to generate atomspace representation of Human gene annotation from http://geneontology.org/gene-associations/gene_association.goa_ref_human.gz.

```
Aging-Mythelation.py 
```
Script read Aging-Mythelation_Geneset dataset, mmc4.xls, and rewrite it in to scheme file.

```
lifeSpanObservation_2015.py
```
Script to convert Human homologue genes from file Lifespan-observations_2015-02-21.csv to scheme file, equivalent atomspace representation.

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

