using Documenter
using MathJSONComputeEngineBridge

makedocs(
    modules = [MathJSONComputeEngineBridge],
    authors = "Sébastien Celles <s.celles@gmail.com>",
    sitename = "MathJSONComputeEngineBridge.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    pages = [
        "Home" => "index.md",
    ],
)
