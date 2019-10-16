__author__ = "Hedra"
__email__ = "hedra@singularitynet.io"


# The following script maps the biogrid_genes to their biogrid_id  

import pandas as pd
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO
from collections import defaultdict


thefile = urlopen('https://downloads.thebiogrid.org/Download/BioGRID/Latest-Release/BIOGRID-ORGANISM-LATEST.tab2.zip')
extracted_files = ZipFile(BytesIO(thefile.read()))
dataset = [i for i in extracted_files.namelist() if "BIOGRID-ORGANISM-Homo_sapiens" in i][0]
version = dataset.split('-')[-1].replace(".tab2.txt", "")
print("done downloading, started importing")
data = pd.read_csv(extracted_files.open(dataset), low_memory=False, delimiter='\t')

dct = defaultdict(list)

col = ['BioGRID ID Interactor A', 'BioGRID ID Interactor B', 'Official Symbol Interactor A', 'Official Symbol Interactor B']

data = data[col]

print("Collecting biogrid_id and gene_symbol mappings")

for i in range(data.shape[0]):
    dct[data.iloc[i]['Official Symbol Interactor A'].upper()].append(data.iloc[i]['BioGRID ID Interactor A'])
    dct[data.iloc[i]['Official Symbol Interactor B'].upper()].append(data.iloc[i]['BioGRID ID Interactor B'])

lst = []

print("Creating a dataframe data with biogrid_id and gene_symbol as column")

for g in dct.keys():
    for i in set(dct[g]):
        result = []
        result.append(g)
        result.append(i)
        lst.append(result)

df = pd.DataFrame(lst, columns=["gene_symbol","biogrid_id"])
df = df.drop_duplicates()
print("Done, Exporting the result into csv. check raw_data/gene2biogrid.csv")

df.to_csv("raw_data/gene2biogrid.csv", index=False, sep='\t')
