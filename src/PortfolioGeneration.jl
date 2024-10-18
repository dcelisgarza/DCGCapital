@kwdef struct FilterOpt{T1, T2, T3, T4, T5, T6, T7, T8}
    rms::T1 = SD()
    cov_type::T2 = PortCovCor()
    cor_type::T3 = PortCovCor()
    dist_type::T4 = DistCanonical()
    hclust_alg::T5 = HAC()
    hclust_opt::T6 = HCOpt()
    best::T7 = 0.2
    worst::T8 = 0.2
end
function filter_tickers(prices, solvers, fopt::FilterOpt = FilterOpt())
    rms = fopt.rms
    cov_type = fopt.cov_type
    cor_type = fopt.cor_type
    dist_type = fopt.dist_type
    hclust_alg = fopt.hclust_alg
    hclust_opt = fopt.hclust_opt
    best = fopt.best
    worst = fopt.worst

    @smart_assert(zero(best) <= best <= one(best))
    @smart_assert(zero(worst) <= worst <= one(worst))

    if isa(prices, DataFrame)
        prices = TimeArray(prices; timestamp = :timestamp)
    end

    all_tickers = Vector{eltype(colnames(prices))}(undef, 0)
    best_tickers = Vector{eltype(colnames(prices))}(undef, 0)
    worst_tickers = Vector{eltype(colnames(prices))}(undef, 0)

    w1 = Float64[]

    # Percentile after n steps
    f(x, n) = 1 - exp(log(x) / n)

    if isone(best)
        best_tickers = colnames(prices)
    elseif iszero(best)
        nothing
    else
        best_tickers = colnames(prices)
        q = f(best, length(rms))
        println("Filter best portfolios.")
        for rm ∈ rms
            kurt_idx, skurt_idx, set_skew, set_sskew = PortfolioOptimiser.find_cov_kurt_skew_rm(rms)[2:end]
            portfolio = HCPortfolio(; prices = prices[best_tickers], solvers = solvers)
            asset_statistics!(portfolio; cov_type = cov_type, cor_type = cor_type,
                              dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                              set_skurt = !isempty(skurt_idx), set_skew = set_skew,
                              set_sskew = set_sskew)
            cluster_assets!(portfolio; hclust_alg = hclust_alg, hclust_opt = hclust_opt)

            w = optimise!(portfolio; type = HERC(), rm = rm)
            if isempty(w)
                continue
            end

            w = w.weights
            if isempty(w1)
                append!(w1, copy(w))
            end

            best_tickers = best_tickers[w .>= quantile(w, q)]
        end
        append!(all_tickers, best_tickers)
    end

    if isone(worst)
        worst_tickers = colnames(prices)
    elseif iszero(worst)
        nothing
    else
        worst_tickers = colnames(prices)
        q = f(worst, length(rms))
        println("Filter worst portfolios.")
        for rm ∈ rms
            if !isempty(w1)
                worst_tickers = worst_tickers[w1 .<= quantile(w1, one(q) - q)]
                w1 = Float64[]
                continue
            end
            kurt_idx, skurt_idx, set_skew, set_sskew = PortfolioOptimiser.find_cov_kurt_skew_rm(rms)[2:end]
            portfolio = HCPortfolio(; prices = prices[worst_tickers], solvers = solvers)
            asset_statistics!(portfolio; cov_type = cov_type, cor_type = cor_type,
                              dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                              set_skurt = !isempty(skurt_idx), set_skew = set_skew,
                              set_sskew = set_sskew)
            cluster_assets!(portfolio; hclust_alg = hclust_alg, hclust_opt = hclust_opt)

            w = optimise!(portfolio; type = HERC(), rm = rm)
            if isempty(w)
                continue
            end

            worst_tickers = worst_tickers[w .<= quantile(w, one(q) - q)]
        end
        append!(all_tickers, worst_tickers)
    end

    return unique!(all_tickers), unique!(best_tickers), unique!(worst_tickers)
end

@kwdef struct OptimOpt{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14}
    rms::T1 = SD()
    cov_type::T2 = PortCovCor()
    cor_type::T3 = PortCovCor()
    dist_type::T4 = DistCanonical()
    hclust_alg::T5 = HAC()
    hclust_opt::T6 = HCOpt()
    short::T7 = false
    short_budget::T8 = 0.2
    short_u::T9 = 0.2
    long_u::T10 = 1.0
    rf::T11 = 3.5 / 100 / 252
    obj::T12 = Sharpe(; rf = rf)
    kelly::T13 = EKelly()
    alloc_method::T14 = LP()
