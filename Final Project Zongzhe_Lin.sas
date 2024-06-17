libname lb "/home/u63617625/nonshare_files/Final";

proc import datafile="/home/u63617625/nonshare_files/Final/CaseSubset.csv"
   out=lb.casesubset
   dbms=csv
   replace;
run;

data filter;
  set lb.casesubset;
  if SUBSETNUMBER = 24;
run;


PROC SORT DATA = filter; BY CASEID_NEW; run;
PROC SORT DATA = lb.hcmst; by CASEID_NEW; run;


/* #2700 total   */
data final;
	merge filter (IN=IND1)
		lb.hcmst (IN=IND2);
	by CASEID_NEW;
	IF IND1 AND IND2;
run;
/* #2700 total   */


proc format;
    value genderfmt
    1 = 'Male'
    2 = 'Female';
run;

proc format;
    value relationshipformat
    1 = 'Excellent'
    0 = 'NotExcellent';
run;



data final;
	set final;
	Indicator = 0;
	if (PPAGE - Q9 <= 5) and (PPAGE - Q9 >= -5) then Indicator = 1;
	else if Q9 = . or ppage = . then Indicator = .;
run;


data final;
    set final;
    if RELATIONSHIP_QUALITY = 5 then Indicator2 = 1;
    else if RELATIONSHIP_QUALITY = . then Indicator2 = .;
    else Indicator2 = 0;
run;


options spool;

/* Final  */
%MACRO Benbi(varname, varlabel, varformat, data);

ods exclude all;

ods output CrossTabFreqs=CTF (where=(Q31_1 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));	   
proc freq data= &data; 
	table Q31_1 * &varname/NOPERCENT NOCOL CHISQ;
run;

proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;

data CSCTF;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Work"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;



ods output CrossTabFreqs=CTF (where=(Q31_2 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_2 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF2;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31School"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;


ods output CrossTabFreqs=CTF (where=(Q31_3 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_3 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF3;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Church"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;

ods output CrossTabFreqs=CTF (where=(Q31_4 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_4 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF4;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Internet"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;



ods output CrossTabFreqs=CTF (where=(Q31_5 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_5 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF5;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Vocation"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;


ods output CrossTabFreqs=CTF (where=(Q31_6 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_6 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF6;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Club"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;


ods output CrossTabFreqs=CTF (where=(Q31_7 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_7 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF7;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Organization"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;


ods output CrossTabFreqs=CTF (where=(Q31_8 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_8 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF8;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Party"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;

ods output CrossTabFreqs=CTF (where=(Q31_9 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q31_9 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF9;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "31Other"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;






ods output CrossTabFreqs=CTF (where=(Q33_1 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_1 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF11;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Family"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;






ods output CrossTabFreqs=CTF (where=(Q33_2 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_2 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF12;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Friends"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;






ods output CrossTabFreqs=CTF (where=(Q33_3 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_3 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF13;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Co-workers"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;



ods output CrossTabFreqs=CTF (where=(Q33_4 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_4 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF14;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Classmates"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;




ods output CrossTabFreqs=CTF (where=(Q33_5 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_5 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF15;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Neighbors"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;


ods output CrossTabFreqs=CTF (where=(Q33_6 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_6 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF16;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Self"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;





ods output CrossTabFreqs=CTF (where=(Q33_7 = 1 & RowPercent ne .))
 		   ChiSq=CS (where=(statistic="Chi-Square"));
proc freq data= &data;
	table Q33_7 * &varname/NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF; by table; run;
proc sort data=CS; by table; run;
data CSCTF17;
    merge CTF(in=a) CS(in=b);
    by table;
    if a and b; 
    question = "33Other.2"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;

ods output CrossTabFreqs=CTF_AgeDiff (where=(Indicator = 1))
    ChiSq=CS_AgeDiff (where=(statistic="Chi-Square"));
proc freq data=&data;
    tables Indicator * &varname /NOPERCENT NOCOL CHISQ;
run;
proc sort data=CTF_AgeDiff; by table; run;
proc sort data=CS_AgeDiff; by table; run;
data CSCTF_AgeDiff;
    merge CTF_AgeDiff(in=a) CS_AgeDiff(in=b);
    by table;
    if a and b;
    question = "AgeDifference"; 
    varlabel = "&varlabel";
    keep varlabel &varname frequency rowpercent prob question;
run;
    
    
data combined;
 length varlabel $30.;
 set CSCTF_AgeDiff CSCTF CSCTF2 CSCTF3 CSCTF4 CSCTF5 CSCTF6 CSCTF7 CSCTF8 CSCTF9 CSCTF11 CSCTF12 CSCTF13 CSCTF14 CSCTF15 CSCTF16 CSCTF17;
 if question in ('31Club', '31Church', '31Internet', '31Organizatio', '31Other', '31Party', '31School', '31Vocation', '31Work') then category = 1;
 else if question in ('33Classmates', '33Co-workers', '33Family', '33Other.2', '33Friends', '33Neighbors', '330ther.2', '33Self') then category = 2;
 else if question = 'AgeDifference' then category = 3;
run;

ods exclude none;



proc tabulate data=combined;
    class question &varname category;
    var frequency rowpercent prob; 
    table category*question, (&varname*(frequency="N"*f=6. rowpercent="%"*f=6.2))*sum=""ALL*prob*mean*f=10.4 ; 
    label &varname = "&varlabel";
    format &varname &varformat.. ;
run;

%mend Benbi;

%Benbi(PPGENDER, Gender, genderfmt, final);
/* Final  */



/* Final 2 */

%Benbi(Indicator2, Relationship, relationshipformat, final);

















