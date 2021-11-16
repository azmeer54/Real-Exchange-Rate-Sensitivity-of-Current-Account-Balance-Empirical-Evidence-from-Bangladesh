//Loading the Data for the study titled: 
//"Real Exchange Rate and Current Account Balance: Empirical Evidence from Bangladesh(1977-2020)"
//Submitted to Abul Kalam Azad, Assistant Professor, Department of Economics, University of Dhaka. 
//Authored by Azmeer, Ahmad, Arjoo, Ruhul, Jafor as part of Coursework of Econ 306 International Finance



//Importing the Dataset
import excel "C:\Users\ASUS\Desktop\Data_Impact of Real Exchange rate on Current Account Balance_Findings from Bangladesh\Data_Impact of Real Exchange rate on Current Account Balance_Findings from Bangladesh.xlsx", sheet("BD Data") firstrow
//setting Matrix Size
set matsize 1000

//Setting the Dataset as Time Series
tsset Year

//Dropping unnecessary variables
drop Adjustednetnationalincomean Adjustednetnationalincomeper GNIgrowthannual GNIpercapitagrowthannual S
drop R O BroadmoneyofGDP GDPpercapitagrowthannual Inflationconsumerpricesannu 
drop Foreigndirectinvestmentneti CurrentaccountbalanceBoPcu

//Renaming Essential Variable for Econometric Analysis 
rename CurrentaccountbalanceofGD CAB
rename GDPgrowthannual GDPG
rename Realinterestrate R
rename Broadmoneygrowthannual M2G
rename Personalremittancesreceived REMIT
rename Foreigndirectinvestmentneto FDIO
rename OfficialexchangerateLCUper NOMEXRT
rename InflationGDPdeflatorannual HOMEINFALTION
rename WorldGDPDeflator WORLDINFLATION

//Relabelling variables
label variable HOMEINFALTION "Inflation, Home GDP deflator (annual %)"
label variable WORLDINFLATION "Inflation, World GDP deflator (annual %)"

//Generating the new Variable REXTRT
generate REXRT= ((d.NOMEXRT)/NOMEXRT) + WORLDINFLATION-HOMEINFALTION

//Summary of all the variables in the model
sum

//Exporting the Summary of all variables to LATEX file titled "summary_table.tex"
outreg2 using summary_table.tex, replace sum(log) keep(CAB GDPG R M2G REMIT FDIO NOMEXRT HOMEINFALTION WORLDINFLATION REXRT)

//Labelling REXRT as proxy variable
label variable REXRT "Proxy Variable for Real Interest Rate"


//Using the OLS
reg CAB REXRT FDIO REMIT M2G R GDPG
//exporting the OLS regression output into LATEX Format
outreg2 using OLS_regression.tex, replace

//Checking for Heteroscedasticity
//visually
rvfplot, yline(0)
//Exporting the Graph to PDF
graph export rvf.pdf, replace
//Breusch-Pagan test for Heteroscedasticity
estat hettest
//Decision: Not heteroscedastic. 


//Checking for Autocorrelation using Durbin-Watson Test
dwstat
//Result: Durbin-Watson d-statistic(  7,    44) =  1.832089
//Decision: There is positive autocorrelation, use prais command with corc. 


//Checking for Multicollinearity using Variance Inflating Factor
vif
//Decision: There is no significant multicollinearity

//Checking for Specification Bias
linktest //Link Test for Specification Bias
ovtest //Ramser Reset Test for Specification Bias
//Decision: The model is correctly specified

//Checking for normality of the residuals
//Predicting the Residuals 
predict r, resid
//Visializing the predicted residual values 
kdensity r, normal //Shows little deviation 
//Exporting K-density plot
graph export kdensity.pdf, replace
//Generating pnorm graph, showing sensitive to non-normality in the middle range of data
pnorm r // Decision: shows little deviation
//Exporting pnorm visualization
graph export pnorm.pdf, replace  
//Shapiro-Wilk W test for normal data
swilk r //Extremely high p-value, we cannot reject that r is normally distributed
//Decision: Residuals are normally distributed.


//Two variable regression plots
avplots, mlabel(Year) //produces a faucet of visualization
//Exporting the visualization
graph export avf.pdf, replace


//Model 1 
prais CAB REXRT, corc
estimates store m1, title(Model 1)

//Model 2
prais CAB REXRT FDIO, corc
estimates store m2, title(Model 2)

//Model 3
prais CAB REXRT FDIO REMIT, corc
estimates store m3, title(Model 3)

//Model 4
prais CAB REXRT FDIO REMIT M2G, corc
estimates store m4, title(Model 4)

//Model 5
prais CAB REXRT FDIO REMIT M2G R, corc
estimates store m5, title(Model 5)

//Model 6
prais CAB REXRT FDIO REMIT M2G R GDPG, corc
estimates store m6, title(Model 6)


//The Final Table for Hierarchical Regression Analysis
esttab m1 m2 m3 m4 m5 m6, se r2 ar2 mtitles

//Exporting the Final Table into LaTeX format
esttab m1 m2 m3 m4 m5 m6 using "main_regression_table.tex", se r2 ar2 mtitles replace

//Evaluating Model Performance
predict PREDICT_CAB //Predicting the values of CAB
scatter PREDICT_CAB CAB //Evaluating the performance of the predicted value compared to actual values
graph export predictvsactual.pdf, replace //Exporting visualization of model performance for prediction

//Thank you so much for going through the code. 

