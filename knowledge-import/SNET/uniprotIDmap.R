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

datMap <- filter(dat, ID_type %in% c("GeneID", "Gene_Name")) %>%
  group_by(`UniProtKB-AC`) %>% 
  mutate(grouped_id = row_number()) %>%
  spread(ID_type, ID) %>%
  select(uniprot = `UniProtKB-AC`, entrez = GeneID, symbol = Gene_Name)
datMap <- bind_rows(filter(datMap, n() == 1), 
                   filter(datMap, n() > 1) %>% summarize_all(funs(na.omit(.)[1])))
write_csv(datMap, "data/entrez2uniprot.csv.xz")                    

# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz
tabNames <- c("UniProtKB_AC", "UniProtKB_ID", "ID", "RefSeq", "GI", "PDB", "GO", "UniRef100", "UniRef90", "UniRef50", "UniParc", "PIR", "NCBI-taxon", "MIM", "UniGene", "PubMed", "EMBL", "EMBL-CDS", "Ensembl", "Ensembl_TRS", "Ensembl_PRO", "Additional_PubMed")
tab <- read_tsv("/mnt/biodata/uniprot/HUMAN_9606_idmapping_selected.tab.gz", col_names = tabNames, col_types = strrep("c", 22))
                     