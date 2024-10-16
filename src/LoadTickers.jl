@kwdef struct LoadOpt{T1, T2, T3, T4, T5}
    period::T1 = Day(1)
    date0::T2 = DateTime(2000, 01, 01)
    date1::T3 = DateTime(today() + period)
    path::T4 = "./Data/Tickers/"
    select::T5 = [:timestamp, :adjclose]
end
function load_ticker_prices(ticker, lopt::LoadOpt = LoadOpt())
    date0 = lopt.date0
    date1 = lopt.date1
    path = lopt.path
    select = lopt.select
    filename = joinpath(path, "$ticker.csv")
    if !isa(date0, DateTime)
        date0 = DateTime(date0)
    end
    if !isa(date1, DateTime)
        date1 = DateTime(date1)
    end
    if isfile(filename)
        prices = CSV.read(filename, DataFrame; select = select)
        prices = sort!(filter!(:timestamp => x -> date0 <= x <= date1, prices), :timestamp)
    else
        prices = DataFrame()
    end

    return prices
end
function join_ticker_prices(tickers, lopt::LoadOpt = LoadOpt())
    select = lopt.select
    println("Generating master prices dataframe.")
    prices = DataFrame(; timestamp = DateTime[])
    for ticker ∈ ProgressBar(tickers)
        ticker_prices = load_ticker_prices(ticker, lopt)
        if isempty(ticker_prices)
            continue
        end
        DataFrames.rename!(ticker_prices,
                           setdiff(select, (:timestamp,))[1] => Symbol(ticker))
        prices = outerjoin(prices, ticker_prices; on = :timestamp)
    end

    f(x) =
        if (x isa Number && (isnan(x) || x < 0))
            missing
        else
            x
        end

    transform!(prices, setdiff(names(prices), ("timestamp",)) .=> ByRow((x) -> f(x));
               renamecols = false)

    return dropmissing!(prices)
end
export LoadOpt, load_ticker_prices, join_ticker_prices