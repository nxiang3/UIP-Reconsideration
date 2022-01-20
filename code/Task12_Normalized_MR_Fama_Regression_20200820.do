*****************************************************
*  Econ872 Task: Medium-Run Excess Returns          *
*              Equation  6, 7, 8                    *
*****************************************************
* by Nan Xiang
cd E:/Econ872_Paper/analysis
use input/data_updated_200617,clear

replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
gen s_year = f12.s_fama // exchange rate 12 month ahead t+12
gen s_yoy = s_year - s_fama // s_t+12 - s_t
//sum of interest differential into 11 periods ahead 
forval i = 1(1)11{
    gen i_diff_forward`i' = f`i'.i_diff
}
egen i_sum = rowtotal(i_diff_forward*)
replace i_sum = i_sum + i_diff
//inflation
gen p_r = cpi_usa - cpi
gen p_r_lag12 = l12.p_r
gen pi_ryoy = (p_r - p_r_lag12)/12 // p_t - p_t-12 - (p_t* - p_t-12*)
gen norm_idiff = i_diff - pi_ryoy

forval i = 1(1)11{
    drop if i_diff_forward`i'==.
}
keep country2 cty2 date year month q s_yoy i_sum i_diff_forward* i_diff pi_ryoy norm_idiff

//whole sample
drop if country2 == "AUD" | country2 == "NZD"
drop if i_diff ==.
drop if norm_idiff ==.
gen mr_ex_re = s_yoy - i_sum

bys cty2: reg mr_ex_re norm_idiff, r
//common ending date
preserve 
keep if year > 1988
keep if year < 2018
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re norm_idiff, r
restore

//pre-crisis
preserve 
keep if year < 2007
keep if year > 1988
bys cty2: reg mr_ex_re norm_idiff, r
restore

//post-crisis
preserve 
keep if year < 2018
keep if year > 2006
drop if year == 2017 & month == 12 
bys cty2: reg mr_ex_re norm_idiff, r
restore

