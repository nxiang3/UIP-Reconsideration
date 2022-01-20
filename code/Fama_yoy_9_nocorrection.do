clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 03/25/20 Fama regressions
*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201216
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	** data from 11 countries during 06/1979 - 03/2020
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
use "$data/data_updated_201009", clear
	gen p_r = log(cpi_usa) - log(cpi)
	xtset cty2 t
	gen pr_lag = l12.p_r
	gen pi_diff = p_r - pr_lag
	gen srex = s_change - i_diff
	drop if pi_diff==.
	drop if s_change ==. | i_diff ==.

	drop t
	gen coef = .
	gen tstat = .
	gen cilow = .
	gen cihigh = .
	gen p_val = .
	
	gen coef_pi = .
	gen tstat_pi = .
	gen cilow_pi = .
	gen cihigh_pi = .
	gen p_val_pi = .
	
	sort country2 year month
	bysort country2: gen t = _n
	save $inter/data_1216_yoy.dta, replace
	
		**** whole sample
		local i = 2
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_79_20.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_79_20_pi.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		forvalue i = 3/9{
		
			reg srex i_diff pi_diff if cty2 == `i', r
			replace coef = _b[i_diff] if cty2 == `i'
			local tstat = _b[i_diff]/_se[i_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
			replace cilow = `cilow'  if cty2 == `i'
			local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
			replace cihigh = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
			replace p_val = `p_v'
			outreg2 using "$tables/fama_yoy_79_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

			replace coef_pi = _b[pi_diff] if cty2 == `i'
			local tstat = _b[pi_diff]/_se[pi_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
			replace cilow_pi = `cilow' if cty2 == `i'
			local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
			replace cihigh_pi = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
			replace p_val_pi = `p_v'
			outreg2 using "$tables/fama_yoy_79_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		}
		
		local i = 11
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_79_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_79_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		save $inter/fama_yoy_79_20.dta, replace
		
		**** 1987/01 - 2020/09
		use $inter/data_1216_yoy.dta, clear
		keep if year >= 1987 
		
		local i = 2
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_87_20.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_87_20_pi.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		forvalue i = 3/9{
		
			reg srex i_diff pi_diff if cty2 == `i', r
			replace coef = _b[i_diff] if cty2 == `i'
			local tstat = _b[i_diff]/_se[i_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
			replace cilow = `cilow'  if cty2 == `i'
			local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
			replace cihigh = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
			replace p_val = `p_v'
			outreg2 using "$tables/fama_yoy_87_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

			replace coef_pi = _b[pi_diff] if cty2 == `i'
			local tstat = _b[pi_diff]/_se[pi_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
			replace cilow_pi = `cilow' if cty2 == `i'
			local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
			replace cihigh_pi = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
			replace p_val_pi = `p_v'
			outreg2 using "$tables/fama_yoy_87_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		}
		
		local i = 11
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_87_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_87_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		save $inter/fama_yoy_87_20.dta, replace

		**** 1987/01 - 2006/12
		use $inter/data_1216_yoy.dta, clear
		keep if year >= 1987 & year < 2007
		
		local i = 2
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_87_06.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_87_06_pi.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		forvalue i = 3/9{
		
			reg srex i_diff pi_diff if cty2 == `i', r
			replace coef = _b[i_diff] if cty2 == `i'
			local tstat = _b[i_diff]/_se[i_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
			replace cilow = `cilow'  if cty2 == `i'
			local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
			replace cihigh = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
			replace p_val = `p_v'
			outreg2 using "$tables/fama_yoy_87_06.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

			replace coef_pi = _b[pi_diff] if cty2 == `i'
			local tstat = _b[pi_diff]/_se[pi_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
			replace cilow_pi = `cilow' if cty2 == `i'
			local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
			replace cihigh_pi = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
			replace p_val_pi = `p_v'
			outreg2 using "$tables/fama_yoy_87_06_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		}
		
		local i = 11
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_87_06.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_87_06_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		save $inter/fama_yoy_87_06.dta, replace

		**** 2007/01 - 2020/09
		use $inter/data_1216_yoy.dta, clear
		keep if year >= 2007 
		local i = 2
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_07_20.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_07_20_pi.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		forvalue i = 3/9{
		
			reg srex i_diff pi_diff if cty2 == `i', r
			replace coef = _b[i_diff] if cty2 == `i'
			local tstat = _b[i_diff]/_se[i_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
			replace cilow = `cilow'  if cty2 == `i'
			local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
			replace cihigh = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
			replace p_val = `p_v'
			outreg2 using "$tables/fama_yoy_07_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

			replace coef_pi = _b[pi_diff] if cty2 == `i'
			local tstat = _b[pi_diff]/_se[pi_diff]
			replace tstat = `tstat' if cty2 == `i'
			local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
			replace cilow_pi = `cilow' if cty2 == `i'
			local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
			replace cihigh_pi = `cihigh' if cty2 == `i'
			local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
			replace p_val_pi = `p_v'
			outreg2 using "$tables/fama_yoy_07_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		}
		
		local i = 11
		reg srex i_diff pi_diff if cty2 == `i', r
		replace coef = _b[i_diff] if cty2 == `i'
		local tstat = _b[i_diff]/_se[i_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[i_diff] - 1.96 * _se[i_diff] 
		replace cilow = `cilow'  if cty2 == `i'
		local cihigh = _b[i_diff] + 1.96 * _se[i_diff]
		replace cihigh = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[i_diff]/_se[i_diff]))
		replace p_val = `p_v'
		outreg2 using "$tables/fama_yoy_07_20.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')

		replace coef_pi = _b[pi_diff] if cty2 == `i'
		local tstat = _b[pi_diff]/_se[pi_diff]
		replace tstat = `tstat' if cty2 == `i'
		local cilow = _b[pi_diff] - 1.96 * _se[pi_diff]
		replace cilow_pi = `cilow' if cty2 == `i'
		local cihigh = _b[pi_diff] + 1.96 * _se[pi_diff]	
		replace cihigh_pi = `cihigh' if cty2 == `i'
		local p_v = 2*ttail(e(df_r), abs(_b[pi_diff]/_se[pi_diff]))
		replace p_val_pi = `p_v'
		outreg2 using "$tables/fama_yoy_07_20_pi.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p_val, `p_v')
		
		save $inter/fama_yoy_07_20.dta, replace

*** Report CI as a graph

**** whole sample 
	use $inter/fama_yoy_79_20.dta, clear
	
	duplicates drop cty2, force
	keep cty2 coef cilow cihigh coef_pi cilow_pi cihigh_pi
	twoway rcap cilow cihigh cty2, color(navy) || scatter coef cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma1", color(black) size(small)) ///
				note("Monthly data from June 1979 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
				legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_79_20_b.gph, replace
	graph export $figures/fama_yoy_ci_79_20_b.png, replace
	
	twoway rcap cilow_pi cihigh_pi cty2, color(navy) || scatter coef_pi cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma2", color(black) size(small)) ///
				note("Monthly data from June 1979 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of Inflation", size(small)) ///
				legend(label(1 "95% CI of Inflation") label(2 "Estimated Coefficients of Inflation") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_79_20_c.gph, replace
	graph export $figures/fama_yoy_ci_79_20_c.png, replace
		
** 1987/01 - 2020/09

	use $inter/fama_yoy_87_20.dta, clear
	
*** Report CI as a graph
	duplicates drop cty2, force
	keep cty2 coef cilow cihigh coef_pi cilow_pi cihigh_pi
	twoway rcap cilow cihigh cty2, color(navy) || scatter coef cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma1", color(black) size(small)) ///
				note("Monthly data from January 1987 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
				legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_87_17_b.gph, replace
	graph export $figures/fama_yoy_ci_87_17_b.png, replace
	
	twoway rcap cilow_pi cihigh_pi cty2, color(navy) || scatter coef_pi cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma2", color(black) size(small)) ///
				note("Monthly data from January 1987 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of Inflation", size(small)) ///
				legend(label(1 "95% CI of Inflation") label(2 "Estimated Coefficients of Inflation") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_87_20_c.gph, replace
	graph export $figures/fama_yoy_ci_87_20_c.png, replace
	

** 1987/01 to 2006/12

	use $inter/fama_yoy_87_06.dta, clear
	
*** Report CI as a graph
	duplicates drop cty2, force
	keep cty2 coef cilow cihigh coef_pi cilow_pi cihigh_pi 
	twoway rcap cilow cihigh cty2, color(navy) || scatter coef cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma1", color(black) size(small)) ///
				note("Monthly data from January 1987 to December 2006", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
				legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_87_06_b.gph, replace
	graph export $figures/fama_yoy_ci_87_06_b.png, replace
	
	twoway rcap cilow_pi cihigh_pi cty2, color(navy) || scatter coef_pi cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma2", color(black) size(small)) ///
				note("Monthly data from January 1987 to December 2006", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of Inflation", size(small)) ///
				legend(label(1 "95% CI of Inflation") label(2 "Estimated Coefficients of Inflation") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_87_06_c.gph, replace
	graph export $figures/fama_yoy_ci_87_06_c.png, replace
		
** 2007/01 to 2020/09
	
	use $inter/fama_yoy_07_20.dta, clear

*** Report CI as a graph
	duplicates drop cty2, force
	keep cty2 coef cilow cihigh coef_pi cilow_pi cihigh_pi
	twoway rcap cilow cihigh cty2, color(navy) || scatter coef cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma1", color(black) size(small)) ///
				note("Monthly data from January 2007 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
				legend(label(1 "95% CI of LIBOR rates differential") label(2 "Estimated Coefficients of LIBOR rates differential") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_07_b.gph, replace
	graph export $figures/fama_yoy_ci_07_b.png, replace
	
	twoway rcap cilow_pi cihigh_pi cty2, color(navy) || scatter coef_pi cty2, msize(medium) msymbol(X) ///
				title("Coefficient and 95% CI in Fama Regression with Inflation: gamma2", color(black) size(small)) ///
				note("Monthly data from January 2007 to September 2020", color(black) size(vsmall)) ///
				ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
				xlabel(2 "CAD" 3 "CHF" 4 "DEM" 5 "FRF" 6 "GBP" 7 "ITL" 8 "JPY" 9 "NOK" 11 "SEK",labsize(vsmall)) xtitle("Foreign Countries", size(small)) ytitle("Estimated Coefficients of Inflation", size(small)) ///
				legend(label(1 "95% CI of Inflation") label(2 "Estimated Coefficients of Inflation") size(small) symxsize(6)) yline(0, lpattern(dash)) yline(1, lpattern(dash) lcolor(green))
	graph save $figures/fama_yoy_ci_07_20_c.gph, replace
	graph export $figures/fama_yoy_ci_07_20_c.png, replace
	
	
