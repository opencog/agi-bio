
MOZI-AI Annotation service Datasets import scripts
==================================================

The Atomspace of the annotation service(MOZI-AI) integrates the follwoing 
list of biology datasets filtering only of humans (Homo sapiens species).

1. The Biogrid
   BioGRID is a repository for Interaction Datasets. 
   - biogrid.py script
   - gene2proteinMapping.py
   - gene2proteinIDs.R

2. Reactome pathway
   The complete list of pathways and hierarchial relationship among them.
   - reactome.py

   The three Physical Entity (PE) Identifier mapping files 
	- Uniprot to Pathways
	- ChEbi to Pathways and
	- NCBI to pathways are imported

   - check Physical Entity (PE) Identifier mapping.py

3. Small molecule Pathway database (SMPDB)
   The Metabolite names linked to SMPDB pathways and 
   Protein names linked to SMPDB pathways
   - smpdb.py

4. Gene ontology database
   The Genes and their ontology GO (classes used to describe gene function
   and relationships betweeen these classes)

   - Check ../knowledge-import/GO_Annotation_scm.py and GO_scm.py
