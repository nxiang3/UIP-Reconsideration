clear
clear matrix
set more off
mata: mata set matafavor speed, perm
set matsize 1000

*** ECON872 task 04/27/20 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task210108/stationary/wholesample

** CAD
use temp/VAR_CAD_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", replace dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", replace dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", replace dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", replace dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** CHF
use temp/VAR_CHF_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** DEM
use temp/VAR_DEM_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** FRF
use temp/VAR_FRF_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** GBP
use temp/VAR_GBP_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


** ITL
use temp/VAR_ITL_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** JPY
use temp/VAR_JPY_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


** NOK
use temp/VAR_NOK_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

** SEK
use temp/VAR_SEK_correction_stationary, clear
replace pi_r_yoy = pi_r_yoy * 12
gen pi_r_yoy_shock = d.pi_r_yoy

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

gen p_t = .
label variable p_t "p-value of transitory component"
gen p_ip = .
label variable p_ip "p-value of UIP measure"
gen p_diff = .
label variable p_diff "p-value of of difference"
gen p_shock = .
label variable p_shock "p-value of difference shock"

//Regression
newey s_T pi_r_yoy, lag(3)
local coef_t = _b[pi_r_yoy]
replace coef_t = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_t = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_t = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_t = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_t')/`se'))
replace p_t = `p_val'
outreg2 using "tables/s_t_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

newey s_IP pi_r_yoy, lag(3) 
local coef_ip = _b[pi_r_yoy]
replace coef_ip = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_ip = `tstat'
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_ip = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_ip = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_ip')/`se'))
replace p_ip = `p_val'
outreg2 using "tables/s_ip_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')

gen coef_diff = .
label variable coef_diff "Estimated coefficient "
gen tstat_diff = .
label variable tstat_diff "t-statistics"
gen cilow_diff = .
label variable cilow_diff "Lower bound of 95% CI, s_T-s_IP"
gen cihigh_diff = .
label variable cihigh_diff "Upper bound of 95% CI, s_T-s_IP"

//Regression
newey s_diff pi_r_yoy, lag(3)
local coef_diff = _b[pi_r_yoy] 
replace coef_diff = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_diff = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_diff = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_diff = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_diff')/`se'))
replace p_diff = `p_val'
outreg2 using "tables/s_diff_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')


gen coef_shock = .
label variable coef_shock "Estimated coefficient "
gen tstat_shock = .
label variable tstat_shock "t-statistics"
gen cilow_shock = .
label variable cilow_shock "Lower bound of 95% CI, s_T-s_IP shock"
gen cihigh_shock = .
label variable cihigh_shock "Upper bound of 95% CI, s_T-s_IP shock"

//Regression
newey s_diff_shock pi_r_yoy_shock,lag(3)
local coef_shock = _b[pi_r_yoy] 
replace coef_shock = _b[pi_r_yoy] 
local se = _se[pi_r_yoy]
local tstat = _b[pi_r_yoy]/_se[pi_r_yoy]
replace tstat_shock = `tstat' 
local cilow = _b[pi_r_yoy] - 1.96 * _se[pi_r_yoy]
replace cilow_shock = `cilow' 
local cihigh = _b[pi_r_yoy] + 1.96 * _se[pi_r_yoy]	
replace cihigh_shock = `cihigh'
local p_val = 2*ttail(e(df_r), abs((`coef_shock')/`se'))
replace p_shock = `p_val'
outreg2 using "tables/s_diff_shock_pi.xls", append dec(3) noaster stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh', p-val, `p_val')
