
function (@main)(dmkt, gmkt, solvers = Dict(), alloc_solvers = Dict(), download = true,
                 generate = true, mopt::MarketOpt = MarketOpt(),
                 dopt::DownloadOpt = DownloadOpt(), lopt::LoadOpt = LoadOpt(),
                 gopt::GenOpt = GenOpt())
    if download
        update_download_tickers(shuffle!(get_all_market_tickers(dmkt, mopt)), dopt)
    end

    if generate
        update_download_tickers(shuffle!(get_all_market_tickers(gmkt, mopt)), dopt)
    end
    # prices = join_ticker_prices(tickers, lopt)
    # portfolios_vec = generate_portfolios(prices, solvers, alloc_solvers, gopt)

    # return portfolios_vec

    return nothing
end
export main