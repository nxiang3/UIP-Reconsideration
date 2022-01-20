**************************************************************
*s_T and s_IP for whole sample
**************************************************************
cd E:\Econ872_Paper\analysis
foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
	clear matrix
	use temp/VAR_`country'_8917.dta, clear
	gen t = _n
	xtset cty2 t
	* deviation from mean of real exchange rate, relative inflation and relative interest rate
	var q pi_r i_diff, lags(1/3)
	* Residuals Prediction
	predict u1, r equation(#1)
	predict u2, r equation(#2)
	predict u3, r equation(#3)

	drop if u1==.
	drop if u2==.
	drop if u3==.
	drop u1 u2 u3

	drop t
	sort year month
	gen t = _n

	gen q_dev = .
	gen q_mean = .
	sum q 
	local q_mean = r(mean)
	replace q_dev = q - `q_mean' 
	replace q_mean = `q_mean'
		
	gen pi_dev = .
	gen pi_mean = .
	sum pi_r
	local pi_mean = r(mean)
	replace pi_dev = pi_r - `pi_mean'
	replace pi_mean = `pi_mean' 

	gen i_dev = .
	gen i_mean = .
	sum i_diff 
	local i_mean = r(mean)
	replace i_dev = i_diff - `i_mean' 
	replace i_mean = `i_mean'

	xtset cty2 t
	gen q_dev_lag = l.q_dev
	gen q_dev_lag2 = l2.q_dev
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
	matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
	matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

	scalar N =_N

	forval i = 1/`=N'{
		mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
	}

	matrix IP = e3 * inv(I(9)-B)
	matrix T = e2 * B * inv(I(9)-B)

	gen s_T =.
	gen s_IP =.

	forval i = 1/`=N'{
		matrix temp1 = IP*psi`i'
		matrix temp2 = T*psi`i'
		replace s_IP = -temp1[1,1] if t == `i'
		replace s_T = q_dev - temp2[1,1] if t == `i'
	}

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
	//Regression
	newey s_T i_diff, lag(3)
	replace coef_t = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_t = `tstat' 
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_t = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_t = `cihigh'
	outreg2 using "temp/tables/s_t_3-12lag.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')

	newey s_IP i_diff, lag(3)
	replace coef_ip = _b[i_diff] 
	local tstat = _b[i_diff]/_se[i_diff]
	replace tstat_ip = `tstat'
	local cilow = _b[i_diff] - 1.96 * _se[i_diff]
	replace cilow_ip = `cilow' 
	local cihigh = _b[i_diff] + 1.96 * _se[i_diff]	
	replace cihigh_ip = `cihigh'
	outreg2 using "temp/tables/s_ip_3-12lag.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
}