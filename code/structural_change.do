************************************************
*         Structural Break for Fama Reg         *
*            By: Nan Xiang                     *
************************************************

use "$data/data_updated_201009",clear

drop if year < 1989
forval i = 1(1)11{
	reg s_change i_diff if cty == `i', r
    xtset cty2 t
	estat sbknown, break(337)
}
