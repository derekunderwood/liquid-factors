library(quantmod)

# ETF tickers for liquid factors
tickers <- c("SPY", "IWM", "IWD", "IWF", "LQD", "HYG", "STIP", "IEF", "IEI")
getSymbols(tickers, src = "yahoo", from = "2010-11-01", to = "2025-04-30", 
           auto.assign = T, periodicity = "daily")

getSymbols("^VIX", src = "yahoo", from = "2010-11-30", to = "2025-04-30", 
           auto.assign = T, periodicity = "daily")

# YC tickers
yc <- c("TB3MS", "GS2", "GS5", "GS10", "GS30")
getSymbols(yc, src = "FRED", from = "2010-11-30", to = "2025-04-30")
yields_monthly <- merge(TB3MS, GS2, GS5, GS10, GS30)
colnames(yields_monthly) <- c("3M", "2Y", "5Y", "10Y", "30Y")

# Large cap equity index (excess)
SPY_mth <- to.period(SPY, indexAt = "lastof")
TB3MS <- to.period(TB3MS, indexAt = "lastof")[,4]
SP500.xs <- diff(log(SPY_mth$SPY.Close)) - (TB3MS/100)/12

# Equity size factor
IWM_mth <- to.period(IWM, indexAt = "lastof")
r2kspx <- diff(log(IWM_mth$IWM.Close) - log(SPY_mth$SPY.Close))

# Equity value factor
IWD_mth <- to.period(IWD, indexAt = "lastof")
IWF_mth <- to.period(IWF, indexAt = "lastof")
value <- diff(log(IWD_mth$IWD.Close) - log(IWF_mth$IWF.Close))

# Momentum
mom <- getSymbols("SPY", src = "yahoo", from = "2010-01-01", to = "2025-04-30", 
                  auto.assign = F, periodicity = "daily")
mom_mth <- to.period(mom, indexAt = "lastof")
momentum <- diff(log(mom_mth$mom.Close),12)

# YC Level
avg_yield <- rowMeans(yields_monthly)
YCLevel <- diff(avg_yield)
YCLevel <- xts(YCLevel, order.by = index(yields_monthly)[-1])  # remove first NA
YCLevel <- to.period(YCLevel, indexAt = "lastof")[,4]

# YC Slope: percentage point change per year of maturity
long_slope <- (yields_monthly$`30Y` - yields_monthly$`3M`) / 18.95
mid_slope  <- (yields_monthly$`10Y` - yields_monthly$`2Y`) / 6.7
slope_avg <- (long_slope + mid_slope) / 2
YCSlope <- diff(slope_avg)
YCSlope <- to.period(YCSlope, indexAt = "lastof")[,4]

# YC Bump: tracks curvature changes in the YC
long_slope  <- (yields_monthly$`30Y` - yields_monthly$`5Y`) / 14.5
front_slope <- (yields_monthly$`5Y`  - yields_monthly$`3M`) / 4.5
slope_diff <- long_slope - front_slope
YCBump <- diff(slope_diff)
YCBump <- to.period(YCBump, indexAt = "lastof")[,4]

# zero-DV01 credit indices: index's value is not sensitive to changes in interest rates
LQD_mth <- to.period(LQD, indexAt = "lastof")
HYG_mth <- to.period(HYG, indexAt = "lastof")
IG10 <- diff(log(LQD_mth$LQD.Close)) - periodReturn(IEF, indexAt = "lastof")
HY5 <- diff(log(HYG_mth$HYG.Close)) - periodReturn(IEI, indexAt = "lastof")
HY5IG10 <- HY5 - IG10

# change in break even inflation
STIP_mth <- to.period(STIP, indexAt = "lastof")
GS5_clean <- to.period(GS5, indexAt = "lastof")[,4]
InflSurp5Y <- diff(STIP_mth$STIP.Close - GS5_clean)

# VIX
VIX <- to.period(VIX, indexAt = "lastof")
vix_delta <- diff(VIX$VIX.Close)/100

temp <- merge(SP500.xs, r2kspx, join = "inner")
temp <- merge(temp, value, join = "inner")
temp <- merge(temp, momentum, join = "inner")
temp <- merge(temp, YCLevel, join = "inner")
temp <- merge(temp, YCSlope, join = "inner")
temp <- merge(temp, YCBump, join = "inner")
temp <- merge(temp, IG10, join = "inner")
temp <- merge(temp, HY5IG10, join = "inner")
temp <- merge(temp, InflSurp5Y, join = "inner")
temp <- merge(temp, vix_delta, join = "inner")

colnames(temp) <- c("SP500.xs", "R2KSPX", "R1KVMG", "Momentum",
                    "YCLevel", "YCSlope", 
                    "YCBump", "IG10", "HY5IG10", "InflSurp5Y", "VIX")

factor_vars <- temp