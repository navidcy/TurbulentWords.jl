using Documenter, Literate

using CairoMakie
# CairoMakie.activate!(type = "svg")

using TurbulentWords

#####
##### Generate literated examples
#####

const EXAMPLES_DIR = joinpath(@__DIR__, "..", "examples")
const OUTPUT_DIR   = joinpath(@__DIR__, "src/literated")

examples = [
  "hello_flow.jl",
]

for example in examples
  withenv("GITHUB_REPOSITORY" => "FourierFlows/GeophysicalFlowsDocumentation") do
    example_filepath = joinpath(EXAMPLES_DIR, example)
    withenv("JULIA_DEBUG" => "Literate") do
      Literate.markdown(example_filepath, OUTPUT_DIR;
                        flavor = Literate.DocumenterFlavor(), execute = true)
    end
  end
end

example_pages = [
    "Hello flow" => "literated/hellow_flow.md",
]

appendix_pages = [
    "Library" => "appendix/library.md",
    "Function index" => "appendix/function_index.md"
]

pages = [
    "Home" => "index.md",
    "Examples" => example_pages,
    "Appendix" => appendix_pages
]


#####
##### Build and deploy docs
#####

format = Documenter.HTML(
  collapselevel = 2,
     prettyurls = get(ENV, "CI", nothing) == "true",
      canonical = "https://navidcy.github.io/TurbulentWords.jl/dev/"
)

makedocs(
      authors = "Navid C. Constantinou and Gregory L. Wagner",
     sitename = "TurbulentWords.jl",
      modules = [TurbulentWords],
       format = format,
      doctest = true,
        clean = true,
    checkdocs = :all,
        pages = pages
)

@info "Clean up temporary .jld2 and .nc output created by doctests or literated examples..."

"""
    recursive_find(directory, pattern)

Return list of filepaths within `directory` that contains the `pattern::Regex`.
"""
recursive_find(directory, pattern) =
    mapreduce(vcat, walkdir(directory)) do (root, dirs, files)
        joinpath.(root, filter(contains(pattern), files))
    end

files = []
for pattern in [r"\.jld2", r"\.nc"]
    global files = vcat(files, recursive_find(@__DIR__, pattern))
end

for file in files
    rm(file)
end

withenv("GITHUB_REPOSITORY" => "navidcy/TurbulentWords.jl") do
  deploydocs(       repo = "github.com/navidcy/TurbulentWords.jl.git",
                versions = ["stable" => "v^", "dev" => "dev", "v#.#.#"],
            push_preview = false,
               forcepush = true,
               devbranch = "main"
            )
end