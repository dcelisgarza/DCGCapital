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
                        fopt = FilterOpt(;
                                         #
                                         rms = [SSD(), CVaR(), CDaR_r()],
                                         #
                                         cor_type = PortCovCor(;
                                                               #
                                                               ce = CovSemi(),
                                                               denoise = DenoiseSpectral(;
                                                                                         detone = true),
                                                               logo = LoGo(;
                                                                           #
                                                                           distance = DistDistMLP(),
                                                                           similarity = DBHTExp()
                                                                           #
                                                                           )
                                                               #
                                                               ),
                                         #
                                         dist_type = DistDistCanonical(),
                                         #
                                         hclust_alg = HAC(),
                                         #
                                         hclust_opt = HCOpt(; k_method = StdSilhouette()),
                                         #
                                         best = 0.25, worst = 0.25
                                         #
                                         )
                        #
                        )

popts = PortOpt(; market = "Wilshire_5000_B25_W25_all",
                lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                gopts = GenOpt(; oopt = OptimOpt(; rms = [SD(), CVaR()]),
                               dtopt = DateOpt(; date0 = "2023-04-29",
                                               date1 = "2023-06-23")))

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = true,
     optimise = false, process = false, markets = "Wilshire_5000", mopt = MarketOpt(),
     dopt = dopt, gmkopts = gmktopts, popts = popts)

ports = load("D:\\Daniel Celis Garza\\dev\\DCGCapital\\Data\\Portfolios\\TestMarketBW_all\\2023-04-29_2023-06-23.jld2",
             "portfolios")

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
