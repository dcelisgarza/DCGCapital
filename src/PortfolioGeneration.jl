function filter_tickers(prices, rms, cov_type, cor_type, solvers, best = 0.2, worst = 0.2)
    @smart_assert(zero(best) <= best <= one(best))
    @smart_assert(zero(worst) <= worst <= one(worst))

    tickers = Set{eltype(colnames(prices))}(undef, 0)

    # Percentile after n steps
    f(x, n) = 1 - exp(log(x) / n)

    if !iszero(best)
        tickers_b = colnames(prices)
        q = f(best, length(rms))
        println("Filter best portfolios.")
        for rm ∈ ProgressBar(rms)
        end
    end

    if !iszero(worst)
    end

    return tickers
end