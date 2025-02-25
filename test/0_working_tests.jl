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
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                         fopt = FilterOpt(; rms = [SSD(), SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = TwoDiff()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(;
                         market = Pair("NASDAQ_NSY_AMEX_123_B25",
                                       ["NASDAQ_1", "NASDAQ_2", "NASDAQ_3", "NSY_1",
                                        "NSY_2", "NSY_3", "AMEX_2", "AMEX_3"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                         fopt = FilterOpt(; rms = [SSD(), SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = TwoDiff()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(;
                         market = Pair("NASDAQ_NSY_AMEX_12_B25",
                                       ["NASDAQ_1", "NASDAQ_2", "NSY_1", "NSY_2", "AMEX_2"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                         fopt = FilterOpt(; rms = [SSD(), SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = TwoDiff()),
                                          worst = 0, best = 0.25)),
            GenMarketOpt(; market = Pair("NASDAQ_NSY_1_B50", ["NASDAQ_1", "NSY_1"]),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                         fopt = FilterOpt(; rms = [SSD(), SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = TwoDiff()),
                                          worst = 0, best = 0.5)),
            GenMarketOpt(; market = Pair("S&P_500_Stocks_List_B50", "S&P_500_Stocks_List"),
                         lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                         fopt = FilterOpt(; rms = [SSD(), SVariance(), CVaR(), CDaR_r()],
                                          cor_type = PortCovCor(; ce = CovSemi(),
                                                                denoise = DenoiseSpectral(),
                                                                detone = Detone(;
                                                                                mkt_comp = 1),
                                                                logo = LoGo(;
                                                                            distance = DistDistMLP())),
                                          dist_type = DistDistCanonical(),
                                          clust_alg = HAC(),
                                          clust_opt = ClustOpt(; k_type = TwoDiff()),
                                          worst = 0, best = 0.5))]

popts = [PortOpt(; market = "Wilshire_5000_B25_all", name = "Wilshire_5000_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2020-08-14"),
                                 investment = 7650.39, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2022-08-16"),
                                 investment = 4250.21, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-08-16"),
                                 investment = 2550.13, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_AMEX_123_B25_all", name = "NASDAQ_NSY_AMEX_123_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2020-08-14"),
                                 investment = 7650.39, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2022-08-16"),
                                 investment = 4250.21, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-08-16"),
                                 investment = 2550.13, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.25),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_AMEX_12_B25_all", name = "NASDAQ_NSY_AMEX_12_B25",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2020-08-14"),
                                 investment = 7650.39, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2022-08-16"),
                                 investment = 4250.21, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-08-16"),
                                 investment = 2550.13, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "NASDAQ_NSY_1_B50_all", name = "NASDAQ_NSY_1_B50",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2020-08-14"),
                                 investment = 7650.39, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2022-08-16"),
                                 investment = 4250.21, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-08-16"),
                                 investment = 2550.13, conversion = 1.0,
                                 fopt = FilterOpt(; worst = 0, best = 0),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))]),
         PortOpt(; market = "S&P_500_Stocks_List_B50_all", name = "S&P_500_Stocks_List",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2020-08-14")),
                 gopts = [GenOpt(; dtopt = DateOpt(; date0 = "2020-08-14"),
                                 investment = 7650.39, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2022-08-16"),
                                 investment = 4250.21, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2)),
                          GenOpt(; dtopt = DateOpt(; date0 = "2023-08-16"),
                                 investment = 2550.13, conversion = 1.0,
                                 fopt = FilterOpt(;
                                                  rms = [SSD(), SVariance(), CVaR(),
                                                         CDaR_r()],
                                                  cor_type = PortCovCor(;
                                                                        ce = CovGerberSB1()),
                                                  dist_type = DistDistCanonical(),
                                                  clust_alg = DBHT(;
                                                                   distance = DistDistMLP()),
                                                  clust_opt = ClustOpt(;
                                                                       k_type = TwoDiff()),
                                                  worst = 0, best = 0.5),
                                 oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                 cor_type = PortCovCor(;
                                                                       ce = cor_type = PortCovCor(;
                                                                                                  ce = CovGerberSB1())),
                                                 dist_type = DistDistCanonical(),
                                                 clust_alg = DBHT(;
                                                                  distance = DistDistMLP()),
                                                 clust_opt = ClustOpt(; k_type = TwoDiff()),
                                                 short = false, budget = 1.0,
                                                 short_budget = -0.2, long_ub = 1.0,
                                                 short_lb = -0.2))])]
