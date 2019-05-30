# script to generate id table gene2preteinIDs.csv.xz
# https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.167/BIOGRID-IDENTIFIERS-3.5.167.tab.zip

# filter for human and not synonyms then drop organism column
bgid <- read_tsv("https://downloads.thebiogrid.org/Download/BioGRID/Release-Archive/BIOGRID-3.5.167/BIOGRID-IDENTIFIERS-3.5.167.tab.zip", skip = 28) %>%
  filter(ORGANISM_OFFICIAL_NAME == "Homo sapiens", IDENTIFIER_TYPE != "SYNONYM") %>%
  select(-4)
table(bgid$IDENTIFIER_TYPE)
# BIOGRID                            ENSEMBL                    ENSEMBL PROTEIN 
#   47756                              21828                              29942 
# ENSEMBL RNA                        ENTREZ_GENE                    ENTREZ_GENE_ETG 
#       34414                              47756                              47756 
# GRID LEGACY                               HGNC                               HPRD 
#       23105                              35662                              18042 
# IMGT/GENE-DB                                MIM                            MIRBASE 
#          673                              16137                               1879 
# OFFICIAL SYMBOL                      ORDERED LOCUS                      REFSEQ-LEGACY 
#           47756                               7842                               1715 
# REFSEQ-PROTEIN-ACCESSION REFSEQ-PROTEIN-ACCESSION-VERSIONED                  REFSEQ-PROTEIN-GI 
#                    97709                             113050                              77390 
# REFSEQ-RNA-ACCESSION                      REFSEQ-RNA-GI                         SWISS-PROT 
# 97560                              97560                              19175 
# SYSTEMATIC NAME                             TREMBL                  UNIPROT-ACCESSION 
# 7842                              10956                              68956 
# UNIPROT-ISOFORM                               VEGA 
# 21837                              17013 

# split out ensembl isoforms
# NOTE:  unique has no effect
bgEnsembl <- unique(filter(bgid, grepl("ENSEMBL", IDENTIFIER_TYPE)))
bgRefsq <- unique(filter(bgid, grepl("REFSEQ", IDENTIFIER_TYPE)))
bgUniprot <- unique(filter(bgid, grepl("UNIPROT", IDENTIFIER_TYPE)))
bgSwissprot <- unique(filter(bgid, grepl("SWISS-PROT", IDENTIFIER_TYPE)))
bgid <- filter(bgid, IDENTIFIER_TYPE %in% c("ENTREZ_GENE", "ENTREZ_GENE_ETG", "OFFICIAL SYMBOL")) %>%
  spread(IDENTIFIER_TYPE, IDENTIFIER_VALUE)

sapply(list(setdiff(bgSwissprot$IDENTIFIER_VALUE, bgUniprot$IDENTIFIER_VALUE), 
         intersect(bgUniprot$IDENTIFIER_VALUE, bgSwissprot$IDENTIFIER_VALUE),
         setdiff(bgUniprot$IDENTIFIER_VALUE, bgSwissprot$IDENTIFIER_VALUE)), length)
# [1] 18846     0 89249

ids <- left_join(bgid, bgUniprot)
names(ids)[5:6] <- c("UNIPROT_ID", "UNIPROT_TYPE")
write_csv(ids, "data/gene2proteinIDs.csv.xz")


