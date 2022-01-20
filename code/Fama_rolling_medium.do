clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 03/31/20 Fama regressions
*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201228
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	** data from 11 countries during 06/1979 - 03/2020
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
use "$data/data_updated_201009",clear

*** Fama regression, rolling 10-year window 
		* 10-year window is from t to t+119
		* first 10-year: t = first period with data
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
		* By currency
		
	** 1 "AUD" 
		* data available: 01/1989 (t=116) - 11/2017 (t=462)
		* first 10-year: t = 116
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
		
		* Fama regression in a rolling 10-year window
		keep if country2 == "AUD"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff
		
		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119

		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		
		outreg2 using $tables/fama_10_AUD_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_AUD_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_AUD_med.dta, replace
		
		* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_AUD_med.dta, replace
		export excel using $results/fama_10_AUD_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		replace t = t + 115
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: AUD", color(black) size(small)) ///
					note("Monthly data from January 1989 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_AUD_med.gph, replace
		graph export $figures/fama_bar_10_AUD_med.png, replace

	
	** 2 "CAD" 
		* data available: 06/1979 (t=1) - 11/2017 (t=462)
		* first 10-year: t = 1
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "CAD"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		
		outreg2 using $tables/fama_10_CAD_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_CAD_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_CAD_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_CAD_med.dta, replace
		export excel using $results/fama_10_CAD_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: CAD", color(black) size(small)) ///
					note("Monthly data from June 1979 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_CAD_med.gph, replace
		graph export $figures/fama_bar_10_CAD_med.png, replace

		
	** 3 "CHF" 
		* data available: 01/1989 (t=116) - 02/2020 (t=489)
		* first 10-year: t = 116
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "CHF"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_CHF_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_CHF_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_CHF_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_CHF_med.dta, replace
		export excel using $tables/fama_10_CHF_med.xlsx, firstrow(variables) replace
		
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: CHF", color(black) size(small)) ///
					note("Monthly data from January 1989 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" /// 
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_CHF_med.gph, replace
		graph export $figures/fama_bar_10_CHF_med.png, replace

		
	** 4 "DEM" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		* first 10-year: t = 1
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "DEM"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_DEM_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_DEM_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_DEM_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_DEM_med.dta, replace
		export excel using $tables/fama_10_DEM_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: DEM", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_DEM_med.gph, replace
		graph export $figures/fama_bar_10_DEM_med.png, replace

		
	** 5 "FRF" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		* first 10-year: t = 1
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "FRF"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_FRF_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_FRF_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_FRF_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_FRF_med.dta, replace
		export excel using $tables/fama_10_FRF_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: FRF", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_FRF_med.gph, replace
		graph export $figures/fama_bar_10_FRF_med.png, replace

		
	** 6 "GBP" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		* first 10-year: t = 1
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		keep if country2 == "GBP"
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_GBP_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_GBP_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_GBP_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_GBP_med.dta, replace
		export excel using $results/fama_10_GBP_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: GBP", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_GBP_med.gph, replace
		graph export $figures/fama_bar_10_GBP_med.png, replace


		
	** 7 "ITL"
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		* first 10-year: t = 1
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "ITL"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_ITL_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_ITL_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_ITL_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_ITL_med.dta, replace
		export excel using $results/fama_10_ITL_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: ITL", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_ITL_med.gph, replace
		graph export $figures/fama_bar_10_ITL_med.png, replace

		
	** 8 "JPY" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		* first 10-year: t = 1
		* last 10-year: t = 489-119 = 370 (which is 10/2010)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "JPY"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_JPY_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_JPY_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_JPY_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_JPY_med.dta, replace
		export excel using $results/fama_10_JPY_med.xlsx, firstrow(variables) replace
	
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: JPY", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "Jun 1979" 8 "Jan 1980"  20 "Jan 1981"  32 "Jan 1982"  44 "Jan 1983"  56 "Jan 1984" ///
					68 "Jan 1985"  80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_JPY_med.gph, replace
		graph export $figures/fama_bar_10_JPY_med.png, replace

		
	** 9 "NOK" 
		* data available: 01/1986 (t=80) - 11/2017 (t=462)
		* first 10-year: t = 80
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "NOK"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_NOK_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_NOK_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_NOK_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_NOK_med.dta, replace
		export excel using $results/fama_10_NOK_med.xlsx, firstrow(variables) replace
		
		replace t = t + 79
		
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: NOK", color(black) size(small)) ///
					note("Monthly data from January 1986 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(80 "Jan 1986"  92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_NOK_med.gph, replace
		graph export $figures/fama_bar_10_NOK_med.png, replace

		
	** 10 "NZD" 
		* data available: 01/1999 (t=236) - 11/2017 (t=462)
		* first 10-year: t = 236
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "NZD"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_NZD_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_NZD_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_NZD_med.dta, replace
		
			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_NZD_med.dta, replace
		export excel using $results/fama_10_NZD_med.xlsx, firstrow(variables) replace
		
		replace t = t + 211
		
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: NZD", color(black) size(small)) ///
					note("Monthly data from January 1999 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_NZD_med.gph, replace
		graph export $figures/fama_bar_10_NZD_med.png, replace

		
	** 11 "SEK"
		* data available: 01/1987 (t=92) - 11/2017 (t=462)
		* first 10-year: t = 92
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
//	use "/Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201019/rawdata/data_updated_201009.dta", clear
		use "$data/data_updated_201009",clear
		keep if country2 == "SEK"
		sort country2 year month
		xtset cty2 t
		gen i_diff1 = f.i_diff
		gen i_diff2 = f2.i_diff
		gen i_diff3 = f3.i_diff
		gen i_diff4 = f4.i_diff
		gen i_diff5 = f5.i_diff
		gen i_diff6 = f6.i_diff
		gen i_diff7 = f7.i_diff
		gen i_diff8 = f8.i_diff
		gen i_diff9 = f9.i_diff
		gen i_diff10 = f10.i_diff
		gen i_diff11 = f11.i_diff
		gen i_diffsum = i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
		gen s12 = f12.s_fama
		* Medium Run Excess Return (1y)
		gen s_medium = s12 - s_fama - i_diffsum
		* Short Run Excess Return (1m)
		gen s_short = s_change - i_diff

		gen coef = .
		gen tstat = .
		gen cilow = .
		gen cihigh = .
		gen var_idiff = .
		gen sd_idiff = .
		gen inv_var_idiff = .
		gen inv_sd_idiff = .
		drop t
		forval i = 1(1)11{
			drop if i_diff`i'==.
		}
		drop if i_diff == .
		gen t = _n
		xtset cty2  t
		
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119 
		local i = 1
		local j = `i' + 119
		sum i_diff if t >= `i' & t <= `j'
		local sd = r(sd)
		replace sd_idiff = `sd' if t == `i' 
		replace var_idiff = `sd' * `sd' if t == `i' 
		replace inv_sd_idiff = 1/sd_idiff if t == `i' 
		replace inv_var_idiff = 1/var_idiff if t == `i'

		gen T = 120
		sort year month
		* Horizon
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short i_diff if t >= `i' & t <= `j', r
		predict u if t >= `i' & t <= `j', residual
		* innovation and persistence of autocorrelation
		reg i_diff1 i_diff if t >= `i' & t <= `j', r 
		gen rho = _b[i_diff] if t >= `i' & t <= `j'
		predict v if t >= `i' & t <= `j', residual
		* Covariance between u and v
		correlate u v if t >= `i' & t <= `j', covariance
		gen float uv_cov = r(cov_12) if t >= `i' & t <= `j'
		* Variance of v
		egen v_sd = sd(v) if t >= `i' & t <= `j'
		gen v_var = v_sd * v_sd if t >= `i' & t <= `j'
		* Bias: beta_hat + bias = beta
		gen bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
		* Predictive Regression
		tsset t
		newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[i_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i'
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen i_diff_sd = sd(i_diff) if t >= `i' & t <= `j'
		gen i_diff_var = i_diff_sd * i_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se if t >= `i' & t <= `j'
		local se = r(mean)
		replace tstat = coef/se if t >= `i' & t <= `j'
		summarize tstat if t >= `i' & t <= `j'
		local tstat = r(mean)
		replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
		summarize cihigh if t >= `i' & t <= `j'
		local cihigh = r(mean)
		replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
		summarize cilow if t >= `i' & t <= `j'
		local cilow = r(mean)
		outreg2 using $tables/fama_10_SEK_med.xls, replace dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			sum i_diff if t >= `i' & t <= `j'
			local sd = r(sd)
			replace sd_idiff = `sd' if t == `i' 
			replace var_idiff = `sd' * `sd' if t == `i'
			replace inv_sd_idiff = 1/sd_idiff if t == `i' 
			replace inv_var_idiff = 1/var_idiff if t == `i'

			sort year month
			* Horizon
			* innovation from 1m predictive regression: u
			reg s_short i_diff if t >= `i' & t <= `j', r
			predict u_`i' if t >= `i' & t <= `j', residual
			* innovation and persistence of autocorrelation
			reg i_diff1 i_diff if t >= `i' & t <= `j', r 
			replace rho = _b[i_diff] if t >= `i' & t <= `j'
			predict v_`i' if t >= `i' & t <= `j', residual
			* Covariance between u and v
			correlate u_`i' v_`i' if t >= `i' & t <= `j', covariance
			replace uv_cov = r(cov_12) if t >= `i' & t <= `j'
			* Variance of v
			egen v_sd_`i' = sd(v_`i') if t >= `i' & t <= `j'
			replace v_var = v_sd_`i' * v_sd_`i' if t >= `i' & t <= `j'
			* Bias: beta_hat + bias = beta
			replace bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T if t >= `i' & t <= `j'
			* Predictive Regression
			tsset t
			newey s_medium i_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[i_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i'
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen i_diff_sd_`i' = sd(i_diff) if t >= `i' & t <= `j'
			replace i_diff_var = i_diff_sd_`i' * i_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/i_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se if t >= `i' & t <= `j'
			local se = r(mean)
			replace tstat = coef/se if t >= `i' & t <= `j'
			summarize tstat if t >= `i' & t <= `j'
			local tstat = r(mean)
			replace cihigh = beta_J + 1.96*se if t >= `i' & t <= `j'
			summarize cihigh if t >= `i' & t <= `j'
			local cihigh = r(mean)
			replace cilow = beta_J -1.96*se if t >= `i' & t <= `j'
			summarize cilow if t >= `i' & t <= `j'
			local cilow = r(mean)
			drop u_`i' v_`i' v_sd_`i' i_diff_sd_`i' sr_sd_`i'
			outreg2 using $tables/fama_10_SEK_med.xls, append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
			local i = `i' + 1
		}
		
		keep country2 cty2 date year month t coef cilow cihigh var_idiff sd_idiff inv_sd_idiff inv_var_idiff 
		save $data/fama_10_SEK_med.dta, replace

			* Report CI as a graph
		keep if coef !=.
 
		sort t
		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 0
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_SEK_med.dta, replace
		export excel using $results/fama_10_SEK_med.xlsx, firstrow(variables) replace
		
		replace t = t + 91
		
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1

		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regressions: SEK", color(black) size(small)) ///
					note("Monthly data from January 1987 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(92 "Jan 1987"  104 "Jan 1988" ///
					116 "Jan 1989" 128 "Jan 1990" 140 "Jan 1991" 152 "Jan 1992" 164 "Jan 1993" 176 "Jan 1994" ///
					188 "Jan 1995" 200 "Jan 1996" 212 "Jan 1997" 224 "Jan 1998" 236 "Jan 1999" 248 "Jan 2000" ///
					260 "Jan 2001" 272 "Jan 2002" 284 "Jan 2003" 296 "Jan 2004" 308 "Jan 2005" 320 "Jan 2006" ///
					332 "Jan 2007" 344 "Jan 2008" 356 "Jan 2009" 367 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of LIBOR rates differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef <= 0") label(3 "coef = 0") label(4 "coef >= 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_SEK_med.gph, replace
		graph export $figures/fama_bar_10_SEK_med.png, replace


