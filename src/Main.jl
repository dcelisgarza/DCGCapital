function (@main)(tickers, date0 = [DateTime(2000, 01, 01)],
                 date1 = [DateTime(today() + Day(1))], path = "./Data/Tickers/",
                 period = Day(1))
    if !isa(eltype(date0), DateTime)
        date0 = DateTime.(date0)
    end
    if !isa(eltype(date1), DateTime)
        date1 = DateTime.(date1)
    end

    min_date0, max_date1 = minimum(date0), minimum(date1)

    update_download_tickers(tickers, min_date0, max_date1, path, period)
    println("")

    prices = join_ticker_prices(tickers, min_date0, max_date1, path)
    println("\nGenerating portfolios.")
    for (date0_i, date1_i) ∈ ProgressBar(zip(date0, date1))
        prices_i = TimeArray(filter(:timestamp => x -> date0_i <= x <= date1_i, prices);
                             timestamp = :timestamp)
        # Filter
    end
    return prices
end
export main