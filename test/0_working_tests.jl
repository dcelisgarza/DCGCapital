using Dates, DCGCapital, Clarabel, CovarianceEstimation, HiGHS, OrderedCollections,
      PortfolioOptimiser

solvers = OrderedDict(:Clarabel1 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => false)),
                      :Clarabel2 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => false,
                                                         "max_step_fraction" => 0.9)),
                      :Clarabel3 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => false,
                                                         "max_step_fraction" => 0.8,
                                                         "max_iter" => 400)),
                      :Clarabel4 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => false,
                                                         "max_step_fraction" => 0.7,
                                                         "max_iter" => 700)),
                      :Clarabel4 => Dict(:solver => Clarabel.Optimizer,
                                         :check_sol => (allow_local = true,
                                                        allow_almost = true),
                                         :params => Dict("verbose" => false,
                                                         "max_step_fraction" => 0.6,
                                                         "max_iter" => 1100)))

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

popts = [PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "SB1",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CorSB1()),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "SB1_norm",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CorSB1(;
                                                                                   normalise = true)),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "GSB1",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CorGerberSB1()),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "GSB1_norm",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CorGerberSB1(;
                                                                                         normalise = true)),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "G1",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CorGerber1()),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "G1_norm",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CorGerber1(;
                                                                                       normalise = true)),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_Denoise_detone",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSemi(),
                                                                       denoise = DenoiseSpectral(;
                                                                                                 detone = true)),
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
                                                                                                detone = true)),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_Denoise",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSemi(),
                                                                       denoise = DenoiseSpectral()),
                                                 dist_type = DistDistCanonical(),
                                                 hclust_alg = DBHT(;
                                                                   distance = DistDistMLP(),
                                                                   similarity = DBHTExp()),
                                                 hclust_opt = HCOpt(;
                                                                    k_method = StdSilhouette()),
                                                 best = 0.25, worst = 0.25),
                                oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                cor_type = PortCovCor(; ce = CovSemi(),
                                                                      denoise = DenoiseSpectral()),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_Denoise_detone_LoGo",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
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
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_Denoise_LoGo",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSemi(),
                                                                       denoise = DenoiseSpectral(),
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
                                                                      denoise = DenoiseSpectral(),
                                                                      logo = LoGo(;
                                                                                  distance = DistDistMLP(),
                                                                                  similarity = DBHTExp())),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_LoGo",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSemi(),
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
                                                                      logo = LoGo(;
                                                                                  distance = DistDistMLP(),
                                                                                  similarity = DBHTExp())),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(; ce = CovSemi()),
                                                 dist_type = DistDistCanonical(),
                                                 hclust_alg = DBHT(;
                                                                   distance = DistDistMLP(),
                                                                   similarity = DBHTExp()),
                                                 hclust_opt = HCOpt(;
                                                                    k_method = StdSilhouette()),
                                                 best = 0.25, worst = 0.25),
                                oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                cor_type = PortCovCor(; ce = CovSemi()),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_LUV",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CovSemi(;
                                                                                    ce = LinearShrinkage(DiagonalUnequalVariance(),
                                                                                                         :ss))),
                                                 dist_type = DistDistCanonical(),
                                                 hclust_alg = DBHT(;
                                                                   distance = DistDistMLP(),
                                                                   similarity = DBHTExp()),
                                                 hclust_opt = HCOpt(;
                                                                    k_method = StdSilhouette()),
                                                 best = 0.25, worst = 0.25),
                                oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                cor_type = PortCovCor(;
                                                                      ce = CovSemi(;
                                                                                   ce = LinearShrinkage(DiagonalUnequalVariance(),
                                                                                                        :ss))),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2))),
         PortOpt(; market = "Wilshire_5000_B25_W25_all", name = "Semi_ANL",
                 lopt = LoadOpt(; dtopt = DateOpt(; date0 = "2022-10-20")),
                 gopts = GenOpt(; dtopt = DateOpt(; date0 = "2022-10-20"),
                                investment = 40000, conversion = 1.3,
                                fopt = FilterOpt(; rms = [SSD(), CVaR(), CDaR_r()],
                                                 cor_type = PortCovCor(;
                                                                       ce = CovSemi(;
                                                                                    ce = AnalyticalNonlinearShrinkage())),
                                                 dist_type = DistDistCanonical(),
                                                 hclust_alg = DBHT(;
                                                                   distance = DistDistMLP(),
                                                                   similarity = DBHTExp()),
                                                 hclust_opt = HCOpt(;
                                                                    k_method = StdSilhouette()),
                                                 best = 0.25, worst = 0.25),
                                oopt = OptimOpt(; rms = [CDaR(), EDaR(), RLDaR()],
                                                cor_type = PortCovCor(;
                                                                      ce = CovSemi(;
                                                                                   ce = AnalyticalNonlinearShrinkage())),
                                                dist_type = DistDistCanonical(),
                                                hclust_alg = DBHT(;
                                                                  distance = DistDistMLP(),
                                                                  similarity = DBHTExp()),
                                                hclust_opt = HCOpt(;
                                                                   k_method = StdSilhouette()),
                                                short = true, budget = 1.0,
                                                short_budget = 0.2, long_u = 1.0,
                                                short_u = 0.2)))]

main(; solvers = solvers, alloc_solvers = alloc_solvers, download = false, generate = false,
     optimise = false, process = true, markets = "Wilshire_5000", mopt = MarketOpt(),
     dopt = dopt, gmktopts = gmktopts, popts = popts)

# Semi denoise detone logo
# Semi denoise logo
# Semi denoise detone
# CorGerberSB1(normalise=true)
# CorGerberSB1()
# Semi logo
# Semi denoise

ports = load("D:\\Daniel Celis Garza\\dev\\DCGCapital\\Data\\Portfolios\\Wilshire_5000_B25_W25_all\\2022-10-20_2024-10-23.jld2",
             "portfolios")

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
