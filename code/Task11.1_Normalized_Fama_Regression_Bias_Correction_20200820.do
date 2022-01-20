************************************************
*         Bias Correction for Fama Reg         *
*            By: Nan Xiang                     *
************************************************

cd "E:\Econ872_Paper\analysis"
use input/data_updated_200617,clear
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
* pi_t = p_t - p_(t-1)
gen s_growth = d.s_fama
gen pi = d.cpi
gen pi_dollar = d.cpi_usa 
gen pi_r = pi_dollar - pi
* qt = s_t-pr_t
gen p_r = cpi_usa - cpi
forval i = 1(1)12{
    gen p_r_lag`i' = l`i'.p_r
}
gen pi_ryoy = (p_r - p_r_lag12) / 12	
drop if i_diff ==. | pi_ryoy ==. | s_growth ==.
gen norm_idiff = i_diff - pi_ryoy
gen exre = s_growth - i_diff
//////////////////////////////////////////////

*********89 - 2017/11***************
keep if year > 1988
drop if year > 2017
drop if year == 2017 & month == 12
************************************

********89 - 06/12******************
keep if year < 2007 & year > 1988
************************************


********07 - 17/11******************
keep if year > 20016
drop if year > 2017
drop if year == 2017 & month == 12
************************************
//////////////////////////////////////////////

bys cty2: gen num = _N
xtset cty2 t
gen i_lag = l.norm_idiff

reg norm_idiff i_lag if country2 == "CAD", r
gen var_rho = _se[i_lag]^2 if country2 == "CAD"
* Step 1: construct corrected residuals
gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if country2 == "CAD"
gen theta_c = _b[_cons] if country2 == "CAD"
gen v_c = norm_idiff - rho_c*i_lag - theta_c if country2 == "CAD"
replace v_c = f.v_c if country2 == "CAD"
* Step 2: estimate fama coefficient
reg exre norm_idiff v_c if country2 == "CAD" ,r
gen beta_c = _b[norm_idiff] if country2 == "CAD"
gen phi_c = _b[v_c] if country2 == "CAD"
* Step 3: SE correction
gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if country2 == "CAD"
gen var_beta_c = _se[norm_idiff]^2 if country2 == "CAD"
gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if country2 == "CAD"
gen low = beta_c - 1.96*se_beta_c_corrected if country2 == "CAD"
gen high = beta_c + 1.96*se_beta_c_corrected if country2 == "CAD"
//whole sample
foreach country in CHF DEM FRF GBP ITL JPY NOK SEK{
	reg norm_idiff i_lag if country2 == "`country'", r
	replace var_rho = _se[i_lag]^2 if country2 == "`country'"
	* Step 1: construct corrected residuals
	replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if country2 == "`country'"
	replace theta_c = _b[_cons] if country2 == "`country'"
	replace v_c = norm_idiff - rho_c*i_lag - theta_c if country2 == "`country'"
	replace v_c = f.v_c if country2 == "`country'"
	* Step 2: estimate fama coefficient
	reg exre norm_idiff v_c if country2 == "`country'",r
	replace beta_c = _b[norm_idiff] if country2 == "`country'"
	replace phi_c = _b[v_c] if country2 == "`country'"
	* Step 3: SE correction
	replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if country2 == "`country'"
	replace var_beta_c = _se[norm_idiff]^2 if country2 == "`country'"
	replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if country2 == "`country'"
	replace low = beta_c - 1.96*se_beta_c_corrected if country2 == "`country'"
    replace high = beta_c + 1.96*se_beta_c_corrected if country2 == "`country'"
}
keep country2 beta_c se_beta_c_corrected low high
drop if beta_c ==.
duplicates drop
