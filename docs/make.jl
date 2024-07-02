using DecisionTreeSoleInterface
using Documenter

DocMeta.setdocmeta!(DecisionTreeSoleInterface, :DocTestSetup, :(using DecisionTreeSoleInterface); recursive=true)

makedocs(;
    modules=[DecisionTreeSoleInterface],
    authors="Giovanni Pagliarini",
    sitename="DecisionTreeSoleInterface.jl",
    format=Documenter.HTML(;
        canonical="https://giopaglia.github.io/DecisionTreeSoleInterface.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/giopaglia/DecisionTreeSoleInterface.jl",
    devbranch="main",
)
