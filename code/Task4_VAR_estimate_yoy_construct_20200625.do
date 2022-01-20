clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 task 2020/06/25 Permanent Exchange Rate and UIP Exchange Rate from VAR
*** by Nan Xiang
cd E:\Econ872_Paper\analysis
use input\data_updated_200617,clear

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
gen q = s_fama - p_r	
drop if i_diff ==. | q ==. | pi_ryoy ==. 

keep country2 cty2 date year month q s_fama s_growth i_diff pi_ryoy p_r*
save input/data_var_pi_ryoy.dta, replace

/*
** 1 "AUD" 
		* data available: 01/1989 (t=116) - 11/2017 (t=462)
		* AUD has gaps, not able to run VAR
		
		keep if country2 == "AUD"
		save temp/VAR_AUD.dta, replace
		
		keep if year >= 1989
		save temp/VAR_AUD_89.dta, replace
*/
	** 2 "CAD" 
		* data available: 06/1979 (t=1) - 11/2017 (t=462)

		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "CAD"
		save temp/VAR_CAD_yoy.dta, replace
		
		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_CAD_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_CAD_8906_yoy.dta, replace
		
		use temp/VAR_CAD_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_CAD_0717_yoy.dta, replace

	** 3 "CHF" 
		* data available: 01/1989 (t=116) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "CHF"
		save temp/VAR_CHF_yoy.dta, replace
		
		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_CHF_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_CHF_8906_yoy.dta, replace
		
		use temp/VAR_CHF_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_CHF_0717_yoy.dta, replace

	** 4 "DEM" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "DEM"
		save temp/VAR_DEM_yoy.dta, replace
		
		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_DEM_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_DEM_8906_yoy.dta, replace
		
		use temp/VAR_DEM_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_DEM_0717_yoy.dta, replace
		
	** 5 "FRF" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "FRF"
		save temp/VAR_FRF_yoy.dta, replace
		
		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_FRF_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_FRF_8906_yoy.dta, replace
		
		use temp/VAR_FRF_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_FRF_0717_yoy.dta, replace

	** 6 "GBP" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "GBP"
		save temp/VAR_GBP_yoy.dta, replace

		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_GBP_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_GBP_8906_yoy.dta, replace
		
		use temp/VAR_GBP_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_GBP_0717_yoy.dta, replace
		
	** 7 "ITL"
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "ITL"
		save temp/VAR_ITL_yoy.dta, replace
		
		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_ITL_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_ITL_8906_yoy.dta, replace
		
		use temp/VAR_ITL_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_ITL_0717_yoy.dta, replace
	
	** 8 "JPY" 
		* data available: 06/1979 (t=1) - 02/2020 (t=489)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "JPY"
		save temp/VAR_JPY_yoy.dta, replace

		keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_JPY_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_JPY_8906_yoy.dta, replace
		
		use temp/VAR_JPY_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_JPY_0717_yoy.dta, replace
	
	** 9 "NOK" 
		* data available: 01/1986 (t=80) - 11/2017 (t=462)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "NOK"
		save temp/VAR_NOK_yoy.dta, replace
		
	    keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_NOK_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_NOK_8906_yoy.dta, replace
		
		use temp/VAR_NOK_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_NOK_0717_yoy.dta, replace
		
/*
	** 10 "NZD" 
		* data available: 01/1999 (t=236) - 11/2017 (t=462)
		* NZD has gaps, not able to run VAR

		use input/data_var_estimate.dta, clear
		keep if country2 == "NZD"
		save temp/VAR_NZD.dta, replace

		keep if year >= 1989
		save temp/VAR_NZD_89.dta, replace
*/
		
	** 11 "SEK"
		* data available: 01/1987 (t=92) - 11/2017 (t=462)
		
		use input/data_var_pi_ryoy.dta, clear
		keep if country2 == "SEK"
		save temp/VAR_SEK_yoy.dta, replace

		 keep if year >= 1989 & year < 2018
		drop if year == 2017 & month == 12
		save temp/VAR_SEK_8917_yoy.dta, replace
		
		keep if year < 2007
		save temp/VAR_SEK_8906_yoy.dta, replace
		
		use temp/VAR_SEK_8917_yoy.dta, clear
		keep if year > 2006
		save temp/VAR_SEK_0717_yoy.dta, replace
