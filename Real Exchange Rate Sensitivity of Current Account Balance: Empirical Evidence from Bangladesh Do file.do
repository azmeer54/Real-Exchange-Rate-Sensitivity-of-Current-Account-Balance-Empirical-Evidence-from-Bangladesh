set more off
clear all 

// Importing the Dataset
use "https://github.com/azmeer54/Real-Exchange-Rate-Sensitivity-of-Current-Account-Balance-Empirical-Evidence-from-Bangladesh/blob/main/Real_Exchange_Rate_Sensitivity_of_Current_Account_Balance_Empirical_Evidence_from_Bangladesh.dta?raw=true"


//Starting the texdoc stata log
texdoc init "RERandCABpaper.tex", force cmdstrip nooutput replace

//Setting the Dataset as Time Series
tsset Year

//Keeping Important Variables 
keep WorldGDPDeflator GDPgrowthannual CurrentaccountbalanceofGD Broadmoneygrowthannual Personalremittancesreceived OfficialexchangerateLCUper InflationGDPdeflatorannual Realinterestrate Foreigndirectinvestmentneti Foreigndirectinvestmentneto BroadmoneyofGDP Year 

//Renaming Essential Variable for Econometric Analysis 
rename CurrentaccountbalanceofGD CAB
rename GDPgrowthannual GDPG
rename Realinterestrate R
rename Broadmoneygrowthannual M2G
rename Personalremittancesreceived REMIT
rename OfficialexchangerateLCUper NER
rename InflationGDPdeflatorannual DOMINF
rename WorldGDPDeflator WORLDINF
rename Foreigndirectinvestmentneti FDI 
rename Foreigndirectinvestmentneto FDIO
rename BroadmoneyofGDP M2SHARE

//Relabelling variables
label variable DOMINF "Inflation, Home GDP deflator (annual percentage)"
label variable WORLDINF "Inflation, World GDP deflator (annual percentage)"
label variable NER "Official Exchange Rate, LCU per USD (period average)"
label variable REMIT "Personal Remittances Received (Percentage of GDP)"
label variable M2G "Broad Money Growth (Annual Percentage)"
label variable R "Real Interest Rate (Percentage)"
label variable GDPG "Per Capita GDP Growth USD (Base year 2015)"
label variable CAB "Current Account Balance (Percentage of GDP)"
label variable M2SHARE "Broad Money (Percentage of GDP)"
label variable FDI "Foreign Direct Investment, net inflows (Percentage of GDP)"
label variable FDIO "Foreign Direct Investment, net outflows (Percentage of GDP)"
label variable Year "Year"

//Generating the new Variable REXTRT
sort Year 
generate REXRT= ((D.NER)/NER)*100 + WORLDINF - DOMINF


//RER Model 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//Lag Order Selection 
varsoc REXRT, maxlag(10) // Lag 1
varsoc NER, maxlag(10) //Lag 1
varsoc WORLDINF, maxlag(10) //lag 1
varsoc DOMINF, maxlag(10) //lag 0

//Checking I(0)
dfuller REXRT, lags(1) //stationary
dfuller NER, lags(1) //non-stationary
dfuller WORLDINF, lags(1) //non-stationary
dfuller DOMINF, lags(0) //stationary

//Cheking I(1)
dfuller D.REXRT, lags(1) //stationary
dfuller D.NER, lags(1) //Stationary
dfuller D.WORLDINF, lags(1) //Stationary
dfuller D.DOMINF, lags(0) //Stationary


//Lag Selection for the Real Exchange Rate Long Run Model 
texdoc stlog "RERlagmodelselection"
varsoc REXRT NER WORLDINF DOMINF, maxlag(4) //lag is 1
texdoc stlog close 
//Confirming there is a single cointegrating relationship
texdoc stlog "RERcointegration"
vecrank REXRT NER WORLDINF DOMINF, trend(constant) lags(1) //rank is 2
texdoc stlog close 

