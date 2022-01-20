* A Reconsideration of the Failure of Uncovered Interest Parity for the U.S. Dollar
* Charles Engel, Ekaterina Kazakova, Mengqi Wang, Nan Xiang
clear all
*Set this path to whereever the files are downloaded
// global uip E:/Econ872_Paper/UIP
global uip /Users/nxiang/Econ872_Paper/UIP

*Set the remaining paths and globals
do $uip/code/setup.do

* Short-Run
** Corrected Fama Regression: Equation 3
do $uip/code/Task9_BiasCorrection_For_Fama_Reg_20200716.do


** Rolling Fama Regression, Variance of Interest Rate and VIX
do $uip/code/Fama_rolling_corrected_201028.do
do $uip/code/correlation_calculation_201028.do
do $uip/code/correlation_VIX_201028.do


** Excess Return on Inflation, Corrected: Equation 6
do $uip/code/Task9.1_BiasCorrection_For_Fama_Reg_Inflation_20200727.do


** Rolling Excess Return on Inflation
do $uip/code/Fama_rolling_excess_corrected.do


** Shadow Rates
//do $uip/code/Shadow_Rates_Reg_201115.do

** Equation 9
do $uip/code/Fama_yoy_9_nocorrection.do
do $uip/code/Equation9_restricted.do

* Medium0-Run

** Equation 4
do $uip/code/Task10_BiasCorrection_For_MR_Fama_Reg_20200720.do
do $uip/code/Fama_rolling_medium.do

** Equation 7
do $uip/code/Task10.1_BiasCorrection_For_MR_Fama_Reg_Inflation_20200727.do
do $uip/code/Fama_rolling_excess_medium

** Inflation Shocks: Equation 11
do $uip/code/ER_and_Inflation_shock.do

* Robustness

** Libor's response to Inflation
do $uip/code/robustness_inflation_20210624.do
do $uip/code/robustness_policyrate.do
do $uip/code/robustness_panel.do

** Including business cycle components
do $uip/code/robustness_ipgrowth.do

** UIP in real terms: Equation 10
do $uip/code/robustness_real_uip.do
