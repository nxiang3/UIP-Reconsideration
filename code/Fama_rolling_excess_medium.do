clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 06/01/20 Rolling Fama regressions with price adjusted
*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201228
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	** data from 11 countries during 06/1979 - 03/2020
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
	gen i_diffsum = i_diff + i_diff1 + i_diff2 + i_diff3 + i_diff4 + i_diff5 + i_diff6 + i_diff7 + i_diff8 + i_diff9 + i_diff10 + i_diff11
	gen s12 = f12.s_fama
	
	gen coef = .
	gen tstat = .
	gen cilow = .
	gen cihigh = .

	* Medium Run Excess Return (1y)
	gen s_medium = s12 - s_fama - i_diffsum
	* Short Run Excess Return (1m)
	gen s_short = s_change - i_diff
	
	replace cpi = log(cpi)
	replace cpi_usa = log(cpi_usa)

	//inflation
	gen p_r = cpi_usa - cpi
	gen p_r_lag12 = l12.p_r
	gen p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)
	gen p_diff_lag = l.p_r_diff

	forval i = 1(1)11{
		drop if i_diff`i'== .
	}
	drop if i_diff == .
	drop if p_r_diff == .
	
	save $data/data_1228_excess_med.dta, replace
	
	** 1 "AUD" 
		* data available: 01/1989 (t=116) - 11/2017 (t=462)
		* AUD has gaps, not able to run VAR
		keep if country2 == "AUD"
		sort year month
		quietly replace t = _n
		
	** 2 "CAD" 
		* data available: 06/1979 (t=1) - 11/2017 (t=462)

		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "CAD"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_CAD_excess_med.dta, replace
		

	** 3 "CHF" 
		* data available: 01/1989 (t=116) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "CHF"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_CHF_excess_med.dta, replace
				
	** 4 "DEM" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "DEM"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_DEM_excess_med.dta, replace
			
	** 5 "FRF" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "FRF"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_FRF_excess_med.dta, replace

	** 6 "GBP" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "GBP"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_GBP_excess_med.dta, replace
				
	** 7 "ITL"
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "ITL"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_ITL_excess_med.dta, replace
			
	** 8 "JPY" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "JPY"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_JPY_excess_med.dta, replace
			
	** 9 "NOK" 
		* data available: 01/1986 (t=80) - 11/2017 (t=462)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "NOK"
		sort year month
		quietly replace t = _n
		save $inter/data_1228_NOK_excess_med.dta, replace
				
	** 10 "NZD" 
		* data available: 01/1999 (t=236) - 11/2017 (t=462)
		* NZD has gaps, not able to run VAR

		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "NZD"
		sort year month
		quietly replace t = _n

	** 11 "SEK"
		* data available: 01/1987 (t=92) - 11/2017 (t=462)
		
		use $data/data_1228_excess_med.dta, clear
		keep if country2 == "SEK"	
		sort year month
		quietly replace t = _n
		xtset cty2 t
		save $inter/data_1228_SEK_excess_med.dta, replace
		

*** Fama regression, rolling 10-year window 
		* 10-year window is from t to t+119
		* first 10-year: t = first period with data
		* last 10-year: t = 462-119 = 343 (which is 12/2007)
		* By currency
	
	** 2 "CAD" 
		* data available: 06/1979 - 11/2017 

		use $inter/data_1228_CAD_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_CAD_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
			
			outreg2 using $tables/fama_10_CAD_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_CAD_excess_med.dta, replace
		export excel using $results/fama_10_CAD_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: CAD", color(black) size(small)) ///
					note("Monthly data from June 1979 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_CAD_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_CAD_c_excess_med.png, replace
	
	** 3 "CHF" 
		* data available: 01/1989 - 02/2020 

		use $inter/data_1228_CHF_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		
		outreg2 using $tables/fama_10_CHF_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
					
			outreg2 using $tables/fama_10_CHF_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_CHF_excess_med.dta, replace
		export excel using $results/fama_10_CHF_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: CHF", color(black) size(small)) ///
					note("Monthly data from January 1989 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_CHF_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_CHF_c_excess_med.png, replace	

		
	** 4 "DEM" 
		* data available: 06/1979 - 02/2020 
		
		use $inter/data_1228_DEM_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_DEM_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
					
			outreg2 using $tables/fama_10_DEM_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_DEM_excess_med.dta, replace
		export excel using $results/fama_10_DEM_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: DEM", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_DEM_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_DEM_c_excess_med.png, replace	

		
	** 5 "FRF" 
		* data available: 06/1979 - 02/2020
		
		use $inter/data_1228_FRF_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_FRF_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
			
			outreg2 using $tables/fama_10_FRF_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_FRF_excess_med.dta, replace
		export excel using $results/fama_10_FRF_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: FRF", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_FRF_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_FRF_c_excess_med.png, replace	

		
	** 6 "GBP" 
		* data available: 06/1979 - 02/2020 
		
		use $inter/data_1228_GBP_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
			
		outreg2 using $tables/fama_10_GBP_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
			
			outreg2 using $tables/fama_10_GBP_excess_med.xls,  dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t

		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_GBP_excess_med.dta, replace
		export excel using $results/fama_10_GBP_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: GBP", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_GBP_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_GBP_c_excess_med.png, replace	

		
	** 7 "ITL"
		* data available: 06/1979 - 02/2020 
		
		use $inter/data_1228_ITL_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_ITL_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
				
			outreg2 using $tables/fama_10_ITL_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
		
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_ITL_excess_med.dta, replace
		export excel using $results/fama_10_ITL_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: ITL", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_ITL_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_ITL_c_excess_med.png, replace	

		
	** 8 "JPY" 
		* data available: 06/1979 - 02/2020 
		use $inter/data_1228_JPY_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_JPY_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
				
			outreg2 using $tables/fama_10_JPY_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
	
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_JPY_excess_med.dta, replace
		export excel using $results/fama_10_JPY_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: JPY", color(black) size(small)) ///
					note("Monthly data from June 1979 to March 2020, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(1 "June 1980"  8 "Jan 1981"  20 "Jan 1982"  32 "Jan 1983"  44 "Jan 1984" ///
					56 "Jan 1985"  68 "Jan 1986"  80 "Jan 1987"  92 "Jan 1988" ///
					104 "Jan 1989" 116 "Jan 1990" 128 "Jan 1991" 140 "Jan 1992" 152 "Jan 1993" 164 "Jan 1994" ///
					176 "Jan 1995" 188 "Jan 1996" 200 "Jan 1997" 212 "Jan 1998" 224 "Jan 1999" 236 "Jan 2000" ///
					248 "Jan 2001" 260 "Jan 2002" 272 "Jan 2003" 284 "Jan 2004" 296 "Jan 2005" 308 "Jan 2006" ///
					320 "Jan 2007" 332 "Jan 2008" 344 "Jan 2009" 356 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_JPY_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_JPY_c_excess_med.png, replace	

		
	** 9 "NOK" 
		* data available: 01/1986 - 11/2017 
		
		use $inter/data_1228_NOK_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_NOK_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
			
			outreg2 using $tables/fama_10_NOK_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
	
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_NOK_excess_med.dta, replace
		export excel using $results/fama_10_NOK_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		replace t = t - 12
		
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: NOK", color(black) size(small)) ///
					note("Monthly data from January 1986 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(-11 "Jan 1986" 1 "Jan 1987"  13 "Jan 1988"  25 "Jan 1989" ///
					37 "Jan 1990" 49 "Jan 1991" 61 "Jan 1992" 73 "Jan 1993" 85 "Jan 1994" 97 "Jan 1995" ///
					109 "Jan 1996" 121 "Jan 1997" 133 "Jan 1998" 145 "Jan 1999" 157 "Jan 2000" 169 "Jan 2001" ///
					181 "Jan 2002" 193 "Jan 2003" 205 "Jan 2004" 217 "Jan 2005" 229 "Jan 2006" 241 "Jan 2007" ///
					253 "Jan 2008" 265 "Jan 2009" 277 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_NOK_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_NOK_c_excess_med.png, replace	


	** 11 "SEK"
		* data available: 01/1987 - 11/2017 
		use $inter/data_1228_SEK_excess_med.dta, clear
		quietly sum t
		local T = r(max)
		local t_end = `T' - 119
		local i = 1
		local j = `i' + 119
		gen T = 120
		gen J = 12
		* innovation from 1m predictive regression: u
		reg s_short p_r_diff if t >= `i' & t <= `j', r
		predict u, residual
		* innovation and persistence of autocorrelation
		reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
		gen rho = _b[p_diff_lag] if t >= `i' & t <= `j'
		predict v, residual
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
		newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
		gen beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
		gen num = e(N) if t >= `i' & t <= `j'
		replace beta_J = beta_J + bias if t >= `i' & t <= `j'
		replace coef = beta_J if t == `i' 
		summarize coef if t >= `i' & t <= `j'
		local coef = r(mean)
		* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
		egen sr_sd = sd(s_short) if t >= `i' & t <= `j'
		gen sr_var = sr_sd * sr_sd if t >= `i' & t <= `j'
		egen p_diff_sd = sd(p_r_diff) if t >= `i' & t <= `j'
		gen p_diff_var = p_diff_sd * p_diff_sd if t >= `i' & t <= `j'
		gen se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
		sum se  if t >= `i' & t <= `j'
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
		
		outreg2 using $tables/fama_10_SEK_excess_med.xls, replace dec(3) stats(coef se) 
		
		local i = `i' + 1
		
		while `i' <= `t_end'{
			local j = `i' + 119
			* innovation from 1m predictive regression: u
			reg s_short p_r_diff if t >= `i' & t <= `j', r
			predict u_`i', residual
			* innovation and persistence of autocorrelation
			reg p_r_diff p_diff_lag if t >= `i' & t <= `j'
			replace rho = _b[p_diff_lag] if t >= `i' & t <= `j'
			predict v_`i', residual
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
			newey s_medium p_r_diff if t >= `i' & t <= `j', lag(12)
			replace beta_J = _b[p_r_diff] if t >= `i' & t <= `j'
			replace num = e(N) if t >= `i' & t <= `j'
			replace beta_J = beta_J + bias if t >= `i' & t <= `j'
			replace coef = beta_J if t == `i' 
			summarize coef if t >= `i' & t <= `j'
			local coef = r(mean)
			* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
			egen sr_sd_`i' = sd(s_short) if t >= `i' & t <= `j'
			replace sr_var = sr_sd_`i' * sr_sd_`i' if t >= `i' & t <= `j'
			egen p_diff_sd_`i' = sd(p_r_diff) if t >= `i' & t <= `j'
			replace p_diff_var = p_diff_sd_`i' * p_diff_sd_`i' if t >= `i' & t <= `j'
			replace se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho)))) if t >= `i' & t <= `j'
			sum se  if t >= `i' & t <= `j'
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
			drop u_`i' v_`i' v_sd_`i' sr_sd_`i' p_diff_sd_`i'
			
			outreg2 using $tables/fama_10_SEK_excess_med.xls, append dec(3) stats(coef se) 
			local i = `i' + 1
		}
		
			* Report CI as a graph
		keep if coef != .
		replace t = _n
		sort t
	
		sum cihigh
		local max1 = int(r(max)) + 1
		gen coef_max1 = int(r(max)) + 1

		gen d1coef = -2 if coef < 0 & cihigh < 0    // significantly less than 0
		replace d1coef = -1 if coef < 0 & cihigh >= 0 // insignificantly less than 0
		replace d1coef = 0 if coef == 0  // coef == 1
		replace d1coef = 1 if coef > 0 & cilow <= 0 // insignificantly greater than 0
		replace d1coef = 2 if coef > 0 & cilow > 0  // significantly greater than 0
		
		gen ref0 = 0
		gen ref1 = 1

		save $data/fama_10_SEK_excess_med.dta, replace
		export excel using $results/fama_10_SEK_excess_med.xlsx, firstrow(variables) replace
				
		sum cilow
		local min1 = round(r(min))-1
		sum cihigh
		local max1 = int(r(max)) + 1
		
		replace t = t - 12
		twoway bar coef_max1 t if d1coef == -2, color(navy*0.3) base(`min1') || bar coef_max1 t if d1coef == -1, color(maroon*0.3) base(`min1') || bar coef_max1 t if d1coef == 0, color(orange*0.3) base(`min1') || /// 
			bar coef_max1 t if d1coef == 1, color(green*0.3) base(`min1') || bar coef_max1 t if d1coef == 2, color(purple*0.3) base(`min1') ///
			|| line coef t, lcolor(maroon) || line cihigh t, lcolor(navy) lpattern(dash) || line cilow t, lcolor(navy) lpattern(dash) ///
			|| line ref0 t, lcolor(black) lpattern(shortdash) || line ref1 t, lcolor(red) lpattern(shortdash) ///
					title("10-year Rolling Medium-Run Regression, Inflation as Regressor: SEK", color(black) size(small)) ///
					note("Monthly data from January 1987 to December 2017, in each 10-year window", color(black) size(vsmall)) ///
					ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
					xlabel(-11 "Jan 1987" 1 "Jan 1988"  13 "Jan 1989"  25 "Jan 1990" ///
					37 "Jan 1991" 49 "Jan 1992" 61 "Jan 1993" 73 "Jan 1994" 85 "Jan 1995" 97 "Jan 1996" ///
					109 "Jan 1997" 121 "Jan 1998" 133 "Jan 1999" 145 "Jan 2000" 157 "Jan 2001" 169 "Jan 2002" ///
					181 "Jan 2003" 193 "Jan 2004" 205 "Jan 2005" 217 "Jan 2006" 229 "Jan 2007" 241 "Jan 2008" 253 "Jan 2009" 265 "Jan 2010",labsize(vsmall) angle(30)) ///
					xtitle("Starting Time", size(small)) ytitle("Estimated Coefficients of Inflation differential", size(small)) ///
					///legend(label(1 "-1 if coef < 0", 0 if 0 <= coef <= 1, 1 if coef > 1) col(3) size(vsmall) symxsize(6))
				  legend(label(1 "coef << 0") label(2 "coef < 0") label(3 "coef = 0") label(4 "coef > 0") label(5 "coef >> 0") label(6 "Coefficients") label(7 "95% CI: upper bound") label(8 "95% CI: lower bound") label(9 "0") label(10 "1") col(5) size(vsmall) symxsize(6))
		graph save $figures/fama_bar_10_SEK_c_excess_med.gph, replace
		graph export $figures/fama_bar_10_SEK_c_excess_med.png, replace	

