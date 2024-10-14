module DCGCapital
using DataFrames, YFinance, TimeSeries, JSON3, FileIO, JLD2, StatsPlots, GraphRecipes,
      ArgParse, CSV, Dates, ProgressBars
include("./Download.jl")
include("./LoadTickers.jl")
include("./Main.jl")
# Write your package code here.

end
