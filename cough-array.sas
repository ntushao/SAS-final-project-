proc import datafile="\\Client\H$\Downloads\cough.xls"
out=cough dbms=xls;
run;
proc sort data=cough nodup;
by sid date;
run;
data cough2;
set cough;
by sid date;
if first.sid then n=1;
else n+1;
run;
proc transpose data=cough out=wide;
by sid;
var date;
run;
/*key part: use arrays to define the upper and lower bounds of cough time*/
data test1 (keep=sid i j);
set wide;
array coughtime (25)  col1-col25;
array coughtime_120 (25) upper1-upper25;
array coughtime_56 (25) lower1-lower25;
do k=1 to 25;
coughtime_120[k]=coughtime[k]+120;
coughtime_56[k]=coughtime[k]+56;
if coughtime[k]=. then coughtime[k]=0;
if coughtime_120[k]=. then coughtime_120[k]=0;
if coughtime_56[k]=. then coughtime_56[k]=0;
end;
do i=3 to 25;
do j=1 to 23;
if i>=j+2 and coughtime_56[j]<coughtime[i]<coughtime_120[j] then output;
end;
end;
run;
/*Output the data*/
proc sql;
create table test2 as
select cough2.sid,date,n,j
from cough2
left join test1
on cough2.sid=test1.sid and n=i;
quit;
data final;
set test2;
if j ne . then cough_type="chronic";
run;
proc export data=final
outfile="\\Client\H$\Downloads\final.xlsx";
run;


