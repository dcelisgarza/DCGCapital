function process_portfolios(process_path = "./Data/Portfolios/", popt::PortOpt = PortOpt(),
                            mopt::MarketOpt = MarketOpt())
    market = popt.market
    name = popt.name
    gopts = popt.gopts
    path = popt.path
    mkpath(path)

    tickers = get_market_tickers(market, mopt)
    if isempty(tickers)
        return nothing
    end

    path = joinpath(path, market)
    mkpath(path)

    gopts_iter = ProgressBar(gopts)
    for gopt ∈ gopts_iter
        set_description(gopts_iter, "Processing $market portfolios:")
        filename = joinpath(path,
                            "$(isempty(name) ? name : name*"_")$(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1)).jld2")
        if !isfile(filename)
            continue
        end
        portfolios = load(filename, "portfolios")
        for (k1, v1) ∈ portfolios
            for (k2, v2) ∈ v1
                sort!(v2[:w], :weights; rev = true)
                v2[:w].weights = replace(v2[:w].weights, 0.0 => missing, -0.0 => missing)
                dropmissing!(v2[:w])
                tmp_name = "$(market)_$(isempty(name) ? name : name*"_")$(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1))_$(k1)_$(k2)"
                append!(v2[:w],
                        DataFrame(; tickers = [tmp_name], shares = Int[0],
                                  price = Float64[v2[:sr]], cost = sum(v2[:w].cost),
                                  weights = Float64[0]))
                CSV.write(joinpath(process_path, "portfolios.csv"), v2[:w]; append = true)
                display(v2[:h])
                display(v2[:dd])
                if haskey(v2, :c)
                    display(v2[:c])
                end
            end
        end
    end

    return nothing
end

function process_all_portfolios(path = "./Data/Portfolios/", name = "portfolios",
                                popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt(),
                                mopt::MarketOpt = MarketOpt())
    mkpath(path)
    filename = joinpath(path, "$(name).csv")
    CSV.write(filename,
              DataFrame(; tickers = String[], shares = Int[], price = Float64[],
                        cost = Float64[], weights = Float64[]))
    popts_iter = ProgressBar(popts)
    for popt ∈ popts_iter
        set_description(popts_iter, "Processing portfolios:")
        process_portfolios(path, popt, mopt)
    end

    return nothing
end

export process_portfolios, process_all_portfolios