clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 10/19/20 Rolling Fama regressions with bias correction
*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	** data from 11 countries during 06/1979 - 09/2020
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear

use "$data/data_updated_201009",clear

*** Fama regression, rolling 10-year window 
		* 10-year window is from t to t+119
		* first 10-year: t = first period with data
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
		* By currency
		
	** 1 "AUD" 
	
		capture erase "$tables/fama_10_AUD.xls"
		* Fama regression in a rolling 10-year window
		keep if country2 == "AUD"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_AUD.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_AUD.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		
		replace t = t + 115

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$inter/fama_10_AUD.dta", replace
		export excel using "$data/fama_10_AUD.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (AUD)", color(black) size(small)) ///
					note("Monthly data from January 1989 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_AUD.gph", replace
		graph export "$figures/fama_bar_10_AUD.png", replace

		
	** 2 "CAD" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		capture erase "$tables/fama_10_CAD.xls"
		keep if country2 == "CAD"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_CAD.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_CAD.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		
		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_CAD.dta", replace
		export excel using "$data/fama_10_CAD.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (CAD)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_CAD.gph", replace
		graph export "$figures/fama_bar_10_CAD.png", replace
		

	** 3 "CHF" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_CHF.xls"
		keep if country2 == "CHF"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		outreg2 using "$tables/fama_10_CHF.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_CHF.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_CHF.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_CHF.dta", replace
		export excel using "$data/fama_10_CHF.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (CHF)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" /// 
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_CHF.gph", replace
		graph export "$figures/fama_bar_10_CHF.png", replace
		

		
	** 4 "DEM" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_DEM.xls"
		keep if country2 == "DEM"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_DEM.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_DEM.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_DEM.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_DEM.dta", replace
		export excel using "$data/fama_10_DEM.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (DEM)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_DEM.gph", replace
		graph export "$figures/fama_bar_10_DEM.png", replace
		
		
	** 5 "FRF" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		capture erase "$tables/fama_10_FRF.xls"
		keep if country2 == "FRF"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_FRF.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_FRF.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_FRF.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_FRF.dta", replace
		export excel using "$data/fama_10_FRF.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (FRF)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_FRF.gph", replace
		graph export "$figures/fama_bar_10_FRF.png", replace
		

		
	** 6 "GBP" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_GBP.xls"
		keep if country2 == "GBP"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_GBP.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_GBP.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_GBP.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_GBP.dta", replace
		export excel using "$data/fama_10_GBP.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (GBP)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_GBP.gph", replace
		graph export "$figures/fama_bar_10_GBP.png", replace
		

		
	** 7 "ITL"
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_ITL.xls"
		keep if country2 == "ITL"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_ITL.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_ITL.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_ITL.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_ITL.dta", replace
		export excel using "$data/fama_10_ITL.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (ITL)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_ITL.gph", replace
		graph export "$figures/fama_bar_10_ITL.png", replace
		


		
	** 8 "JPY" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_JPY.xls"
		keep if country2 == "JPY"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_JPY.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_JPY.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_JPY.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_JPY.dta", replace
		export excel using "$data/fama_10_JPY.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (JPY)", color(black) size(small)) ///
					note("Monthly data from June 1979 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_JPY.gph", replace
		graph export "$figures/fama_bar_10_JPY.png", replace
		


		
	** 9 "NOK" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_NOK.xls"
		keep if country2 == "NOK"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'
		
		outreg2 using "$tables/fama_10_NOK.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_NOK.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_NOK.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t
		replace t = t + 79
		
		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_NOK.dta", replace
		export excel using "$data/fama_10_NOK.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (NOK)", color(black) size(small)) ///
					note("Monthly data from January 1986 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_NOK.gph", replace
		graph export "$figures/fama_bar_10_NOK.png", replace
		

		
	** 10 "NZD" 
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_NZD.xls"
		keep if country2 == "NZD"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_NZD.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'
			
			outreg2 using "$tables/fama_10_NZD.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_NZD.dta", replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t
		replace t = t + 214
		
		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_NZD.dta", replace
		export excel using "$data/fama_10_NZD.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (NZD)", color(black) size(small)) ///
					note("Monthly data from April 1997 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(215 "Apr 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_NZD.gph", replace
		graph export "$figures/fama_bar_10_NZD.png", replace
		

		
	** 11 "SEK"
//		use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009", clear
		capture erase "$tables/fama_10_SEK.xls"
		keep if country2 == "SEK"
		drop if s_change ==. | i_diff ==.
		drop t
		gen t = _n
		sum t
		local t_max = r(max) - 119
		gen num = 120
		xtset cty2 t
		gen i_lag = l.i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen phi_c = .
		
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i'
		replace var_idiff = `sd' * `sd' if t == `i'
		replace inv_sd_idiff = 1/sd_idiff if t == `i'
		replace inv_var_idiff = 1/var_idiff if t == `i'

		reg i_diff i_lag if t >= `i' & t <= `j', r
		gen var_rho = _se[i_lag]^2 if t == `i'
		* Step 1: construct corrected residuals
		gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
		gen theta_c = _b[_cons] if t >= `i' & t <= `j'
		gen v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
		replace v_c = f.v_c if t >= `i' & t <= `j'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if t >= `i' & t <= `j',r
		replace coef = _b[i_diff] if t == `i'
		replace phi_c = _b[v_c] if t >= `i' & t <= `j'
		* Step 3: SE correction
		gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
		gen var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
		gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
		sum se_beta_c_corrected if t >= `i' & t <= `j'
		local tmp = r(mean)
		local tstat = _b[i_diff]/`tmp'
		replace tstat = `tstat' if t == `i'
		local cilow = _b[i_diff] - 1.96*`tmp'
		replace cilow = `cilow' if t == `i'
		local cihigh = _b[i_diff] + 1.96*`tmp'
		replace cihigh = `cihigh' if t == `i'

		outreg2 using "$tables/fama_10_SEK.xls", replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

		local i = `i' + 1
		
		while `i' <= `t_max'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i'
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i'
			replace inv_var_idiff = 1/var_idiff if t == `i'

			reg i_diff i_lag if t >= `i' & t <= `j', r
			replace var_rho = _se[i_lag]^2 if t == `i'
			* Step 1: construct corrected residuals
			replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if t >= `i' & t <= `j'
			replace theta_c = _b[_cons] if t >= `i' & t <= `j'
			replace v_c = i_diff - rho_c*i_lag - theta_c if t >= `i' & t <= `j'
			replace v_c = f.v_c if t >= `i' & t <= `j'
			* Step 2: estimate fama coefficient
			reg s_change i_diff v_c if t >= `i' & t <= `j',r
			replace coef = _b[i_diff] if t == `i'
			replace phi_c = _b[v_c] if t >= `i' & t <= `j'
			* Step 3: SE correction
			replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if t >= `i' & t <= `j'
			replace var_beta_c = _se[i_diff]^2 if t >= `i' & t <= `j'
			replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if t >= `i' & t <= `j'
			sum se_beta_c_corrected if t >= `i' & t <= `j'
			local tmp = r(mean)
			local tstat = _b[i_diff]/`tmp'
			replace tstat = `tstat' if t == `i'
			local cilow = _b[i_diff] - 1.96*`tmp'
			replace cilow = `cilow' if t == `i'
			local cihigh = _b[i_diff] + 1.96*`tmp'
			replace cihigh = `cihigh' if t == `i'

			outreg2 using "$tables/fama_10_SEK.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

			local i = `i' + 1
		}
		
		
		keep country2 cty2 year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save "$data/fama_10_SEK.dta", replace

		* Report CI as a graph
		keep if coef !=.
 
		sort t
		replace t = t + 91

		gen d1coef = -2 if coef < 1 & cihigh < 1    // significantly less than 1
		replace d1coef = -1 if coef < 1 & cihigh >= 1 // insignificantly less than 1
		replace d1coef = 0 if coef == 1  // coef == 1
		replace d1coef = 1 if coef > 1 & cilow <= 1 // insignificantly greater than 1
		replace d1coef = 2 if coef > 1 & cilow > 1  // significantly greater than 1

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save "$data/fama_10_SEK.dta", replace
		export excel using "$data/fama_10_SEK.xlsx", firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("Coefficient and 95% CI in Fama Regression (SEK)", color(black) size(small)) ///
					note("Monthly data from January 1987 to September 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 368 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 1") label(2 "coef <= 1") label(3 "coef = 1") label(4 "coef >= 1") label(5 "coef >> 1") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save "$figures/fama_bar_10_SEK.gph", replace
		graph export "$figures/fama_bar_10_SEK.png", replace
		

