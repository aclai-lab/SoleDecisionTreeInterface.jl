module SoleDecisionTreeInterface

import DecisionTree as DT

using Sole
using Sole: DecisionTree

export solemodel

function solemodel(tree::DT.InfoNode, keep_condensed = false)
    # @show fieldnames(typeof(tree))
    root, info = begin
        if keep_condensed
            root = solemodel(tree.node)
            info = (;
                apply_preprocess=(y -> UInt32(findfirst(x -> x == y, tree.info.classlabels))),
                apply_postprocess=(y -> tree.info.classlabels[y]),
            )
            root, info
        else
            root = solemodel(tree.node, tree.info.classlabels)
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

function solemodel(tree::DT.Node, replace_classlabels = nothing)
    test_operator = (<)
    # @show fieldnames(typeof(tree))
    cond = ScalarCondition(Sole.VariableValue(tree.featid), test_operator, tree.featval)
    antecedent = Atom(cond)
    lefttree = solemodel(tree.left, replace_classlabels)
    righttree = solemodel(tree.right, replace_classlabels)
    info = (;
        supporting_predictions = [lefttree.info[:supporting_predictions]..., righttree.info[:supporting_predictions]...],
        supporting_labels = [lefttree.info[:supporting_labels]..., righttree.info[:supporting_labels]...],
    )
    return Branch(antecedent, lefttree, righttree, info)
end

function solemodel(tree::DT.Leaf, replace_classlabels = nothing)
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
