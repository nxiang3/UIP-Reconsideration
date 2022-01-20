************************************************
*    Regress exchange rate change to           *
*            inflation shock                   *
*            By: Nan Xiang                     *
************************************************

use "$data/data_updated_201009",clear

drop if country2 == "AUD" || country2 == "NZD"
levelsof country2, local(countries)

xtset cty2 t
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
gen q = s_fama - (cpi_usa - cpi)
gen pi = cpi - l12.cpi
gen pi_usa = cpi_usa - l12.cpi_usa
gen pi_r = pi_usa - pi
gen pi_r_shock = d.pi_r
//gen i_shock = d.i_diff
rename s_change_lag s_shock
keep if year < 2007 & year >=1987
//g rho = s_change -i_diff

foreach country in `countries'{
	preserve
	keep if country2 == "`country'"
	//drop if i_shock ==.
	drop if s_shock ==.
	drop if pi_r_shock ==.
	tsset t
	
	qui: reg s_shock pi_r_shock,r
	gen coef0 = _b[pi_r_shock]
	gen low0 = _b[pi_r_shock] - 1.96*_se[pi_r_shock]
	gen high0 = _b[pi_r_shock] + 1.96*_se[pi_r_shock]

	forval i = 1(1)30{
		gen s_change_`i' = f`i'.s_fama - s_fama
		qui: reg s_change_`i' pi_r_shock, r
		gen coef`i' = _b[pi_r_shock]
		g low`i' = _b[pi_r_shock] - 1.96*_se[pi_r_shock]
		g high`i' = _b[pi_r_shock] + 1.96*_se[pi_r_shock]
	}

	keep coef* low* high* country2
	duplicates drop

	reshape long coef low high, i(country2) j(time)

	twoway line coef time, color(black) || line low time, lpattern(longdash) color(black) || line high time, lpattern(longdash) color(black) title("Slope of ex post ER regressions", color(black) size(small)) ///
	note("Pre 2007", color(black) size(vsmall)) ///
	ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
	xtitle("Months", size(small)) ytitle("Coefficient", size(small)) yline(0, lpattern() lcolor()) legend(off)
	graph export $figures/expostER_`country'_pre07.png, as(png) name("Graph") replace
	restore
}

use "$data/data_updated_201009",clear

drop if country2 == "AUD" || country2 == "NZD"
levelsof country2, local(countries)

xtset cty2 t
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
gen q = s_fama - (cpi_usa - cpi)
gen pi = cpi - l12.cpi
gen pi_usa = cpi_usa - l12.cpi_usa
gen pi_r = pi_usa - pi
gen pi_r_shock = d.pi_r
//gen i_shock = d.i_diff
rename s_change_lag s_shock
keep if year >= 2007
//g rho = s_change -i_diff

foreach country in `countries'{
	preserve
	keep if country2 == "`country'"
	//drop if i_shock ==.
	drop if s_shock ==.
	drop if pi_r_shock ==.
	tsset t
	
	qui: reg s_shock pi_r_shock,r
	gen coef0 = _b[pi_r_shock]
	gen low0 = _b[pi_r_shock] - 1.96*_se[pi_r_shock]
	gen high0 = _b[pi_r_shock] + 1.96*_se[pi_r_shock]

	forval i = 1(1)30{
		gen s_change_`i' = f`i'.s_fama - s_fama
		qui: reg s_change_`i' pi_r_shock, r
		gen coef`i' = _b[pi_r_shock]
		g low`i' = _b[pi_r_shock] - 1.96*_se[pi_r_shock]
		g high`i' = _b[pi_r_shock] + 1.96*_se[pi_r_shock]
	}

	keep coef* low* high* country2
	duplicates drop

	reshape long coef low high, i(country2) j(time)

	twoway line coef time, color(black) || line low time, lpattern(longdash) color(black) || line high time, lpattern(longdash) color(black) title("Slope of ex post ER regressions", color(black) size(small)) ///
	note("Post 2007", color(black) size(vsmall)) ///
	ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
	xtitle("Months", size(small)) ytitle("Coefficient", size(small)) yline(0, lpattern() lcolor()) legend(off)
	graph export $figures/expostER_`country'_post07.png, as(png) name("Graph") replace
	restore
}


