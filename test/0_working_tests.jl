using DCGCapital, Dates, YFinance, TimeSeries, DataFrames, CSV
tickers = ["AAL", "AAPL", "AMC", "BB", "BBY", "DELL", "DG", "DRS", "GME", "INTC", "LULU",
           "MARA", "MCI", "MSFT", "NKLA", "NVAX", "NVDA", "PARA", "PLNT", "SAVE", "SBUX",
           "SIRI", "STX", "TLRY", "TSLA"]

df, dfi = main(tickers, ["2023-04-28"], ["2023-06-27"])
unique(df)