//VEC Model for RER estimation
texdoc stlog "RERestimation"
vec REXRT NER WORLDINF DOMINF, trend(constant) rank(2) lags(1) noetable  
texdoc stlog close 

vec REXRT NER WORLDINF DOMINF, trend(constant) rank(2) lags(1) noetable
estimates store m1
//Exporting Short Run Coefficient Table
esttab m1 using "RERshortrun.tex", noobs width(1\textwidth) p nogaps nonumbers unstack nomtitles compress nofloat replace

//Predicting RER
vec REXRT NER WORLDINF DOMINF, trend(constant) rank(2) lags(1) noetable
predict REXT, xb equation(D_REXRT)

//VEC Autocorrelation
texdoc stlog "VECautcorrRER"
veclmar
texdoc stlog close 

//VEC Stability 
texdoc stlog "vecstableRERtable"
vecstable  //Decision stable
texdoc stlog close 


//VEC Normality
texdoc stlog "vecnormalityRER"
vecnorm, jbera skewness kurtosis  
texdoc stlog close 

///Decision: Target model is okay 

//CAB Model 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//Lag order Selection for CAB Model
varsoc CAB, maxlag(10) // Lag 1
varsoc REXT, maxlag(10) //Lag 1
varsoc GDPG, maxlag(10) //lag 1
varsoc R, maxlag(10) //lag 1
varsoc M2G, maxlag(10) // Lag 0
varsoc M2SHARE, maxlag(10) // Lag 1
varsoc FDI, maxlag(10) // Lag 1

//Checking I(0)
dfuller CAB, lags(1) //non-stationary
dfuller REXT, lags(1) //stationary
dfuller GDPG, lags(1) //non-stationary
dfuller R, lags(1) //stationary
dfuller M2G, lags(0) //stationary
dfuller M2SHARE, lags(1) //non-stationary
dfuller FDI, lags(1) //non-stationary

//Cheking I(1)
dfuller D.CAB, lags(1) //stationary
dfuller D.REXT, lags(1) //stationary
dfuller D.GDPG, lags(1) //stationary
dfuller D.R, lags(1) //stationary
dfuller D.M2G, lags(0) //stationary
dfuller D.M2SHARE, lags(1) //stationary
dfuller D.FDI, lags(1) //stationary

//Lag Selection for the Real Exchange Rate Long Run Model 
texdoc stlog "CABlagmodelselection"
varsoc CAB REXT FDI GDPG R M2G, maxlag(4) //decision 1 lags 
texdoc stlog close 
//Cointegration Check for Final Model 
texdoc stlog "CABcointegration"
vecrank CAB REXT FDI GDPG R M2G, trend(constant) lags(1) //Decision Rank 4
texdoc stlog close 

//Final Model Estimation
texdoc stlog "CABFinal_LR"
vec CAB REXT FDI GDPG R M2G, trend(constant) rank(4) lags(1) noetable  
texdoc stlog close 

//Exporting the Short run coefficients 
vec CAB REXT FDI GDPG R M2G, trend(constant) rank(4) lags(1) noetable
estimates store v1

esttab v1 using "CABshortrun.tex", noobs width(1\textwidth) p nogaps nonumbers unstack nomtitles compress nofloat replace


//VEC Autocorrelation
texdoc stlog "VECautcorrCAB"
veclmar 
texdoc stlog close 

//VEC Stability 
texdoc stlog "vecstableCABtable"
vecstable  //Decision stable
texdoc stlog close 

//VEC Normality 
texdoc stlog "vecnormalityCAB"
vecnorm, jbera skewness kurtosis  //Target model is okay
texdoc stlog close 

//Marginal analysis
vec CAB REXT FDI GDPG R M2G, trend(constant) rank(4) lags(1) noetable
texdoc stlog "PredictiveMargin"
margins
texdoc stlog close 

//Exporting Graph of Predictive Margin
marginsplot
graph export marginsplot.pdf, replace

