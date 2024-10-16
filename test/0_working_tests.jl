using DCGCapital, Clarabel, HiGHS
tickers = ["AAL", "AAPL", "AMC", "BB", "BBY", "DELL", "DG", "DRS", "GME", "INTC", "LULU",
           "MARA", "MCI", "MSFT", "NKLA", "NVAX", "NVDA", "PARA", "PLNT", "SAVE", "SBUX",
           "SIRI", "STX", "TLRY", "TSLA"]

solvers = Dict(:Clarabel => Dict(:solver => Clarabel.Optimizer,
                                 :check_sol => (allow_local = true, allow_almost = true),
                                 :params => Dict("verbose" => false,
                                                 "max_step_fraction" => 0.75)))

alloc_solvers = Dict(:HiGHS => Dict(:solver => HiGHS.Optimizer,
                                    :check_sol => (allow_local = true, allow_almost = true),
                                    :params => Dict("log_to_console" => false)))

portfolio_vec = main(tickers, solvers, alloc_solvers,
                     DownloadOpt(; date0 = "2023-04-25", date1 = "2023-06-30"),
                     LoadOpt(; date0 = "2023-04-29", date1 = "2023-06-23"),
                     GenOpt(; date0 = "2023-04-29", date1 = "2023-06-23"))
