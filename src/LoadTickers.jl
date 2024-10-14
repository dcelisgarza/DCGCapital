function load_ticker_prices(ticker, date0 = DateTime(2000, 01, 01),
                            date1 = DateTime(today() + Day(1)), path = "./Data/Tickers/",
                            select = [:timestamp, :adjclose])
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
function join_ticker_prices(tickers, date0 = DateTime(2000, 01, 01),
                            date1 = DateTime(today() + Day(1)), path = "./Data/Tickers/",
                            select = [:timestamp, :adjclose])
    println("Generating master prices dataframe.")
    prices = DataFrame(; timestamp = DateTime[])
    for ticker ∈ ProgressBar(tickers)
        ticker_prices = load_ticker_prices(ticker, date0, date1, path, select)
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
export load_ticker_prices, join_ticker_prices