//Dynamic Forecasting 
vec CAB REXT FDI GDPG R M2G, trend(constant) rank(4) lags(1) noetable
fcast compute Forecasted, step(20) dynamic(2021)  differences 
fcast graph ForecastedCAB ForecastedREXT ForecastedGDPG ForecastedFDI ForecastedR ForecastedM2G 
graph export DynamicForecast.pdf, replace

//First Difference Forecasting
fcast graph ForecastedCAB ForecastedREXT ForecastedGDPG ForecastedFDI ForecastedR ForecastedM2G, differences
graph export DifferenceForecast.pdf, replace


//Exporting the forecasted values
texdoc stlog "ForecastedValue"
list Year ForecastedCAB ForecastedREXT ForecastedGDPG ForecastedFDI ForecastedR ForecastedM2G  if Year>=2020, table separator(1) divider noobs
texdoc stlog close 



//IRF 
irf create CAB1, step(20) set(vecCABirf) replace 
irf graph oirf irf, impulse(REXT) response(CAB) 
graph export ImpulseResponseCAB.pdf, replace
irf graph oirf irf, impulse(REXT) response(GDPG) 
graph export ImpulseResponseGDPG.pdf, replace
irf graph oirf irf , impulse(REXT) response(FDI) 
graph export ImpulseResponseFDI.pdf, replace
irf graph oirf irf, impulse(REXT) response(R) 
graph export ImpulseResponseR.pdf, replace
irf graph oirf irf, impulse(REXT) response(M2G) 
graph export ImpulseResponseM2G.pdf, replace
irf graph oirf irf, impulse(REXT) response(REXT) 
graph export ImpulseResponseREXT.pdf, replace
irf graph oirf irf, impulse(M2G) response(REXT) 
graph export ImpulseResponseM2GREXT.pdf, replace
irf graph oirf irf, impulse(M2G) response(CAB) 
graph export ImpulseResponseM2GCAB.pdf, replace
irf graph oirf irf, impulse(GDPG) response(CAB) 
graph export ImpulseResponseGDPGCAB.pdf, replace
irf graph oirf irf, impulse(GDPG) response(REXT) 
graph export ImpulseResponseGDPGREXT.pdf, replace
irf graph oirf irf, impulse(M2G) response(GDPG) 
graph export ImpulseResponseM2GGDPG.pdf, replace
irf graph oirf irf, impulse(FDI) response(CAB) 
graph export ImpulseResponseFDICAB.pdf, replace

irf table oirf irf, impulse(REXT) response(CAB FDI GDPG R M2G) title(~)

texdoc stlog "OIRFtable"
irf table oirf, impulse(REXT) response(CAB FDI GDPG R M2G) title(~)
texdoc stlog close 

texdoc stlog "IRFtable"
irf table irf, impulse(REXT) response(CAB FDI GDPG R M2G) title(~)
texdoc stlog close 

irf drop CAB1
texdoc close

twoway (tsline CAB  GDPG R M2G), legend(label(1  "CAB") label(2  "GDPG") label(3  "R")label(4  "M2G"))
graph export TSlineCAB.pdf, replace

twoway (tsline REXT DOMINF WORLDINF), legend(label(1  " Calculated RER") label(2  "Domestic Inflation") label(3  "Global Inflation"))
graph export TSlineRER.pdf, replace


//Summary Table 
sum CAB FDI GDPG R M2G REXT REXRT NER DOMINF WORLDINF  ForecastedCAB ForecastedREXT ForecastedGDPG ForecastedFDI ForecastedR ForecastedM2G Year, format separator(0)

//Exporting the Summary of all variables to LATEX file titled "summary_table.tex"
outreg2 using "summary_table.tex", replace sum(log) label(insert) keep(CAB FDI GDPG R M2G REXT REXRT NER DOMINF WORLDINF  ForecastedCAB ForecastedREXT ForecastedGDPG ForecastedFDI ForecastedR ForecastedM2G Year) title(Summary of Variables) nonotes

clear all
//Thank you so much for going through the code. 

