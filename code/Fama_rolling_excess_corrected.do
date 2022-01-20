clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 06/01/20 Rolling Fama regressions with price adjusted
*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201111
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	** data from 11 countries during 06/1979 - 09/2020
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
use "$data/data_updated_201009",clear

*** Fama regression, rolling 10-year window 
		* 10-year window is from t to t+119
		* first 10-year: t = first period with data
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
		* By currency
	
	** 2 "CAD" 
		* data available: 06/1979 - 11/2017 
		keep if cty2 == 2
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_CAD_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_CAD_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_CAD_excess.dta, replace
		//export excel using "export/fama_10_CAD_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (CAD): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_CAD_excess.gph", replace
		graph export "$figures/fama_bar_10_CAD_excess.png", replace
		
	
	** 3 "CHF" 
		* data available: 01/1989 - 02/2020 
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
use "$data/data_updated_201009",clear

		keep if cty2 == 3
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_CHF_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_CHF_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_CHF_excess.dta, replace
		//export excel using "export/fama_10_CHF_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (CHF): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980" 20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" /// 
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_CHF_excess.gph", replace
		graph export "$figures/fama_bar_10_CHF_excess.png", replace
			
		
	** 4 "DEM" 
		* data available: 06/1979 - 02/2020 
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 4
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_DEM_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_DEM_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_DEM_excess.dta, replace
		//export excel using "export/fama_10_DEM_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (DEM): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_DEM_excess.gph", replace
		graph export "$figures/fama_bar_10_DEM_excess.png", replace

		
	** 5 "FRF" 
		* data available: 06/1979 - 02/2020
		
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 5
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_FRF_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_FRF_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_FRF_excess.dta, replace
		//export excel using "export/fama_10_FRF_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (FRF): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980" 20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_FRF_excess.gph", replace
		graph export "$figures/fama_bar_10_FRF_excess.png", replace

		
	** 6 "GBP" 
		* data available: 06/1979 - 02/2020 
		
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 6
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_GBP_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_GBP_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_GBP_excess.dta, replace
		//export excel using "export/fama_10_GBP_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (GBP): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980" 20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_GBP_excess.gph", replace
		graph export "$figures/fama_bar_10_GBP_excess.png", replace

		
	** 7 "ITL"
		* data available: 06/1979 - 02/2020 
		
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 7
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_ITL_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_ITL_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_ITL_excess.dta, replace
		//export excel using "export/fama_10_ITL_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (ITL): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_ITL_excess.gph", replace
		graph export "$figures/fama_bar_10_ITL_excess.png", replace

	** 8 "JPY" 
		* data available: 06/1979 - 02/2020 
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 8
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_JPY_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_JPY_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		replace t = t+12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_JPY_excess.dta, replace
		//export excel using "export/fama_10_JPY_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (JPY): d", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(13 "June 1980" 20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_JPY_excess.gph", replace
		graph export "$figures/fama_bar_10_JPY_excess.png", replace

		
	** 9 "NOK" 
		* data available: 01/1986 - 11/2017 
		
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 9
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_NOK_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_NOK_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		sort t
		replace t = t + 79 + 12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_NOK_excess.dta, replace
		//export excel using "export/fama_10_NOK_excess.xlsx", firstrow(variables) replace
				
		sum cilow_pi
		local min1 = round(r(min))-1
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (NOK): d", color(black) size(small)) ///
					note("Monthly data from January 1986 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_NOK_excess.gph", replace
		graph export "$figures/fama_bar_10_NOK_excess.png", replace
		

	** 11 "SEK"
		* data available: 01/1987 - 11/2017 
//use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if cty2 == 11
		drop if s_change ==. | i_diff ==.
		gen num = 120
		gen p_r = log(cpi_usa) - log(cpi)
		xtset cty2 t
		gen pr_lag = l12.p_r
		gen p_r_diff = p_r - pr_lag
		gen p_diff_lag = l.p_r_diff
		
		gen srex = s_change - i_diff
		drop if p_r_diff==.
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		drop t
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
		* Step 1: donstruct corrected residuals
		gen rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
		replace coef = _b[p_r_diff] if t == `i' 
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[p_r_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[p_r_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[p_r_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		//outreg2 using "tables/fama_10_SEK_excess.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[p_diff_lag]^2 if t >= `i' & t <= `j'
			* Step 1: donstruct corrected residuals
			replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = p_diff - rho_c*p_diff_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg srex p_r_diff v_c if t >= `i' & t <= `j' ,r
			replace coef = _b[p_r_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[p_r_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[p_r_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[p_r_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[p_r_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			//outreg2 using "tables/fama_10_SEK_excess.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		* Report CI as a graph
		rename coef coef_pi
		rename cihigh cihigh_pi
		rename cilow cilow_pi
		keep if coef_pi != .
		sort t
		replace t = t + 91 + 12
	
		sum cihigh_pi
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef_pi < 0 & cihigh_pi < 0    // significantly less than 0
		replace d1coef = -1 if coef_pi < 0 & cihigh_pi >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef_pi == 0  // coef == 1
		replace d1coef = 1 if coef_pi > 0 & cilow_pi <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef_pi > 0 & cilow_pi > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		//save data/fama_10_SEK_excess.dta, replace
		//export excel using "export/fama_10_SEK_excess.xlsx", firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef_pi t, lcolor(maroon) || line cihigh_pi t, lcolor(navy) lpattern(dash) || line cilow_pi t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Equation 6 (SEK): d", color(black) size(small)) ///
					note("Monthly data from January 1987 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_SEK_excess.gph", replace
		graph export "$figures/fama_bar_10_SEK_excess.png", replace

	

