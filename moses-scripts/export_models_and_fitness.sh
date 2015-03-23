#!/bin/bash

# Little script to export in scheme format (readily dumpable into the
# AtomSpace) the models and their scores, given to a CSV, following
# Mike's format, 4 columns, the combo program, then its score (that is
# 1 - accuracy), its precision and recall.
#
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
# 4. The label associated with its precision
#
# ImplicationLink <precision>
#     PredicateNode MODEL_PREDICATE_NAME
#     PredicateNode TARGET_FEATURE_NAME

set -u
# set -x

####################
# Source common.sh #
####################
PRG_PATH="$(readlink -f "$0")"
PRG_DIR="$(dirname "$PRG_PATH")"
. "$PRG_DIR/common.sh"

####################
# Program argument #
####################
if [[ $# != 1 ]]; then
    echo "Usage: $0 MODEL_CSV_FILE"
    echo "Example: $0 chr10_moses.5x10.csv"
    exit 1
fi

#############
# Constants #
#############
readonly MODEL_CSV_FILE="$1"
readonly BASE_MODEL_CSV_FILE="$(basename "$MODEL_CSV_FILE")"

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
(ImplicationLink (stv $accuracy 1)
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
model_precision_def() {
    local name="$1"
    local target="$2"
    local recall="$3"
    cat <<EOF
(ImplicationLink (stv $accuracy 1)
    (PredicateNode "$target"))
    (PredicateNode "$name")
EOF
}

########
# Main #
########

# Count the number of models and how to pad their unique numeric ID
rows=$(nrows "$MODEL_CSV_FILE")
npads=$(python -c "import math; print int(math.log($rows, 10) + 1)")

# Check that the header is correct (if not maybe the file format has
# changed)
header=$(head -n 1 "$MODEL_CSV_FILE")
expected_header='"","Accuracy","Pos Pred Value","Recall"'
if [[ "$header" != "$expected_header" ]]; then
    fatalError "Wrong header format: expect '$expected_header' but got '$header'"
fi

OLDIFS="$IFS"
IFS=","
i=0                             # used to give unique names to models
while read combo score precision recall; do
    # Output model name predicate associated with model
    model_name="${BASE_MODEL_CSV_FILE}:moses_model_$(pad $i $npads)"
    scm_model="$(combo-fmt-converter -c "$combo" -f scheme)"
    echo "$(model_name_def "$model_name" "$scm_model")"

    # Output model accuracy
    accuracy=$(bc <<< "1 - $score")
    echo "$(model_accuracy_def "$model_name" aging $accuracy)"

    # Output model precision
    echo "$(model_precision_def "$model_name" aging $precision)"

    # Output model recall
    echo "$(model_recall_def "$model_name" aging $recall)"

    ((++i))
done < <(tail -n +2 "$MODEL_CSV_FILE") # skip header
IFS="$OLDIFS"