# Totora: 14_450.73

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = true,
     optimise = true, process = true,
     markets = ["NASDAQ_1", "NASDAQ_2", "NASDAQ_3", "NASDAQ_4", "NASDAQ_5", "NASDAQ_6",
                "NSY_1", "NSY_2", "NSY_3", "NSY_4", "NSY_5", "NSY_6", "AMEX_2", "AMEX_3",
                "AMEX_4", "AMEX_5", "AMEX_6"], mopt = MarketOpt(), dopt = dopt,
     gmktopts = gmktopts, popts = popts)

using DataFrames, CSV, Statistics
data = CSV.read("D:/Daniel Celis Garza/dev/DCGCapital/Data/Portfolios/totora.csv",
                DataFrame)
gdf = groupby(data, :tickers)
data = combine(gdf,
               [:shares, :price, :cost] => ((s, p, c) -> (shares = sum(s), price = mean(p), cost = sum(c))) => AsTable)
data.weights = data.cost / sum(data.cost)
sort!(data, :cost; rev = true)
data_f = filter(:weights => x -> x >= 0.03, data)
data_f.weights = data_f.cost / sum(data_f.cost)

data_f[:, :shares] .+= 4
data_f[:, :cost] += data_f[:, :price] * 4
data_f[3:5, :shares] .-= 1
data_f[3:5, :cost] -= data_f[3:5, :price]

CSV.write("D:/Daniel Celis Garza/dev/DCGCapital/Data/Portfolios/totora_comprar.csv", data_f)

data_f = data_f[data_f.tickers .!= "SFBC", :]
sum(data_f.cost)
data_f[5, :shares] -= 1
data_f[5, :cost] = data_f[5, :cost] - data_f[5, :price]

data_f[2, :shares] += 1
data_f[2, :cost] += data_f[2, :price]

data_f.weights .= data_f.cost / sum(data_f.cost)

# data[1:3, :shares] = data[1:3, :shares] * 2
# data[1:3, :cost] = data[1:3, :cost] * 2
# data[6, :shares] += 1
# data[6, :cost] += data[6, :price]
# data[4, :shares] += 1
# data[4, :cost] += data[4, :price]
# data[5, :shares] += 1
# data[5, :cost] += data[5, :price]
# data.weights = data.cost / sum(data.cost)
# sort!(data, :weights; rev = true)

CSV.write("D:/Daniel Celis Garza/dev/DCGCapital/Data/Portfolios/vic_comprar.csv", data_f)

# wilshire 5000
# 2020
# cdar h 1.375, cdar t 1.416, edar h 1.069, edar t 1.216, rldar h 0.875, rldar t 1.09
# 2022
# cdar h 1.878, cdar t 1.694, edar h 1.683, edar t 1.545, rldar h 1.595, rldar t 1.434
# 2023
# cdar h 4.536, cdar t 4.953, edar h 4.229, edar t 4.645, rldar h 3.632, rldar t 4.211

# NSY 123
# 2020
# cdar h 1.506, cdar t 1.448, edar h 1.321, edar t 1.268, rldar h 1.204, rldar t 1.2
# 2022
# cdar h 2.222, cdar t 2.17, edar h 1.843, edar t 1.998, rldar h 1.74, rldar t 2.029
# 2023
# cdar h 8.452, cdar t 7.767, edar h 4.637, edar t 6.787, rldar h 4.865, rldar t 6.414

# NSY 12
# 2020
# cdar h 1.352, cdar t 1.528, edar h 1.273, edar t 1.364, rldar h 1.24, rldar t 1.084
# 2022
# cdar h 2.68, cdar t 2.61, edar h 2.41, edar t 2.289, rldar h 2.215, rldar t 2.189
# 2023
# cdar h 7.69, cdar t 7.647, edar h 5.608, edar t 6.667, rldar h 5.347, rldar t 6.22

# NSY 1
# 2020
# cdar h 1.594, cdar t 1.532, edar h 1.434, edar t 1.279, rldar h 1.287, rldar t 1.23
# 2022
# cdar h 2.121, cdar t 2.312, edar h 1.888, edar t 2.109, rldar h 1.826, rldar t 1.748
# 2023
# cdar h 3.777, cdar t 4.752, edar h 3.477, edar t 4.583, rldar h 3.383, rldar t 4.465

# S&P 500
# 2020
# cdar h 1.38, cdar t 1.429, edar h 1.342, edar t 1.271, rldar h 0.937, rldar t 1.179
# 2022
# cdar h 2.269, cdar t 2.119, edar h 2.095, edar t 1.952, rldar h 1.898, rldar t 1.725
# 2023
# cdar h 5.191, cdar t 5.396, edar h 4.696, edar t 3.447, rldar h 4.771, rldar t 3.345

# 2020 rldar h wilshire
# 2022 rldar h s&p 500
# 2023 rldar h nsy 123