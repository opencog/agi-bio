# Mapping MOSES models into the AtomSpace

This document contains suggestions to map models, their scores, and
their features into AtomSpace hypergraphs.

## Usage

scripts to import moses model csv files exported from R moses analyses here:

### export_models_and_fitness.sh  <MODEL_CSV_FILE>  -o <OUTPUT_FILE>
to convert models and their scores into a scheme readily dumpable into
the AtomSpace.  column headers:  "","Sensitivity","Pos Pred Value"

### relate_features_and_genes.sh  <FEATURE_CSV_FILE>  -o <OUTPUT_FILE>
to generate scheme code to relate MOSES features and their
corresponding genes.  column headers:  gene,Freq,level

## Models

Models are exported in the following format

```
EquivalenceLink <1, 1>
  PredicateNode <MODEL_PREDICATE_NAME>
  <MODEL_BODY>
```

## Features

We need to related `GeneNodes <GENE_NAME>`, used in the GO description,
and `PredicateNodes <GENE_NAME>`, used in the MOSES models. For that I
suggest to use the predicate "overexpressed" as follows:

```
EquivalenceLink <1, 1>
  PredicateNode <GENE_NAME>
  LambdaLink
    VariableNode "$X"
    EvaluationLink
      PredicateNode "overexpressed"
      ListLink
        GeneNode <GENE_NAME>
        VariableNode "$X"
```
which says that PredicateNode <GENE_NAME> over sample $X is
equivalent to "GeneNode <GENE_NAME> is overexpressed in sample $X".

## Fitnesses

I'm discussing 4 fitness scores:

1. Accuracy
2. Precision
3. Sensitivity/Recall
4. False Positive Rate

Let's assume we have the following predicates

1. A MOSES model, binary classifier

```
PredicateNode <MODEL>
```

2. The target feature, i.e. the real outcome

```
PredicateNode <OUTCOME>
```

3. The whole dataset, i.e. containing all inviduals under
   consideration

```
PredicateNode <DATA>
```

Given that we can easily translate the 4 scores into implication links
involving combinations of these 4 predicates.

### Precision

Precision translates directly into an Implication TV strength. that is

```
ImplicationLink <TV.strength = PRE, TV.count = POS>
  PredicateNode <MODEL>
  PredicateNode <OUTCOME>
```

Indeed, According to PLN (assuming all individuals are equiprobable)

```
TV.s = Sum_x min(p(x), q(x)) / Sum_x p(x)
```

where `p` is the indicator function associated to the predicate of a
model, `x` runs over the individuals of the dataset.

This corresponds indeed to the precision

```
PRE = TP / (TP + FP) = TP / P
```

where

```
POS = TP + FP
```

the number of positive outcomes classified by the model.

One can see that `Sum_x p(x)` is indeed the number of positively
classified individuals `POS`, and `Sum_x min(p(x), q(x))` the number
of correctly classified individuals, `TP`.

### Recall

Similarly recall is easily translated into an Implication TV
strength. that is

```
ImplicationLink <TV.strength = REC, TV.count = TRU>
  PredicateNode <OUTCOME>
  PredicateNode <MODEL>
```

given that

```
REC = TP / (TP + FN) = TP / TRU
```

where

```
TRU = TP + FN
```

is the number of actual true outcomes.

### False Positive Rate

Likewise, the False Positive Rate is translated into the following
Implication

```
ImplicationLink <TV.strength = FPR, TV.count = FAL>
  And
    PredicateNode <DATA>
    Not
      PredicateNode <OUTCOME>
  PredicateNode <MODEL>
```

given that

```
FPR = FP / (FP + TN) = FP / FAL
```

where

```
FAL = FP + TN
```

is the number of actual false outcomes.

Note the usage of `PredicateNode <DATA>` to guaranty that the negation
of `PredicateNode <OUTCOME>` has the cardinality of `FAL`.

### Accuracy

Accuracy also translates into an implication link

```
ImplicationLink <TV.strength = ACC, TV.count = TOT>
  PredicateNode <DATA>
  Or
    And
      PredicateNode <MODEL>
      PredicateNode <OUTCOME>
    And
      Not PredicateNode <MODEL>
      Not PredicateNode <OUTCOME>
```

with

```
ACC = (TP + TN) / (TRU + FAL) = (TP + TN) / TOT
```

where

```
TOT = TRU + FAL
```

is the total size of the population.

As one can see `TP` is the cardinality of

```
    And
      PredicateNode <MODEL>
      PredicateNode <OUTCOME>
```

and `TN` is the cardinality of

```
    And
      Not PredicateNode <MODEL>
      Not PredicateNode <OUTCOME>
```

Since these two sets are disjoint the cardinality of their union
is `TP + TN`.
