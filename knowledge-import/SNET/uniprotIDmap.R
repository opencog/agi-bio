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

datMap <- filter(dat, ID_type %in% c("GeneID", "Gene_Name", "HGNC"), !is.na(ID)) %>%
  group_by(`UniProtKB-AC`, ID_type) %>%
  summarize(ID = toString(unique(ID))) %>%
  spread(ID_type, ID) %>%
  select(uniprot = `UniProtKB-AC`, entrez = GeneID, symbol = Gene_Name, HGNC) %>%
  filter(!is.na(HGNC)) %>%
  ungroup()
# edge cases
summarize_all(datMap, ~ sum(grepl(",", .)))
# uniprot entrez symbol  HGNC
#       0    254     76   168
datMapEdge <- filter(datMap, grepl(",", symbol)) %>%
  mutate(maxn = pmax(str_count(entrez, ","), str_count(symbol, ","), str_count(HGNC, ","), na.rm = TRUE) + 1) %>%
  mutate_at(c("entrez", "symbol", "HGNC"), ~str_split(., ", ", maxn))
singletons <- sapply(datMapEdge$entrez, length) == 1
datMapEdge$entrez[singletons] <- mapply(rep_len, datMapEdge$entrez[singletons], datMapEdge$maxn[singletons])
datMapEdge[54, 2] <- c("100506084", "100996709")
datMapEdge <- unnest(datMapEdge, entrez, symbol, HGNC)
# missed some edge cases! fix by dropping extra entrez values
datMap <- filter(datMap, !(symbol %in% datMapEdge$symbol)) %>%
  mutate(entrez = gsub(",.*", "", entrez)) %>%
  filter(!is.na(symbol))
summarize_all(datMap, ~ sum(grepl(",", .)))
# uniprot entrez symbol  HGNC
#       0      0      0    92
summarize_all(datMap,~ sum(is.na(.)))
# uniprot entrez symbol  HGNC
#       0  49607      0     0

summarize_all(datMap, ~ sum(duplicated(.)))
# A tibble: 1 x 4
# uniprot entrez symbol  HGNC
#       0  53637  52197 52161
write_csv(datMap, "data/symbol2uniprot.csv.xz")

# compare with old version
e2u <- read_csv("data/entrez2uniprot.csv.xz")
summarize_all(e2u, n_distinct)
# uniprot entrez symbol
# 151498  19051  26462
summarize_all(datMap, n_distinct)
# uniprot entrez symbol  HGNC
#   72535  18898  20338 20374

# check biogrid ids
uniprot2biogrid <- filter(dat, ID_type == "BioGrid") %>%
  select(-ID_type)
dim(uniprot2biogrid)
# [1] 16738     2
summarize_all(uniprot2biogrid, n_distinct)
# `UniProtKB-AC`    ID
#          16612 16666

# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping_selected.tab.gz
tabNames <- c("UniProtKB_AC", "UniProtKB_ID", "ID", "RefSeq", "GI", "PDB", "GO", "UniRef100", "UniRef90", "UniRef50", "UniParc", "PIR", "NCBI-taxon", "MIM", "UniGene", "PubMed", "EMBL", "EMBL-CDS", "Ensembl", "Ensembl_TRS", "Ensembl_PRO", "Additional_PubMed")
tab <- read_tsv("/mnt/biodata/uniprot/HUMAN_9606_idmapping_selected.tab.gz", col_names = tabNames, col_types = strrep("c", 22))
         
# try hgnc map
# 
hgncMap <- read_tsv("/mnt/biodata/hgnc/geneIDmap.tsv")
biogridMap <- filter(dat, ID_type == "BioGrid", !is.na(ID)) %>%
  group_by(`UniProtKB-AC`) %>%
  summarize(ID = toString(unique(ID))) %>%
   select(uniprot = `UniProtKB-AC`, BioGrid = ID) %>%
  ungroup()
write_csv(biogridMap, "data/uniprot2biogrid.csv")
