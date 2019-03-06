knowledge-import
----------------
Scripts for converting Bio knowledge bases into scheme files for importing into  atomspace

Description
-----------

```
MSigDB_to_scheme.py [obsolete]
```
Script for converting [Molecular signatures database (MSigDB)](http://software.broadinstitute.org/gsea/msigdb/index.jsp) from [msigdb_v6.1.xml](http://software.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/6.1/msigdb_v6.1.xml) to Atomspace representation scheme file.

```
GO_scm.py
```
Script convert Human ontology, [go.obo](http://data.bioontology.org/ontologies/GO/submissions/1676/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb), from http://bioportal.bioontology.org/ontologies/GO to scheme file.
latest version removes all GO synonyms and adds GO term definition strings as ConceptNodes.  **If you intend to use scheme text dumps to save atoms, run `fix_obo.sh` in the same directory as `go.obo` to replace parens with brackets in the definition strings to avoid a bug in scheme text file loading!**

```
Go_Annotation_scm.py
```
Script to generate atomspace representation of Human gene annotation from http://geneontology.org/gene-associations/goa_human.gaf.gz.

```
Aging-Mythelation.py  [obsolete]
```
Script read Aging-Mythelation_Geneset dataset, mmc4.xls, and rewrite it in to scheme file.

```
lifeSpanObservation_2015.py  [obsolete]
```
Script to convert Human homologue genes from csv dump of Lifespan observations DB  equivalent atomspace representation.  The current raw version of the cvs file is [here](http://lifespandb.sageweb.org/search?format=csv)
but `lifespan_observation_to_human_homologue.R`  is broken.

```
SifToScheme.py
```
Script to convert PathwayCommons v9 sif files to scheme using
`RulesOfTranslation.txt`

(IN-COMPLEX-WITH not yet implemented)
```
