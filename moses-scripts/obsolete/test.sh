#!/bin/bash

# Script test to attempt to load MOSES models in scheme format to the
# AtomSpace so that PLN can then reason on them.
#
# It performs the following
#
# 1. Launch an OpenCog server
#
# 2. Load background knowledge from a Scheme file (like feature
# definitions)
#
# 3. Split dataset into k-fold train and test sets
#
# 4. Run MOSES on some problem
#
# 5. Parse the output and pipe it in OpenCog
#
# 6. Use PLN to perform reasoning, etc.

set -u
# set -x

if [[ $# != 1 ]]; then
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

#############
# Constants #
#############

PRG_PATH="$(readlink -f "$0")"
PRG_DIR="$(dirname "$PRG_PATH")"
ROOT_DIR="$(dirname "$PRG_DIR")"
SET_PATH="$1"
SET_BASENAME="$(basename "$SET_PATH")"

#############
# Functions #
#############

# Given an error message, display that error on stderr and exit
fatalError() {
    echo "[ERROR] $@" 1>&2
    exit 1
}

warnEcho() {
    echo "[WARN] $@"    
}

infoEcho() {
    echo "[INFO] $@"
}

# Convert human readable integer into machine full integer. For
# instance $(hr2i 100K) returns 100000, $(hr2i 10M) returns 10000000.
hr2i() {
    local val=$1
    local val=${val/M/000K}
    local val=${val/K/000}
    echo $val
}

# Pad $1 symbol with up to $2 0s
pad() {
    local pad_expression="%0${2}d"
    printf "$pad_expression" "$1"
}

# Split the data into train and test, renaming FILENAME.csv by
# FILENAME_train.csv and FILENAME_test.csv given
#
# 1. Dataset csv file with header
#
# 2. A ratio = train sample size / total size
#
# 3. A random seed
train_test_split() {
    local DATAFILE="$1"
    local RATIO="$2"

    # Reset random seed
    RANDOM="$3"

    # Define train and test outputs
    local DATAFILE_TRAIN=${DATAFILE//.csv/_train.csv}
    local DATAFILE_TEST=${DATAFILE//.csv/_test.csv}

    # Copy header into train and test files
    head -n 1 "$DATAFILE" > "${DATAFILE_TRAIN}"
    head -n 1 "$DATAFILE" > "${DATAFILE_TEST}"

    # Subsample
    while read line; do
        if [[ $(bc <<< "$RATIO * 32767 >= $RANDOM") == 1 ]]; then
            echo "$line" >> "${DATAFILE_TRAIN}"
        else
            echo "$line" >> "${DATAFILE_TEST}"
        fi
    done < <(tail -n +2 "$DATAFILE")
}

# Given
#
# 1. a model name
#
# 2. a combo model
#
# return a scheme code defining the equivalence between the model name
# and the model.
model_def() {
    name="$1"
    model="$2"
    echo "(EquivalenceLink (stv 1.0 1.0) (PredicateNode \"${name}\") $model)"
}

########
# Main #
########

# 0. Copy in experiment dir and source settings

infoEcho "Copy $SET_PATH to current directory"
cp "$SET_PATH" .
. "$SET_BASENAME"

# 1. Launch an OpenCog server

infoEcho "Launch cogserver"
cd "$opencog_repo_path/scripts/"
./run_cogserver.sh "$build_dir_name" &
cd -
sleep 5

# 2. Load background knowledge

infoEcho "Load background knowledge"
if [[ "$scheme_file_path" =~ ^[^/] ]]; then # It is relative
    scheme_file_path="$ROOT_DIR/$scheme_file_path"
fi

(echo "scm"; cat "$scheme_file_path") \
    | "$opencog_repo_path/scripts/run_telnet_cogserver.sh"

# 3. Create train and test data

infoEcho "Create train and test data"
if [[ "$data_path" =~ ^[^/] ]]; then # It is relative
    data_path="$ROOT_DIR/$data_path"
fi
cp $data_path .
data_basename="$(basename "$data_path")"
train_test_split "$data_basename" "$train_ratio" "$init_seed"
data_basename_train=${data_basename//.csv/_train.csv}
data_basename_test=${data_basename//.csv/_test.csv}

# 4. Run MOSES

infoEcho "Run MOSES"
moses_output_file=results.moses
. "$PRG_DIR/moses.sh"

# 5. Parse MOSES output and pipe it in OpenCog

infoEcho "Load MOSES models into the AtomSpace"
(echo "scm";
    i=0
    while read line; do
        moses_model_name="moses_$(pad $i 3)"
        echo "$(model_def "$moses_model_name" "$line")"
        ((++i))
    done < "$moses_output_file"
) | "$opencog_repo_path/scripts/run_telnet_cogserver.sh"

# 6. Use PLN to perform reasoning, etc.
# TODO

# 7. Kill cogserver
