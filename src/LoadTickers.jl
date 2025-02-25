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
    path = lopt.path
    select = lopt.select
    tickers = intersect(tickers, replace.(readdir(path), ".csv" => ""))
    prices = DataFrame(; timestamp = DateTime[])
    jtp_iter = ProgressBar(tickers)
    for ticker ∈ jtp_iter
        set_description(jtp_iter, "Generating master prices dataframe:")
        ticker_prices = load_ticker_prices(ticker, lopt)
        if isempty(ticker_prices)
            continue
        end
        DataFrames.rename!(ticker_prices,
                           setdiff(select, (:timestamp,))[1] => Symbol(ticker))
        prices = outerjoin(prices, ticker_prices; on = :timestamp)
    end

    f(x) =
        if (isa(x, Number) && (isnan(x) || x < zero(x)))
            missing
        else
            x
        end

    transform!(prices, setdiff(names(prices), ("timestamp",)) .=> ByRow((x) -> f(x));
               renamecols = false)

    missings = Int[]
    sizehint!(missings, ncol(prices))
    for col ∈ eachcol(prices)
        push!(missings, count(ismissing.(col)))
    end

    m = StatsBase.mode(missings)
    missings[1] = m
    prices = prices[!, missings .== m]
    dropmissing!(prices)
    return sort!(prices, :timestamp)
end
export LoadOpt, load_ticker_prices, join_ticker_prices
