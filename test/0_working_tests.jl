using DCGCapital, Clarabel, HiGHS

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

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = true,
     optimise = false, markets = "TestMarket", mopt = MarketOpt(), dopt = dopt,
     gmkopts = gmktopts, popts = PortOpt())

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
