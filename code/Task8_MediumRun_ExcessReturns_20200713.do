*****************************************************
*  Econ872 Task: Medium-Run Excess Returns          *
*              Equation  6, 7, 8                    *
*****************************************************
* by Nan Xiang
cd E:/Econ872_Paper/analysis
use input/data_updated_200617,clear

replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
gen s_year = f12.s_fama // exchange rate 12 month ahead t+12
gen s_yoy = s_year - s_fama // s_t+12 - s_t
//sum of interest differential into 11 periods ahead 
forval i = 1(1)11{
    gen i_diff_forward`i' = f`i'.i_diff
}
egen i_sum = rowtotal(i_diff_forward*)
//inflation
gen p_r = cpi_usa - cpi
gen p_r_lag12 = l12.p_r
gen p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)

forval i = 1(1)11{
    drop if i_diff_forward`i'==.
}
keep country2 cty2 date year month q s_yoy i_sum i_diff_forward* i_diff p_r_diff

//whole sample
drop if i_diff ==.
gen mr_ex_re = s_yoy - i_sum

bys cty2: reg mr_ex_re i_diff, r
//common ending date
preserve 
keep if year < 2018
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re i_diff, r
restore

//pre-crisis
preserve 
keep if year < 2007
keep if year > 1988
bys cty2: reg mr_ex_re i_diff, r
restore

//post-crisis
preserve 
keep if year < 2018
keep if year > 2006
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re i_diff, r
restore

* 10-year Rolling Regression
sort country2 year month
bys country2: gen t = _n
tsset cty2 t
foreach cnty in AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(120) saving(output/`cnty'_10y,replace) keep(date,start): reg mr_ex_re i_diff if country2 == "`cnty'",r
}

	use output/SEK_10y,clear 
	gen lower = _b_i_diff - 1.96 * _se_i_diff
	gen upper = _b_i_diff + 1.96 * _se_i_diff
	twoway rcap lower upper start, color(navy) || scatter _b_i_diff start, msize(medium) msymbol(X) ///
					title("Coefficient and 95% CI in Fama Regression (AUD)", color(black) size(small)) ///
					note("Monthly data from January 1989 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))

* 5-year Rolling Regression
foreach cnty in AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(60) saving("`cnty'_5y",replace) keep(date,start): reg mr_ex_re i_diff if country2 == "`cnty'",r
}

* Equation 7
//whole sample
bys cty2: reg mr_ex_re i_diff p_r_diff, r
//common ending date
preserve 
keep if year > 1988
keep if year < 2018
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re norm_idiff, r
restore

//pre-crisis
preserve 
keep if year < 2007
keep if year > 1988
bys cty2: reg mr_ex_re i_diff p_r_diff, r
restore

//post-crisis
preserve 
keep if year < 2018
keep if year > 2006
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re i_diff p_r_diff, r
restore

* 10-year Rolling Regression
drop if p_r_diff ==.
sort country2 year month
bys country2: gen t = _n
tsset cty2 t
foreach cnty in CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(120) saving(output/`cnty'_10y,replace) keep(date,start): reg mr_ex_re i_diff p_r_diff if country2 == "`cnty'",r
}

	use output/DEM_10y,clear 
	gen lower = _b_i_diff - 1.96 * _se_i_diff
	gen upper = _b_i_diff + 1.96 * _se_i_diff
	twoway rcap lower upper start, color(navy) || scatter _b_i_diff start, msize(medium) msymbol(X) ///
					title("Coefficient and 95% CI in Fama Regression (AUD)", color(black) size(small)) ///
					note("Monthly data from January 1989 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))


* 5-year Rolling Regression
foreach cnty in AUD CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(60) saving("`cnty'_5y",replace) keep(date,start): reg mr_ex_re i_diff p_r_diff if country2 == "`cnty'",r
}


* Equation 8
replace mr_ex_re = mr_ex_re - i_diff

bys cty2: reg mr_ex_re p_r_diff, r
//common ending date
preserve 
keep if year > 1988
keep if year < 2018
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re p_r_diff, r
restore

//pre-crisis
preserve 
keep if year < 2007
keep if year > 1988
bys cty2: reg mr_ex_re p_r_diff, r
restore

//post-crisis
preserve 
keep if year < 2018
keep if year > 2006
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re  p_r_diff, r
restore

* 10-year Rolling Regression
drop if p_r_diff ==.
sort country2 year month
bys country2: gen t = _n
tsset cty2 t
foreach cnty in CAD CHF DEM FRF GBP ITL JPY NOK NZD SEK{
	rolling _b _se, window(120) saving(output/`cnty'_10y,replace) keep(date,start): reg mr_ex_re  p_r_diff if country2 == "`cnty'",r
}

	use output/NOK_10y,clear 
	gen lower = _b_p_r_diff - 1.96 * _se_p_r_diff
	gen upper = _b_p_r_diff + 1.96 * _se_p_r_diff
	twoway rcap lower upper start, color(navy) || scatter _b_p_r_diff start, msize(medium) msymbol(X) ///
					title("Coefficient and 95% CI in Fama Regression (AUD)", color(black) size(small)) ///
					note("Monthly data from January 1989 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))


