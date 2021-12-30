LIBNAME out 'D:\AMSE\Cours\Mag2\sas\Project\sas_data'; RUN;

/************************* STEP 1: Import and clean data ********************************/

/* Import ERIX and ECO renewable index */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\ERIX_ECO.xlsx"
OUT=out.eco_erix
DBMS=xlsx  REPLACE ; 
RUN ;
PROC PRINT DATA = out.eco_erix (obs=100);RUN;


/****************** ERIX index (EU)*************************/
/*Make a ERIX table */
DATA out.erix; set out.eco_erix;
keep Dates ERIX_Index;RUN;
PROC PRINT DATA = out.erix;RUN;

/* Change "date" to "dates" */
DATA out.erix;set out.erix (rename=(ERIX_Index=ERIX));RUN;

PROC CONTENTS DATA=out.erix;RUN;

/*Sort by date and plot the graph */
PROC SORT DATA = out.erix; by Dates ;RUN;

/************************ BRENT index (EU) ********************************/

/*Import BRENT*/

 PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\BRENT.xlsx"
out = out.oil
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.oil (obs=100); RUN;
PROC CONTENTS DATA=out.oil;RUN;

/* Rename close as brent and date as dates*/
DATA out.oil;set out.oil (rename=(close=BRENT));RUN;
DATA out.oil;set out.oil (rename=(date=Dates));RUN;

/*Convert data to numerical data */
DATA out.oil; set out.oil;
new_brent=input(BRENT,best4.);
DROP BRENT;RUN;
DATA out.oil;set out.oil (rename=(new_brent=BRENT));RUN;

/*Sort by date*/
PROC SORT DATA = out.oil; by Dates;RUN;

/************************ EURIBOR at 3 months ********************************/

 /* Import EURIBOR */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\EURIBOR.xlsx"
OUT=out.euribor
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.euribor;RUN;
PROC CONTENTS DATA=out.euribor;RUN;

/* Change "EURIBOR__3_mois" to "EURIBOR" */
DATA out.euribor;set out.euribor (rename=(EURIBOR___3_mois=EURIBOR));RUN;

/* Select date from 01/2010 to 09/2019 */
DATA out.euribor ;set out.euribor;
IF '01jan2010'd<=Dates<='01sep2019'd
THEN output out.euribor;RUN;

/*Delete row with "-" as value */
DATA out.euribor ;set out.euribor;
IF EURIBOR = "-" then delete;RUN;

/*Convert data to numerical data */
DATA out.euribor; set out.euribor;
new_euribor=input(EURIBOR,best22.);
DROP EURIBOR;RUN;
DATA out.euribor;set out.euribor (rename=(new_euribor=EURIBOR));RUN;

/*Delete row with "null" as value */
DATA out.euribor ;set out.euribor;
IF EURIBOR = "null" then delete;RUN;

PROC CONTENTS DATA=out.euribor;RUN;

/*Sort by date*/
PROC SORT DATA = out.euribor; by Dates;RUN;

/************************ Technological index ********************************/

 /* Import TECH */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\STK.xlsx"
OUT=out.stk
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.stk (obs=10);RUN;
PROC CONTENTS DATA = out.stk;RUN;


/* Change "Dernier" to "STK" and "Date" to "Dates" */
DATA out.stk;set out.stk (rename=(Dernier=STK));RUN;
DATA out.stk;set out.stk (rename=(Date=Dates));RUN;


/*Sort by date*/
PROC SORT DATA = out.stk; by Dates;RUN;

/************************ Carbonne index ********************************/

 /* Import CARBONE */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\CARBONE.xlsx"
OUT=out.carb
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.carb (obs=10);RUN;
PROC CONTENTS DATA = out.carb;RUN;


/* Change "Dernier" to "CARBONE" and "Date" to "Dates" */
DATA out.carb;set out.carb (rename=(Dernier=CARBONE));RUN;
DATA out.carb;set out.carb (rename=(Date=Dates));RUN;

/*Sort by date */
PROC SORT DATA = out.carb; by Dates;RUN;

 /************************  Change rate euro vs US dollar ********************************/

 /* Import EUR_USD */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\EUR_USD.xlsx"
OUT=out.change
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.change (obs=10);RUN;
PROC CONTENTS DATA = out.change;RUN;


