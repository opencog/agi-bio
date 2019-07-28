MOZI-AI Gene annotation service datasets
Gene ontology (GO)
Source: http://snapshot.geneontology.org/ontology/go.obo 
Downloaded on  Apr 23, 2019
Scheme version: https://mozi.ai/datasets/GO.scm 
Sample scheme representation in atomese format
(EvaluationLink
     (PredicateNode "GO_name")
     (ListLink
         (ConceptNode "GO:0000187")
         (ConceptNode "activation of MAPK activity")
     )
)
(EvaluationLink
     (PredicateNode "GO_namespace")
     (ListLink
         (ConceptNode "GO:0000187")
         (ConceptNode "biological_process")
     )
)
(EvaluationLink
     (PredicateNode "GO_definition")
     (ListLink
         (ConceptNode "GO:0000187")
         (ConceptNode "The initiation of the activity of the inactive enzyme MAP kinase (MAPK).")
     )
)
(InheritanceLink
     (ConceptNode "GO:0000187")
     (ConceptNode "GO:0032147")
)
Gene Ontology annotation
Source: http://current.geneontology.org/annotations/goa_human.gaf.gz 
Downloaded on  April 23, 2019
Scheme version: https://mozi.ai/datasets/GO_annotation.scm 
Sample scheme representation in atomese format
(MemberLink
    (GeneNode "IGF1")
    (ConceptNode "GO:0000187"))
(EvaluationLink
     (PredicateNode "has_name")
     (ListLink
         (GeneNode "IGF1")
         (ConceptNode "Insulin-like growth factor I"))
))
Proteins (UniProt) to GO mapping
Source: http://current.geneontology.org/annotations/goa_human_isoform.gaf.gz 
Downloaded on  May 18, 2019
Scheme version: https://mozi.ai/datasets/uniprot2GO.scm 
Sample scheme representation in atomese format
(MemberLink 
(MoleculeNode "Uniprot:P05019")
(ConceptNode "GO:0005179"))
Entrez to protein mapping
Source: 
Downloaded on  
Scheme version: https://mozi.ai/datasets/entrez_to_protein.scm
Sample scheme representation in atomese format
(EvaluationLink 
(PredicateNode "expresses")
(ListLink 
(GeneNode "IGF1")
(MoleculeNode "Uniprot:P05019")
))
(EvaluationLink 
(PredicateNode "has_entrez_id")
(ListLink 
(GeneNode "IGF1")
(ConceptNode "entrez:3479")
))
SMPDB Uniprot
Source: http://smpdb.ca/downloads/smpdb_proteins.csv.zip 
Downloaded on  Nov  1 2018
Scheme version: https://mozi.ai/datasets/smpdb_protein.scm 
Sample scheme representation in atomese format
(MemberLink
(GeneNode "MAP2K4")
(ConceptNode "SMP0000358"))
(MemberLink
(MoleculeNode "Uniprot:P45985")
(ConceptNode "SMP0000358"))
(EvaluationLink
(PredicateNode "has_name")
(ListLink
(ConceptNode "SMP0000358")
(ConceptNode "Fc Epsilon Receptor I Signaling in Mast Cells")
))
(EvaluationLink
(PredicateNode "has_name")
(ListLink
                                                 (MoleculeNode "Uniprot:P45985")
                                                (ConceptNode "Dual specificity mitogen-activated protein kinase kinase 4")
))
SMPDB Chebi
Source: http://smpdb.ca/downloads/smpdb_metabolites.csv.zip 
Downloaded on  September 16, 2018
Scheme version: https://mozi.ai/datasets/smpdb_chebi_wname.scm 
Sample scheme representation in atomese format
(MemberLink
(MoleculeNode "ChEBI:30915")
(ConceptNode "SMP0000055"))
(EvaluationLink
(PredicateNode "has_name")
(ListLink
(MoleculeNode "ChEBI:30915")
(ConceptNode "2-oxopentanedioic acid")
))
Reactome pathway
Sources: https://reactome.org/download/current/ReactomePathwaysRelation.txt
https://reactome.org/download/current/ReactomePathways.txt 
Downloaded on  April 30, 2019
Scheme version: https://mozi.ai/datasets/reactome.scm 
Sample scheme representation in atomese format
(EvaluationLink
(PredicateNode "has_name")
(ListLink
(ConceptNode "R-HSA-114608")
(ConceptNode "Platelet degranulation ")))
(InheritanceLink
(ConceptNode "R-HSA-114608")
(ConceptNode "R-HSA-76005"))
NCBI to reactome
Source: https://reactome.org/download/current/NCBI2Reactome_PE_Pathway.txt 
Downloaded on  Apr 23 2019
Scheme version: https://mozi.ai/datasets/NCBI2Reactome_PE_Pathway.txt.scm  
Sample scheme representation in atomese format
(AndLink
(MemberLink 
(GeneNode "IGF1")
(ConceptNode "R-HSA-114608"))
(EvaluationLink
(PredicateNode "has_location")
(ListLink
(GeneNode "IGF1")
(ConceptNode "platelet alpha granule lumen")))
)
(AndLink
(MemberLink 
(GeneNode "IGF1")
(ConceptNode "R-HSA-114608"))
(EvaluationLink 
(PredicateNode "has_location")
(ListLink
(GeneNode "IGF1")
(ConceptNode "extracellular region")))
)

