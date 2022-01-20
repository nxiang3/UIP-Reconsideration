**************************************************

**************************************************
clear
import excel "E:\Econ872_Paper\analysis\input\data_update_20201009.xlsx", sheet("Sheet1") firstrow
//whole sample
bys cty2: reg s_change i_diff,r
//89 - 2017/11
preserve
drop if year > 2017
drop if year == 2017 & month == 12
bys cty2: reg s_change i_diff if year > 1988,r
restore
//pre-crisis
bys cty2: reg s_change i_diff if year < 2007,r
//1989-pre-crisis
bys cty2: reg s_change i_diff if year < 2007 & year > 1988,r
//crisis
* keep end date the same
preserve
drop if year > 2017
drop if year == 2017 & month == 12
bys cty2: reg s_change i_diff if year > 2006,r
restore

* 10-year Rolling Regression
cd E:/Econ872_Paper/analysis/output
tsset cty2 t
foreach cnty in AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(120) saving("`cnty'_10y",replace) keep(date,start): reg s_change    i_diff if country2 == "`cnty'",r
}

* 5-year Rolling Regression
cd E:/Econ872_Paper/analysis/output
foreach cnty in AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(60) saving("`cnty'_5y",replace) keep(date,start): reg s_change    i_diff if country2 == "`cnty'",r
}