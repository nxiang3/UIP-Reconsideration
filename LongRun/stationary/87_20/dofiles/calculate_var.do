clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/stationary/87_20

**** 1989 - 2017

** CAD
use temp/VAR_CAD_correction_stationary_87_20.dta, clear
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
save temp/variance_CAD_87_20.dta, replace

** CHF
use temp/VAR_CHF_correction_stationary_87_20.dta, clear
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
save temp/variance_CHF_87_20.dta, replace

** DEM
use temp/VAR_DEM_correction_stationary_87_20.dta, clear
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
save temp/variance_DEM_87_20.dta, replace

** FRF
use temp/VAR_FRF_correction_stationary_87_20.dta, clear
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
save temp/variance_FRF_87_20.dta, replace

** GBP
use temp/VAR_GBP_correction_stationary_87_20.dta, clear
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
save temp/variance_GBP_87_20.dta, replace

** ITL
use temp/VAR_ITL_correction_stationary_87_20.dta, clear
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
save temp/variance_ITL_87_20.dta, replace

** JPY
use temp/VAR_JPY_correction_stationary_87_20.dta, clear
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
save temp/variance_JPY_87_20.dta, replace

** NOK
use temp/VAR_NOK_correction_stationary_87_20.dta, clear
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
save temp/variance_NOK_87_20.dta, replace

** SEK
use temp/VAR_SEK_correction_stationary_87_20.dta, clear
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
save temp/variance_SEK_87_20.dta, replace

use temp/variance_CAD_87_20.dta, clear
append using temp/variance_CHF_87_20.dta
append using temp/variance_DEM_87_20.dta
append using temp/variance_FRF_87_20.dta
append using temp/variance_GBP_87_20.dta
append using temp/variance_ITL_87_20.dta
append using temp/variance_JPY_87_20.dta
append using temp/variance_NOK_87_20.dta
append using temp/variance_SEK_87_20.dta
gen F = var_t/var_ip
save temp/variance_87_20.dta, replace
export excel using tables/variance_87_20.xlsx, replace firstrow(variables)
