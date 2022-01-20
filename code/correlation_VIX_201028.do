clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201027
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

***** 10-year 
	*** append data set
	use "$raw/VIX_merge.dta", clear
	drop if VIX ==.
	gen t = _n
	
	gen VIX_mean = .
	local i = 1
	while `i' <= 250{
		local j = `i' + 119
		sum VIX if t >= `i' & t <= `j'
		local mean = r(mean)
		replace VIX_mean = `mean' if t == `i'
		local i = `i' + 1
	}	
	drop if VIX_mean ==.
	keep year month VIX_mean
	save "$inter/VIX_mean.dta", replace
	
	use "$data/fama_10_all.dta", clear
	merge m:1 year month using "$inter/VIX_mean.dta"
	keep if _merge == 3
	drop _merge
	sort country2 year month
/*
	
	gen VIX_mean = .
	local i = 128
	while `i' <= 376{
		local j = `i' + 119
		sum VIX if t >= `i' & t <= `j'
		local mean = r(mean)
		replace VIX_mean = `mean' if t == `i'
		local i = `i' + 1
	}	
*/
		
	*** Correlation coefficients calculation
		gen corr_vix_cty = .
		
	** By country
		correlate coef VIX_mean if country2 == "AUD" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "AUD"
		
		correlate coef VIX_mean if country2 == "CAD" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "CAD"
		
		correlate coef VIX_mean if country2 == "CHF" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "CHF"
		
		correlate coef VIX_mean if country2 == "DEM" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "DEM"
		
		correlate coef VIX_mean if country2 == "FRF" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "FRF"
		
		correlate coef VIX_mean if country2 == "GBP" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "GBP"
		
		correlate coef VIX_mean if country2 == "ITL" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "ITL"
		
		correlate coef VIX_mean if country2 == "JPY" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "JPY"
		
		correlate coef VIX_mean if country2 == "NOK" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "NOK"
		
		correlate coef VIX_mean if country2 == "NZD" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "NZD"
		
		correlate coef VIX_mean if country2 == "SEK" & coef != . & VIX_mean != .
		local corrcoef = r(rho)
		replace corr_vix_cty = `corrcoef' if country2 == "SEK"
			
		duplicates drop country2, force
		keep country2 corr_vix_cty
		sort country2
		save "$results/corr_vix_10.dta", replace
		
// ****** 5-year 
	
// 	use "$data/fama_5_all.dta", clear
// 	merge m:1 year month using "$raw/VIX_merge.dta"
// 	drop _merge

// 	gen VIX_mean = .
// 	local i = 128
// 	while `i' <= 436{
// 		local j = `i' + 59
// 		sum VIX if t >= `i' & t <= `j' 
// 		local mean = r(mean)
// 		replace VIX_mean = `mean' if t == `i' 
// 		local i = `i' + 1
// 	}	
		
// 	*** Correlation coefficients calculation
// 		gen corr_vix_cty = .
		
// 	** By country
// 		correlate coef VIX_mean if country2 == "AUD" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "AUD"
		
// 		correlate coef VIX_mean if country2 == "CAD" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "CAD"
		
// 		correlate coef VIX_mean if country2 == "CHF" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "CHF"
		
// 		correlate coef VIX_mean if country2 == "DEM" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "DEM"
		
// 		correlate coef VIX_mean if country2 == "FRF" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "FRF"
		
// 		correlate coef VIX_mean if country2 == "GBP" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "GBP"
		
// 		correlate coef VIX_mean if country2 == "ITL" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "ITL"
		
// 		correlate coef VIX_mean if country2 == "JPY" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "JPY"
		
// 		correlate coef VIX_mean if country2 == "NOK" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "NOK"
		
// 		correlate coef VIX_mean if country2 == "NZD" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "NZD"
		
// 		correlate coef VIX_mean if country2 == "SEK" & coef != . & VIX_mean != .
// 		local corrcoef = r(rho)
// 		replace corr_vix_cty = `corrcoef' if country2 == "SEK"
			
// 		duplicates drop country2, force
// 		keep country2 corr_vix_cty
// 		sort country2
		
// 		save "$results/corr_vix_5.dta", replace
