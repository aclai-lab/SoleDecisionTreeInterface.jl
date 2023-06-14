module SoleModels

using SoleBase
using SoleData
using SoleLogics
using SoleLogics: AbstractInterpretation, AbstractInterpretationSet
using SoleLogics: AbstractSyntaxToken
using SoleLogics: AbstractFormula, Formula, synstruct
using SoleLogics: ⊤, ¬, ∧

using FunctionWrappers: FunctionWrapper
using StatsBase
using ThreadSafeDicts
using Lazy

include("utils.jl")

export outcometype, outputtype

export Rule, Branch
export check_antecedent
export antecedent, consequent
export posconsequent, negconsequent

export DecisionList
export rulebase, defaultconsequent

export DecisionTree
export root

export MixedSymbolicModel, DecisionForest

include("models/base.jl")

export printmodel, displaymodel

include("models/print.jl")

export immediatesubmodels, listimmediaterules
export listrules

include("models/symbolic-utils.jl")

export Label, bestguess

include("machine-learning.jl")

export rulemetrics

include("models/rule-evaluation.jl")

export minify, isminifiable

# Minification interface for lossless data compression
include("utils/minify.jl")

export AbstractFeature,
        Feature, ExternalFWDFeature

export propositions

export parsecondition
export modalities

export slicedataset, concatdatasets

export World, Feature, featvalue
export ValueCondition, FunctionalCondition
export parsecondition
export SupportedLogiset, nmemoizedvalues
export ExplicitBooleanLogiset, checkcondition
export ExplicitLogiset, ScalarCondition

export ninstances, nfeatures
export MultiLogiset, nmodalities, modalities

export UnivariateMin, UnivariateMax,
        UnivariateSoftMin, UnivariateSoftMax,
        MultivariateFeature

export VarFeature,
        UnivariateNamedFeature,
        UnivariateFeature

# Definitions for logical datasets (i.e., logisets)
include("logisets/main.jl")


# export get_ontology,
#        get_interval_ontology

# export DimensionalLogiset, Logiset, SupportedScalarLogiset

# include("logisets/dimensional-logisets/main.jl")


# using .DimensionalDatasets: nfeatures, nrelations,
#                             #
#                             relations,
#                             #
#                             GenericModalDataset,
#                             AbstractLogiset,
#                             AbstractActiveScalarLogiset,
#                             DimensionalLogiset,
#                             Logiset,
#                             SupportedScalarLogiset

# using .DimensionalDatasets: AbstractWorld, AbstractRelation
# using .DimensionalDatasets: AbstractWorldSet, WorldSet
# using .DimensionalDatasets: FullDimensionalFrame

# using .DimensionalDatasets: Ontology, worldtype

# using .DimensionalDatasets: get_ontology,
#                             get_interval_ontology

# using .DimensionalDatasets: OneWorld, OneWorldOntology

# using .DimensionalDatasets: Interval, Interval2D

# using .DimensionalDatasets: IARelations

end
