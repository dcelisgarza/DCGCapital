module DCGCapital
using DataFrames, YFinance, TimeSeries, JSON3, FileIO, JLD2, StatsPlots, GraphRecipes,
      ArgParse, CSV, Dates, ProgressBars, SmartAsserts, Statistics, PortfolioOptimiser,
      Random

include("./MarketTickers.jl")
include("./Download.jl")
include("./LoadTickers.jl")
include("./PortfolioGeneration.jl")
include("./Main.jl")

end
