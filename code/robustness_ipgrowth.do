************************************************
*    Bias Correction for Fama with Inflation   *
*            By: Nan Xiang                     *
************************************************

* IMPORT INDUSTRIAL PRODUCTION INDEX
import delimited $raw/Industrial_Production.csv, clear
keep time value country 
duplicates drop 
replace country = "CAD" if country == "Canada"
replace country = "FRF" if country == "France"
replace country = "DEM" if country == "Germany"
replace country = "ITL" if country == "Italy"
replace country = "JPY" if country == "Japan"
replace country = "NOK" if country == "Norway"
replace country = "SEK" if country == "Sweden"
replace country = "GBP" if country == "United Kingdom"
replace country = "USD" if country == "United States"
rename (country value) (country2 IP)
gen year = substr(time, 1, 4)
gen month = substr(time, -2, 2) 
destring year month, replace

drop time
egen cty2 = group(country2)
sort cty2 year month
bys cty2: gen t = _n
xtset cty2 t

// BUSINESS CYCLE COMPONENT
gen lIP = log(IP)
gen lIP_l24 = l24.lIP
gen lIP_growth = s12.lIP
forval i=1/11{
	gen lIP_lag`i' = l`i'.lIP_l24
}

gen yhat =.
forval i=1/9{
	reg lIP lIP_l24 lIP_lag* if cty2 == `i',r
	predict yhat_temp
	replace yhat = yhat_temp if cty2 == `i'
	drop yhat_temp
}
gen gap = lIP - yhat
keep country2 year month lIP lIP_growth gap
sort country2 year month

save "$inter/production_index.dta",replace

keep if country2 == "USD"
rename (country2 lIP gap lIP_growth) (country1 lIP_us gap_us lIP_growth_us)
save "$inter/production_index_us.dta", replace
 
foreach x of global date{
	
	use "$data/data_updated_201009",clear
	sort country2 year month
	merge 1:1 country2 year month using $inter/production_index
	drop if _merge == 2
	drop _merge
	merge m:1 country1 year month using $inter/production_index_us
	drop if _merge ==2 
	drop _merge
	xtset cty2 t
	// YEAR ON YEAR IP GROWTH
	gen ip_growth_relative = lIP_growth_us - lIP_growth
	gen ip_growth_relative_lag = l.ip_growth_relative
	gen lIP_growth_us_lag = l.lIP_growth_us
	
	// BUSINESS CYCLE RELATIVE
	gen gap_relative = gap_us - gap
	
	// INFLATION
	gen p_r = log(cpi_usa) - log(cpi)
	gen p_r_diff= s12.p_r
	gen srex = s_change - i_diff
	drop if p_r_diff==.
	drop if s_change ==. | i_diff ==.
	
	label var s "Dollar Price of Foreign Currency"

	if "`x'" == "v2"{
		qui: keep if year >= 1987
		di "1987/01-2020/09"
	}
	if "`x'" == "v3"{
		qui: keep if year >= 1987 & year <2007
		di "1989/01-2006/12"
	}
	if "`x'" == "v4"{
		qui: keep if year >= 2007
		di "2007/01-2020/09"
	}
	keep if inlist(country2, "CAD", "DEM", "FRF", "GBP", "ITL", "JPY", "NOK", "SEK")
	drop cty2 
	egen cty2 = group(country2)
	

	* REGRESSION RESULT
	forval i = 1/8{
		eststo relative`i': reg srex i_diff p_r_diff ip_growth_relative gap_relative if cty2 == `i', r
	}
	
	esttab relative* using "$results/relative_PI_growth_`x'.csv", star(* 0.1 ** 0.05 *** 0.01) nonotes b(%9.2f) ///
    s(N r2, label("Observations" "R-Squared") ///
	fmt(%9.0fc %9.2fc %9.0fc)) se replace  compress substitute(/_ _) nodepvars
	
	forval i = 1/8{
		eststo us`i': reg srex i_diff p_r_diff lIP_growth_us gap_us if cty2 == `i', r
	}
	
	esttab us* using "$results/us_PI_growth_`x'.csv", star(* 0.1 ** 0.05 *** 0.01) nonotes b(%9.2f) ///
    s(N r2, label("Observations" "R-Squared") ///
	fmt(%9.0fc %9.2fc %9.0fc)) se replace  compress substitute(/_ _) nodepvars

}	