Uniprot to Reactome
Source: https://reactome.org/download/current/UniProt2Reactome_PE_Pathway.txt 
Downloaded on  Apr 23 2019
Scheme version: https://mozi.ai/datasets/UniProt2Reactome_PE_Pathway.txt.scm 
Sample scheme representation in atomese format
(EvaluationLink 
(PredicateNode "has_name")
(ListLink
(MoleculeNode "Uniprot:O00194")
(ConceptNode "RAB27B")))
(AndLink
(MemberLink 
(MoleculeNode "Uniprot:O00194")
(ConceptNode "R-HSA-114608"))
(EvaluationLink 
(PredicateNode "has_location")
(ListLink
(MoleculeNode "Uniprot:O00194")
(ConceptNode "platelet dense granule membrane")))
)
Chebi to reactome
Source: https://reactome.org/download/current/ChEBI2Reactome_PE_Pathway.txt 
Downloaded on  April 23, 2019
Scheme version: https://mozi.ai/datasets/ChEBI2Reactome_PE_Pathway.txt.scm 
Sample scheme representation in atomese format
(AndLink
(MemberLink 
(MoleculeNode "ChEBI:30915")
(ConceptNode "R-HSA-1614558"))
(EvaluationLink 
(PredicateNode "has_location")
(ListLink
(MoleculeNode "ChEBI:30915")
(ConceptNode "mitochondrial matrix")))
)
(EvaluationLink
(PredicateNode "has_name")
(ListLink
(MoleculeNode "ChEBI:30915")
(ConceptNode "2OG")))
The biogrid 
Source: https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.174/BIOGRID-ORGANISM-3.5.174.tab2.zip 
Downloaded on  July 22 2019
Scheme version: https://mozi.ai/datasets/biogrid_gene_gene_174.scm 
Sample scheme representation in atomese format
(EvaluationLink
(PredicateNode "has_pubmedID")
(ListLink
                                                       (EvaluationLink
                                                       (PredicateNode "interacts_with")
                                                            (ListLink
                                                                (GeneNode "IGFBP3")
                                                                (GeneNode "IGF1")))
                                                       (ListLink
                                                   (ConceptNode "https://www.ncbi.nlm.nih.gov/pubmed/?term=9446566")
          (ConceptNode "https://www.ncbi.nlm.nih.gov/pubmed/?term=1383255")
          (ConceptNode "https://www.ncbi.nlm.nih.gov/pubmed/?term=11600567")
          )
)
)


