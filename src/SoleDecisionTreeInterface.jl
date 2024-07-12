module SoleDecisionTreeInterface

using Reexport

import DecisionTree as DT

@reexport using Sole
using Sole: DecisionTree

export solemodel

function solemodel(tree::DT.InfoNode, keep_condensed = false, use_featurenames = true, kwargs...)
    # @show fieldnames(typeof(tree))
    use_featurenames = use_featurenames ? tree.info.featurenames : false
    root, info = begin
        if keep_condensed
            root = solemodel(tree.node; use_featurenames = use_featurenames, kwargs...)
            info = (;
                apply_preprocess=(y -> UInt32(findfirst(x -> x == y, tree.info.classlabels))),
                apply_postprocess=(y -> tree.info.classlabels[y]),
            )
            root, info
        else
            root = solemodel(tree.node; replace_classlabels = tree.info.classlabels, use_featurenames = use_featurenames, kwargs...)
            info = (;)
            root, info
        end
    end

    info = merge(info, (;
            featurenames=tree.info.featurenames,
            # 
            supporting_predictions=root.info[:supporting_predictions],
            supporting_labels=root.info[:supporting_labels],
        )
    )
    return DecisionTree(root, info)
end

# function solemodel(tree::DT.Root)
#     root = solemodel(tree.node)
#     # @show fieldnames(typeof(tree))
#     info = (;
#         n_feat = tree.n_feat,
#         featim = tree.featim,
#         supporting_predictions = root.info[:supporting_predictions],
#         supporting_labels = root.info[:supporting_labels],
#     )
#     return DecisionTree(root, info)
# end

function solemodel(tree::DT.Node; replace_classlabels = nothing, use_featurenames = false)
    test_operator = (<)
    # @show fieldnames(typeof(tree))
    feature = (use_featurenames != false) ? Sole.VariableValue(use_featurenames[tree.featid]) : Sole.VariableValue(tree.featid)
    cond = ScalarCondition(feature, test_operator, tree.featval)
    antecedent = Atom(cond)
    lefttree = solemodel(tree.left; replace_classlabels = replace_classlabels, use_featurenames = use_featurenames)
    righttree = solemodel(tree.right; replace_classlabels = replace_classlabels, use_featurenames = use_featurenames)
    info = (;
        supporting_predictions = [lefttree.info[:supporting_predictions]..., righttree.info[:supporting_predictions]...],
        supporting_labels = [lefttree.info[:supporting_labels]..., righttree.info[:supporting_labels]...],
    )
    return Branch(antecedent, lefttree, righttree, info)
end

function solemodel(tree::DT.Leaf; replace_classlabels = nothing, use_featurenames = false)
    # @show fieldnames(typeof(tree))
    prediction = tree.majority
    labels = tree.values
    if !isnothing(replace_classlabels)
        prediction = replace_classlabels[prediction]
        labels = replace_classlabels[labels]
    end
    info = (;
        supporting_predictions = fill(prediction, length(labels)),
        supporting_labels = labels,
    )
    return SoleModels.ConstantModel(prediction, info)
end

end
