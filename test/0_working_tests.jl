using Dates, DCGCapital, Clarabel, CovarianceEstimation, HiGHS, OrderedCollections,
      PortfolioOptimiser

solvers = OrderedDict(:Clarabel1 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => true)),
                      :Clarabel2 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => true,
                                                         "max_step_fraction" => 0.9)),
                      :Clarabel3 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => true,
                                                         "max_step_fraction" => 0.8,
                                                         "max_iter" => 400)),
                      :Clarabel4 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => true,
                                                         "max_step_fraction" => 0.7,
                                                         "max_iter" => 700)),
                      :Clarabel4 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => true,
                                                         "max_step_fraction" => 0.6,
                                                         "max_iter" => 1100)))

alloc_solvers = Dict(:HiGHS => Dict(:solver => HiGHS.Optimizer,
                                    :check_sol => (allow_local = true, allow_almost = true),
                                    :params => Dict("log_to_console" => false)))

dopt = DownloadOpt(; dtopt = DateOpt(; date0 = "2014-01-01"))
gmktopts = GenMarketOpt(; market = Pair("Wilshire_5000_B25_W25", "Wilshire_5000"),
                        lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                        fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                         cor_type = PortCovCor(; ce = CovSemi(),
                                                               denoise = DenoiseSpectral(),
                                                               detone = Detone(;
                                                                               mkt_comp = 1),
                                                               logo = LoGo(;
                                                                           distance = DistDistMLP(),
                                                                           similarity = DBHTExp())),
                                         dist_type = DistDistCanonical(), clust_alg = HAC(),
                                         clust_opt = ClustOpt(; k_type = StdSilhouette()),
                                         best = 0.25, worst = 0.25))

popts = [PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "GerberSB2",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SVariance(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CovGerberSB2()),
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
