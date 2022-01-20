clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** by Mengqi Wang

version 14.0
//cd /Users/wangmengqi/Desktop/UW/Courses/Econ872/Secondpart/task201027
	** Under this folder, I have 6 folders with names "rawdata", "data", "figures", "tables", "dofiles", and "results".

*** Data import

	*** append data set
	use "$data/fama_10_AUD.dta", clear
	append using "$data/fama_10_CAD.dta"
	append using "$data/fama_10_CHF.dta"
	append using "$data/fama_10_DEM.dta"
	append using "$data/fama_10_FRF.dta"
	append using "$data/fama_10_GBP.dta"
	append using "$data/fama_10_ITL.dta"
	append using "$data/fama_10_JPY.dta"
	append using "$data/fama_10_NOK.dta"
	append using "$data/fama_10_NZD.dta"
	append using "$data/fama_10_SEK.dta"
	
	save "$data/fama_10_all.dta", replace

	*** Correlation coefficients calculation
	
	*** calculate correlation
	
		** variance
		gen corr_var_cty = .
		gen corr_var_all = .
		
		** By country
		correlate coef var_idiff if country2 == "AUD" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "AUD"
		
		correlate coef var_idiff if country2 == "CAD" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "CAD"
		
		correlate coef var_idiff if country2 == "CHF" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "CHF"
		
		correlate coef var_idiff if country2 == "DEM" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "DEM"
		
		correlate coef var_idiff if country2 == "FRF" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "FRF"
		
		correlate coef var_idiff if country2 == "GBP" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "GBP"
		
		correlate coef var_idiff if country2 == "ITL" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "ITL"
		
		correlate coef var_idiff if country2 == "JPY" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "JPY"
		
		correlate coef var_idiff if country2 == "NOK" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "NOK"
		
		correlate coef var_idiff if country2 == "NZD" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "NZD"
		
		correlate coef var_idiff if country2 == "SEK" & coef != .
		local corrcoef = r(rho)
		replace corr_var_cty = `corrcoef' if country2 == "SEK"
		
		** All
		gen coef_demean = .
		gen var_idiff_demean = .
		local i = 1
		while `i' <= 11{
			sum coef if cty2 == `i'
			local mean = r(mean)
			replace coef_demean = coef - `mean'
			sum var_idiff if cty2 == `i'
			local mean = r(mean)
			replace var_idiff_demean = var_idiff - `mean' if cty2 == `i'
			local i = `i' + 1
		}
		correlate coef_demean var_idiff_demean if coef != .
		local corrcoef = r(rho)
		replace corr_var_all = `corrcoef'
		
		** sd
		gen corr_sd_cty = .
		gen corr_sd_all = .
		
		** By country
		correlate coef sd_idiff if country2 == "AUD" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "AUD"
		
		correlate coef sd_idiff if country2 == "CAD" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "CAD"
		
		correlate coef sd_idiff if country2 == "CHF" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "CHF"
		
		correlate coef sd_idiff if country2 == "DEM" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "DEM"
		
		correlate coef sd_idiff if country2 == "FRF" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "FRF"
		
		correlate coef sd_idiff if country2 == "GBP" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "GBP"
		
		correlate coef sd_idiff if country2 == "ITL" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "ITL"
		
		correlate coef sd_idiff if country2 == "JPY" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "JPY"
		
		correlate coef sd_idiff if country2 == "NOK" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "NOK"
		
		correlate coef sd_idiff if country2 == "NZD" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "NZD"
		
		correlate coef sd_idiff if country2 == "SEK" & coef != .
		local corrcoef = r(rho)
		replace corr_sd_cty = `corrcoef' if country2 == "SEK"
		
		** All
		gen sd_idiff_demean = .
		local i = 1
		while `i' <= 11{
			sum sd_idiff if cty2 == `i'
			local mean = r(mean)
			replace sd_idiff_demean = sd_idiff - `mean' if cty2 == `i'
			local i = `i' + 1
		}
		correlate coef_demean sd_idiff_demean if coef != .
		local corrcoef = r(rho)
		replace corr_sd_all = `corrcoef'
				
		** 1/var
		gen corr_inv_var_cty = .
		gen corr_inv_var_all = .
		
		** By country
		correlate coef inv_var_idiff if country2 == "AUD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "AUD"
		
		correlate coef inv_var_idiff if country2 == "CAD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "CAD"
		
		correlate coef inv_var_idiff if country2 == "CHF" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "CHF"
		
		correlate coef inv_var_idiff if country2 == "DEM" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "DEM"
		
		correlate coef inv_var_idiff if country2 == "FRF" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "FRF"
		
		correlate coef inv_var_idiff if country2 == "GBP" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "GBP"
		
		correlate coef inv_var_idiff if country2 == "ITL" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "ITL"
		
		correlate coef inv_var_idiff if country2 == "JPY" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "JPY"
		
		correlate coef inv_var_idiff if country2 == "NOK" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "NOK"
		
		correlate coef inv_var_idiff if country2 == "NZD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "NZD"
		
		correlate coef inv_var_idiff if country2 == "SEK" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_var_cty = `corrcoef' if country2 == "SEK"
		
		** All
		gen inv_var_idiff_demean = .
		local i = 1
		while `i' <= 11{
			sum inv_var_idiff if cty2 == `i'
			local mean = r(mean)
			replace inv_var_idiff_demean = inv_var_idiff - `mean' if cty2 == `i'
			local i = `i' + 1
		}
		correlate coef_demean inv_var_idiff_demean if coef != .		
		local corrcoef = r(rho)
		replace corr_inv_var_all = `corrcoef'
		
		** 1/sd 
		gen corr_inv_sd_cty = .
		gen corr_inv_sd_all = .
		
		** By country
		correlate coef inv_sd_idiff if country2 == "AUD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "AUD"
		
		correlate coef inv_sd_idiff if country2 == "CAD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "CAD"
		
		correlate coef inv_sd_idiff if country2 == "CHF" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "CHF"
		
		correlate coef inv_sd_idiff if country2 == "DEM" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "DEM"
		
		correlate coef inv_sd_idiff if country2 == "FRF" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "FRF"
		
		correlate coef inv_sd_idiff if country2 == "GBP" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "GBP"
		
		correlate coef inv_sd_idiff if country2 == "ITL" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "ITL"
		
		correlate coef inv_sd_idiff if country2 == "JPY" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "JPY"
		
		correlate coef inv_sd_idiff if country2 == "NOK" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "NOK"
		
		correlate coef inv_sd_idiff if country2 == "NZD" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "NZD"
		
		correlate coef inv_sd_idiff if country2 == "SEK" & coef != .
		local corrcoef = r(rho)
		replace corr_inv_sd_cty = `corrcoef' if country2 == "SEK"
		
		** All
		gen inv_sd_idiff_demean = .
		local i = 1
		while `i' <= 11{
			sum inv_sd_idiff if cty2 == `i'
			local mean = r(mean)
			replace inv_sd_idiff_demean = inv_sd_idiff - `mean' if cty2 == `i'
			local i = `i' + 1
		}
		correlate coef_demean inv_sd_idiff_demean if coef != .	
		local corrcoef = r(rho)
		replace corr_inv_sd_all = `corrcoef'
		
		save "$data/fama_10_results.dta", replace
		
		duplicates drop country2, force
		keep country2 corr_var_cty corr_var_all corr_sd_cty corr_sd_all corr_inv_var_cty corr_inv_var_all corr_inv_sd_cty corr_inv_sd_all
		
		save "$results/corr_10.dta", replace
