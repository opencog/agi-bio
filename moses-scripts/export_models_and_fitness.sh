#!/bin/bash

# Overview
# --------
# Little script to export in scheme format (readily dumpable into the
# AtomSpace) the models and their scores, given to a CSV, following
# Mike's format, 3 columns, the combo program, its recall (aka
# sensitivity) and its precision (aka positive predictive value).
#
# Usage
# -----
# Run it without argument to print the usage.
#
# Description
# -----------
# The model will be labeled FILENAME:moses_model_INDEX
#
# where FILENAME is the basename of the filename provided in argument,
# and INDEX is the row index of the model (starting by 0)
#
# The exported hypergraphs are
#
# 1. The model itself associated with its label (MODEL_PREDICATE_NAME)
#
# EquivalenceLink <1, 1>
#     PredicateNode MODEL_PREDICATE_NAME
#     MODEL
#
# 2. The label associated with its accuracy
#
# EvaluationLink <accuracy>
#     PredicateNode "accuracy"
#     ListLink
#         PredicateNode PREDICATE_MODEL_NAME
#         PredicateNode TARGET_FEATURE_NAME
#
# 3. The label associated with its balanced accuracy [REMOVED]
#
# EvaluationLink <balanced_accuracy>
#     PredicateNode "balancedAccuracy"
#     ListLink
#         PredicateNode PREDICATE_MODEL_NAME
#         PredicateNode TARGET_FEATURE_NAME
#
# 4. The label associated with its precision [REMOVED]
#
# ImplicationLink <precision>
#     PredicateNode MODEL_PREDICATE_NAME
#     PredicateNode TARGET_FEATURE_NAME
#
# 5. The label associated with its recall
#
# ImplicationLink <recall>
#     PredicateNode TARGET_FEATURE_NAME
#     PredicateNode MODEL_PREDICATE_NAME

set -u                          # raise error on unknown variable read
# set -x                          # debug trace

####################
# Source common.sh #
####################
PRG_PATH="$(readlink -f "$0")"
PRG_DIR="$(dirname "$PRG_PATH")"
. "$PRG_DIR/common.sh"

####################
# Program argument #
####################
if [[ $# == 0 || $# -gt 4 ]]; then
    echo "Usage: $0 MODEL_CSV_FILE PRED_NAME [-o OUTPUT_FILE]"
    echo "Example: $0 chr10_moses.5x10.csv \"aging\" -o chr10_moses.5x10.scm"
    exit 1
fi

readonly MODEL_CSV_FILE="$1"
readonly BASE_MODEL_CSV_FILE="$(basename "$MODEL_CSV_FILE")"
readonly PRED_NAME="$2"
shift
OUTPUT_FILE="/dev/stdout"
while getopts "o:" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG"
            ;;
    esac
done

#############
# Functions #
#############

# Given
#
# 1. a model predicate name
#
# 2. a combo model
#
# return a scheme code defining the equivalence between the model name
# and the model:
#
# EquivalenceLink <1, 1>
#     PredicateNode MODEL_PREDICATE_NAME
#     MODEL
model_name_def() {
    local name="$1"
    local model="$2"
    cat <<EOF
(EquivalenceLink (stv 1.0 1.0)
    (PredicateNode "${name}")
    $model)
EOF
}

# Given
#
# 1. a model predicate name
#
# 2. a target feature name
#
# 3. an accuracy
#
# return a scheme code relating the model predicate with the accuracy:
#
# EvaluationLink <accuracy>
#     PredicateNode "accuracy"
#     ListLink
#         PredicateNode PREDICATE_MODEL_NAME
#         PredicateNode TARGET_FEATURE_NAME
model_accuracy_def() {
    local name="$1"
    local target="$2"
    local accuracy="$3"
    cat <<EOF
(EvaluationLink (stv $accuracy 1)
    (PredicateNode "accuracy")
    (ListLink
        (PredicateNode "$name")
        (PredicateNode "$target")))
EOF
}

# Like above but for balanced accuracy
model_balanced_accuracy_def() {
    local name="$1"
    local target="$2"
    local accuracy="$3"
    cat <<EOF
(EvaluationLink (stv $accuracy 1)
    (PredicateNode "balancedAccuracy")
    (ListLink
        (PredicateNode "$name")
        (PredicateNode "$target")))
EOF
}

# Given
#
# 1. a model predicate name
#
# 2. a target feature name
#
# 3. a precision
#
# return a scheme code relating the model predicate with its precision:
#
# ImplicationLink <precision>
#     PredicateNode PREDICATE_MODEL_NAME
#     PredicateNode TARGET_FEATURE_NAME
model_precision_def() {
    local name="$1"
    local target="$2"
    local precision="$3"
    cat <<EOF
(ImplicationLink (stv $precision 1)
    (PredicateNode "$name")
    (PredicateNode "$target"))
EOF
}

# Given
#
# 1. a model predicate name
#
# 2. a target feature name
#
# 3. a recall
#
# return a scheme code relating the model predicate with its recall:
#
# ImplicationLink <recall>
#     PredicateNode TARGET_FEATURE_NAME
#     PredicateNode PREDICATE_MODEL_NAME
model_recall_def() {
    local name="$1"
    local target="$2"
    local recall="$3"
    cat <<EOF
(ImplicationLink (stv $recall 1)
    (PredicateNode "$target")
    (PredicateNode "$name"))
EOF
}

########
# Main #
########

# Count the number of models and how to pad their unique numeric ID
rows=$(nrows "$MODEL_CSV_FILE")
npads=$(python -c "import math; print(int(math.log($rows, 10) + 1))")

# Check that the header is correct (if not maybe the file format has
# changed)
# header=$(head -n 1 "$MODEL_CSV_FILE")
# expected_header='"","Sensitivity","Pos Pred Value"'
# if [[ "$header" != "$expected_header" ]]; then
#     fatalError "Wrong header format: expect '$expected_header' but got '$header'"
# fi

# Create a temporary pipe and save the scheme code
tmp_pipe=$(mktemp -u)
mkfifo "$tmp_pipe"

OLDIFS="$IFS"
IFS=","
i=0                             # used to give unique names to models
while read combo recall precision; do
    # Output model name predicate associated with model
    model_name="${BASE_MODEL_CSV_FILE}:moses_model_$(pad $i $npads)"
    scm_model="$(combo-fmt-converter -c "$combo" -f scheme)"
    echo ";;begin_model"
    echo "$(model_name_def "$model_name" "$scm_model")"
    echo ";;end_model"

    # Output model precision
    echo ";;model_${i} precision"
    echo "$(model_precision_def "$model_name" $PRED_NAME $precision)"
    echo ";;model_${i} precision"

    # Output model recall
    echo ";;model_${i} recall"
    echo "$(model_recall_def "$model_name" $PRED_NAME $recall)"
    echo ";;model_${i} recall"

    ((++i))
done < <(tail -n +2 "$MODEL_CSV_FILE") > "$OUTPUT_FILE"
IFS="$OLDIFS"
