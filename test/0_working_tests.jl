using Dates, DCGCapital, Clarabel, CovarianceEstimation, HiGHS, OrderedCollections,
      PortfolioOptimiser

solvers = [PortOptSolver(; name = :Clarabel1, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false)),
           PortOptSolver(; name = :Clarabel2, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.95,
                                       "max_iter" => 300)),
           PortOptSolver(; name = :Clarabel3, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.9,
                                       "max_iter" => 425, "equilibrate_max_iter" => 12)),
           PortOptSolver(; name = :Clarabel4, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.85,
                                       "max_iter" => 425, "equilibrate_max_iter" => 15)),
           PortOptSolver(; name = :Clarabel5, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.8,
                                       "max_iter" => 575, "equilibrate_max_iter" => 19)),
           PortOptSolver(; name = :Clarabel6, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.75,
                                       "max_iter" => 750, "equilibrate_max_iter" => 24)),
           PortOptSolver(; name = :Clarabel7, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.7,
                                       "max_iter" => 950, "equilibrate_max_iter" => 30)),
           PortOptSolver(; name = :Clarabel7, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.65,
                                       "max_iter" => 1175, "equilibrate_max_iter" => 37)),
           PortOptSolver(; name = :Clarabel7, solver = Clarabel.Optimizer,
                         check_sol = (; allow_local = true, allow_almost = true),
                         params = Dict("verbose" => false, "max_step_fraction" => 0.6,
                                       "max_iter" => 1425, "equilibrate_max_iter" => 45))]

alloc_solvers = PortOptSolver(; name = :HiGHS, solver = HiGHS.Optimizer,
                              check_sol = (; allow_local = true, allow_almost = true),
                              params = Dict("log_to_console" => false,
                                            "time_limit" => 180.0))

dopt = DownloadOpt(; dtopt = DateOpt(; date0 = "2014-01-01"))
gmktopts = [GenMarketOpt(; market = Pair("Wilshire_5000_B25", "Wilshire_5000"),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(;
                         market = Pair("NASDAQ_NSY_AMEX_123_B25",
                                       ["NASDAQ_1", "NASDAQ_2", "NASDAQ_3", "NSY_1",
                                        "NSY_2", "NSY_3", "AMEX_2", "AMEX_3"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(;
                         market = Pair("NASDAQ_NSY_AMEX_12_B25",
                                       ["NASDAQ_1", "NASDAQ_2", "NSY_1", "NSY_2", "AMEX_2"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(; market = Pair("NASDAQ_NSY_1_B50", ["NASDAQ_1", "NSY_1"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          worst = 0, best = 0.5)),
            GenMarketOpt(; market = Pair("S&P_500_Stocks_List_B50", "S&P_500_Stocks_List"),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                         fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                          worst = 0, best = 0.5))]

popts = [PortOpt(; market = "Wilshire_5000_B25_all", name = "Wilshire_5000_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2021-02-07"),
                                 investment = 5930.1, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-02-07"),
                                 investment = 2969.11, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2024-02-07"),
                                 investment = 1488.61, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_AMEX_123_B25_all", name = "NASDAQ_NSY_AMEX_123_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2021-02-07"),
                                 investment = 5930.1, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-02-07"),
                                 investment = 2969.11, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2024-02-07"),
                                 investment = 1488.61, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_AMEX_12_B25_all", name = "NASDAQ_NSY_AMEX_12_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2021-02-07"),
                                 investment = 5930.1, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-02-07"),
                                 investment = 2969.11, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2024-02-07"),
                                 investment = 1488.61, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_AMEX_1_B50_all", name = "NASDAQ_NSY_AMEX_1_B5",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2021-02-07"),
                                 investment = 5930.1, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-02-07"),
                                 investment = 2969.11, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2024-02-07"),
                                 investment = 1488.61, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "S&P_500_Stocks_List_B50_all", name = "S&P_500_Stocks_List",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2021-02-07")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2021-02-07"),
                                 investment = 5930.1, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-02-07"),
                                 investment = 2969.11, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2024-02-07"),
                                 investment = 1488.61, conversion = 1.0,
                                 fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = StdSilhouette()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(;
                                                                      k_type = StdSilhouette()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))])]

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = false,
     optimise = true, process = true,
     markets = ["NASDAQ_1", "NASDAQ_2", "NASDAQ_3", "NASDAQ_4", "NASDAQ_5", "NASDAQ_6",
                "NSY_1", "NSY_2", "NSY_3", "NSY_4", "NSY_5", "NSY_6", "AMEX_2", "AMEX_3",
                "AMEX_4", "AMEX_5", "AMEX_6"], mopt = MarketOpt(), dopt = dopt,
     gmktopts = gmktopts, popts = popts)
