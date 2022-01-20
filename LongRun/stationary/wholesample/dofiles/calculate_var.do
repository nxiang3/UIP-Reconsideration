clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/stationary/wholesample

**** whole sample 

** CAD
use temp/VAR_CAD_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_CAD.dta, replace

** CHF
use temp/VAR_CHF_correction_stationary.dta, clear

egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_CHF.dta, replace

** DEM
use temp/VAR_DEM_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_DEM.dta, replace

** FRF
use temp/VAR_FRF_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_FRF.dta, replace

** GBP
use temp/VAR_GBP_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_GBP.dta, replace

** ITL
use temp/VAR_ITL_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_ITL.dta, replace

** JPY
use temp/VAR_JPY_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_JPY.dta, replace

** NOK
use temp/VAR_NOK_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_NOK.dta, replace

** SEK
use temp/VAR_SEK_correction_stationary.dta, clear
egen sd_t = sd(s_T)
gen var_t = sd_t * sd_t
egen sd_ip = sd(s_IP)
gen var_ip = sd_ip * sd_ip
sum s_T
gen n_t = r(N) 
sum s_IP
gen n_ip = r(N)
keep cty2 country2 var_t var_ip n_t n_ip 
keep if _n == 1
save temp/variance_SEK.dta, replace

use temp/variance_CAD.dta, clear
append using temp/variance_CHF.dta
append using temp/variance_DEM.dta
append using temp/variance_FRF.dta
append using temp/variance_GBP.dta
append using temp/variance_ITL.dta
append using temp/variance_JPY.dta
append using temp/variance_NOK.dta
append using temp/variance_SEK.dta
gen F = var_t/var_ip
save temp/variance.dta, replace
export excel using tables/variance.xlsx, replace firstrow(variables)
