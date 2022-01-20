clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/stationary/87_20

log using estimate_stationary_87_20, replace

use rawdata/data_updated_201009.dta,clear

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

gen p_r_1 = l.p_r
gen p_r_2 = l2.p_r
gen p_r_3 = l3.p_r
gen p_r_4 = l4.p_r
gen p_r_5 = l5.p_r
gen p_r_6 = l6.p_r
gen p_r_7 = l7.p_r
gen p_r_8 = l8.p_r
gen p_r_9 = l9.p_r
gen p_r_10 = l10.p_r
gen p_r_11 = l11.p_r

gen s_T_extra = p_r - (p_r + p_r_1 + p_r_2 + p_r_3 + p_r_4 + p_r_5 + p_r_6 + p_r_7 + p_r_8 + p_r_9 + p_r_10 + p_r_11)/12

keep if year >= 1987

keep country2 cty2 date year month t q s_fama i_diff p_r pi_r_yoy s_T_extra
save data/data_var_estimate_87_20.dta, replace


	** 2 "CAD" 
		* data available: 06/1979 (t=1) - 11/2017 (t=462)

		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "CAD"
		
		save temp/VAR_CAD_87_20.dta, replace

	** 3 "CHF" 
		* data available: 01/1989 (t=116) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "CHF"
		
		save temp/VAR_CHF_87_20.dta, replace

	** 4 "DEM" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "DEM"
		
		save temp/VAR_DEM_87_20.dta, replace
	
	** 5 "FRF" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "FRF"
		
		save temp/VAR_FRF_87_20.dta, replace

	** 6 "GBP" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "GBP"
		
		save temp/VAR_GBP_87_20.dta, replace
		
	** 7 "ITL"
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "ITL"
		
		save temp/VAR_ITL_87_20.dta, replace
	
	** 8 "JPY" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "JPY"
		
		save temp/VAR_JPY_87_20.dta, replace
	
	** 9 "NOK" 
		* data available: 01/1986 (t=80) - 11/2017 (t=462)
		
		use data/data_var_estimate_87_20.dta, clear		
		keep if country2 == "NOK"
		
		save temp/VAR_NOK_87_20.dta, replace
		
		
	** 11 "SEK"
		* data available: 01/1987 (t=92) - 11/2017 (t=462)
		
		use data/data_var_estimate_87_20.dta, clear
		keep if country2 == "SEK"
		
		save temp/VAR_SEK_87_20.dta, replace


******************************************************************
* VAR 
******************************************************************
* CAD
clear matrix
use temp/VAR_CAD_87_20.dta, clear
sort year month
replace t = _n
xtset cty2 t

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_CAD_est_87_20.dta, replace

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
use temp/VAR_CHF_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_CHF_est_87_20.dta, replace

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
use temp/VAR_DEM_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_DEM_est_87_20.dta, replace

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
use temp/VAR_FRF_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_FRF_est_87_20.dta, replace


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
use temp/VAR_GBP_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_GBP_est_87_20.dta, replace


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
use temp/VAR_ITL_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_ITL_est_87_20.dta, replace

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
use temp/VAR_JPY_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_JPY_est_87_20.dta, replace


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
use temp/VAR_NOK_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_NOK_est_87_20.dta, replace


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
use temp/VAR_SEK_87_20.dta, clear

** Initial VARs
quietly var q pi_r_yoy i_diff, lags(1/3)
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
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
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
	quietly sum q if cty2 == `i'
	local q_mean = r(mean)
	quietly replace q_dev = q - `q_mean' if cty2 == `i'
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

save temp/VAR_SEK_est_87_20.dta, replace


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
