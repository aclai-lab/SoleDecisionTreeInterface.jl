using SoleDecisionTreeInterface
using Documenter

DocMeta.setdocmeta!(SoleDecisionTreeInterface, :DocTestSetup, :(using SoleDecisionTreeInterface); recursive=true)

makedocs(;
    modules=[SoleDecisionTreeInterface],
    authors="Giovanni Pagliarini",
    sitename="SoleDecisionTreeInterface.jl",
    format=Documenter.HTML(;
        canonical="https://aclai-lab.github.io/SoleDecisionTreeInterface.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/giopaglia/SoleDecisionTreeInterface.jl",
    devbranch="main",
)
