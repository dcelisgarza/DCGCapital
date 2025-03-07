@kwdef struct FilterOpt{T1, T2, T3, T4, T5, T6, T7, T8}
    rms::T1 = Variance()
    cov_type::T2 = PortCovCor()
    cor_type::T3 = PortCovCor()
    dist_type::T4 = DistCanonical()
    clust_alg::T5 = HAC()
    clust_opt::T6 = ClustOpt()
    best::T7 = 0.2
    worst::T8 = 0.2
end
function filter_tickers(prices, solvers, fopt::FilterOpt = FilterOpt())
    rms = fopt.rms
    cov_type = fopt.cov_type
    cor_type = fopt.cor_type
    dist_type = fopt.dist_type
    clust_alg = fopt.clust_alg
    clust_opt = fopt.clust_opt
    best = fopt.best
    worst = fopt.worst

    @smart_assert(zero(best) <= best <= one(best))
    @smart_assert(zero(worst) <= worst <= one(worst))

    if iszero(best) && iszero(worst)
        all_tickers = colnames(prices)
        return all_tickers, Vector{eltype(colnames(prices))}(undef, 0),
               Vector{eltype(colnames(prices))}(undef, 0)
    end

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
        fbt_iter = ProgressBar(rms)
        for rm ∈ fbt_iter
            set_description(fbt_iter, "Filter best portfolios:")
            special_rm_idx = PortfolioOptimiser.find_special_rm(rm)
            (; kurt_idx, skurt_idx, skew_idx, sskew_idx, wc_idx) = special_rm_idx
            portfolio = Portfolio(; prices = prices[best_tickers], solvers = solvers)
            asset_statistics!(portfolio; cov_type = cov_type, cor_type = cor_type,
                              dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                              set_skurt = !isempty(skurt_idx),
                              set_skew = !isempty(skew_idx),
                              set_sskew = !isempty(sskew_idx))
            cluster_assets!(portfolio; clust_alg = clust_alg, clust_opt = clust_opt)

            w = optimise!(portfolio; type = HERC(; rm = rm))
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
        fwt_iter = ProgressBar(rms)
        for rm ∈ fwt_iter
            set_description(fwt_iter, "Filter worst portfolios:")
            if !isempty(w1)
                worst_tickers = worst_tickers[w1 .<= quantile(w1, one(q) - q)]
                w1 = Float64[]
                continue
            end
            special_rm_idx = PortfolioOptimiser.find_special_rm(rm)
            (; kurt_idx, skurt_idx, skew_idx, sskew_idx, wc_idx) = special_rm_idx
            portfolio = Portfolio(; prices = prices[worst_tickers], solvers = solvers)
            asset_statistics!(portfolio; cov_type = cov_type, cor_type = cor_type,
                              dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                              set_skurt = !isempty(skurt_idx),
                              set_skew = !isempty(skew_idx),
                              set_sskew = !isempty(sskew_idx))
            cluster_assets!(portfolio; clust_alg = clust_alg, clust_opt = clust_opt)

            w = optimise!(portfolio, HERC(; rm = rm))
            if isempty(w)
                continue
            end

            w = w.weights

            worst_tickers = worst_tickers[w .<= quantile(w, one(q) - q)]
        end
        append!(all_tickers, worst_tickers)
    end

    return unique!(all_tickers), unique!(best_tickers), unique!(worst_tickers)
end

@kwdef struct OptimOpt{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15}
    rms::T1 = SD()
    cov_type::T2 = PortCovCor()
    cor_type::T3 = PortCovCor()
    dist_type::T4 = DistCanonical()
    clust_alg::T5 = HAC()
    clust_opt::T6 = ClustOpt()
    short::T7 = false
    budget::T8 = 1.0
    short_budget::T9 = -0.2
    long_ub::T10 = 1.0
    short_lb::T11 = -0.2
    rf::T12 = 3.5 / 100 / 252
    obj::T13 = Sharpe(; rf = rf)
    kelly::T14 = EKelly()
    alloc_method::T15 = LP()
