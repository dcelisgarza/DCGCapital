using DCGCapital, Clarabel, HiGHS, PortfolioOptimiser, JLD2, FileIO

solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                 :check_sol => (allow_local = true, allow_almost = true),
                                 :params => Dict("verbose" => false,
                                                 "max_step_fraction" => 0.75)))

alloc_solvers = Dict(:HiGHS => Dict(:solver => HiGHS.Optimizer,
                                    :check_sol => (allow_local = true, allow_almost = true),
                                    :params => Dict("log_to_console" => false)))

dopt = DownloadOpt(; dtopt = DateOpt(; date0 = "2023-04-01", date1 = "2023-07-12"))
gmktopts = [GenMarketOpt(; market = Pair("TestMarketBW", "TestMarket"),
                         lopt = LoadOpt(;
                                        dtopt = DateOpt(; date0 = "2023-04-07",
                                                        date1 = "2023-07-03"))),
            GenMarketOpt(; market = Pair("TestMarketBW2", "TestMarket"),
                         lopt = LoadOpt(;
                                        dtopt = DateOpt(; date0 = "2023-04-07",
                                                        date1 = "2023-07-03")))]
popts = [PortOpt(; market = "TestMarket",
                 lopt = LoadOpt(;
                                dtopt = DateOpt(; date0 = "2023-04-07",
                                                date1 = "2023-07-03")),
                 gopts = [GenOpt(; oopt = OptimOpt(; rms = [SD(), CVaR()]),
                                 dtopt = DateOpt(; date0 = "2023-04-29",
                                                 date1 = "2023-06-23")),
                          GenOpt(; oopt = OptimOpt(; rms = EDaR()),
                                 dtopt = DateOpt(; date0 = "2023-04-05",
                                                 date1 = "2023-06-23"))]),
         PortOpt(; market = "TestMarketBW_all",
                 lopt = LoadOpt(;
                                dtopt = DateOpt(; date0 = "2023-04-07",
                                                date1 = "2023-07-03")),
                 gopts = GenOpt(;
                                dtopt = DateOpt(; date0 = "2023-04-29",
                                                date1 = "2023-06-23")))]
fopt = FilterOpt()
main(; solvers = solvers, alloc_solvers = alloc_solvers, download = true, generate = true,
     optimise = true, process = true, markets = "TestMarket", mopt = MarketOpt(),
     dopt = dopt, gmkopts = gmktopts, popts = popts)

ports = load("D:\\Daniel Celis Garza\\dev\\DCGCapital\\Data\\Portfolios\\TestMarketBW_all\\2023-04-29_2023-06-23.jld2",
             "portfolios")

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
