#!/bin/bash

# Scripts that take a list of feature names (one on each line, given
# in stdin) and generate the corresponding hypergraphs relating them
# to geneNodes.  That is for each feature of name <GENE_NAME> produce:
#
# EquivalenceLink <1, 1>
#     PredicateNode <GENE_NAME>
#     LambdaLink
#         VariableNode $X
#         EvaluationLink
#             PredicateNode "overexpressed"
#             ListLink
#                 GeneNode <GENE_NAME>
#                 $X

########
# Main #
########

while read gene_name; do
    cat <<EOF
(EquivalenceLink
    (PredicateNode "$gene_name")
    (LambdaLink
        (VariableNode "$X")
        (EvaluationLink
            (PredicateNode "overexpressed")
            (ListLink
                (GeneNode "$gene_name")
                (VariableNode "$X"))))
EOF
