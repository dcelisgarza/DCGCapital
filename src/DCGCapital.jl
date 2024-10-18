module DCGCapital
using DataFrames, YFinance, TimeSeries, FileIO, JLD2, StatsPlots, GraphRecipes, ArgParse,
      CSV, Dates, ProgressBars, SmartAsserts, Statistics, PortfolioOptimiser, Random

include("./MarketTickers.jl")
include("./Download.jl")
include("./LoadTickers.jl")
include("./OptimisePortfolios.jl")
include("./ProcessPortfolios.jl")

for op ∈ (MarketOpt, DateOpt, DownloadOpt, LoadOpt, FilterOpt, OptimOpt, GenOpt, PortOpt,
          GenMarketOpt)
    eval(quote
             Base.iterate(S::$op, state = 1) = state > 1 ? nothing : (S, state + 1)
             function Base.length(::$op)
                 return 1
             end
             function Base.getindex(S::$op, ::Any)
                 return S
             end
             function Base.view(S::$op, ::Any)
                 return S
             end
         end)
end
include("./Main.jl")

end
