*********************************
* Annualized Interest Rates
*********************************
cd E:\Econ872_Paper\analysis
* US + Germany + Italy + France
use input\data_updated_200617.dta, clear
keep if country2 == "DEM" | country2 == "ITL" | country2 == "FRF"
drop if libor_1mannualized_dollar ==.
drop if libor_1mannualized ==.
drop if country2 == "ITL" & year > 1998
drop if country2 == "FRF" & year > 1998
append using input\us_interest
sort year month
gen date2 = ym(year, month)
tsset cty2 date2, monthly

graph twoway tsline libor_1mannualized if country2 == "DEM" ||  tsline libor_1mannualized if country2 == "ITL" ||  tsline libor_1mannualized if country2 == "FRF" || tsline libor_1mannualized if country2 == "USD", lcolor(black) , xtitle("Time", size(small)) ytitle("Interest Rates", size(small)) graphregion(fcolor(white)) legend(label(1 "DEM") label(2 "ITL") label(3 "FRF") label(4 "USD") size(small) symxsize(12))

* US + Norway + Sweden + Switzerland + UK
use input\data_updated_200617.dta, clear
keep if country2 == "NOK" | country2 == "SEK" | country2 == "CHF" | country2 == "GBP"
drop if libor_1mannualized_dollar ==.
drop if libor_1mannualized ==.
append using input\us_interest
sort year month
gen date2 = ym(year, month)
tsset cty2 date2, monthly

graph twoway tsline libor_1mannualized if country2 == "NOK" ||  tsline libor_1mannualized if country2 == "SEK" ||  tsline libor_1mannualized if country2 == "CHF" ||  tsline libor_1mannualized if country2 == "GBP" || tsline libor_1mannualized if country2 == "USD", lcolor(black) , xtitle("Time", size(small)) ytitle("Interest Rates", size(small)) graphregion(fcolor(white)) legend(label(1 "NOK") label(2 "SEK") label(3 "CHF") label(4 "GBP") label(5 "USD") size(small) symxsize(12))

* US + Austrailia + New Zealand + Canada + Japan
use input\data_updated_200617.dta, clear
keep if country2 == "AUD" | country2 == "NZD" | country2 == "CAD" | country2 == "JPY"
drop if libor_1mannualized_dollar ==.
drop if libor_1mannualized ==.
append using input\us_interest
sort year month
gen date2 = ym(year, month)
tsset cty2 date2, monthly

graph twoway tsline libor_1mannualized if country2 == "AUD" ||  tsline libor_1mannualized if country2 == "NZD" ||  tsline libor_1mannualized if country2 == "CAD" ||  tsline libor_1mannualized if country2 == "JPY" || tsline libor_1mannualized if country2 == "USD", lcolor(black) , xtitle("Time", size(small)) ytitle("Interest Rates", size(small)) graphregion(fcolor(white)) legend(label(1 "AUD") label(2 "NZD") label(3 "CAD") label(4 "JPY") label(5 "USD") size(small) symxsize(12))


