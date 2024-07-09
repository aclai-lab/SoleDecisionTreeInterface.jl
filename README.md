# SoleDecisionTreeInterface.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://aclai-lab.github.io/SoleDecisionTreeInterface.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aclai-lab.github.io/SoleDecisionTreeInterface.jl/dev/)
[![Build Status](https://github.com/aclai-lab/SoleDecisionTreeInterface.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/aclai-lab/SoleDecisionTreeInterface.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/giopaglia/SoleDecisionTreeInterface.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/giopaglia/SoleDecisionTreeInterface.jl)

<!--
[![Build Status](https://api.cirrus-ci.com/github/giopaglia/SoleDecisionTreeInterface.jl.svg)](https://cirrus-ci.com/github/giopaglia/SoleDecisionTreeInterface.jl) 
-->

Ever wondered what to do with a trained decision tree? Start by inspecting its knowledge, and end up evaluating it in a dedicated framework!
This package allows you to convert learned [DecisionTree](https://github.com/JuliaAI/DecisionTree.jl) models to [Sole](https://github.com/aclai-lab/Sole.jl) decision tree models.
With a Sole model in your hand, you can then to treat the extracted knowledge in symbolic form, that is, as a set of logical formulas, which allows you to:
- Evaluate them in terms of
  + accuracy (e.g., confidence, lift),
  + relevance (e.g., support),
  + interpretability (e.g., syntax height, number of atoms);
- Modify them;
- Merge them.

<!-- Note: this is a newly developed package; its potential is still unknown. -->

## Usage

### Converting to a Sole model

```julia
using MLJ
using MLJDecisionTreeInterface
using DataFrames

X, y = @load_iris
X = DataFrame(X)

train, test = partition(eachindex(y), 0.8, shuffle=true);
X_train, y_train = X[train, :], y[train];
X_test, y_test = X[test, :], y[test];

# Train a model
learned_dt_tree = begin
  Tree = MLJ.@load DecisionTreeClassifier pkg=DecisionTree
  model = Tree(max_depth=-1, )
  mach = machine(model, X_train, y_train)
  fit!(mach)
  fitted_params(mach).tree
end

using SoleDecisionTreeInterface

# Convert to Sole model
sole_dt = solemodel(learned_dt_tree)
```

### Model inspection & rule study


```julia-repl
julia> using Sole;

julia> # Make test instances flow into the model, so that test metrics can, then, be computed.
       apply!(sole_dt, X_test, y_test);

julia> # Print Sole model
       printmodel(sole_dt; show_metrics = true);
▣ V4 < 0.8
├✔ setosa : (ninstances = 7, ncovered = 7, confidence = 1.0, lift = 1.0)
└✘ V3 < 4.95
 ├✔ V4 < 1.65
 │├✔ versicolor : (ninstances = 10, ncovered = 10, confidence = 1.0, lift = 1.0)
 │└✘ V2 < 3.1
 │ ├✔ virginica : (ninstances = 2, ncovered = 2, confidence = 1.0, lift = 1.0)
 │ └✘ versicolor : (ninstances = 0, ncovered = 0, confidence = NaN, lift = NaN)
 └✘ V3 < 5.05
  ├✔ V1 < 6.5
  │├✔ virginica : (ninstances = 0, ncovered = 0, confidence = NaN, lift = NaN)
  │└✘ versicolor : (ninstances = 0, ncovered = 0, confidence = NaN, lift = NaN)
  └✘ virginica : (ninstances = 11, ncovered = 11, confidence = 0.91, lift = 1.0)

julia> # Extract rules that are at least as good as a random baseline model
       interesting_rules = listrules(sole_dt, min_lift = 1.0, min_ninstances = 0);

julia> printmodel.(interesting_rules; show_metrics = true);
▣ (V4 < 0.8) ∧ (⊤)  ↣  setosa : (ninstances = 30, ncovered = 7, coverage = 0.23, confidence = 1.0, natoms = 1, lift = 4.29)
▣ (¬(V4 < 0.8)) ∧ (V3 < 4.95) ∧ (V4 < 1.65) ∧ (⊤)  ↣  versicolor : (ninstances = 30, ncovered = 10, coverage = 0.33, confidence = 1.0, natoms = 3, lift = 2.73)
▣ (¬(V4 < 0.8)) ∧ (V3 < 4.95) ∧ (¬(V4 < 1.65)) ∧ (V2 < 3.1) ∧ (⊤)  ↣  virginica : (ninstances = 30, ncovered = 2, coverage = 0.07, confidence = 1.0, natoms = 4, lift = 2.5)
▣ (¬(V4 < 0.8)) ∧ (¬(V3 < 4.95)) ∧ (¬(V3 < 5.05)) ∧ (⊤)  ↣  virginica : (ninstances = 30, ncovered = 11, coverage = 0.37, confidence = 0.91, natoms = 3, lift = 2.27)

julia> # Simplify rules while extracting and prettify result
       interesting_rules = listrules(sole_dt, min_lift = 1.0, min_ninstances = 0, normalize = true);

julia> printmodel.(interesting_rules; show_metrics = true, syntaxstring_kwargs = (; threshold_digits = 2));
▣ V4 < 0.8  ↣  setosa : (ninstances = 30, ncovered = 7, coverage = 0.23, confidence = 1.0, natoms = 1, lift = 4.29)
▣ (V4 ∈ [0.8,1.65)) ∧ (V3 < 4.95)  ↣  versicolor : (ninstances = 30, ncovered = 10, coverage = 0.33, confidence = 1.0, natoms = 2, lift = 2.73)
▣ (V4 ≥ 1.65) ∧ (V3 < 4.95) ∧ (V2 < 3.1)  ↣  virginica : (ninstances = 30, ncovered = 2, coverage = 0.07, confidence = 1.0, natoms = 3, lift = 2.5)
▣ (V4 ≥ 0.8) ∧ (V3 ≥ 5.05)  ↣  virginica : (ninstances = 30, ncovered = 11, coverage = 0.37, confidence = 0.91, natoms = 2, lift = 2.27)

julia> # Directly access rule metrics
       readmetrics.(listrules(sole_dt; min_lift=1.0, min_ninstances = 0))
4-element Vector{NamedTuple{(:ninstances, :ncovered, :coverage, :confidence, :natoms, :lift), Tuple{Int64, Int64, Float64, Float64, Int64, Float64}}}:
 (ninstances = 30, ncovered = 7, coverage = 0.23333333333333334, confidence = 1.0, natoms = 1, lift = 4.285714285714286)
 (ninstances = 30, ncovered = 10, coverage = 0.3333333333333333, confidence = 1.0, natoms = 3, lift = 2.7272727272727275)
 (ninstances = 30, ncovered = 2, coverage = 0.06666666666666667, confidence = 1.0, natoms = 4, lift = 2.5)
 (ninstances = 30, ncovered = 11, coverage = 0.36666666666666664, confidence = 0.9090909090909091, natoms = 3, lift = 2.2727272727272725)

julia> # Show rules with an additional metric (syntax height of the rule's antecedent)
       printmodel.(sort(interesting_rules, by = readmetrics); show_metrics = (; round_digits = nothing, additional_metrics = (; height = r->SoleLogics.height(antecedent(r)))));

▣ (V4 ≥ 1.65) ∧ (V3 < 4.95) ∧ (V2 < 3.1)  ↣  virginica : (ninstances = 30, ncovered = 2, coverage = 0.06666666666666667, confidence = 1.0, height = 2, lift = 2.5)
▣ V4 < 0.8  ↣  setosa : (ninstances = 30, ncovered = 7, coverage = 0.23333333333333334, confidence = 1.0, height = 0, lift = 4.285714285714286)
▣ (V4 ∈ [0.8,1.65)) ∧ (V3 < 4.95)  ↣  versicolor : (ninstances = 30, ncovered = 10, coverage = 0.3333333333333333, confidence = 1.0, height = 1, lift = 2.7272727272727275)
▣ (V4 ≥ 0.8) ∧ (V3 ≥ 5.05)  ↣  virginica : (ninstances = 30, ncovered = 11, coverage = 0.36666666666666664, confidence = 0.9090909090909091, height = 1, lift = 2.2727272727272725)

julia> # Pretty table of rules and their metrics
       metricstable(interesting_rules; metrics_kwargs = (; round_digits = nothing, additional_metrics = (; height = r->SoleLogics.height(antecedent(r)))))
┌────────────────────────────────────────┬────────────┬────────────┬──────────┬───────────┬────────────┬────────┬─────────┐
│                             Antecedent │ Consequent │ ninstances │ ncovered │  coverage │ confidence │ height │    lift │
├────────────────────────────────────────┼────────────┼────────────┼──────────┼───────────┼────────────┼────────┼─────────┤
│                               V4 < 0.8 │     setosa │         30 │        7 │  0.233333 │        1.0 │      0 │ 4.28571 │
│        (V4 ∈ [0.8,1.65)) ∧ (V3 < 4.95) │ versicolor │         30 │       10 │  0.333333 │        1.0 │      1 │ 2.72727 │
│ (V4 ≥ 1.65) ∧ (V3 < 4.95) ∧ (V2 < 3.1) │  virginica │         30 │        2 │ 0.0666667 │        1.0 │      2 │     2.5 │
│               (V4 ≥ 0.8) ∧ (V3 ≥ 5.05) │  virginica │         30 │       11 │  0.366667 │   0.909091 │      1 │ 2.27273 │
└────────────────────────────────────────┴────────────┴────────────┴──────────┴───────────┴────────────┴────────┴─────────┘
```
