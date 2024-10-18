struct LoadOpt{T1, T2, T3}
    dtopt::T1
    path::T2
    select::T3
end
function LoadOpt(; dtopt::DateOpt = DateOpt(), path::AbstractString = "./Data/Tickers/",
                 select::Union{AbstractVector{Symbol}, AbstractVector{<:AbstractString}} = [:timestamp,
                                                                                            :adjclose])
    return LoadOpt{typeof(dtopt), typeof(path), typeof(select)}(dtopt, path, select)
end
function load_ticker_prices(ticker, lopt::LoadOpt = LoadOpt())
    date0 = lopt.dtopt.date0
    date1 = lopt.dtopt.date1
    path = lopt.path
    select = lopt.select
    filename = joinpath(path, "$ticker.csv")

    if isfile(filename)
        prices = unique!(CSV.read(filename, DataFrame; select = select))
        prices = sort!(filter!(:timestamp => x -> date0 <= x <= date1, prices), :timestamp)
    else
        prices = DataFrame()
    end

    return prices
end
function join_ticker_prices(tickers, lopt::LoadOpt = LoadOpt())
    select = lopt.select
    prices = DataFrame(; timestamp = DateTime[])
    iter = ProgressBar(tickers)
    for ticker ∈ iter
        ticker_prices = load_ticker_prices(ticker, lopt)
        if isempty(ticker_prices)
            continue
        end
        DataFrames.rename!(ticker_prices,
                           setdiff(select, (:timestamp,))[1] => Symbol(ticker))
        prices = outerjoin(prices, ticker_prices; on = :timestamp)
        set_description(iter, "Generating master prices dataframe:")
    end

    f(x) =
        if (isa(x, Number) && (isnan(x) || x < zero(x)))
            missing
        else
            x
        end

    transform!(prices, setdiff(names(prices), ("timestamp",)) .=> ByRow((x) -> f(x));
               renamecols = false)

    return dropmissing!(prices)
end
export LoadOpt, load_ticker_prices, join_ticker_prices