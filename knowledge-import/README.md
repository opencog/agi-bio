knowledge-import
----------------
The contents of this directory are obsolete; content has been moved to
the [MOZI.AI/knowlege-import](https://github.com/MOZI-AI/knowledge-import)
git repo. That repo contains all the various scripts used to import
various biomic knowledge bases into the AtomSpace. These are used by
the MOZI.AI (SingularityNet) gene annotation service and other biomic
datamining/analysis tools. See the README in that repo for details.

Description
-----------
Scripts for converting published knowledge bases into Atomese files, for
import into the AtomSpace.

```
MSigDB_to_scheme.py [obsolete]
```
Script for converting
[Molecular signatures database (MSigDB)](http://software.broadinstitute.org/gsea/msigdb/index.jsp)
from
[msigdb_v6.1.xml](http://software.broadinstitute.org/gsea/msigdb/download_file.jsp?filePath=/resources/msigdb/6.1/msigdb_v6.1.xml)
to Atomese (the scheme AtomSpace representation file format).

```
SifToScheme.py [obsolete]
```
experimental script to convert PathwayCommons v9 sif files to scheme Atomese.
`RulesOfTranslation.txt` is an accessory file with the definitions.

(IN-COMPLEX-WITH not yet implemented)
