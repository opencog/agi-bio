#!/bin/bash

# Little script to export the models and their scores, given to a CSV,
# following Mike's format, 3 columns, the combo program, then its
# score (that is 1 - accuracy), and finally it's balanced accuracy.
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
# 3. The label associated with its balanced accuracy
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
# Program argument #
####################
if [[ $# != 3 ]]; then
    echo "Usage: $0 COGSERVER_HOST COGSERVER_PORT MODEL_CSV_FILE"
    echo "Example: $0 chr10_moses.5x10.csv localhost 17001"
    exit 1
fi

#############
# Constants #
#############
readonly COGSERVER_HOST="$1"
readonly COGSERVER_PORT="$2"
readonly MODEL_CSV_FILE="$3"
readonly BASE_MODEL_CSV_FILE="$(basename "$MODEL_CSV_FILE")"

#############
# Functions #
#############

# Pad $1 symbol with up to $2 0s
pad() {
    local pad_expression="%0${2}d"
    printf "$pad_expression" "$1"
}

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
    echo "(EquivalenceLink (stv 1.0 1.0) (PredicateNode \"${name}\") $model)"
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
    echo "(EvaluationLink (stv $accuracy 1) (PredicateNode \"accuracy\") (ListLink (PredicateNode \"$name\") (PredicateNode \"$target\")))"
}

# Like above but for balanced accuracy
model_precision_def() {
    local name="$1"
    local target="$2"
    local accuracy="$3"
    echo "(EvaluationLink (stv $accuracy 1) (PredicateNode \"balancedAccuracy\") (ListLink (PredicateNode \"$name\") (PredicateNode \"$target\")))"
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
model_accuracy_def() {
    local name="$1"
    local target="$2"
    local precision="$3"
    echo "(ImplicationLink (stv $accuracy 1) (PredicateNode \"$name\") (PredicateNode \"$target\"))"
}

########
# Main #
########

(echo "scm";
    OLDIFS="$IFS"
    IFS=","
    i=0                             # used to give unique names to models
    while read combo score balanced_accuracy precision; do
        # Skip if that's the header
        if [[ $combo =~ combo ]]; then
            continue
        fi

        # Output model name predicate associated with model
        model_name="${BASE_MODEL_CSV_FILE}:moses_model_$(pad $i 3)"
        scm_model="$(combo-fmt-converter -c "$combo" -f scheme)"
        echo "$(model_name_def "$model_name" "$scm_model")"

        # Output model accuracy
        accuracy=$(bc <<< "1 - $score")
        echo "$(model_accuracy_def "$model_name" aging $accuracy)"

        # Output model balanced accuracy
        echo "$(model_balanced_accuracy_def "$model_name" aging $balanced_accuracy)"

        # Output model precision
        echo "$(model_precision_def "$model_name" aging $precision)"

        ((++i))
    done < "$MODEL_CSV_FILE"
    IFS="$OLDIFS"
) | telnet "$COGSERVER_HOST" "$COGSERVER_PORT"
