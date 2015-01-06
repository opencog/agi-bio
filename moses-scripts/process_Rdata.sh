#!/bin/bash

set -u
set -x

# Convert the R data into csv files
R --no-save --quiet --slave <<EOF
load('GSE16716.Rdata')
write.csv(offvscontrol, file = "offvscontrol.csv")
write.csv(oldvscontrol, file = "oldvscontrol.csv")
write.csv(oldvsoff, file = "oldvsoff.csv")
EOF

# Remove the first column (contain sample IDs, not really useful)
for f in offvscontrol.csv oldvscontrol.csv oldvsoff.csv; do
    cut -d',' -f 2- $f > ${f//.csv/_no_col1.csv}
done
