function process_portfolios(process_path = "./Data/Portfolios/", popt::PortOpt = PortOpt(),
                            mopt::MarketOpt = MarketOpt())
    market = popt.market
    gopts = popt.gopts
    path = popt.path
    mkpath(path)

    tickers = get_market_tickers(market, mopt)
    if isempty(tickers)
        return nothing
    end

    path = joinpath(path, market)
    mkpath(path)

    iter = ProgressBar(gopts)
    for gopt ∈ iter
        filename = joinpath(path,
                            "$(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1)).jld2")
        if !isfile(filename)
            set_description(iter, "Processing $market portfolios:")
            continue
        end
        portfolios = load(filename, "portfolios")
        for (k1, v1) ∈ portfolios
            for (k2, v2) ∈ v1
                sort!(v2[:w], :weights; rev = true)
                v2[:w].weights = replace(v2[:w].weights, 0.0 => missing, -0.0 => missing)
                dropmissing!(v2[:w])

                name = market *
                       " $(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1)) $k1 $k2"
                println(name)
                # append!(v2[:w],
                #         DataFrame(; tickers = ["$k1 $k2 $market"], shares = Int[0],
                #                   price = Float64[v2[:sr]], cost = Float64[0],
                #                   weights = Float64[0]))

                # CSV.write(filename,
                #           DataFrame(; tickers = String[], shares = Int[], price = Float64[],
                #                     cost = Float64[], weights = Float64[]); append = true)

                display(v2[:h])
                display(v2[:dd])
                if haskey(v2, :c)
                    display(v2[:c])
                end
            end
        end
        set_description(iter, "Processing $market portfolios:")
    end

    return nothing
end

function process_all_portfolios(path = "./Data/Portfolios/",
                                popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt(),
                                mopt::MarketOpt = MarketOpt())
    mkpath(path)
    filename = joinpath(path, "portfolios.csv")
    CSV.write(filename,
              DataFrame(; tickers = String[], shares = Int[], price = Float64[],
                        cost = Float64[], weights = Float64[]))
    iter = ProgressBar(popts)
    for popt ∈ iter
        process_portfolios(path, popt, mopt)
        set_description(iter, "Processing portfolios:")
    end

    return nothing
end

export process_portfolios, process_all_portfolios