cd E:\Econ872_Paper\analysis
capture close
//3-lags
foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{

	use temp/VAR_CAD_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("CAD: i-i*", color(black)) graphregion(fcolor(white))saving(temp\cadi,replace)
    graph twoway tsline s_fama, title("CAD: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\cads,replace)
	//gr combine temp/cadi.gph temp/cads.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/cad, replace)
	gr combine temp/cadi.gph temp/cads.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/cad_row, replace)
	
	use temp/VAR_CHF_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("CHF: i-i*", color(black)) graphregion(fcolor(white))saving(temp\chfi,replace)
    graph twoway tsline s_fama, title("CHF: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\chfs,replace)
	//gr combine temp/chfi.gph temp/chfs.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/chf, replace)
	gr combine temp/chfi.gph temp/chfs.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/chf_row, replace)
	
	use temp/VAR_DEM_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("DEM: i-i*", color(black)) graphregion(fcolor(white))saving(temp\demi,replace)
    graph twoway tsline s_fama, title("DEM: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\dems,replace)
	//gr combine temp/demi.gph temp/dems.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/dem, replace)
	gr combine temp/demi.gph temp/dems.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/dem_row, replace)
	
	use temp/VAR_FRF_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("FRF: i-i*", color(black)) graphregion(fcolor(white))saving(temp\frfi,replace)
    graph twoway tsline s_fama, title("FRF: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\frfs,replace)
	//gr combine temp/frfi.gph temp/frfs.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/frf, replace)
	gr combine temp/frfi.gph temp/frfs.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/frf_row, replace)
	
	use temp/VAR_GBP_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("GBP: i-i*", color(black)) graphregion(fcolor(white))saving(temp\gbpi,replace)
    graph twoway tsline s_fama, title("GBP: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\gbps,replace)
	//gr combine temp/gbpi.gph temp/gbps.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/gbp, replace)
	gr combine temp/gbpi.gph temp/gbps.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/gbp_row, replace)
	
	use temp/VAR_ITL_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("ITL: i-i*", color(black)) graphregion(fcolor(white))saving(temp\itli,replace)
    graph twoway tsline s_fama, title("ITL: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\itls,replace)
	//gr combine temp/itli.gph temp/itls.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/itl, replace)
	gr combine temp/itli.gph temp/itls.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/itl_row, replace)
	
	use temp/VAR_JPY_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("JPY: i-i*", color(black)) graphregion(fcolor(white))saving(temp\jpyi,replace)
    graph twoway tsline s_fama, title("JPY: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\jpys,replace)
	//gr combine temp/jpyi.gph temp/jpys.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/jpy, replace)
	gr combine temp/jpyi.gph temp/jpys.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/jpy_row, replace)
	
	use temp/VAR_NOK_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("NOK: i-i*", color(black)) graphregion(fcolor(white))saving(temp\noki,replace)
    graph twoway tsline s_fama, title("NOK: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\noks,replace)
	//gr combine temp/noki.gph temp/noks.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/nok, replace)
	gr combine temp/noki.gph temp/noks.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/nok_row, replace)
	
	use temp/VAR_SEK_0717_yoy.dta,clear
	sort year month
	gen t = _n
	gen date2 = ym(year, month)
	tsset date2, monthly
	graph twoway tsline i_diff, title("SEK: i-i*", color(black)) graphregion(fcolor(white))saving(temp\seki,replace)
    graph twoway tsline s_fama, title("SEK: Log(ER)", color(black)) graphregion(fcolor(white)) saving(temp\seks,replace)
	//gr combine temp/seki.gph temp/seks.gph, cols(1) iscale(.7273) ysize(4) graphregion(margin(zero)) saving(temp/sek, replace)
	gr combine temp/seki.gph temp/seks.gph, rows(1) iscale(.7273) xsize(10) graphregion(margin(zero)) saving(temp/sek_row, replace)
	