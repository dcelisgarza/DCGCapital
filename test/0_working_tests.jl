using Dates, DCGCapital, Clarabel, CovarianceEstimation, HiGHS, OrderedCollections,
      PortfolioOptimiser

solvers = [PortOptSolver(; name = :Clarabel1, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = "verbose" => true),
           PortOptSolver(; name = :Clarabel2, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = ["verbose" => true, "max_step_fraction" => 0.9]),
           PortOptSolver(; name = :Clarabel2, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = ["verbose" => true, "max_step_fraction" => 0.8,
                                   "max_iter" => 400]),
           PortOptSolver(; name = :Clarabel2, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = ["verbose" => true, "max_step_fraction" => 0.7,
                                   "max_iter" => 700]),
           PortOptSolver(; name = :Clarabel2, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = ["verbose" => true, "max_step_fraction" => 0.6,
                                   "max_iter" => 11000])]

alloc_solvers = PortOptSolver(; name = :HiGHS, solver = HiGHS.Optimizer,
                              check_sol = (; allow_local = true, allow_almost = true),
                              params = "log_to_console" => false)

dopt = DownloadOpt(; dtopt = DateOpt(; date0 = "2014-01-01"))
gmktopts = [GenMarketOpt(; market = Pair("Wilshire_5000_B10_W10", "Wilshire_5000"),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2024-07-21")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP(),
                                                                            similarity = DBHTExp())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          best = 0.1, worst = 0.1))]

popts = [PortOpt(; market = "Wilshire_5000_B10_W10_all", name = "GerberSB2",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2024-07-21")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2024-07-21"),
                                investment = 1047.0, conversion = 1.0,
                                fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSB1()),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 best = 0.25, worst = 0.25),
                                oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                cor_type = PortCovCor(; ce = CovSemi(),
                                                                      detone = Detone(;
                                                                                      mkt_comp = 1)),
                                                dist_type = DistDistCanonical(),
                                                clust_alg = DBHT(; distance = DistDistMLP(),
                                                                 similarity = DBHTExp()),
                                                clust_opt = ClustOpt(;
                                                                     k_type = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = -0.2, long_ub = 1.0,
                                                short_lb = -0.2)))]

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = false,
     optimise = true, process = true, markets = "Wilshire_5000", mopt = MarketOpt(),
     dopt = dopt, gmktopts = gmktopts, popts = popts)
