cd E:/Econ872_Paper/analysis
use input/data_updated_200617,clear
levelsof country2, local(countries)


//keep if year >= 2007
keep if year < 2007
//g rho = s_change -i_diff

foreach country in `countries'{
	preserve
	keep if country2 == "`country'"
	drop if i_diff ==.

	tsset t

	forval i = 1(1)99{
		gen s_`i' = f`i'.s_fama
		qui: reg s_`i' i_diff, r
		gen coef`i' = _b[i_diff]
		g low`i' = _b[i_diff] - 1.96*_se[i_diff]
		g high`i' = _b[i_diff] + 1.96*_se[i_diff]
	}

	keep coef* low* high* country2
	duplicates drop

	reshape long coef low high, i(country2) j(time)

	twoway line coef time, color(black) || line low time, lpattern(longdash) color(black) || line high time, lpattern(longdash) color(black) title("Slope of ex post ER regressions", color(black) size(small)) ///
	note("Pre 2006", color(black) size(vsmall)) ///
	ylabel(,labsize(vsmall)) graphregion(fcolor(white)) ///
	xtitle("Months", size(small)) ytitle("Coefficient", size(small)) yline(0, lpattern() lcolor()) legend(off)

	graph export temp\graphs\ERSlope06_`country'.png, as(png) name("Graph") replace
	restore
}

