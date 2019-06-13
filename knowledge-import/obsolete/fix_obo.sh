#!/bin/bash

# script to replace parens with brackets in go.obo to avoid bug when loading
# scheme text files into atomspace, and remove '\"' from conversion bug

sed -i -e 's/(/\[/g' go.obo
sed -i -e 's/)/]/g' go.obo
python GO_scm.py

# why does this work from shell cl but not in script?
sed -i -e 's/\"/"/g' GO.scm

# delete messed up relation defs at end
# TODO:  fix external relationship definishon translations
sed -i '1839165,1839469d' GO.scm