end
function optimise(prices, solvers, alloc_solvers, investment, oopt::OptimOpt = OptimOpt(),
                  name = "")
    rms = oopt.rms
    cov_type = oopt.cov_type
    cor_type = oopt.cor_type
    dist_type = oopt.dist_type
    clust_alg = oopt.clust_alg
    clust_opt = oopt.clust_opt
    short = oopt.short
    budget = oopt.budget
    short_budget = oopt.short_budget
    long_ub = oopt.long_ub
    short_lb = oopt.short_lb
    obj = oopt.obj
    rf = oopt.rf
    kelly = oopt.kelly
    alloc_method = oopt.alloc_method

    special_rm_idx = PortfolioOptimiser.find_special_rm(rms)
    (; kurt_idx, skurt_idx, skew_idx, sskew_idx, wc_idx) = special_rm_idx

    portfolio = Portfolio(; prices = prices, solvers = solvers,
                          alloc_solvers = alloc_solvers, short = short, budget = budget,
                          short_budget = short_budget, long_ub = long_ub,
                          short_lb = short_lb, w_max = short ? long_ub : 1.0,
                          w_min = short ? short_lb : 0.0)

    type1 = Trad(; obj = obj, kelly = kelly)
    type2 = NCO(; internal = NCOArgs(; type = type1), finaliser = JWF())

    asset_statistics!(portfolio; cov_type = cov_type, cor_type = cor_type,
                      dist_type = dist_type, set_kurt = !isempty(kurt_idx),
                      set_skurt = !isempty(skurt_idx), set_skew = !isempty(skew_idx),
                      set_sskew = !isempty(sskew_idx))
    cluster_assets!(portfolio; clust_alg = clust_alg, clust_opt = clust_opt)

    date0 = timestamp(prices)[1]
    date1 = timestamp(prices)[end]

    title1 = "$(name)$(Date(date0))_$(Date(date1))"

    portfolios = Dict()

    op_iter = ProgressBar(rms)
    for rm ∈ op_iter
        set_description(op_iter, "Optimising portfolios:")
        trm = PortfolioOptimiser.get_rm_symbol(rm)
        portfolios[trm] = Dict()
        title2 = "$title1 $trm"
        type1.rm = rm
        w1 = optimise!(portfolio, type1)
        if !isempty(w1)
            title3 = "$(title2) T"
            portfolios[trm][:t] = Dict()

            portfolio.optimal[:alloc1] = allocate!(portfolio, alloc_method; key = :Trad,
                                                   investment = investment)
            if isempty(w1)
                alloc_method = setdiff((LP(), Greedy()), (alloc_method,))[1]
                portfolio.optimal[:alloc1] = allocate!(portfolio, alloc_method; key = :Trad,
                                                       investment = investment)
            end

            sr = sharpe_ratio(portfolio, :alloc1; rm = rm,
                              kelly = isa(kelly, NoKelly) ? false : true, rf = rf)
            port_dd = plot_drawdown(portfolio, :alloc1;
                                    kwargs_ret = (title = title3,
                                                  label = "SR: $(round(sr*100, digits=3)) %",
                                                  legend = :best))
            port_hist = plot_hist(portfolio, :alloc1; kwargs_h = (title = title3,))

            portfolios[trm][:t][:w] = portfolio.optimal[:alloc1]
            portfolios[trm][:t][:sr] = sr
            portfolios[trm][:t][:dd] = port_dd
            portfolios[trm][:t][:h] = port_hist
        end

        w2 = optimise!(portfolio, type2)
        if !isempty(w2)
            title3 = "$(title2) H"
            portfolios[trm][:h] = Dict()

            portfolio.optimal[:alloc2] = allocate!(portfolio, alloc_method; key = :NCO,
                                                   investment = investment)
            if isempty(w2)
                alloc_method = setdiff((LP(), Greedy()), (alloc_method,))[1]
                portfolio.optimal[:alloc2] = allocate!(portfolio, alloc_method; key = :NCO,
                                                       investment = investment)
            end

            hcsr = sharpe_ratio(portfolio, :alloc2; rm = rm,
                                kelly = isa(kelly, NoKelly) ? false : true)
            hcport_dd = plot_drawdown(portfolio, :alloc2;
                                      kwargs_ret = (title = title3,
                                                    label = "SR: $(round(hcsr*100, digits=3)) %",
                                                    legend = :best))
            hcport_hist = plot_hist(portfolio, :alloc2; kwargs_h = (title = title3,))
            hcport_clst = plot_clusters(portfolio; cluster = false,
                                        kwargs_d1 = (title = title2, titlefontsize = 10))

            portfolios[trm][:h][:w] = portfolio.optimal[:alloc2]
            portfolios[trm][:h][:sr] = hcsr
            portfolios[trm][:h][:dd] = hcport_dd
            portfolios[trm][:h][:h] = hcport_hist
            portfolios[trm][:h][:c] = hcport_clst
        end
    end

    return portfolios
end

