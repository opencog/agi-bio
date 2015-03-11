knowledge-import 
=================
Scripts for converting Bio knowledge bases into scheme files for importing into the atomspace

Description
-----------

-- Aging-Mythelation.py  -- Python script to generate scheme file from Aging-Mythelation_Geneset dataset

-- GO_scm.py -- Python script used file from http://purl.obolibrary.org/obo/go.obo to generate gene onltology scheme file 

-- Go_Annotation_scm.py -- Python script used file gene_association.goa_ref_human.gz from http://geneontology.org/gene-associations/gene_association.goa_ref_human.gz and generate scheme file for human gene annotation

-- MSigDB_to_scheme.py -- Python script to generate scheme file from Molecular signatures database, version 4

Bio_schemeFiles.zip --  Bio Scheme files all in one

load_atoms.py --- This python script load all bio scheme files from docker container set for loading these scheme files in Hetzner server. In order to use this one needs to have acess to the server. once login to the server run the folllowing commands 

	$ docker exec -i -t for_pattern bash
	$ cd /home/doc
	$ python load_atoms.py
	 once all batasets are loadded one can use the following command to access the running cogserver
	$ rlwrap nc localhost 17001
	 to exit from the cogserver	
	$ ctrl c 
	 to exit from the container
	$ exit 

