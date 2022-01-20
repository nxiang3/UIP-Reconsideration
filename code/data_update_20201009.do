***************************************
* New Libor Middle rate (DataStream)
***************************************
clear all
cd E:/Econ872_Paper/analysis/input
import excel "E:\Econ872_Paper\build\input\1mLIBOR.xlsx", sheet("Sheet3") firstrow
sort Country2 Year Month
by Country2: gen t = _n
rename Country2 country2 
rename Year year
rename Month month

rename LIBOR_1mannualized libor_1mannualized_update

g libor_update = libor_1mannualized_update / 1200

save CHF_1979_1987, replace

clear
import excel "E:\Econ872_Paper\build\input\1mLIBOR.xlsx", sheet("Sheet2") firstrow cellrange(A1:D3931)
sort Country2 Year Month
by Country2: gen t = _n
rename Country2 country2 
rename Year year
rename Month month

rename LIBOR_1mannualized libor_1mannualized_update

g libor_update = libor_1mannualized_update / 1200
append using CHF_1979_1987

save new_libor_temp, replace

** USD
preserve
keep if country2 == "USD"
rename libor_1mannualized libor_1ma_dollar
rename libor_update libor_dollar_update
rename country2 country1
save libor_dollar_temp, replace

restore
keep if country2 == "EUR"
save libor_eur, replace

use new_libor_temp, clear
drop if country2 == "USD"
replace country2 = "DEM" if country2 == "EUR"
append using libor_eur
replace country2 = "FRF" if country2 == "EUR"
append using libor_eur
replace country2 = "ITL" if country2 == "EUR"

save new_libor_temp, replace


* Merge with Original Data
use data_updated_200617.dta, clear
sort country2 year month
merge 1:1 country2 year month using new_libor_temp
drop _merge
sort country2 year month

//replace libor_1mannualized = libor_1mannualized_update if year > 1999 & libor_1mannualized_update !=.
replace libor_1mannualized = libor_1mannualized_update if libor_1mannualized_update !=.

//replace libor = libor_update if year > 1999 & libor_update !=.
replace libor = libor_update if libor_update !=.
replace country1 = "USD"

sort country1 year month
merge m:1 country1 year month using libor_dollar_temp

replace libor_dollar = libor_dollar_update if libor_dollar_update !=.
replace libor_1mannualized_dollar = libor_1ma_dollar if libor_1ma_dollar !=.

drop _merge libor_dollar_update libor_1ma_dollar
sort country2 year month

save data_updated_201009, replace

keep country2 year month libor_1mannualized libor_1mannualized_dollar libor libor_dollar
keep if year == 2020
foreach var of varlist libor_1mannualized-libor_dollar{
	rename `var' `var'_20
}
sort country2 year month
save libor_20, replace

/*
* Compare Libor rate to FRED data, from 1997/4-1998/12
** AUD
use data_updated_201009, clear
keep if country2 == "AUD"
gen date2 = ym(year, month)
keep if year == 1997 | year == 1998
drop if year == 1997 & month < 4
tsset date2, monthly
graph twoway tsline libor || tsline libor_update, title("AUD", color(black)) graphregion(fcolor(white)) legend(label(1 "FRED LIBOR") label(2 "DataStream LIBOR") size(small)) saving(AUD,replace)

** NOK
use data_updated_201009, clear
keep if country2 == "NOK"
gen date2 = ym(year, month)
keep if year == 1997 | year == 1998
drop if year == 1997 & month < 4
tsset date2, monthly
graph twoway tsline libor || tsline libor_update, title("NOK", color(black)) graphregion(fcolor(white)) legend(label(1 "FRED LIBOR") label(2 "DataStream LIBOR") size(small)) saving(NOK,replace)

** SEK
use data_updated_201009, clear
keep if country2 == "SEK"
gen date2 = ym(year, month)
keep if year == 1997 | year == 1998
drop if year == 1997 & month < 4
tsset date2, monthly
graph twoway tsline libor || tsline libor_update, title("SEK", color(black)) graphregion(fcolor(white)) legend(label(1 "FRED LIBOR") label(2 "DataStream LIBOR") size(small)) saving(SEK,replace)
*/

use data_updated_201009, clear
drop if year == 2020
append using data_for2020_mengqi, force
sort country2 year month
merge 1:1 country2 year month using libor_20

foreach var of varlist libor_1mannualized-libor_dollar{
	replace `var' = `var'_20 if _merge == 3
}

drop libor_1mannualized_20 - _merge
drop qdate libor_1mannualized_update libor_update

replace i_diff = libor_dollar - libor

save data_updated_201009, replace
 