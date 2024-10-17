
function (@main)(; solvers = Dict(), alloc_solvers = Dict(), download = true,
                 generate = true, optimise = true,
                 markets::Union{<:AbstractString, AbstractVector{<:String}} = "",
                 mopt::MarketOpt = MarketOpt(), dopt::DownloadOpt = DownloadOpt(),
                 gmkopts::Union{<:GenMarketOpt, AbstractVector{<:GenMarketOpt}} = GenMarketOpt(),
                 popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt())
    if download
        update_download_tickers(markets, mopt, dopt)
    end

    if generate
        generate_markets(solvers, gmkopts, mopt)
    end

    if optimise
        generate_all_portfolios(solvers, alloc_solvers, popts, mopt)
    end

    return nothing
end

export main