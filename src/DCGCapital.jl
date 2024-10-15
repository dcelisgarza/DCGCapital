module DCGCapital
using DataFrames, YFinance, TimeSeries, JSON3, FileIO, JLD2, StatsPlots, GraphRecipes,
      ArgParse, CSV, Dates, ProgressBars, SmartAsserts
include("./Download.jl")
include("./LoadTickers.jl")
include("./PortfolioGeneration.jl")
include("./Main.jl")
# Write your package code here.

end
