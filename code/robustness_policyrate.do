*********************************************
*  how interest rates react to y.o.y. inflation 
*  in the pre-ZLB period
*********************************************

use "$data/data_updated_201009",clear

keep if country2 == "CAD"
replace country2 = "USD" if country2 == "CAD"
replace s = 1
replace logs = log(s)
replace s_fama = 0
replace s_change_lag = 0
replace s_change = 0
replace libor_1mannualized = libor_1mannualized_dollar
replace libor = libor_dollar
replace i_diff = 0
replace cpi = cpi_usa
replace cty2 = 12

save "$data/data_us_210625", replace

foreach x of global version{
	
	use "$data/data_updated_201009",clear
	append using "$data/data_us_210625"
	sort year month country2
    merge 1:1 year month country2 using "$data/policyrate"
	drop if _merge == 2
	drop _merge

	* construct y-o-y inflation for each country
	xtset cty2 t
	gen cpi_lag = l12.cpi
	gen inflation = (log(cpi) - log(cpi_lag))/12
	gen inflation_lag = l.inflation
	gen inflation_change = inflation - l.inflation
	* relative inflation
	gen p_r = (log(cpi_usa) - log(cpi))/12
	gen pr_lag = l12.p_r
	gen p_r_diff = p_r - pr_lag
	gen p_diff_lag = l.p_r_diff
	drop if p_r_diff==.
	* last period policy rate
	replace rate1 = rate1/1200
	replace rate2 = rate2/1200
	gen r_diff = rate1 - rate2
	gen r_diff_lag = l.r_diff
	gen rate_lag = l.rate2
	gen rate_change = rate2 - rate_lag
	* change in relative policy rates
	gen r_diff_change = r_diff - r_diff_lag
	* change in relative inflation
	gen p_r_diff_change = p_r_diff - p_diff_lag
	
	keep if year >= 1990
	
	//keep if inlist(country2, "CAD", "CHF", "DEM", "FRF", "GBP", "ITL", "JPY", "NOK", "SEK", "USD")
	drop if country2 == "AUD" || country2 == "NZD"
	drop cty2 
	egen cty2 = group(country2)
	
	if "`x'" == "r1"{
			qui: keep if year <= 2008
			di "Pre-GFC"
			capture erase $tables/inflation_level_1.xls
			capture erase $tables/inflation_change_1.xls
			capture erase $tables/rinflation_level_1.xls
			capture erase $tables/rinflation_change_1.xls
			reg rate2 inflation rate_lag if cty2 == 1, r
			outreg2 using $tables/inflation_level_1.xls, replace dec(3) stats(coef se)
			reg rate_change inflation_change rate_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_1.xls, replace dec(3) stats(coef se)
			reg r_diff p_r_diff r_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_1.xls, replace dec(3) stats(coef se)
			reg r_diff_change p_r_diff_change r_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_1.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg rate2 inflation rate_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_1.xls, append dec(3) stats(coef se)
				reg rate_change inflation_change rate_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_1.xls, append dec(3) stats(coef se)
				reg r_diff p_r_diff r_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_1.xls, append dec(3) stats(coef se)
			    reg r_diff_change p_r_diff_change r_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_1.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
		}
		if "`x'" == "r2"{
			qui: keep if year >= 2009
			di "Post-GFC"
			capture erase $tables/inflation_level_2.xls
			capture erase $tables/inflation_change_2.xls
			capture erase $tables/rinflation_level_2.xls
			capture erase $tables/rinflation_change_2.xls
			reg rate2 inflation rate_lag if cty2 == 1,r
			outreg2 using $tables/inflation_level_2.xls, replace dec(3) stats(coef se)
			reg rate_change inflation_change rate_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_2.xls, replace dec(3) stats(coef se)
			reg r_diff p_r_diff r_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_2.xls, replace dec(3) stats(coef se)
			reg r_diff_change p_r_diff_change r_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_2.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg rate2 inflation rate_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_2.xls, append dec(3) stats(coef se)
				reg rate_change inflation_change rate_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_2.xls, append dec(3) stats(coef se)
				reg r_diff p_r_diff r_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_2.xls, append dec(3) stats(coef se)
			    reg r_diff_change p_r_diff_change r_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_2.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
		}
	
}
