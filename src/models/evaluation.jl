using SoleModels
using MLJBase
using SoleModels: LeafModel
import SoleLogics: npropositions

"""
    readmetrics(m::AbstractModel; kwargs...)

Return a NamedTuple with some performance metrics for the given symbolic model.
Performance metrics can be computed when the `info` structure of the model:
    - :supporting_labels
    - :supporting_predictions

"""
function readmetrics(m::LeafModel{L}; digits = 2) where {L<:Label}
    merge(if haskey(info(m), :supporting_labels) && haskey(info(m), :supporting_predictions)
        _gts = info(m).supporting_labels
        _preds = _gts = info(m).supporting_predictions
        if L <: CLabel
            (; ninstances = length(_gts), confidence = round(MLJBase.accuracy(_gts, _preds); digits = digits))
        elseif L <: RLabel
            (; ninstances = length(_gts), mae = round(MLJBase.mae(_gts, _preds); digits = digits))
        else
            error("Could not compute readmetrics with unknown label type: $(L).")
        end
    elseif haskey(info(m), :supporting_labels)
        return (; ninstances = length(info(m).supporting_labels))
    elseif haskey(info(consequent(m)), :supporting_labels)
        return (; ninstances = length(info(m).supporting_labels))
    else
        return (;)
    end, (; coverage = 1.0))
end

function readmetrics(m::Rule; kwargs...)
    if haskey(info(m), :supporting_labels) && haskey(info(consequent(m)), :supporting_labels)
        _gts = info(m).supporting_labels
        _gts_leaf = info(consequent(m)).supporting_labels
        coverage = length(_gts_leaf)/length(_gts)
        merge(readmetrics(consequent(m); kwargs...), (; coverage = coverage))
    elseif haskey(info(m), :supporting_labels)
        return (; ninstances = length(info(m).supporting_labels))
    elseif haskey(info(consequent(m)), :supporting_labels)
        return (; ninstances = length(info(m).supporting_labels))
    else
        return (;)
    end
end


"""
    evaluaterule(
        r::Rule{O},
        X::AbstractInterpretationSet,
        Y::AbstractVector{L}
    ) where {O,L<:Label}

Evaluate the rule on a labelled dataset, and return a `NamedTuple` consisting of:
- `antsat::Vector{Bool}`: satsfaction of the antecedent for each instance in the dataset;
- `ys::Vector{Union{Nothing,O}}`: rule prediction. For each instance in X:
    - `consequent(rule)` if the antecedent is satisfied,
    - `nothing` otherwise.

See also
[`Rule`](@ref),
[`AbstractInterpretationSet`](@ref),
[`Label`](@ref),
[`check_antecedent`](@ref).
"""
function evaluaterule(
    rule::Rule{O, C, FM},
    X::AbstractInterpretationSet,
    Y::AbstractVector{<:Label}
) where {O,C,FM<:AbstractModel}
    ys = apply(rule,X)

    antsat = ys .!= nothing

    cons_sat = begin
        idxs_sat = findall(antsat .== true)
        cons_sat = Vector{Union{Bool,Nothing}}(fill(nothing, length(Y)))

        idxs_true = begin
            idx_cons = findall(outcome(consequent(rule)) .== Y)
            intersect(idxs_sat, idx_cons)
        end
        idxs_false = begin
            idx_cons = findall(outcome(consequent(rule)) .!= Y)
            intersect(idxs_sat, idx_cons)
        end
        cons_sat[idxs_true]  .= true
        cons_sat[idxs_false] .= false
        cons_sat
    end

    # - `cons_sat::Vector{Union{Nothing,Bool}}`: for each instance in the dataset:
    #     - `nothing` if antecedent is not satisfied.
    #     - `false` if the antecedent is satisfied, but the consequent does not match the ground-truth label,
    #     - `true` if the antecedent is satisfied, and the consequent matches the ground-truth label,

    return (;
        ys = ys,
        antsat     = antsat,
        # cons_sat    = cons_sat,
    )
end

# """
#     npropositions(rule::Rule{O,<:TrueAntecedent}) where {O}
#     npropositions(rule::Rule{O,<:TruthAntecedent}) where {O}

# See also
# [`Rule`](@ref),
# [`TrueAntecedent`](@ref),
# [`TruthAntecedent`](@ref),
# [`antecedent`](@ref),
# [`formula`](@ref),
# [`n_propositions`](@ref).
# """
# npropositions(rule::Rule{O,<:TrueAntecedent}) where {O} = 1
# npropositions(rule::Rule{O,<:TruthAntecedent}) where {O} = npropositions(antecedent(rule))

"""
    rulemetrics(
        r::Rule,
        X::AbstractInterpretationSet,
        Y::AbstractVector{<:Label}
    )

Calculate metrics for a rule with respect to a labelled dataset and returns a `NamedTuple` consisting of:
- `support`: number of instances satisfying the antecedent of the rule divided by
    the total number of instances;
- `error`:
    - For classification problems: number of instances that were not classified
    correctly divided by the total number of instances;
    - For regression problems: mean squared error;
- `length`: number of propositions in the rule's antecedent.

See also
[`Rule`](@ref),
[`AbstractInterpretationSet`](@ref),
[`Label`](@ref),
[`evaluaterule`](@ref),
[`ninstances`](@ref),
[`outcometype`](@ref),
[`consequent`](@ref).
"""
function rulemetrics(
    rule::Rule{O, C, FM},
    X::AbstractInterpretationSet,
    Y::AbstractVector{<:Label}
) where {O,C,FM<:AbstractModel}
    eval_result = evaluaterule(rule, X, Y)
    ys = eval_result[:ys]
    antsat = eval_result[:antsat]
    n_instances = ninstances(X)
    n_satisfy = sum(antsat)

    rule_support =  n_satisfy / n_instances

    rule_error = begin
        if outcometype(consequent(rule)) <: CLabel
            # Number of incorrectly classified instances divided by number of instances
            # satisfying the rule condition.
            # TODO: failure
            misclassified_instances = length(findall(ys .!= Y))
            misclassified_instances / n_satisfy
        elseif outcometype(consequent(rule)) <: RLabel
            # Mean Squared Error (mse)
            mse(ys[antsat], Y[antsat])
        else
            error("The outcome type of the consequent of the input rule $(outcometype(consequent(rule))) is not among those accepted")
        end
    end

    return (;
        support   = rule_support,
        error     = rule_error,
        length    = npropositions(antecedent(rule)),
    )
end

############################################################################################
############################################################################################
############################################################################################
