clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/nonstationary/wholesample

log using estimate_nonstationary, replace

use rawdata/data_updated_201009,clear

replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
* pi_t = p_t - p_(t-1)
//gen pi = d.cpi
//gen pi_dollar = d.cpi_usa 
//gen pi_r = pi_dollar - pi
* qt = s_t-pr_t
gen p_r = cpi_usa - cpi
gen q = s_fama - p_r	
gen p_r_12 = l12.p_r
gen pi_r_yoy = (p_r - p_r_12)/12

keep country2 cty2 date year month t s_change_lag i_diff p_r pi_r_yoy
save data/data_var_estimate.dta, replace


	** 2 "CAD" 
		* data available: 06/1979 (t=1) - 11/2017 (t=462)

		use data/data_var_estimate.dta, clear
		keep if country2 == "CAD"
		
		save temp/VAR_CAD.dta, replace

	** 3 "CHF" 
		* data available: 01/1989 (t=116) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "CHF"
		
		save temp/VAR_CHF.dta, replace

	** 4 "DEM" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "DEM"
		
		save temp/VAR_DEM.dta, replace
	
	** 5 "FRF" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "FRF"
		
		save temp/VAR_FRF.dta, replace

	** 6 "GBP" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "GBP"
		
		save temp/VAR_GBP.dta, replace
		
	** 7 "ITL"
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "ITL"
		
		save temp/VAR_ITL.dta, replace
	
	** 8 "JPY" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "JPY"
		
		save temp/VAR_JPY.dta, replace
	
	** 9 "NOK" 
		* data available: 01/1986 (t=80) - 11/2017 (t=462)
		
		use data/data_var_estimate.dta, clear		
		keep if country2 == "NOK"
		
		save temp/VAR_NOK.dta, replace
		
	** 11 "SEK"
		* data available: 01/1987 (t=92) - 11/2017 (t=462)
		
		use data/data_var_estimate.dta, clear
		keep if country2 == "SEK"
		
		save temp/VAR_SEK.dta, replace


******************************************************************
* VAR 
******************************************************************
* CAD
clear matrix
use temp/VAR_CAD.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_CAD_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_CAD.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_CAD.txt", novarnames replace

file open outdat using matrix/T_CAD.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* CHF
clear matrix
use temp/VAR_CHF.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_CHF_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_CHF.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_CHF.txt", novarnames replace

file open outdat using matrix/T_CHF.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* DEM
clear matrix
use temp/VAR_DEM.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_DEM_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_DEM.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_DEM.txt", novarnames replace

file open outdat using matrix/T_DEM.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* FRF
clear matrix
use temp/VAR_FRF.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_FRF_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_FRF.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_FRF.txt", novarnames replace

file open outdat using matrix/T_FRF.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* GBP
clear matrix
use temp/VAR_GBP.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_GBP_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_GBP.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_GBP.txt", novarnames replace

file open outdat using matrix/T_GBP.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* ITL
clear matrix
use temp/VAR_ITL.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_ITL_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_ITL.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_ITL.txt", novarnames replace

file open outdat using matrix/T_ITL.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* JPY
clear matrix
use temp/VAR_JPY.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_JPY_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_JPY.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_JPY.txt", novarnames replace

file open outdat using matrix/T_JPY.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* NOK
clear matrix
use temp/VAR_NOK.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_NOK_est.dta, replace


clear
svmat B_hat1
export delimited using "matrix/B_NOK.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_NOK.txt", novarnames replace

file open outdat using matrix/T_NOK.txt, write replace
file write outdat (T)
file close outdat

******************************************************************
* VAR 
******************************************************************
* SEK
clear matrix
use temp/VAR_SEK.dta, clear

** Initial VARs
quietly var s_change_lag pi_r_yoy i_diff, lags(1/3)
scalar T = e(N)

matrix B = e(b)

matrix V = e(Sigma)

matrix B0_hat = [B[1,10] \ B[1, 20] \ B[1, 30]]

matrix B1_hat = [B[1, 1], B[1, 4], B[1, 7] \ B[1, 11], B[1, 14], B[1, 17] \ B[1, 21], B[1, 24], B[1, 27]]

matrix B2_hat = [B[1, 2], B[1, 5], B[1, 8] \ B[1, 12], B[1, 15], B[1, 18] \ B[1, 22], B[1, 25], B[1, 28]]

matrix B3_hat = [B[1, 3], B[1, 6], B[1, 9] \ B[1, 13], B[1, 16], B[1,19] \ B[1, 23], B[1, 26], B[1, 29]]

matrix zero = [0, 0, 0 \ 0, 0, 0 \ 0, 0, 0]

matrix Identity = I(3)

matrix B_hat1 = [B1_hat, B2_hat, B3_hat \ Identity, zero, zero \ zero, Identity, zero]
matrix e1 = [1, 0, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

** keep residuals from initial VARs
predict u1, r equation(#1)
predict u2, r equation(#2)
predict u3, r equation(#3)

drop if u1==.
drop if u2==.
drop if u3==.
drop t 
sort year month
gen t = _n

* deviation from mean of real exchange rate, relative inflation and relative interest rate
gen q_dev = .
gen q_mean = .
local i = 1
while `i' <= 11{
	quietly sum s_change_lag if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = s_change_lag - `q_mean' if cty2 == `i'
	quietly replace q_mean = `q_mean' if cty2 == `i'
	local i = `i' + 1
}

gen pi_dev = .
gen pi_mean = .
local i = 1
while `i' <= 11{
	quietly sum pi_r_yoy if cty2 == `i'
	local pi_mean = r(mean)
	quietly replace pi_dev = pi_r_yoy - `pi_mean' if cty2 == `i'
	quietly replace pi_mean = `pi_mean' if cty2 == `i'
	local i = `i' + 1
}

gen i_dev = .
gen i_mean = .
local i = 1
while `i' <= 11{
	quietly sum i_diff if cty2 == `i'
	local i_mean = r(mean)
	quietly replace i_dev = i_diff - `i_mean' if cty2 == `i'
	quietly replace i_mean = `i_mean' if cty2 == `i'
	local i = `i' + 1
}
sort cty2 t

gen q_dev_lag = l.q_dev
gen q_dev_lag2 = l2.q_dev
gen pi_dev_lag = l.pi_dev
gen pi_dev_lag2 = l2.pi_dev
gen i_dev_lag = l.i_dev
gen i_dev_lag2 = l2.i_dev

save temp/VAR_SEK_est.dta, replace

clear
svmat B_hat1
export delimited using "matrix/B_SEK.txt", novarnames replace

clear
svmat V
export delimited using "matrix/V_SEK.txt", novarnames replace

file open outdat using matrix/T_SEK.txt, write replace
file write outdat (T)
file close outdat


log close