end
function optimise(prices, solvers, alloc_solvers, investment, oopt::OptimOpt = OptimOpt(),
                  market = "")
    rms = oopt.rms
    cov_type = oopt.cov_type
    cor_type = oopt.cor_type
    dist_type = oopt.dist_type
    hclust_alg = oopt.hclust_alg
    hclust_opt = oopt.hclust_opt
    short = oopt.short
    short_budget = oopt.short_budget
    short_u = oopt.short_u
    long_u = oopt.long_u
    obj = oopt.obj
    rf = oopt.rf
    kelly = oopt.kelly
    alloc_method = oopt.alloc_method

    kurt_idx, skurt_idx, set_skew, set_sskew = PortfolioOptimiser.find_cov_kurt_skew_rm(rms)[2:end]

    portfolio = Portfolio(; prices = prices, solvers = solvers,
                          alloc_solvers = alloc_solvers, short = short,
                          short_budget = short_budget, short_u = short_u, long_u = long_u)

    hctype = NCO(; opt_kwargs = (obj = obj, kelly = kelly),
                 port_kwargs = (short = short, short_budget = short_budget,
                                short_u = short_u, long_u = long_u))
    hcportfolio = HCPortfolio(; prices = prices, solvers = solvers,
                              alloc_solvers = alloc_solvers)

    asset_statistics!(hcportfolio; cov_type = cov_type, cor_type = cor_type,
                      dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                      set_skurt = !isempty(skurt_idx), set_skew = set_skew,
                      set_sskew = set_sskew)
    cluster_assets!(hcportfolio; hclust_alg = hclust_alg, hclust_opt = hclust_opt)

    portfolio.mu = hcportfolio.mu
    portfolio.cov = hcportfolio.cov
    portfolio.kurt = hcportfolio.kurt
    portfolio.skurt = hcportfolio.skurt
    portfolio.skew = hcportfolio.skew
    portfolio.sskew = hcportfolio.sskew

    date0 = timestamp(prices)[1]
    date1 = timestamp(prices)[end]

    title1 = "$(market)$(Date(date0))_$(Date(date1))"

    portfolios = Dict()

    println("Optimising portfolios.")
    for rm ∈ rms
        trm = PortfolioOptimiser.get_rm_symbol(rm)
        portfolios[trm] = Dict()
        title2 = "$title1 $trm"

        w1 = optimise!(portfolio; rm = rm, obj = obj, kelly = kelly)
        if !isempty(w1)
            title3 = "$(title2) T"
            portfolios[trm][:t] = Dict()

            w1 = allocate!(portfolio; type = :Trad, method = alloc_method,
                           investment = investment)
            if isempty(w1)
                alloc_method = setdiff((LP(), Greedy()), (alloc_method,))[1]
                w1 = allocate!(portfolio; method = alloc_method, investment = investment)
            end

            portfolio.optimal[:alloc] = w1
            sr = sharpe_ratio(portfolio; type = :alloc, rm = rm,
                              kelly = isa(kelly, NoKelly) ? false : true, rf = rf)
            port_dd = plot_drawdown(portfolio; type = :alloc,
                                    kwargs_ret = (title = title3,
                                                  label = "SR: $(round(sr*100, digits=3)) %",
                                                  legend = :best))
            port_hist = plot_hist(portfolio; type = :alloc, kwargs_h = (title = title3,))

            portfolios[trm][:t][:w] = w1
            portfolios[trm][:t][:sr] = sr
            portfolios[trm][:t][:dd] = port_dd
            portfolios[trm][:t][:h] = port_hist
        end

        w2 = optimise!(hcportfolio; type = hctype, rm = rm)
        if !isempty(w2)
            title3 = "$(title2) H"
            portfolios[trm][:h] = Dict()

            w2 = allocate!(hcportfolio; type = Symbol(hctype), method = alloc_method,
                           investment = investment, short = short,
                           short_u = min(short_u, short_budget), long_u = long_u)
            if isempty(w2)
                alloc_method = setdiff((LP(), Greedy()), (alloc_method,))[1]
                w2 = allocate!(hcportfolio; type = Symbol(hctype), method = alloc_method,
                               investment = investment, short = short,
                               short_u = min(short_u, short_budget), long_u = long_u)
            end

            hcportfolio.optimal[:alloc] = w2

            hcsr = sharpe_ratio(hcportfolio; type = :alloc, rm = rm,
                                kelly = isa(kelly, NoKelly) ? false : true)
            hcport_dd = plot_drawdown(hcportfolio; type = :alloc,
                                      kwargs_ret = (title = title3,
                                                    label = "SR: $(round(hcsr*100, digits=3)) %",
                                                    legend = :best))
            hcport_hist = plot_hist(hcportfolio; type = :alloc,
                                    kwargs_h = (title = title3,))
            hcport_clst = plot_clusters(hcportfolio; cluster = false,
                                        kwargs_d1 = (title = title2, titlefontsize = 10))

            portfolios[trm][:h][:w] = w2
            portfolios[trm][:h][:sr] = hcsr
            portfolios[trm][:h][:dd] = hcport_dd
            portfolios[trm][:h][:h] = hcport_hist
            portfolios[trm][:h][:c] = hcport_clst
        end
    end

    return portfolios
