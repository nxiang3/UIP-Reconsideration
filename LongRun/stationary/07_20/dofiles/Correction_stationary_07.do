clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/stationary/07_20

log using correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* CAD
clear matrix
clear
import delimited "matrix/B_new_CAD.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]
	
matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_CAD_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_CAD_correction_stationary_07_20, replace


******************************************************************
* VAR 
******************************************************************
* CHF
clear matrix
clear
import delimited "matrix/B_new_CHF.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_CHF_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_CHF_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* DEM
clear matrix
clear
import delimited "matrix/B_new_DEM.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_DEM_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_DEM_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* FRF
clear matrix
clear
import delimited "matrix/B_new_FRF.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_FRF_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_FRF_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* GBP
clear matrix
clear
import delimited "matrix/B_new_GBP.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_GBP_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_GBP_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* ITL
clear matrix
clear
import delimited "matrix/B_new_ITL.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_ITL_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_ITL_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* JPY
clear matrix
clear
import delimited "matrix/B_new_JPY.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_JPY_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_JPY_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* NOK
clear matrix
clear
import delimited "matrix/B_new_NOK.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_NOK_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_NOK_correction_stationary_07_20, replace

******************************************************************
* VAR 
******************************************************************
* SEK
clear matrix
clear
import delimited "matrix/B_new_SEK.txt", encoding(ISO-8859-1)
matrix B_new = [b_new_1[1], b_new_2[1], b_new_3[1], b_new_4[1], b_new_5[1], b_new_6[1], b_new_7[1], b_new_8[1], b_new_9[1] \ ///
	b_new_1[2], b_new_2[2], b_new_3[2], b_new_4[2], b_new_5[2], b_new_6[2], b_new_7[2], b_new_8[2], b_new_9[2] \ ///
	b_new_1[3], b_new_2[3], b_new_3[3], b_new_4[3], b_new_5[3], b_new_6[3], b_new_7[3], b_new_8[3], b_new_9[3] \ ///
	b_new_1[4], b_new_2[4], b_new_3[4], b_new_4[4], b_new_5[4], b_new_6[4], b_new_7[4], b_new_8[4], b_new_9[4] \ ///
	b_new_1[5], b_new_2[5], b_new_3[5], b_new_4[5], b_new_5[5], b_new_6[5], b_new_7[5], b_new_8[5], b_new_9[5] \ ///
	b_new_1[6], b_new_2[6], b_new_3[6], b_new_4[6], b_new_5[6], b_new_6[6], b_new_7[6], b_new_8[6], b_new_9[6] \ ///
	b_new_1[7], b_new_2[7], b_new_3[7], b_new_4[7], b_new_5[7], b_new_6[7], b_new_7[7], b_new_8[7], b_new_9[7] \ ///
	b_new_1[8], b_new_2[8], b_new_3[8], b_new_4[8], b_new_5[8], b_new_6[8], b_new_7[8], b_new_8[8], b_new_9[8] \ ///
	b_new_1[9], b_new_2[9], b_new_3[9], b_new_4[9], b_new_5[9], b_new_6[9], b_new_7[9], b_new_8[9], b_new_9[9] ]

matrix e2 = [0, 1, 0, 0, 0, 0, 0, 0, 0]
matrix e3 = [0, 0, 1, 0, 0, 0, 0, 0, 0]

* Check Validility
matrix eigenvalues r c = B_new
matlist B_new
matlist r
matlist c
*** Calculation of eigenvalues
	forval j = 1(1)9{
		scalar eigen`j' = r[1, `j']^2 + c[1, `j']^2
	}

	if `=eigen1'<=1 & `=eigen2'<=1 & `=eigen3'<=1 & `=eigen4'<=1 & `=eigen5'<=1 & `=eigen6'<=1 & `=eigen7'<=1 & `=eigen8'<=1 & `=eigen9'<=1 {
		display "Valid"
	}
	else{
		display "Invalid"
	}

* Calculate s_T s_IP s_diff s_diff_shock
use temp/VAR_SEK_est_07_20.dta, clear

scalar N =_N

forval i = 1/`=N'{
	mat psi`i' = (q_dev[`i']\pi_dev[`i']\i_dev[`i']\q_dev_lag[`i']\pi_dev_lag[`i']\i_dev_lag[`i']\q_dev_lag2[`i']\pi_dev_lag2[`i']\i_dev_lag2[`i'])
}

matrix IP = -1*e3 * inv(I(9)-B_new)
matrix T = e2 * B_new * inv(I(9)-B_new)
gen s_T =.
gen s_IP =.

forval i = 1/`=N'{
	matrix temp1 = IP*psi`i'
	matrix temp2 = T*psi`i'
	quietly replace s_IP = temp1[1,1] if t == `i'
	quietly replace s_T = q_dev - temp2[1,1] + s_T_extra if t == `i'
}
gen s_diff = s_T - s_IP

xtset cty2 t
gen s_diff_shock = d.s_diff
gen i_diff_shock = d.i_diff

save temp/VAR_SEK_correction_stationary_07_20, replace

log close
