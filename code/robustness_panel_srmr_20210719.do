*********************************************
*  Revision: Panel regression
*********************************************


* Short run panel regression
** interest rate as regressor

use "$data/data_updated_201009",clear
foreach x of global date{
	
	* drop Australia, New Zealand, Italy, and France
	
	drop if country2 == "AUD" || country2 == "NZD" || country2 == "ITL" || country2 == "FRF"
	
	if "`x'" == "v1"{
		continue
	}
	if "`x'" == "v2"{
		preserve
		qui: keep if year >= 1987
		local v "1987/01-2020/09"
		xtset cty2 t
	
		gen Obs = _N
		reg s_change i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_sr_`x', replace
		restore
	}
	if "`x'" == "v3"{
		preserve
		qui: keep if year >= 1987 & year <2007
		local v "1987/01-2006/12"
		xtset cty2 t
	
		gen Obs = _N
		reg s_change i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_sr_`x', replace
		restore
	}
	if "`x'" == "v4"{
		preserve
		qui: keep if year >= 2007
		local v "2007/01-2020/09"
		xtset cty2 t
	
		gen Obs = _N
		reg s_change i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_sr_`x', replace
		restore
	}
	
	
}



** inflation as regressor
use "$data/data_updated_201009",clear

gen p_r = log(cpi_usa) - log(cpi)
xtset cty2 t
gen pr_lag = l12.p_r
gen p_r_diff = (p_r - pr_lag)
gen p_diff_lag = l.p_r_diff
drop if p_r_diff==.
drop if s_change ==. | i_diff ==.

gen srex = s_change - i_diff

foreach x of global date{
	
	* drop Australia, New Zealand, Italy, and France
	
	drop if country2 == "AUD" || country2 == "NZD" || country2 == "ITL" || country2 == "FRF"
	xtset cty2 t
	
	if "`x'" == "v1"{
		continue
	}
	if "`x'" == "v2"{
		preserve
		qui: keep if year >= 1987
		local v "1987/01-2020/09"
		gen Obs = _N
		reg srex p_r_diff i.cty i.t, cluster(cty2)
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_sr_`x', replace
		restore
	}
	if "`x'" == "v3"{
		preserve
		qui: keep if year >= 1987 & year <2007
		local v "1987/01-2006/12"
		gen Obs = _N
		reg srex p_r_diff i.cty i.t, cluster(cty2)
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_sr_`x', replace
		restore
	}
	if "`x'" == "v4"{
		preserve
		qui: keep if year >= 2007
		local v "2007/01-2020/09"
		gen Obs = _N
		xtscc srex p_r_diff i.t,fe
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_sr_`x', replace
		restore
	}
}

* Medium Run

** Interest rate
use "$data/data_updated_201009",clear
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
g s_year = f12.s_fama // exchange rate 12 month ahead t+12
g s_yoy = s_year - s_fama // s_t+12 - s_t
//sum of interest differential into 11 periods ahead 
forval i = 1(1)11{
    g i_diff_forward`i' = f`i'.i_diff
}
egen i_sum = rowtotal(i_diff_forward*)
//inflation
g p_r = cpi_usa - cpi
g p_r_lag12 = l12.p_r
g p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)

drop if i_diff ==.
* Medium Run Excess Return (1y)
g mr_ex_re = s_yoy - i_sum

foreach x of global date{
	
	* drop Australia, New Zealand, Italy, and France
	
	drop if country2 == "AUD" || country2 == "NZD" || country2 == "ITL" || country2 == "FRF"
	
	if "`x'" == "v1"{
		continue
	}
	if "`x'" == "v2"{
		preserve
		qui: keep if year >= 1987
		local v "1987/01-2020/09"
		xtset cty2 t
	
		gen Obs = _N
		reg mr_ex_re i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_mr_`x', replace
		restore
	}
	if "`x'" == "v3"{
		preserve
		qui: keep if year >= 1987 & year <2007
		local v "1987/01-2006/12"
		xtset cty2 t
	
		gen Obs = _N
		reg mr_ex_re i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_mr_`x', replace
		restore
	}
	if "`x'" == "v4"{
		preserve
		qui: keep if year >= 2007
		local v "2007/01-2020/09"
		xtset cty2 t
	
		gen Obs = _N
		reg mr_ex_re i_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen b_se = _se[i_diff]
		gen high = b + 1.96*b_se
		gen low = b - 1.96*b_se
		gen P_value = 2*ttail(e(df_r), abs((b-1)/b_se))
		keep b high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b Obs CI P_value
		order Time b Obs CI P_value
		format b P_value %9.3f
		rename b Coef
		save $results/panel_fama_mr_`x', replace
		restore
	}
}


** Inflation
use "$data/data_updated_201009",clear
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
g s_year = f12.s_fama // exchange rate 12 month ahead t+12
g s_yoy = s_year - s_fama // s_t+12 - s_t
//sum of interest differential into 11 periods ahead 
forval i = 1(1)11{
    g i_diff_forward`i' = f`i'.i_diff
}
egen i_sum = rowtotal(i_diff_forward*)
//inflation
g p_r = cpi_usa - cpi
g p_r_lag12 = l12.p_r
g p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)

drop if i_diff ==.
* Medium Run Excess Return (1y)
g mr_ex_re = s_yoy - i_sum