end

@kwdef struct GenOpt{T1, T2, T3, T4, T5}
    investment::T1 = 1e6
    conversion::T2 = 1
    dtopt::T3 = DateOpt()
    fopt::T4 = FilterOpt()
    oopt::T5 = OptimOpt()
end
function generate_portfolio(prices, solvers, alloc_solvers, gopt::GenOpt = GenOpt(),
                            market = "")
    date0 = gopt.dtopt.date0
    date1 = gopt.dtopt.date1
    investment = gopt.investment * gopt.conversion
    prices = TimeArray(filter(:timestamp => x -> DateTime(date0) <= x <= DateTime(date1),
                              prices); timestamp = :timestamp)
    tickers = filter_tickers(prices, solvers, gopt.fopt)[1]
    portfolios = optimise(prices[tickers], solvers, alloc_solvers, investment, gopt.oopt,
                          market)

    return portfolios
end

@kwdef struct PortOpt{T1, T2, T3, T4}
    market::T1 = ""
    lopt::T2 = LoadOpt()
    gopts::T3 = GenOpt()
    path::T4 = "./Data/Portfolios/"
end
function generate_market_portfolios(solvers, alloc_solvers, popt::PortOpt = PortOpt(),
                                    mopt::MarketOpt = MarketOpt())
    market = popt.market
    lopt = popt.lopt
    gopts = popt.gopts
    path = joinpath(popt.path, market)

    tickers = get_market_tickers(market, mopt)
    if isempty(tickers)
        return nothing
    end

    prices = join_ticker_prices(tickers, lopt)
    if isempty(prices)
        return nothing
    end

    mkpath(path)

    println("Generating $market portfolios")
    for gopt ∈ gopts
        portfolios = generate_portfolio(prices, solvers, alloc_solvers, gopt, "$market ")
        if isempty(portfolios)
            continue
        end
        filename = joinpath(path,
                            "$(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1)).jld2")
        save(filename, "portfolios", portfolios)
    end

    return nothing
end

function generate_all_portfolios(solvers, alloc_solvers,
                                 popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt(),
                                 mopt::MarketOpt = MarketOpt())
    println("Generating portfolios")
    for popt ∈ popts
        generate_market_portfolios(solvers, alloc_solvers, popt, mopt)
    end

    return nothing
end

@kwdef struct GenMarketOpt{T1, T2, T3}
    market::T1 = Pair("", "")
    lopt::T2 = LoadOpt()
    fopt::T3 = FilterOpt()
end
function generate_market(solvers, gmkopt::GenMarketOpt = GenMarketOpt(),
                         mopt::MarketOpt = MarketOpt())
    new_market = gmkopt.market.first
    source_markets = gmkopt.market.second
    lopt = gmkopt.lopt
    fopt = gmkopt.fopt
    path = mopt.path

    tickers = get_all_market_tickers(source_markets, mopt)
    if isempty(tickers)
        return nothing
    end

    prices = join_ticker_prices(tickers, lopt)
    if isempty(prices)
        return nothing
    end

    all_tickers, best_tickers, worst_tickers = filter_tickers(prices, solvers, fopt)

    mkpath(path)
    filename = joinpath(path, new_market)

    if !isempty(all_tickers)
        CSV.write(filename * "_all.csv", DataFrame(; Ticker = all_tickers))
    else
        return nothing
    end

    if !isempty(best_tickers)
        CSV.write(filename * "_best.csv", DataFrame(; Ticker = best_tickers))
    end

    if !isempty(worst_tickers)
        CSV.write(filename * "_worst.csv", DataFrame(; Ticker = worst_tickers))
    end

    return nothing
end
function generate_markets(solvers,
                          gmktopts::Union{<:GenMarketOpt, AbstractVector{<:GenMarketOpt}},
                          mopt::MarketOpt = MarketOpt())
    println("Generating markets.")
    for gmktopt ∈ gmktopts
        generate_market(solvers, gmktopt, mopt)
    end

    return nothing
end

export FilterOpt, OptimOpt, GenOpt, PortOpt, GenMarketOpt, filter_tickers