
function (@main)(; solvers = Dict(), alloc_solvers = Dict(),
                 # download
                 download = true,
                 markets::Union{<:AbstractString, AbstractVector{<:String}} = "",
                 dopt::DownloadOpt = DownloadOpt(),
                 # generate
                 generate = true,
                 gmktopts::Union{<:GenMarketOpt, AbstractVector{<:GenMarketOpt}} = GenMarketOpt(),
                 # optimise
                 optimise = true,
                 # process
                 process = true, path = "./Data/Portfolios/",
                 # optimise, process
                 popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt(),
                 # download, generate, optimise, process
                 mopt::MarketOpt = MarketOpt())
    if download
        update_download_tickers(markets, mopt, dopt)
    end

    if generate
        generate_markets(solvers, gmktopts, mopt)
    end

    if optimise
        generate_all_portfolios(solvers, alloc_solvers, popts, mopt)
    end

    if process
        process_all_portfolios(path, popts, mopt)
    end

    return nothing
end

export main