@kwdef struct GenOpt{T1, T2, T3, T4, T5, T6}
    name::T1 = ""
    investment::T2 = 1e6
    conversion::T3 = 1
    dtopt::T4 = DateOpt()
    fopt::T5 = FilterOpt()
    oopt::T6 = OptimOpt()
end
function generate_portfolio(prices, solvers, alloc_solvers, gopt::GenOpt = GenOpt(),
                            name = "")
    date0 = gopt.dtopt.date0
    date1 = gopt.dtopt.date1
    investment = gopt.investment * gopt.conversion
    prices = TimeArray(filter(:timestamp => x -> DateTime(date0) <= x <= DateTime(date1),
                              prices); timestamp = :timestamp)
    tickers = filter_tickers(prices, solvers, gopt.fopt)[1]
    portfolios = optimise(prices[tickers], solvers, alloc_solvers, investment, gopt.oopt,
                          name)

    return portfolios
end

@kwdef struct PortOpt{T1, T2, T3, T4, T5}
    market::T1 = ""
    name::T2 = ""
    lopt::T3 = LoadOpt()
    gopts::T4 = GenOpt()
    path::T5 = "./Data/Portfolios/"
end
function generate_market_portfolios(solvers, alloc_solvers, popt::PortOpt = PortOpt(),
                                    mopt::MarketOpt = MarketOpt())
    market = popt.market
    name = popt.name
    lopt = popt.lopt
    gopts = popt.gopts
    path = popt.path
    mkpath(path)

    tickers = get_market_tickers(market, mopt)
    if isempty(tickers)
        return nothing
    end

    path = joinpath(path, market)
    mkpath(path)

    prices = join_ticker_prices(tickers, lopt)
    if isempty(prices)
        return nothing
    end

    gmp_iter = ProgressBar(gopts)
    for gopt ∈ gmp_iter
        set_description(gmp_iter, "Generating $market portfolios:")
        _name = gopt.name
        portfolios = generate_portfolio(prices, solvers, alloc_solvers, gopt,
                                        "$(market)$(isempty(name) ? name : " "*name)$(isempty(_name) ? _name : " "*_name) ")
        if isempty(portfolios)
            continue
        end
        tmp_name = if isempty(name)
            _name
        else
            "$(name)$(isempty(_name) ? _name : "_"*_name)"
        end
        filename = joinpath(path,
                            "$(isempty(tmp_name) ? tmp_name : tmp_name*"_")$(Date(gopt.dtopt.date0))_$(Date(gopt.dtopt.date1)).jld2")
        save(filename, "portfolios", portfolios)
    end

    return nothing
end

function generate_all_portfolios(solvers, alloc_solvers,
                                 popts::Union{<:PortOpt, AbstractVector{<:PortOpt}} = PortOpt(),
                                 mopt::MarketOpt = MarketOpt())
    gap_iter = ProgressBar(popts)
    for popt ∈ gap_iter
        set_description(gap_iter, "Generating portfolios:")
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
    mkpath(path)

    tickers = get_all_market_tickers(source_markets, mopt)
    if isempty(tickers)
        return nothing
    end

    prices = join_ticker_prices(tickers, lopt)
    if isempty(prices)
        return nothing
    end

    all_tickers, best_tickers, worst_tickers = filter_tickers(prices, solvers, fopt)

    filename = joinpath(path, new_market)

    if !isempty(all_tickers)
        try
            CSV.write(filename * "_all.csv", DataFrame(; Ticker = all_tickers))
        catch err
            println("error writing to csv: $err")
        end
    else
        return nothing
    end

    if !isempty(best_tickers)
        try
            CSV.write(filename * "_best.csv", DataFrame(; Ticker = best_tickers))
        catch err
            println("error writing to csv: $err")
        end
    end

    if !isempty(worst_tickers)
        try
            CSV.write(filename * "_worst.csv", DataFrame(; Ticker = worst_tickers))
        catch err
            println("error writing to csv: $err")
        end
    end

    return nothing
end
function generate_markets(solvers,
                          gmktopts::Union{<:GenMarketOpt, AbstractVector{<:GenMarketOpt}},
                          mopt::MarketOpt = MarketOpt())
    gm_iter = ProgressBar(gmktopts)
    for gmktopt ∈ gm_iter
        set_description(gm_iter, "Generating markets:")
        generate_market(solvers, gmktopt, mopt)
    end

    return nothing
end

export FilterOpt, OptimOpt, GenOpt, PortOpt, GenMarketOpt, filter_tickers
