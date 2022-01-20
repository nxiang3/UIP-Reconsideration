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
// 	sort year month country2
//     merge 1:1 year month country2 using "$data/policyrate"
// 	drop if _merge == 2
// 	drop _merge
	
// 	sort cty2 year month
// 	merge 1:1 cty2 year month using "/Users/nxiang/Downloads/Libor.dta"

	* construct y-o-y inflation for each country
	xtset cty2 t
	gen cpi_lag = l12.cpi
	gen inflation = (log(cpi) - log(cpi_lag))/12
	//gen inflation = log(cpi) - log(cpi_lag)
	gen inflation_lag = l.inflation
	gen inflation_change = inflation - l.inflation
	* relative inflation
	gen p_r = (log(cpi_usa) - log(cpi))/12
	gen pr_lag = l12.p_r
	gen p_r_diff = p_r - pr_lag
	gen p_diff_lag = l.p_r_diff
	drop if p_r_diff==.
	* last period interest rates
	gen i_diff_lag = l.i_diff
	gen libor_lag = l.libor
	gen libor_change = libor - libor_lag
	* change in relative interest rates
	gen i_diff_change = i_diff - i_diff_lag
	* change in relative inflation
	gen p_r_diff_change = p_r_diff - p_diff_lag
	
	//keep if year >= 2001
	//drop if year == 2001 & month <11
	
	//keep if inlist(country2, "CAD", "CHF", "DEM", "FRF", "GBP", "ITL", "JPY", "NOK", "SEK", "USD")
	drop if country2 == "AUD" || country2 == "NZD"
	drop cty2 
	egen cty2 = group(country2)
	
	if "`x'" == "r1"{
			preserve
			qui: keep if year >= 1987
			qui: drop if year > 2001
			qui: drop if year == 2001 & month == 12
			di "Pre-GFC"
			capture erase $tables/inflation_level_1.xls
			capture erase $tables/inflation_change_1.xls
			capture erase $tables/rinflation_level_1.xls
			capture erase $tables/rinflation_change_1.xls
			reg libor inflation libor_lag if cty2 == 1, r
			outreg2 using $tables/inflation_level_1.xls, replace dec(3) stats(coef se)
			reg libor_change inflation_change libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_1.xls, replace dec(3) stats(coef se)
			reg i_diff p_r_diff i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_1.xls, replace dec(3) stats(coef se)
			reg i_diff_change p_r_diff_change i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_1.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg libor inflation libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_1.xls, append dec(3) stats(coef se)
				reg libor_change inflation_change libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_1.xls, append dec(3) stats(coef se)
				reg i_diff p_r_diff i_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_1.xls, append dec(3) stats(coef se)
			    reg i_diff_change p_r_diff_change i_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_1.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
			restore
		}
		if "`x'" == "r2"{
			preserve
			qui: keep if year >= 1991 & year <= 2001
			qui: drop if year == 1991 & month <4
			qui: drop if year == 2001 & month == 12
			di "Pre-GFC"
			capture erase $tables/inflation_level_2.xls
			capture erase $tables/inflation_change_2.xls
			capture erase $tables/rinflation_level_2.xls
			capture erase $tables/rinflation_change_2.xls
			reg libor inflation libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_level_2.xls, replace dec(3) stats(coef se)
			reg libor_change inflation_change libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_2.xls, replace dec(3) stats(coef se)
			reg i_diff p_r_diff i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_2.xls, replace dec(3) stats(coef se)
			reg i_diff_change p_r_diff_change i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_2.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg libor inflation libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_2.xls, append dec(3) stats(coef se)
				reg libor_change inflation_change libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_2.xls, append dec(3) stats(coef se)
				reg i_diff p_r_diff i_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_2.xls, append dec(3) stats(coef se)
			    reg i_diff_change p_r_diff_change i_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_2.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
		restore
		}

				if "`x'" == "r3"{
			preserve
			qui: keep if year >= 2001 & year <= 2009
			qui: drop if year == 2009 & month >6
			qui: drop if year == 2001 & month < 12
			di "Pre-GFC"
			capture erase $tables/inflation_level_3.xls
			capture erase $tables/inflation_change_3.xls
			capture erase $tables/rinflation_level_3.xls
			capture erase $tables/rinflation_change_3.xls
			reg libor inflation libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_level_3.xls, replace dec(3) stats(coef se)
			reg libor_change inflation_change libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_3.xls, replace dec(3) stats(coef se)
			reg i_diff p_r_diff i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_3.xls, replace dec(3) stats(coef se)
			reg i_diff_change p_r_diff_change i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_3.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg libor inflation libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_3.xls, append dec(3) stats(coef se)
				reg libor_change inflation_change libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_3.xls, append dec(3) stats(coef se)
				reg i_diff p_r_diff i_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_3.xls, append dec(3) stats(coef se)
			    reg i_diff_change p_r_diff_change i_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_3.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
		restore
		}
				if "`x'" == "r4"{
			preserve
			qui: keep if year >= 2009
			qui: drop if year == 2009 & month <7
			di "Pre-GFC"
			capture erase $tables/inflation_level_4.xls
			capture erase $tables/inflation_change_4.xls
			capture erase $tables/rinflation_level_4.xls
			capture erase $tables/rinflation_change_4.xls
			reg libor inflation libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_level_4.xls, replace dec(3) stats(coef se)
			reg libor_change inflation_change libor_lag if cty2 == 1,r
			outreg2 using $tables/inflation_change_4.xls, replace dec(3) stats(coef se)
			reg i_diff p_r_diff i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_level_4.xls, replace dec(3) stats(coef se)
			reg i_diff_change p_r_diff_change i_diff_lag if cty2 == 1,r
			outreg2 using $tables/rinflation_change_4.xls, replace dec(3) stats(coef se)
			forval i = 2(1)10{
				reg libor inflation libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_level_4.xls, append dec(3) stats(coef se)
				reg libor_change inflation_change libor_lag if cty2 == `i',r
				outreg2 using $tables/inflation_change_4.xls, append dec(3) stats(coef se)
				reg i_diff p_r_diff i_diff_lag if cty2 == `i',r
			    outreg2 using $tables/rinflation_level_4.xls, append dec(3) stats(coef se)
			    reg i_diff_change p_r_diff_change i_diff_lag if cty2 == `i',r
				outreg2 using $tables/rinflation_change_4.xls, append dec(3) stats(coef se)
				//reg i_diff p_r_diff i_diff_lag if cty2 == `i', r
				//reg libor_change inflation_change libor_lag if cty2 == `i',r
			}
		restore
		}
}
