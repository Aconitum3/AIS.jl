using AIS
using Documenter

DocMeta.setdocmeta!(AIS, :DocTestSetup, :(using AIS); recursive=true)

makedocs(;
    modules=[AIS],
    authors="March <example.com> and contributors",
    repo="https://github.com/aconitum3/AIS.jl/blob/{commit}{path}#{line}",
    sitename="AIS.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aconitum3.github.io/AIS.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aconitum3/AIS.jl",
    devbranch="main",
)
