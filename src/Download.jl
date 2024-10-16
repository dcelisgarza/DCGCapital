@kwdef struct DownloadOpt{T1, T2, T3, T4}
    period::T1 = Day(1)
    date0::T2 = DateTime(2000, 01, 01)
    date1::T3 = DateTime(today() + period)
    path::T4 = "./Data/Tickers/"
end
function download_ticker(ticker, dopt::DownloadOpt = DownloadOpt)
    date0 = dopt.date0
    date1 = dopt.date1
    path = dopt.path
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
function update_download_ticker(ticker, dopt::DownloadOpt = DownloadOpt())
    path = dopt.path
    filename = joinpath(path, "$ticker.csv")
    if !isfile(filename)
        download_ticker(ticker, dopt)
    else
        period = dopt.period
        date0 = dopt.date0
        date1 = dopt.date1
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
function update_download_tickers(tickers, dopt::DownloadOpt = DownloadOpt())
    println("Downloading and updating data.")
    for ticker ∈ ProgressBar(tickers)
        update_download_ticker(ticker, dopt)
    end
    return nothing
end

export DownloadOpt, download_ticker, update_download_ticker, update_download_tickers
