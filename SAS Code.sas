PROC IMPORT DATAFILE= "C:\Users\sxs17833\Desktop\IBM-Telco-Customer-Churn.xlsx" out=telco_cust_churn DBMS=xlsx REPLACE;
RUN;

proc contents data=telco_cust_churn;
run;

/*converting total_charges from character to numerical decimal(as import function is treating it as character)*/
data telco_cust_churn;
set telco_cust_churn;
Total_Charges=input(TotalCharges,best8.);
run;

proc contents data=telco_cust_churn;
run;

proc means data = telco_cust_churn;
var tenure monthlycharges total_charges;
class churn;
output out = mean_churn;
run;

data mean_churn;
set mean_churn;
where _TYPE_ <> 0;
run;

data mean_churn;
set mean_churn;
where _STAT_ = "MEAN";
run;

proc transpose data=mean_churn
out=mean_churn1;
run;

proc print data=mean_churn1;
run;

data mean_churn1;
set mean_churn1(firstobs=3);
run;

proc print data=mean_churn1;
run;

data mean_churn2;
set mean_churn1;
pcnt_diff = (COL1-COL2)/COL1;
run;

proc sort data = mean_churn2;
by descending pcnt_diff ;
run;


proc print data=mean_churn2;
run;
/* maximum percent diff tenure, then total and then monthly*/

data telco_cust_churn;
set telco_cust_churn;
if gender='Female' then gender_fem=1; else gender_fem=0;
if Partner='Yes' then Part=1; else Part=0;
if Dependents='Yes' then Dep=1; else Dep=0;
if PhoneService='Yes' then PS=1; else PS=0;
if MultipleLines='Yes' then ML_Y=1; else ML_Y=0;
if MultipleLines='No' then ML_N=1; else ML_N=0;
if InternetService='Fiber optic' then IS_FO=1; else IS_FO=0;
if InternetService='DSL' then IS_D=1; else IS_D=0;
if OnlineSecurity='Yes' then OS_Y=1; else OS_Y=0;
if OnlineSecurity='No' then OS_N=1; else OS_N=0;
if DeviceProtection='Yes' then DP_Y=1; else DP_Y=0;
if DeviceProtection='No' then DP_N=1; else DP_N=0;
if OnlineBackup='Yes' then OB_Y=1; else OB_Y=0;
if OnlineBackup='No' then OB_N=1; else OB_N=0;
if TechSupport='Yes' then TS_Y=1; else TS_Y=0;
if TechSupport='No' then TS_N=1; else TS_N=0;
if StreamingTV='Yes' then ST_Y=1; else ST_Y=0;
if StreamingTV='No' then ST_N=1; else ST_N=0;
if StreamingMovies='Yes' then SM_Y=1; else SM_Y=0;
if StreamingMovies='No' then SM_N=1; else SM_N=0;
if Contract='One year' then Con_1=1; else Con_1=0;
if Contract='Two year' then Con_2=1; else Con_2=0;
if PaperlessBilling='Yes' then PB=1; else PB=0;
if PaymentMethod='Mailed check' then PM_Mail=1; else PM_Mail=0;
if PaymentMethod='Electronic check' then PM_Elec=1; else PM_Elec=0;
if PaymentMethod='Bank transfer (automatic)' then PM_BT=1; else PM_BT=0;
run;


proc logistic data=telco_cust_churn descending;
model churn= gender_fem  Part Dep PS ML_Y ML_N IS_FO IS_D OS_Y OS_N DP_Y DP_N OB_Y OB_N TS_Y TS_N ST_Y ST_N SM_Y SM_N Con_1 Con_2 PB PM_Mail PM_Elec PM_BT tenure Total_Charges MonthlyCharges;
run;

proc corr data=telco_cust_churn;
var tenure monthlycharges total_charges;
run;

/* removing monthly charges and total_cvharges( since tenure and total charges are corelated and monthly charges and total charges are corelated)*/
proc logistic data=telco_cust_churn descending;
model churn= gender_fem  Part Dep PS ML_Y ML_N IS_FO IS_D OS_Y OS_N DP_Y DP_N OB_Y OB_N TS_Y TS_N ST_Y ST_N SM_Y SM_N Con_1 Con_2 PB PM_Mail PM_Elec PM_BT tenure ;
run;

/* removing tenure( since tenure and total charges are corelated and monthly charges and total charges are corelated)*/
proc logistic data=telco_cust_churn descending;
model churn= gender_fem  Part Dep PS ML_Y ML_N IS_FO IS_D OS_Y OS_N DP_Y DP_N OB_Y OB_N TS_Y TS_N ST_Y ST_N SM_Y SM_N Con_1 Con_2 PB PM_Mail PM_Elec PM_BT Total_Charges MonthlyCharges ;
run;

/* monthly charges not significant since keeping tenure in my model and removing all these variables since they are linear combination of other variables*/
proc logistic data=telco_cust_churn descending;
model churn= gender_fem  Part Dep PS ML_Y IS_FO IS_D OS_Y  DP_Y  OB_Y  TS_Y  ST_Y  SM_Y  Con_1 Con_2 PB PM_Mail PM_Elec PM_BT tenure ;
run;

/* removing all these variables since they are linear combination of other variables*/
ML_N
OS_N
DP_N
OB_N
TS_N
ST_N
SM_N

/* removing the insignificant variables from the model*/
proc logistic data=telco_cust_churn descending;
model churn=Dep PS ML_Y IS_FO IS_D OS_Y TS_Y ST_Y SM_Y Con_1 Con_2 PB PM_Elec tenure ;
run;