/* Change "Dernier" to "EUR_USD" and "Date" to "Dates" */
DATA out.change;set out.change (rename=(Dernier=EUR_USD));RUN;
DATA out.change;set out.change (rename=(Date=Dates));RUN;


/*Sort by date */
PROC SORT DATA = out.change; by Dates;RUN;

/************************ EURO STOXX 50 ********************************/

 /* Import EURO_50 */
PROC IMPORT DATAFILE="D:\AMSE\Cours\Mag2\sas\Project\xlsx_data\EURO_50.xlsx"
OUT=out.euro50
DBMS=xlsx  REPLACE ; 
RUN ;

PROC PRINT DATA = out.euro50 (obs=10);RUN;
PROC CONTENTS DATA = out.euro50;RUN;


/* Change "Dernier" to "EURO_50" and "Date" to "Dates" */
DATA out.euro50;set out.euro50 (rename=(Close=EURO_50));RUN;
DATA out.euro50;set out.euro50 (rename=(Date=Dates));RUN;

/* Transform to numerical data */
DATA out.euro50; set out.euro50;
new_EURO_50=input(EURO_50,best11.);
DROP EURO_50;RUN;
DATA out.euro50;set out.euro50 (rename=(new_EURO_50=EURO_50));RUN;



/*Sort by date*/
PROC SORT DATA = out.euro50; by Dates;RUN;


/************************* STEP 2: Merge data ********************************/


/*We merge by dates which allowed to delete surplus value in daily data set */
DATA out.EU; MERGE out.erix(IN=in1) out.oil(IN=in2) out.euribor(IN=in3) out.stk(IN=in4) 
out.carb(IN=in5) out.change(IN=in6)out.euro50(IN=in7);
BY Dates;
IF in1 & in2 & in3 & in4 & in5 & in6 & in7;
RUN;

PROC SORT DATA = out.EU; by Dates; RUN;
PROC PRINT DATA=out.EU (obs=10);
TITLE "Final data set"; RUN;
PROC CONTENTS DATA=out.EU;
TITLE "Final data set";RUN;

/*Using log to have a log data set */

DATA out.data_log; set out.EU;
l_ERIX = log(ERIX);
l_BRENT = log(BRENT);
l_STK = log(STK);
l_CARBONE = log(CARBONE);
l_EUR_USD  = log(EUR_USD);
l_EURO_50 = log(EURO_50);
RUN;

PROC PRINT DATA = out.data_log (obs=10);RUN;


/************************* STEP 3: Statistical description ********************************/
/* Plot the evolution of each variable from 2010 to 2009 */
PROC GPLOT DATA = out.EU;
 PLOT EUR_USD*Dates ;
 SYMBOL I = JOIN;
 TITLE "CHANGE RATE BETWEEN EURO AND US DOLLAR VARIATION SINCE 2010";
 RUN ; QUIT ;
 QUIT;


 PROC GPLOT DATA = out.EU;
 PLOT CARBONE*Dates ;
 SYMBOL I = JOIN;
 TITLE "CARBONE VARIATION SINCE 2010";
 RUN ; QUIT ;

 PROC GPLOT DATA = out.EU;
 PLOT STK*Dates ;
 SYMBOL I = JOIN;
 TITLE "STK VARIATION SINCE 2010";
 RUN ; QUIT ;

 PROC GPLOT DATA = out.EU;
 PLOT EURIBOR*Dates ;
 SYMBOL I = JOIN;
 TITLE "EURIBOR VARIATION SINCE 2010";
 RUN ; QUIT ;

 PROC GPLOT DATA=out.EU;
TITLE "BRENT VARIATION SINCE 2010" ;
SYMBOL1 INTERPOL=JOIN;
PLOT BRENT * dates  ;
RUN;

 PROC GPLOT DATA = out.EU;
 PLOT ERIX*Dates ;
 SYMBOL I = JOIN;
 TITLE "ERIX VARIATION SINCE 2010";
 RUN ;

 PROC GPLOT DATA = out.EU;
 PLOT EURO_50*Dates ;
 SYMBOL I = JOIN;
 TITLE "EURO_50 VARIATION SINCE 2010";
 RUN ;

  /*Plot with data in base 100 for a better comprehension */

DATA out.data_100;set out.data_log;
i_brent=100*(brent/81.3);
i_stk=100*(stk/24.94);
i_carbone=100*(carbone/13.09);
i_eur_usd=100*(eur_usd/1.4413);
i_euro_50=100*(euro_50/3017.85);
i_erix=100*(erix/1021.65);
i_euribor=100*(euribor/0.700);
run;

