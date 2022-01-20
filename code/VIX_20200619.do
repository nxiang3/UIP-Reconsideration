use "E:\Econ872_Paper\analysis\input\VIX_merge.dta", clear
drop if VIX ==.
sort year month
gen t = _n
gen id = 1
xtset id t
cd E:\Econ872_Paper\analysis\output
rolling int_mean = r(mean) , window(120) saving(vix_10,replace) keep(t,start): summarize VIX

use "E:\Econ872_Paper\analysis\output\vix_10.dta",clear
gen t = _n
save "E:\Econ872_Paper\analysis\output\vix_10.dta", replace
// 5-year
use "E:\Econ872_Paper\analysis\input\VIX_merge.dta", clear
drop if VIX ==.
sort year month
gen t = _n
gen id = 1
xtset id t
cd E:\Econ872_Paper\analysis\output
rolling int_mean = r(mean) , window(60) saving(vix_5,replace) keep(t,start): summarize VIX

use "E:\Econ872_Paper\analysis\output\vix_5.dta",clear
gen t = _n
save "E:\Econ872_Paper\analysis\output\vix_5.dta", replace