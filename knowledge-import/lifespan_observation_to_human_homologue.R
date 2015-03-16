# Script map "symbol" from Lifespan - observations_2015-02-21.csv file to homosapien homologue.. 

library("biomaRt")
library("stringi")
library("miscTools")

mart_datasets =listDatasets(useMart("ensembl"))

# Read input dataset 
dataset = as.matrix(read.csv("/home/Downloads/Lifespan - observations_2015-02-21.csv", header= TRUE , sep= ","))
#remove rows with no symbol
dataset = subset(dataset, !stri_isempty(dataset[,"symbol"]))

# identify species and corresponding biomart dataset 
species = unique(dataset[,"species"])
db_name <- matrix(nrow = length( species), ncol = 5)
dimnames(db_name)[[2]]  <- c("orgtype", "dataset", "filter","total_genes", "unique_genes")
db_name[ ,"orgtype"] = species

for (each in species){
  for (i in 1:length(mart_datasets$description)){
    if (each  == strsplit(mart_datasets$description[i] ," genes")[[1]][1])
      db_name[, "dataset"][db_name[, "orgtype"] == each] = mart_datasets$dataset[i] }
      db_name[, "total_genes"][db_name[, "orgtype"] == each] = length(dataset[,"symbol"][dataset[ ,"species"] == each])
      db_name[, "unique_genes"][db_name[, "orgtype"] == each] = length(unique(dataset[,"symbol"][dataset[ ,"species"] == each]))
}

#discard those dont have biomart datasets 
db_name = subset(db_name, !is.na(db_name[,"dataset"])) 
db_name[-5,"filter"] = c("external_gene_name", "external_gene_name", "flybasename_gene","mgi_symbol", "mgi_symbol")  # 5. Homo sapiens

# define matrix to hold mapped genes  
mapped_gene <- matrix(nrow = 0, ncol = 5)
dimnames(mapped_gene)[[2]]  <- c("symbol", "hsapiens_homolog_ensembl_gene", "hgnc_symbol" ,"lifespanEffect", "from")
ensembl_hs <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")

# loop through all species 

for (org in db_name[ ,"orgtype"]){  
    ensembl_org <- useMart("ensembl", dataset = db_name[ ,"dataset"][db_name[ ,"orgtype"]== org])
    symbols <-  unique(sub("^\\s+", "", dataset[,"symbol"][dataset[ ,"species"] == org]))
    temp    <- matrix(nrow=length(symbols), ncol = 5)
    dimnames(temp)[[2]]  <- c("symbol", "hsapiens_homolog_ensembl_gene", "hgnc_symbol" ,"lifespanEffect", "from")
    temp[ ,"symbol"] = symbols
    temp[ ,"from"]   = org
    temp = addLifespanEffect(temp, org) # add lifespan values 
    temp = maptoHSensembl(temp ,ensembl_org, db_name[ ,"filter"][db_name[ ,"orgtype"]== org])
    temp = HSensembltoHSymbol(temp)
    mapped_gene = rbind(mapped_gene ,temp)
}

write.csv(mapped_gene, file = paste("lifespan_HumanHomolog.csv", sep = ""), row.names =FALSE)

## defined functions 
## Add lifespan values 

addLifespanEffect <- function(input_mat, org){
  for (sym in input_mat[,"symbol"] ){
    subdataset = subset(dataset, dataset[ ,"species"] == org)
    lifespanType = subdataset[ ,"lifespanEffect"][subdataset[,"symbol"] == sym]
    lifespanType = unique(lifespanType)
    lifespanType =  lifespanType[!stri_isempty(lifespanType)]
    if (length(lifespanType) != 0){
      if (length(lifespanType) == 1 )
      {input_mat[ ,"lifespanEffect"][input_mat[,"symbol"] == sym ] = lifespanType}
      else{
        input_mat[ ,"lifespanEffect"][input_mat[,"symbol"] == sym ] = lifespanType[1]
        for(eachV in lifespanType[2:length(lifespanType)]){
          input_mat = miscTools::insertRow(input_mat,dim(input_mat)[1]+1 , c(sym, input_mat[,"hsapiens_homolog_ensembl_gene"][input_mat[,"symbol"]==sym],input_mat[,"hgnc_symbol"][input_mat[,"symbol"]==sym], eachV) )
        }
      }
    }
  }
  return (subset(input_mat, !stri_isempty(input_mat[,"lifespanEffect"])))
}


## map symbol to human ensembl id 

maptoHSensembl <- function(mappingMat , maRt , filter ) {
  rows = dim(mappingMat)[1]
  for (i in  1:rows){
    if (is.na(mappingMat[i,"hsapiens_homolog_ensembl_gene"])){
      ensembls = getBM(attributes=c('hsapiens_homolog_ensembl_gene'), filters = filter, mappingMat[,"symbol"][i], mart = maRt)
      if(nrow(ensembls) != 0) {
        if(nrow(ensembls) == 1) {mappingMat[ ,"hsapiens_homolog_ensembl_gene"][mappingMat[,"symbol"] == mappingMat[,"symbol"][i]] = ensembls$hsapiens_homolog_ensembl_gene}
        else{
          mappingMat[i ,"hsapiens_homolog_ensembl_gene"] = ensembls$hsapiens_homolog_ensembl_gene[1]
          for (ensemId in ensembls$hgnc_symbol[2: length(ensembls$hsapiens_homolog_ensembl_gene)]) {
            mappingMat = miscTools::insertRow(mappingMat,dim(mappingMat)[1]+1 , c(mappingMat[,"symbol"][i], ensemId, , mappingMat[i , "lifespanEffect"] ))}
        }
      }
    }
  }
  return(subset(mappingMat, !is.na(mappingMat[,"hsapiens_homolog_ensembl_gene"])))
}

## map human esembleId back to human symbol 

HSensembltoHSymbol <- function(mappingMat ) {
  rows = dim(mappingMat)[1]
  for (i in  1:rows){
    if (is.na(mappingMat[i,"hgnc_symbol"])){
      symbols = getBM(attributes=c('hgnc_symbol'), filters = 'ensembl_gene_id', values = mappingMat[,"hsapiens_homolog_ensembl_gene"][i], mart = ensembl_hs)
      if(nrow(symbols) != 0) {
        if(nrow(symbols) == 1) {mappingMat[ ,"hgnc_symbol"][mappingMat[,"hsapiens_homolog_ensembl_gene"] == mappingMat[,"hsapiens_homolog_ensembl_gene"][i]] = symbols$hgnc_symbol}
        else{
          mappingMat[i ,"hgnc_symbol"] = symbols$hgnc_symbol[1]  
          for (symbol in symbols$hgnc_symbol[2: length(symbols$hgnc_symbol)]) {
            mappingMat = miscTools::insertRow(mappingMat,dim(mappingMat)[1]+1 , c(mappingMat[i,"symbol"], mappingMat[,"hsapiens_homolog_ensembl_gene"][i] , symbol, mappingMat[i,"lifespanEffect"]) )}
        }
      }
    }
  }
  return(subset(mappingMat, !is.na(mappingMat[,"hgnc_symbol"])))
}

