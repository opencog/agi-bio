## check out uniprot data downloads
library(tidyverse)

# from ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/README
# idmapping.dat
# This file has three columns, delimited by tab:
# 1. UniProtKB-AC 
# 2. ID_type 
# 3. ID
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping.dat.gz
dat <- read_tsv("/mnt/biodata/uniprot/HUMAN_9606_idmapping.dat.gz", col_names = c("UniProtKB-AC", "ID_type", "ID"))

# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz
tabNames <- c("UniProtKB_AC", "UniProtKB_ID", "ID", "RefSeq", "GI", "PDB", "GO", "UniRef100", "UniRef90", "UniRef50", "UniParc", "PIR", "NCBI-taxon", "MIM", "UniGene", "PubMed", "EMBL", "EMBL-CDS", "Ensembl", "Ensembl_TRS", "Ensembl_PRO", "Additional_PubMed")
tab <- read_tsv("/mnt/biodata/uniprot/HUMAN_9606_idmapping_selected.tab.gz", col_names = tabNames, col_types = strrep("c", 22))
uniprot2ez <- select(tab, uniprot = `UniProtKB_AC`, entrez = ID, symbol = `UniProtKB_ID`) %>%
  mutate(symbol = str_remove(symbol, "_HUMAN"))
table(duplicated(uniprot2ez$entrez))
# FALSE   TRUE 
# 19115 153027
write_csv(uniprot2ez, "data/entrez2uniprot.csv.xz")                    
                     