proc sgplot data=out.data_100;
series x=dates y=i_brent;
series x=dates y=i_stk;
series x=dates y=i_carbone;
series x=dates y=i_eur_usd;
series x=dates y=i_euro_50;
series x=dates y=i_erix;
series x=dates y=i_euribor;
title "Variation with indice base 100";

ods pdf file='D:\AMSE\Cours\Mag2\sas\Project\PDF\graph.pdf';

proc sgplot data=out.data_100;
series x=dates y=i_euro_50;
series x=dates y=i_erix;
title "EURO_50 base 100";

proc sgplot data=out.data_100;
series x=dates y=i_eur_usd;
series x=dates y=i_erix;
title "EUR_USD base 100";

proc sgplot data=out.data_100;
series x=dates y=i_erix;
series x=dates y=i_euribor;
title "EURIBOR base 100";

proc sgplot data=out.data_100;
series x=dates y=i_carbone;
series x=dates y=i_erix;
title "CARBONE base 100";

proc sgplot data=out.data_100;
series x=dates y=i_stk;
series x=dates y=i_erix;
title "STK base 100";

proc sgplot data=out.data_100;
series x=dates y=i_brent;
series x=dates y=i_erix;
title "BRENT base 100";

ods pdf close;



/*** TEST CHOW ***/
/* Chow test : is there structural changes in the model ? (data since 2010) crise de la dette souveraine
    Justification pour faire notre régression sur 2013-2019 */

proc model data = out.data_log plots=none;
l_ERIX = b0+ b_brent*l_BRENT + b_brent_rated*l_brent_rate +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR;
Fit l_ERIX /  Chow=(150) ; /* Il y a 150 semaines en 2010 et fin 2013 */
title "Chow test";
run;
/* F stat : 50.35 donc oui ! */


/*Other data set from 2013 to 2019 */
DATA out.data_log_2013 ;set out.data_log;
IF '01jan2013'd<=Dates<='01sep2019'd
THEN output out.data_log_2013;RUN;

/************************* STEP 4: Linear regression ********************************/

DATA out.data_log_2013; set out.data_log_2013;
l_BRENT_RATE = l_BRENT*l_EUR_USD;
RUN;

/***** OLS REGRESSOR *****/

 PROC REG DATA = out.data_log_2013 plots=none;
model l_ERIX = l_BRENT l_EUR_USD EURIBOR l_STK l_CARBONE  l_EURO_50;
title "Regression 1: first linear regression from 2013 to 2019 ";RUN;


PROC REG DATA = out.data_log_2013 plots=none;
model l_ERIX = l_BRENT l_BRENT_RATE l_STK l_CARBONE l_EURO_50 EURIBOR;
title "Regression 2: first linear regression with BRENT_RATE and without EUR_USD";RUN;

/* Tests on OLS estimation */
	/* Test homoskedasticity*/
proc model data = out.data_log_2013 plots = none;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50 +b_euribor*EURIBOR;
Fit l_ERIX /White Breusch = (1 l_BRENT l_STK l_CARBONE l_EUR_USD l_EURO_50 EURIBOR)
Dw Godfrey = 1;
title "Test White and Breusch-Pagan : Homoskedasticity";
run;
/*Ho is reject so there is Homoskedasticity */
	/* Test  Serial correlation : Test Durbin-Watson and Breusch-Godfrey */ 
proc model data = out.data_log_2013 plots = none;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR;
Fit l_ERIX /Dw Godfrey = 8 ;
title "Test Durbin-Watson and Breusch-Godfrey : Serial correlation";
run;





/***** Dealing with endogeneity*****/

/* Transformation data for instruments */
DATA out.data_log_2013; set out.data_log_2013;
/*Instruments (1)*/
l_LAG_BRENT = lag(l_BRENT);
l_LAG_ERIX = lag(l_ERIX);
/*Instruments (2)*/
l_LAG_STK = lag(l_STK);
l_LAG_CARBONE = lag(l_carbone);
l_LAG_EUR_USD = lag(l_EUR_USD);
l_LAG_EURO_50 = lag(l_EURO_50);
LAG_EURIBOR = lag(EURIBOR);
/*Instruments (3)*/
l_LAG15_STK = lag15(l_STK);
l_LAG15_CARBONE = lag15(l_carbone);
l_LAG15_EUR_USD = lag15(l_EUR_USD);
RUN;

