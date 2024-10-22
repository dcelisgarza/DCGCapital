using Dates, DCGCapital, Clarabel, HiGHS, PortfolioOptimiser

solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                 :check_sol => (allow_local = true, allow_almost = true),
                                 :params => Dict("verbose" => false,
                                                 "max_step_fraction" => 0.75)))

alloc_solvers = Dict(:HiGHS => Dict(:solver => HiGHS.Optimizer,
                                    :check_sol => (allow_local = true, allow_almost = true),
                                    :params => Dict("log_to_console" => false)))

dopt = DownloadOpt(; dtopt = DateOpt(; date0 = "2014-01-01"))
gmktopts = GenMarketOpt(; market = Pair("Wilshire_5000_B25_W25", "Wilshire_5000"),
                        lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                        fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                         cor_type = PortCovCor(; ce = CovSemi(),
                                                               denoise = DenoiseSpectral(;
                                                                                         detone = true),
                                                               logo = LoGo(;
                                                                           distance = DistDistMLP(),
                                                                           similarity = DBHTExp())),
                                         dist_type = DistDistCanonical(),
                                         hclust_alg = HAC(),
                                         hclust_opt = HCOpt(; k_method = StdSilhouette()),
                                         best = 0.25, worst = 0.25))

popts = PortOpt(; market = "Wilshire_5000_B25_W25_all",
                lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                               investment = 40_000, covnersion = 1.3,
                               fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                cor_type = PortCovCor(; ce = CovSemi(),
                                                                      denoise = DenoiseSpectral(;
                                                                                                detone = true),
                                                                      logo = LoGo(;
                                                                                  distance = DistDistMLP(),
                                                                                  similarity = DBHTExp())),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                best = 0.25, worst = 0.25),
                               oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                               cor_type = PortCovCor(; ce = CovSemi(),
                                                                     denoise = DenoiseSpectral(;
                                                                                               detone = true),
                                                                     logo = LoGo(;
                                                                                 distance = DistDistMLP(),
                                                                                 similarity = DBHTExp())),
                                               dist_type = DistDistCanonical(),
                                               hclust_alg = DBHT(; distance = DistDistMLP(),
                                                                 similarity = DBHTExp()),
                                               hclust_opt = HCOpt(;
                                                                  k_method = StdSilhouette()),
                                               short = true, budget = 1.0,
                                               short_budget = 0.2, long_u = 1.0,
                                               short_u = 0.2)))

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

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = true,
     optimise = false, process = false, markets = "Wilshire_5000", mopt = MarketOpt(),
     dopt = dopt, gmkopts = gmktopts, popts = popts)

ports = load("D:\\Daniel Celis Garza\\dev\\DCGCapital\\Data\\Portfolios\\TestMarketBW_all\\2023-04-29_2023-06-23.jld2",
             "portfolios")

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
