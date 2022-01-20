*********************************************
*  how interest rates react to y.o.y. inflation 
*  in the pre-ZLB period: Panel Analysis
*********************************************


use "$data/data_updated_201009",clear
append using "$data/data_us_210625"

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
//drop if p_r_diff==.
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
xtset cty2 t

//gen dummy = year >= 2002 & year <= 2008
//replace dummy = 1 if year == 2001 & month == 12
//replace dummy = 1 if year == 2009 & month <= 6

gen dummy = year >= 2010
replace dummy = 1 if year == 2009 & month >=7

gen inflation_dummy = inflation * dummy
gen libor_lag_dummy = libor_lag * dummy

gen inflation_change_d = inflation_change * dummy

gen p_r_diff_d = p_r_diff * dummy
gen i_diff_lag_d =i_diff_lag * dummy

gen p_r_diff_change_d = p_r_diff_change * dummy

capture erase $tables/panel_dummy.xls

xtscc libor inflation inflation_dummy libor_lag libor_lag_dummy dummy i.t,fe
outreg2 using $tables/panel_dummy.xls, replace dec(3) stats(coef se) keep(inflation inflation_dummy libor_lag libor_lag_dummy dummy)

xtscc libor_change inflation_change inflation_change_d libor_lag libor_lag_dummy dummy i.t, fe
outreg2 using $tables/panel_dummy.xls, append dec(3) stats(coef se) keep(inflation_change inflation_change_d libor_lag libor_lag_dummy dummy)

preserve 
drop if country2 == "USD"
xtscc i_diff p_r_diff p_r_diff_d i_diff_lag i_diff_lag_d dummy i.t, fe
outreg2 using $tables/panel_dummy.xls, append dec(3) stats(coef se) keep(p_r_diff p_r_diff_d i_diff_lag i_diff_lag_d dummy)

xtscc i_diff_change p_r_diff_change p_r_diff_change_d i_diff_lag i_diff_lag_d dummy i.t,fe
outreg2 using $tables/panel_dummy.xls, append dec(3) stats(coef se) keep(p_r_diff_change p_r_diff_change_d i_diff_lag i_diff_lag_d dummy)
restore

	
foreach x of global version{
// 	sort year month country2
//     merge 1:1 year month country2 using "$data/policyrate"
// 	drop if _merge == 2
// 	drop _merge
	
// 	sort cty2 year month
// 	merge 1:1 cty2 year month using "/Users/nxiang/Downloads/Libor.dta"
	
	if "`x'" == "r1"{
			preserve
			qui: keep if year >= 1987
			qui: drop if year > 2001
			qui: drop if year == 2001 & month == 12
			drop if country2 == "ITL" | country2 == "NOK"
			di "Pre-GFC"
			capture erase $tables/inflation_level_panel.xls
			capture erase $tables/inflation_change_panel.xls
			capture erase $tables/rinflation_level_panel.xls
			capture erase $tables/rinflation_change_panel.xls
			xtscc libor inflation libor_lag i.t, fe
			outreg2 using $tables/inflation_level_panel.xls, replace dec(3) stats(coef se) keep(inflation libor_lag)
			xtscc libor_change inflation_change libor_lag i.t, fe
			outreg2 using $tables/inflation_change_panel.xls, replace dec(3) stats(coef se) keep(inflation_change libor_lag)
			drop if country2 == "USD"
			xtscc i_diff p_r_diff i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_level_panel.xls, replace dec(3) stats(coef se) keep(p_r_diff i_diff_lag)
			xtscc i_diff_change p_r_diff_change i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_change_panel.xls, replace dec(3) stats(coef se) keep(p_r_diff_change i_diff_lag)
			restore
		}
		if "`x'" == "r2"{
			preserve
			qui: keep if year >= 1991 & year <= 2001
			qui: drop if year == 1991 & month <4
			qui: drop if year == 2001 & month == 12
			di "Pre-GFC"
			xtscc libor inflation libor_lag i.t, fe
			outreg2 using $tables/inflation_level_panel.xls, append dec(3) stats(coef se) keep(inflation libor_lag)
			xtscc libor_change inflation_change libor_lag i.t, fe
			outreg2 using $tables/inflation_change_panel.xls, append dec(3) stats(coef se) keep(inflation_change libor_lag)
			drop if country2 == "USD"
			xtscc i_diff p_r_diff i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_level_panel.xls, append dec(3) stats(coef se) keep(p_r_diff i_diff_lag)
			xtscc i_diff_change p_r_diff_change i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_change_panel.xls, append dec(3) stats(coef se) keep(p_r_diff_change i_diff_lag)
			restore
		}

				if "`x'" == "r3"{
			preserve
			qui: keep if year >= 2001 & year <= 2009
			qui: drop if year == 2009 & month >6
			qui: drop if year == 2001 & month < 12
			di "Pre-GFC"
			xtscc libor inflation libor_lag i.t, fe
			outreg2 using $tables/inflation_level_panel.xls, append dec(3) stats(coef se) keep(inflation libor_lag)
			xtscc libor_change inflation_change libor_lag i.t, fe
			outreg2 using $tables/inflation_change_panel.xls, append dec(3) stats(coef se) keep(inflation_change libor_lag)
			drop if country2 == "USD"
			xtscc i_diff p_r_diff i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_level_panel.xls, append dec(3) stats(coef se) keep(p_r_diff i_diff_lag)
			xtscc i_diff_change p_r_diff_change i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_change_panel.xls, append dec(3) stats(coef se) keep(p_r_diff_change i_diff_lag)
			restore
		}
				if "`x'" == "r4"{
			preserve
			qui: keep if year >= 2009
			qui: drop if year == 2009 & month <7
			xtscc libor inflation libor_lag i.t, fe
			outreg2 using $tables/inflation_level_panel.xls, append dec(3) stats(coef se) keep(inflation libor_lag)
			xtscc libor_change inflation_change libor_lag i.t, fe
			outreg2 using $tables/inflation_change_panel.xls, append dec(3) stats(coef se) keep(inflation_change libor_lag)
			drop if country2 == "USD"
			xtscc i_diff p_r_diff i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_level_panel.xls, append dec(3) stats(coef se) keep(p_r_diff i_diff_lag)
			xtscc i_diff_change p_r_diff_change i_diff_lag i.t, fe
			outreg2 using $tables/rinflation_change_panel.xls, append dec(3) stats(coef se) keep(p_r_diff_change i_diff_lag)
			restore
		}
}
