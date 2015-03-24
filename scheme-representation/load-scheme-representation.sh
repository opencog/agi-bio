#!/bin/bash

# Simple script to load the scheme representations in the AtomSpace
# assuming the cogserver is already locally running.

set -u

PRG_PATH="$(readlink -f "$0")"
PRG_DIR="$(dirname "$PRG_PATH")"

for f in "$PRG_DIR"/*.scm; do
    echo "Load \"$f\""
    (echo "scm"; echo "(load \"$f\")") | nc localhost 17001 &> /dev/null
done