foreach x of global date{
	
	* drop Australia, New Zealand, Italy, and France
	
	drop if country2 == "AUD" || country2 == "NZD" || country2 == "ITL" || country2 == "FRF"
	xtset cty2 t
	
	if "`x'" == "v1"{
		continue
	}
	if "`x'" == "v2"{
		preserve
		qui: keep if year >= 1987
		local v "1987/01-2020/09"
		gen Obs = _N
		reg mr_ex_re p_r_diff i.cty i.t, cluster(cty2)
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_mr_`x', replace
		restore
	}
	if "`x'" == "v3"{
		preserve
		qui: keep if year >= 1987 & year <2007
		local v "1987/01-2006/12"
		gen Obs = _N
		reg mr_ex_re p_r_diff i.cty i.t, cluster(cty2)
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_mr_`x', replace
		restore
	}
	if "`x'" == "v4"{
		preserve
		qui: keep if year >= 2007
		local v "2007/01-2020/09"
		gen Obs = _N
		reg mr_ex_re p_r_diff i.cty i.t, cluster(cty2)
		gen d = _b[p_r_diff]
		gen d_se = _se[p_r_diff]
		gen high = d + 1.96*d_se
		gen low = d - 1.96*d_se
		gen P_value = 2*ttail(e(df_r), abs((d)/d_se))
		keep d high low Obs P_value
		duplicates drop 
		
		gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time d Obs CI P_value
		order Time d Obs CI P_value
		format d P_value %9.3f
		rename d Coef
		save $results/panel_famaInflation_mr_`x', replace
		restore
	}
}

** Interest rate and Inflation
use "$data/data_updated_201009",clear
replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t

//inflation
g p_r = cpi_usa - cpi
g p_r_lag12 = l12.p_r
g p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)

drop if i_diff ==.
* Medium Run Excess Return (1y)
gen srex = s_change - i_diff

foreach x of global date{
	
	* drop Australia, New Zealand, Italy, and France
	
	drop if country2 == "AUD" || country2 == "NZD" || country2 == "ITL" || country2 == "FRF"
	xtset cty2 t
	
	if "`x'" == "v1"{
		continue
	}
	if "`x'" == "v2"{
		preserve
		qui: keep if year >= 1987
		local v "1987/01-2020/09"
		gen Obs = _N
		reg srex i_diff p_r_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen d = _b[p_r_diff]
		gen b_se = _se[i_diff]
		gen d_se = _se[p_r_diff]
		gen high_b = b + 1.96*b_se
		gen low_b = b - 1.96*b_se
		gen high_d = d + 1.96*d_se
		gen low_d = d - 1.96*d_se
		gen P_value1 = 2*ttail(e(df_r), abs((b)/b_se))
		gen P_value2 = 2*ttail(e(df_r), abs((d)/d_se))
		keep d b high* low* Obs P_value*
		duplicates drop 
		
		gen CI1 = "(" + string(low_b,"%9.3f")  + "," + string(high_b, "%9.3f") + ")"
		gen CI2 = "(" + string(low_d,"%9.3f")  + "," + string(high_d, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b d Obs CI* P_value*
		order Time Obs b CI1 P_value1 d CI2 P_value2
		format b d P_value1 P_value2 %9.3f
		rename b Coef1
		rename d Coef2
		save $results/panel_famaMultivar_`x', replace
		restore
	}
	if "`x'" == "v3"{
		preserve
		qui: keep if year >= 1987 & year <2007
		local v "1987/01-2006/12"
		gen Obs = _N
		reg srex i_diff p_r_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen d = _b[p_r_diff]
		gen b_se = _se[i_diff]
		gen d_se = _se[p_r_diff]
		gen high_b = b + 1.96*b_se
		gen low_b = b - 1.96*b_se
		gen high_d = d + 1.96*d_se
		gen low_d = d - 1.96*d_se
		gen P_value1 = 2*ttail(e(df_r), abs((b)/b_se))
		gen P_value2 = 2*ttail(e(df_r), abs((d)/d_se))
		keep d b high* low* Obs P_value*
		duplicates drop 
		
		gen CI1 = "(" + string(low_b,"%9.3f")  + "," + string(high_b, "%9.3f") + ")"
		gen CI2 = "(" + string(low_d,"%9.3f")  + "," + string(high_d, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b d Obs CI* P_value*
		order Time Obs b CI1 P_value1 d CI2 P_value2
		format b d P_value1 P_value2 %9.3f
		rename b Coef1
		rename d Coef2
		save $results/panel_famaMultivar_`x', replace
		restore
	}
	if "`x'" == "v4"{
		preserve
		qui: keep if year >= 2007
		local v "2007/01-2020/09"
		gen Obs = _N
		reg srex i_diff p_r_diff i.cty i.t, cluster(cty2)
		gen b = _b[i_diff]
		gen d = _b[p_r_diff]
		gen b_se = _se[i_diff]
		gen d_se = _se[p_r_diff]
		gen high_b = b + 1.96*b_se
		gen low_b = b - 1.96*b_se
		gen high_d = d + 1.96*d_se
		gen low_d = d - 1.96*d_se
		gen P_value1 = 2*ttail(e(df_r), abs((b)/b_se))
		gen P_value2 = 2*ttail(e(df_r), abs((d)/d_se))
		keep d b high* low* Obs P_value*
		duplicates drop 
		
		gen CI1 = "(" + string(low_b,"%9.3f")  + "," + string(high_b, "%9.3f") + ")"
		gen CI2 = "(" + string(low_d,"%9.3f")  + "," + string(high_d, "%9.3f") + ")"
		gen Time = "`v'"
		keep Time b d Obs CI* P_value*
		order Time Obs b CI1 P_value1 d CI2 P_value2
		format b d P_value1 P_value2 %9.3f
		rename b Coef1
		rename d Coef2
		save $results/panel_famaMultivar_`x', replace
		restore
	}
}
