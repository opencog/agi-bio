Fitness Functions
=================

This document contains a few suggestions to map model scores (gotten
from MOSES) into hypergraphs.

I'm discussing 2 fitnesses, used by Mike, accuracy (1 - score, in
Mike's terminology) and balanced accuracy.

Accuracy
--------

ACC = (TP + TN) / (P + N)

We define an Accuracy predicate, that takes a model and dataset (or
target feature) as arguments. The model, $M, is itself a predicate
that evaluates to 1 (the confidence is let aside for now) when the
individual $X is classified positively, 0 when it is classified
negatively.

Similarity the target feature, $D, is also a predicate that evaluates
to 1 when the individual $X has its target feature active, 0
otherwise.

```
EquivalenceLink <1>
    BindLink
        ListLink
            $M
            $D
        EvaluationLink
            PredicateNode "Accuracy"
            ListLink
                $M
                $D
    BindLink
        ListLink
            $M
            $D
        AverageLink
            $X
            EquivalenceLink
                ExecutionOutputLink
                    GetStrength 
                    EvaluationLink
                        $M
                        $X
                ExecutionOutputLink
                    GetStrength 
                    EvaluationLink
                        $D
                        $X
```

It turns out the TV on the AverageLink is gonna match the accuracy,
given $M and $D. Indeed, the accuracy is the average number of times
the model is correct with respect to the dataset. With this
representation, given the dataset and the model, PLN can directly
build the Accuracy predicate.

In the absence of dataset, and given the accuracy of each model, one
may directly write down the Accuracy predicate for each model, and
target feature:

```
EvaluationLink <model accuracy>
    PredicateNode "Accuracy"
    ListLink
        PredicateNode <MODEL>
        PredicateNode <TARGET FEATURE>
```