/* IV and find instruments */

/* Instruments (1) */
/*Estimation by IV with Homogeneity and Autocorrelation tests */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_EUR_USD;
Endogenous l_erix l_brent ;
Instruments _exog_ l_LAG_ERIX l_LAG_BRENT ;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / 2SLS 
			White Breusch = (1 l_BRENT l_STK l_CARBONE l_EUR_USD l_EURO_50 EURIBOR)/* heteroscedasticité oui */
			Godfrey = 1; /* auto corrélation oui */
Title " Instrumental variable (1) ";
run;

/*Hansen test for exogeneity of instruments */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent  ;
Instruments _exog_ l_LAG_ERIX l_LAG_BRENT ;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / GMM ;
Title " Hansen test (1)";
run;  
/* Statistic is 44.7 so instruments are endogenous */

/* Instruments (2) */

/*Estimation by IV with Homogeneity and Autocorrelation tests */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_EUR_USD;
Endogenous l_erix l_brent ;
Instruments _exog_ l_LAG_STK l_LAG_CARBONE l_LAG_EURO_50 l_LAG_EUR_USD LAG_EURIBOR ;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / 2SLS 
			White Breusch = (1 l_BRENT l_STK l_CARBONE l_EUR_USD l_EURO_50 EURIBOR)/* heteroscedasticité oui */
			Godfrey = 1; /* auto corrélation oui */
Title "  Instrumental variable (2)";
run;

/*Hansen test for exogeneity of instruments */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent  ;
Instruments _exog_ l_LAG_STK l_LAG_CARBONE l_LAG_EURO_50 l_LAG_EUR_USD LAG_EURIBOR ;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / GMM;
Title " Hansen test (2)";
run;  
/* Statistic is 2.70 so instruments are exogenous */

/* we operate the test as if we have one endogenous regressors and IID disturbances (Cas A dans le cours)*/
proc reg data = out.data_log_2013 plots=none ;
model  l_brent = l_LAG_STK l_LAG_CARBONE l_LAG_EURO_50 l_LAG_EUR_USD LAG_EURIBOR l_CARBONE l_EURO_50 EURIBOR l_STK l_EUR_USD;
test l_LAG_STK=0, l_LAG_CARBONE=0, l_LAG_EUR_USD=0, l_LAG_euro_50=0, LAG_EURIBOR=0; 
Title " Test weak instruments (1) ";
run; 
/* Qf <10: weak instruments */

/* Instruments (3) */

/*Estimation by IV with Homogeneity and Autocorrelation tests */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_EUR_USD;
Endogenous l_erix l_brent ;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_LAG15_EUR_USD;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / 2SLS 
			White Breusch = (1 l_BRENT l_STK l_CARBONE l_EUR_USD l_EURO_50 EURIBOR)/* heteroscedasticité oui */
			Godfrey = 1; /* auto corrélation oui */
Title "  Instrumental variable (3) ";
run;

/*Hansen test for exogeneity of instruments */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent  ;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_LAG15_EUR_USD;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / GMM;
Title " Hansen test (3)";
run;  
/* Statistic is 4.74 so instruments are exogenous */

/* we operate the test as if we have one endogenous regressors and IID disturbances (Cas A dans le cours)*/
proc reg data = out.data_log_2013 plots=none ;
model  l_brent = l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_LAG15_EUR_USD l_CARBONE l_EURO_50 EURIBOR l_STK l_EUR_USD;
test l_LAG15_STK=0, l_LAG15_CARBONE=0, l_LAG15_EUR_USD=0, l_LAG_euro_50=0; 
Title " Test weak instruments (2) ";
run; 
/*Qf >10, strong instruments */

/* Since we have non iid disturbances, estimation by GMM */

proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent  ;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_LAG15_EUR_USD;
l_ERIX = b0+ b_brent*l_BRENT + b_Eur_USD*l_EUR_USD +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR; 
Fit l_ERIX / GMM KERNEL=(bart,2,0);
Title " Estimation by Generalized Method of Moments (linear)";
run; 




/*test exogeneity of regressors (once our instruments have passed validity test de validités, 
			we want to know if our regressors are no more endogenous */

/*Step 8.1*/

