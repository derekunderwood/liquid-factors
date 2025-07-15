# Liquid Factor Models

Based on work from Rosenthal, [Liquid Factor Models](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4825468), this repo compiles a set of macroeconomic factor time series using publicly accessible data from Yahoo Finance and the Federal Reserve Economic Data (FRED) database.

## Factor Definitions

| Factor       | Description                                       |
|--------------|---------------------------------------------------|
| `SP500.xs`   | Excess return of S&P 500 over 3M Treasury yield   |
| `R2KSPX`     | Size factor: Russell 2000 minus S&P 500 returns   |
| `R1KVMG`     | Value factor: Russell 1000 Value minus Growth     |
| `Momentum`   | 12-month momentum of SPY                          |
| `YCLevel`    | Change in average yield across 3M-30Y Treasuries  |
| `YCSlope`    | Change in average slope (30Y - 3M and 10Y - 2Y)   |
| `YCBump`     | Change in curvature: (30Y - 5Y) minus (5Y - 3M)   |
| `IG10`       | Investment-grade credit excess return over 10Y    |
| `HY5IG10`    | High-yield minus investment-grade credit spread   |
| `InflSurp5Y` | Change in 5Y break even inflation (STIP - GS5)    |
| `VIX`        | Monthly change in VIX index                       |

## Output

The output is a `data.frame` named `factor_vars` containing all constructed factors, aligned monthly from January 2011 to April 2025.

## Data Sources

via `quantmod`: 
- **Yahoo Finance**: Equity and ETF prices, VIX 
- **FRED**: Treasury yields and macroeconomic indicators

## Dependencies

-   `quantmod`
-   `xts`

## References

Rosenthal, Dale W. R., [Liquid Factor Models](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4825468) (May 9, 2024)
