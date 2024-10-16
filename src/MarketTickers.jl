@kwdef struct MarketOpt{T1, T2}
    path::T1 = "./Data/Markets/"
    comment::T1 = "#"
    select::T2 = [r"(?i)(sicker|symbol)"]
end
function get_market_tickers(market, mopt::MarketOpt = MarketOpt())
    path = mopt.path
    comment = mopt.comment
    select = mopt.select
    filename = joinpath(path, "$market.csv")
    return if isfile(filename)
        unique!(String.(Vector(CSV.read(filename, DataFrame; comment = comment,
                                        select = select)[!, 1])))
    else
        String[]
    end
end
function get_all_market_tickers(markets, mopt::MarketOpt = MarketOpt())
    if !isa(markets, AbstractVector)
        markets = [markets]
    end
    tickers = String[]
    println("Getting market tickers.")
    for market ∈ ProgressBar(markets)
        append!(tickers, get_market_tickers(market, mopt))
    end

    return unique!(tickers)
end

export MarketOpt, get_market_tickers