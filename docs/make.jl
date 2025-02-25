using DCGCapital
using Documenter

DocMeta.setdocmeta!(DCGCapital, :DocTestSetup, :(using DCGCapital); recursive = true)

makedocs(; modules = [DCGCapital], authors = "Daniel Celis Garza",
         sitename = "DCGCapital.jl",
         format = Documenter.HTML(;
                                  canonical = "https://dcelisgarza.github.io/DCGCapital.jl",
                                  edit_link = "main", assets = String[],),
         pages = ["Home" => "index.md"],)

deploydocs(; repo = "github.com/dcelisgarza/DCGCapital.jl", devbranch = "main",)
