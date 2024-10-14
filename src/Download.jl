function download_ticker(ticker, date0 = DateTime(2000, 01, 01),
                         date1 = DateTime(today() + Day(1)), path = "./Data/Tickers/")
    try
        prices = get_prices(TimeArray, ticker; startdt = date0, enddt = date1)
        mkpath(path)
        filename = joinpath(path, "$ticker.csv")
        CSV.write(filename, prices)
    catch err
        println("error downloading $ticker: error = $err")
    end
    return nothing
end
function update_download_ticker(ticker, date0 = DateTime(2000, 01, 01),
                                date1 = DateTime(today() + Day(1)),
                                path = "./Data/Tickers/", period = Day(1))
    filename = joinpath(path, "$ticker.csv")
    if !isfile(filename)
        download_ticker(ticker, date0, date1, path)
    else
        try
            prices = CSV.read(filename, DataFrame)
            date0_old, date1_old = extrema(prices[!, :timestamp])
            date0_old, date1_old = date0_old - period, date1_old + period
            date0_old, date0, date1_old, date1 = promote(date0_old, DateTime(date0),
                                                         date1_old, DateTime(date1))
            # Update dates before.
            if date0 < date0_old
                try
                    prices0 = get_prices(TimeArray, ticker; startdt = date0,
                                         enddt = date0_old)
                    CSV.write(filename, prices0; append = true)
                catch err
                    println("error updating $ticker pre-date: error = $err")
                end
            end

            # Update dates after.
            if date1 > date1_old
                try
                    prices1 = get_prices(TimeArray, ticker; startdt = date1_old,
                                         enddt = date1)
                    CSV.write(filename, prices1; append = true)
                catch err
                    println("error updating $ticker post-date: error = $err")
                end
            end
        catch err
            println("error reading prices csv: error = $err")
        end
    end
    return nothing
end
function update_download_tickers(tickers, date0 = DateTime(2000, 01, 01),
                                 date1 = DateTime(today() + Day(1)),
                                 path = "./Data/Tickers/", period = Day(1))
    println("Downloading and updating data.")
    for ticker ∈ ProgressBar(tickers)
        update_download_ticker(ticker, date0, date1, path, period)
    end
    return nothing
end
export download_ticker, update_download_ticker, update_download_tickers