proc reg data = out.data_log_2013 plots=none;
model  l_brent =  l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_LAG15_EUR_USD;
output out = pred_x_endog P=p_xstar R=r_xstar;
title 'get predicted values of regression of endogenous regressors on the instruments';
run;

/* Step 8.2 and 8.3: */

proc model data = pred_x_endog plots = none;
Exogenous l_BRENT l_EUR_USD l_CARBONE l_EURO_50 EURIBOR l_STK r_xstar;
Endogenous l_ERIX ;
instruments _exog_;
l_ERIX = b0+ b_brent*l_BRENT + b_l_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE + 
		 b_euro_50*l_EURO_50+b_euribor*EURIBOR + c1*r_xstar;
Fit l_ERIX / GMM KERNEL = (BART,2,0);
Test c1 = 0; /* different de 0, donc il existe au moins un regresseur endogène.. */
title 'Test for endogenous regressors';
run; 




/* Estimation by FGLS */
PROC REG DATA = out.data_log_2013 plots=none;
model l_ERIX = l_BRENT l_EUR_USD l_STK l_CARBONE l_EURO_50 EURIBOR;
output out= residuals r=rhat;
title "Residuals";RUN;
 
data out.data_log_2013; set residuals; run;
 
/* Estimating the variances of u(i) */
data out.data_log_2013; set out.data_log_2013;
resid2 = rhat*rhat;
log_u2 = log(resid2);
run;
 
/* ETAPE PROBLEMATIQUE : Régresser sur toutes les variables ? */
proc reg data = out.data_log_2013 outest = stats  rsquare plots = none;
model log_u2 = l_brent l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR ; /*!!! régresser sur toutes les variables? */
output out = pred_u2 p = pred_log_u2;
run;
 
data out.data_log_2013; set pred_u2; run;
 
data out.data_log_2013; set out.data_log_2013;
sigma2 = exp(pred_log_u2); /* Estimated variance of u(i) */
one_over_sigma = 1/(sigma2**0.5); /* computes 1/sigma to be used later as weight for correcting for heteroskedasticity */ 
run;
 
/* = Feasible GLS on the augmented regression y */ 
proc reg data = out.data_log_2013 plots = none;
model l_ERIX = l_BRENT l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR;
weight one_over_sigma; /* This corrects for heteroskedasticity */
run;



/************************* STEP 5: Autoregressive regression ********************************/
DATA out.data_log_2013; set out.data_log_2013;
l_LAG15_ERIX = lag15(l_ERIX);
run;

/**** OLS estimations and test ***/
proc model data = out.data_log_2013 plots=none;
l_ERIX = b0+ b_brent*l_BRENT + b_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50 +b_euribor*EURIBOR+b_erix*l_LAG_ERIX;
Fit l_ERIX /white Breusch = (1 l_BRENT l_STK l_CARBONE l_eur_usd l_EURO_50 euribor l_lag_erix) /*Heteroskedasticity*/
			Dw Godfrey = 1;/*No serial correlation */
title "OLS: Autoregressive model" ;
run;

/*Estimation by IV with Homogeneity and Autocorrelation tests */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent l_LAG_ERIX;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_lag15_eur_usd  l_LAG15_ERIX ;
l_ERIX = b0+ b_brent*l_BRENT + b_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR+b_erix*l_LAG_ERIX;
Fit l_ERIX / 2SLS
			Breusch = (1 l_BRENT l_STK l_CARBONE l_brent_rate l_EURO_50 l_LAG_ERIX)/*Heteroskedasticity*/
            DW Godfrey = 1; /*Serial correlation */
Title1 " Instrumental variable (4) ";
Title2 "test Homoskedasticity and Serial correlation";
run;

/*Hansen test for exogeneity of instruments */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent l_LAG_ERIX;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_lag15_eur_usd  l_LAG15_ERIX  ;
l_ERIX = b0+ b_brent*l_BRENT + b_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR+b_erix*l_LAG_ERIX;
Fit l_ERIX / GMM;
Title1 " Hansen test (4) ";
Title2 "Hansen test because disturbances are heteroskedastics and serial correlated";
run; 

/* we operate the test as if we have one endogenous regressors and IID disturbances (Cas A dans le cours)*/
proc reg data = out.data_log_2013  plots = none;
model l_brent l_lag_erix = l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd l_lag15_CARBONE l_lag_EURO_50 l_lag15_EUR_usd l_lag15_STK l_LAG15_ERIX;
output out = brent_resid r = brent_residuals; 
test l_lag15_CARBONE=0, l_lag_EURO_50=0, l_lag15_EUR_usd =0, l_lag15_STK=0, l_LAG15_ERIX=0; 
title "Test weak instruments (3)";
run;

