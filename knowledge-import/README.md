knowledge-import 
----------------
Scripts for converting Bio knowledge bases into scheme files for importing into the atomspace 

Description
-----------

- Bio_schemeFiles.zip --  Imported Bio Scheme files all in one

-- msigdb_v4.0_verbose.scm -- Atomspace representation of Molecular signatures database from http://www.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/4.0/msigdb_v4.0.xml. MSigDB_to_scheme.py script convert msigdb xml file to scheme file. 

-- GO_new.scm -- Atomspace representation of Human ontology from http://purl.obolibrary.org/obo/go.obo,  GO_scm.py script used to convert go.obo to scheme. 

-- GO_annotation.scm -- Atomspace representation of Human gene annotation from http://geneontology.org/gene-associations/gene_association.goa_ref_human.gz and generated using Go_Annotation_scm.py. 

-- mmc4.scm  -- Atomspace representation of Aging-Mythelation_Geneset dataset (mmc4.xml). Aging-Mythelation.py script read mmc4 excel file and rewrite it in scheme.

-- super-centenarian_snp.scm -- Atomspace representaion of moses output model, perfect combos from moses runs on the super-centenarian data set, and used combo-fmt-converter to create the scheme file. 

-- Lifespan-observations_2015-02-21.scm -- Atomspace representation of Human homologue genes from file Lifespan-observations_2015-02-21.csv where lifeSpanObservation_2015.py script used to convert the csv file to scheme file.

-- load_atoms.py --- This python script load all bio scheme files from docker container set for loading these scheme files in Hetzner server. In order to use this one needs to have acess to the server. once login to the server run the folllowing commands 

	$ docker exec -i -t bio_cogserver bash
	$ cd /home/doc
	$ python load_atoms.py
	 once all batasets are loadded one can use the following command to access the running cogserver
	$ rlwrap nc localhost 17001
	 to exit from the cogserver	
	$ ctrl c 
	 to exit from the container
	$ exit 

