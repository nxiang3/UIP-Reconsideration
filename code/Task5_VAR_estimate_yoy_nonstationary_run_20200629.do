**************************************************************
*s_T and s_IP for non-stationary ER
**************************************************************
cd E:\Econ872_Paper\analysis
//3-lags
foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
	clear matrix
	use temp/VAR_`country'_yoy.dta, clear
	//use temp/VAR_`country'_8917_yoy.dta,clear
	//use temp/VAR_`country'_8906_yoy.dta,clear
	//use temp/VAR_`country'_0717_yoy.dta,clear
	sort year month
	gen t = _n
	xtset cty2 t
	* deviation from mean of real exchange rate, relative inflation and relative interest rate
	qui: var s_growth pi_ryoy i_diff, lags(1/3)
	* Residuals Prediction
	predict u1, r equation(#1)
	predict u2, r equation(#2)
	predict u3, r equation(#3)

	//e(Sigma): variance-covariance matrix for error term
	drop if u1==.
	drop if u2==.
	drop if u3==.
	drop u1 u2 u3

	drop t
	sort year month
	gen t = _n

	gen sg_dev = .
	gen sg_mean = .
	qui: sum s_growth
	local sg_mean = r(mean)
	replace sg_dev = s_growth - `sg_mean' 
	replace sg_mean = `sg_mean'
		
	gen pi_dev = .
	gen pi_mean = .
	qui: sum pi_ryoy
	local pi_mean = r(mean)
	replace pi_dev = pi_r - `pi_mean'
	replace pi_mean = `pi_mean' 

	gen i_dev = .
	gen i_mean = .
	qui: sum i_diff 
	local i_mean = r(mean)
	replace i_dev = i_diff - `i_mean' 
	replace i_mean = `i_mean'

	xtset cty2 t
	gen sg_dev_lag = l.sg_dev
	gen sg_dev_lag2 = l2.sg_dev
	gen pi_dev_lag = l.pi_dev
	gen pi_dev_lag2 = l2.pi_dev
	gen i_dev_lag = l.i_dev
	gen i_dev_lag2 = l2.i_dev

	matrix B = e(b)

	matrix B0 = [B[1,10] \ B[1, 20] \ B[1, 30]]

	matrix B1 = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

	matrix B2 = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

	matrix B3 = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

	matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

	matrix Identity = I(3)

	matrix B = [B1, B2, B3 \ Identity, zero, zero \ zero, Identity, zero]
	matrix eigenvalues r c = B
	matrix list r
	matrix list c
	
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Yeah!"
	}

	matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
	matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
	matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

	scalar N =_N

	forval i = 1/`=N'{
		mat psi`i' = (sg_dev[`i']\pi_dev[`i']\i_dev[`i']\sg_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\sg_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
	}

	matrix IP = e3 * inv(I(9)-B)
	matrix T = e1 * B * inv(I(9)-B)

	gen s_T =.
	gen s_IP =.

	qui: forval i = 1/`=N'{
		matrix temp1 = IP*psi`i'
		matrix temp2 = T*psi`i'
		replace s_IP = -temp1[1,1] if t == `i'
		replace s_T = - temp2[1,1] if t == `i'
	}
	gen s_diff = s_T - s_IP

	gen s_diff_shock = d.s_diff
	gen i_diff_shock = d.i_diff
	
	sdtest s_T == s_IP
	


	gen coef_t = .
	label variable coef_t "Estimated coefficient of transitory component"
	gen tstat_t = .
	label variable tstat_t "t-statistics of transitory component"
	gen cilow_t = .
	label variable cilow_t "Lower bound of 95% CI, transitory component"
	gen cihigh_t = .
	label variable cihigh_t "Upper bound of 95% CI, transitory component"

	gen coef_ip = .
	label variable coef_ip "Estimated coefficient of UIP measure"
	gen tstat_ip = .
	label variable tstat_ip "t-statistics of UIP measure"
	gen cilow_ip = .
	label variable cilow_ip "Lower bound of 95% CI, UIP measure"
	gen cihigh_ip = .
	label variable cihigh_ip "Upper bound of 95% CI, UIP measure"
	//Regression: s_T, s_IP
	newey s_T i_diff, lag(3)
	replace coef_t = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_t = `tstat' 
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_t = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_t = `cihigh'
	outreg2 using "temp/s_t_3lag.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

	newey s_IP i_diff, lag(3)
	replace coef_ip = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_ip = `tstat'
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_ip = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_ip = `cihigh'
	outreg2 using "temp/s_ip_3lag.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
	
	gen coef_diff = .
	label variable coef_diff "Estimated coefficient "
	gen tstat_diff = .
	label variable tstat_diff "t-statistics"
	gen cilow_diff = .
	label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
	gen cihigh_diff = .
	label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

	//Regression excess
	newey s_diff i_diff, lag(3)
	replace coef_diff = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_diff = `tstat' 
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_diff = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_diff = `cihigh'
	outreg2 using "temp/s_diff_3lags.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
	
	gen coef_shock = .
	label variable coef_shock "Estimated coefficient "
	gen tstat_shock = .
	label variable tstat_shock "t-statistics"
	gen cilow_shock = .
	label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
	gen cihigh_shock = .
	label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

	//Regression shock
	newey s_diff_shock i_diff_shock, lag(12)

	replace coef_shock = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_shock = `tstat' 
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_shock = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_shock = `cihigh'
	outreg2 using "temp/s_diff_shock_3lag.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
*/

}