/* Since we have non iid disturbances, estimation by GMM */
proc model data = out.data_log_2013 plots=none;
Exogenous l_CARBONE l_EURO_50 EURIBOR l_STK l_eur_usd;
Endogenous l_erix l_brent l_LAG_ERIX;
Instruments _exog_ l_LAG15_STK l_LAG15_CARBONE l_LAG_EURO_50 l_lag15_eur_usd  l_LAG15_ERIX  ;
l_ERIX = b0+ b_brent*l_BRENT + b_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE + b_euro_50*l_EURO_50+b_euribor*EURIBOR+b_erix*l_LAG_ERIX;
Fit l_ERIX / GMM KERNEL = (BART,2,0);
Title1 "  Estimation by Generalized Method of Moments (Autoregressive) ";
run;

/*test exogeneity of regressors (once our instruments have passed validity test de validités, 
			we want to know if our regressors are no more endogenous */

/*Step 8.1 */

proc reg data = out.data_log_2013 plots=none;
model l_brent l_lag_erix=  l_lag15_CARBONE l_lag_EURO_50 l_lag15_EUR_usd l_lag15_STK l_lag15_erix;
output out = pred_x_endog P=p_star R=r_star;
title 'get predicted values of regression of endogenous regressors on the instruments';
run;

/* Step 8.2 and 8.3: */

proc model data = pred_x_endog plots=none;
Exogenous l_BRENT l_eur_usd l_lag_erix l_CARBONE l_EURO_50 EURIBOR l_STK r_star;
Endogenous l_ERIX;
instruments _exog_;
l_ERIX = b0+ b_brent*l_BRENT + b_eur_usd*l_eur_usd +b_stk*l_STK + b_carbone*l_CARBONE +
         b_euro_50*l_EURO_50+b_euribor*EURIBOR+b_erix*l_lag_erix + c1*r_star;
Fit l_ERIX / GMM KERNEL = (BART,2,0);
Test c1 = 0; /* Non significativement différent de 0 donc il n'y a pas de regresseurs endogènes */
title 'Test for endogenous regressors';
run;

/** FGLS **/

PROC REG DATA = out.data_log_2013 plots=none;
model l_ERIX = l_BRENT l_EUR_USD l_STK l_CARBONE l_EURO_50 EURIBOR l_LAG_ERIX;
output out= residuals.A r=rhat.A;
title "Residuals";RUN;
 
data out.data_log_2013; set residuals.A; run;
 
/* Estimating the variances of u(i) */
data out.data_log_2013; set out.data_log_2013;
resid2.A = rhat.A*rhat.A;
log_u2.A = log(resid2.A);
run;
 
/* ETAPE PROBLEMATIQUE : Régresser sur toutes les variables ? */
proc reg data = out.data_log_2013 outest = stats  rsquare plots = none;
model log_u2.A = l_brent l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR l_LAG_ERIX; /*!!! régresser sur toutes les variables? */
output out = pred_u2.A p = pred_log_u2.A;
run;
 
data out.data_log_2013; set pred_u2.A; run;
 
data out.data_log_2013; set out.data_log_2013;
sigma2.A = exp(pred_log_u2.A); /* Estimated variance of u(i) */
one_over_sigma.A = 1/(sigma2.A**0.5); /* computes 1/sigma to be used later as weight for correcting for heteroskedasticity */ 
run;
 
/* = Feasible GLS on the augmented regression y */ 
proc reg data = out.data_log_2013 plots = none;
model l_ERIX = l_BRENT l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR l_LAG_erix;
weight one_over_sigma.A; /* This corrects for heteroskedasticity */
run;

/************************* STEP 6: PROC AUTOREG / GARCH ********************************/

proc autoreg data = out.data_log_2013 plots = none;
model l_ERIX =l_BRENT l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR /archtest;
title "AUTOREG: archtest";
run;

proc autoreg data = out.data_log_2013 plots = none;
model l_ERIX =l_BRENT l_eur_usd l_STK l_CARBONE l_EURO_50 EURIBOR / garch = (q=1);
title "AUTOREG: garch option";
run;

