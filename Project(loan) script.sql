use finance;
select * from loan;

					-------------------------------
					--           KPI's           --
					-------------------------------
-----------------------------------------------------------------------------------

--Total Loan Applications
select count(*) as Total_applications from loan;

-----------------------------------------------------------------------------------

--Month To date Applications
select count(*) as MTD_applications 
from loan
where month(issue_date) = (select top 1 month(issue_date) 
						   from loan 
						   order by issue_date desc)

-----------------------------------------------------------------------------------

--Month on Month % growth in application
with cte as(
select (select count(loan_amount) as PMTD_applications 
        from loan
        where month(issue_date) = (select top 1 month(dateadd(month,-1,issue_date))
						           from loan 
						           order by issue_date desc)) as PMTD_applications,
       (select count(loan_amount) as MTD_applications 
       from loan
       where month(issue_date) = (select top 1 month(issue_date) 
						          from loan 
						          order by issue_date desc)) as MTD_applications)
select format((cast(MTD_applications as decimal)-cast(PMTD_applications as decimal))/cast(PMTD_applications as decimal),'0.00 %') as '% MoM growth'
from cte

-----------------------------------------------------------------------------------

--Total Funded Amount
select sum(loan_amount) as 'Total Funded Amount' from loan

-----------------------------------------------------------------------------------

--MTD Total Funded Amount
select sum(loan_amount) as 'MTD Total FA' from loan
where month(issue_date) =(select top 1 month(issue_date) 
								from loan 
								order by issue_date desc)

-----------------------------------------------------------------------------------

--MoM % growth in Funded Amount
with cte as(
select (select sum(loan_amount) as PMTD_LA 
			from loan
			where month(issue_date) = (select top 1 month(dateadd(month,-1,issue_date))
											from loan 
											order by issue_date desc)) as PMTD_LA,
       (select sum(loan_amount) as MTD_LA 
			from loan
			where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)) as MTD_LA)
select (MTD_LA-PMTD_LA)*100/PMTD_LA as '% MoM growth(FA)'  --FA stands for funded amount
from cte

-----------------------------------------------------------------------------------

--Total Amount Received
select sum(total_payment) as 'Total AR' from loan

-----------------------------------------------------------------------------------

--MTD Total Amount Received
select sum(total_payment) as 'MTD Total AR' from loan
where month(issue_date) =(select top 1 month(issue_date) 
								from loan 
								order by issue_date desc)

-----------------------------------------------------------------------------------

--% MoM Growth in Amount Received
with cte as(
select (select sum(total_payment) as PMTD_AR 
			from loan
			where month(issue_date) = (select top 1 month(dateadd(month,-1,issue_date))
											from loan 
											order by issue_date desc)) as PMTD_AR,
       (select sum(total_payment) as MTD_AR 
			from loan
			where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)) as MTD_AR)
select (MTD_AR-PMTD_AR)*100/PMTD_AR as '% MoM growth(AR)'  --AR stands for Amount Recieved
from cte

-----------------------------------------------------------------------------------

--Average Interest Rate(IR)
select round(AVG(int_rate)*100,2) as 'AVG IR' from loan

-----------------------------------------------------------------------------------

--MTD Avg IR
select round(AVG(int_rate)*100,2) as 'AVG IR' from loan
where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)

-----------------------------------------------------------------------------------

--MoM Increase in IR
with cte as(
select (select round(AVG(int_rate)*100,2) as PAVG_IR    --Previous Month Avg IR
			from loan
			where month(issue_date) = (select top 1 month(dateadd(month,-1,issue_date))
											from loan 
											order by issue_date desc)) as  PAVG_IR,
       (select round(AVG(int_rate)*100,2) as AVG_IR 
			from loan
			where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)) as AVG_IR)
select round((AVG_IR-PAVG_IR)*1,4) as 'MoM change(IR)'  --IR stands for Interest Rate
from cte

-----------------------------------------------------------------------------------

--Average Debt to Income (DTI)
select ROUND(AVG(dti),4)*100 as Avg_DTI from loan

-----------------------------------------------------------------------------------

--Avg MTD Debt to income(DTI)
select ROUND(AVG(dti),4)*100 as Avg_DTI from loan
where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)

-----------------------------------------------------------------------------------

--Change(increase/decrease) in MTD Avg_DTI percentage

with cte as(
select (select ROUND(AVG(dti),4)*100 as PyAvg_DTI    --Previous Month Avg DTI
			from loan
			where month(issue_date) = (select top 1 month(dateadd(month,-1,issue_date))
											from loan 
											order by issue_date desc)) as  PyAvg_DTI,
       (select ROUND(AVG(dti),4)*100 as Avg_DTI
			from loan
			where month(issue_date) = (select top 1 month(issue_date) 
											from loan 
											order by issue_date desc)) as Avg_DTI)
select round((Avg_DTI-PyAvg_DTI)*1,4) as MoM_change_DTI 
from cte

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

--Good Loan Applications
select count(*) as good_Loan_Applications from loan
where loan_status = 'Fully Paid' or loan_status = 'current'

-----------------------------------------------------------------------------------

--Good Loan Application Percentage
select round((select count(loan_status) from loan 
		where loan_status = 'fully paid' or loan_status = 'current')*100/
	  (select count(*) from loan),4) as Good_loan_per

-----------------------------------------------------------------------------------

--Good Loan Funded Amount(FA)
select Sum(loan_amount) as Good_loan_FA from loan
where loan_status in('fully paid','current')

-----------------------------------------------------------------------------------

--Good Loan Total Amount Received(AR)
select Sum(total_payment) as Good_loan_AR from loan
where loan_status in('fully paid','current')

-----------------------------------------------------------------------------------

--Bad loan Applications
select count(*) as Bad_Loan_Applications from loan
where loan_status = 'Charged Off'	

-----------------------------------------------------------------------------------
--Bad Loan Aplication Percentage
select round((select count(loan_status) from loan 
		where loan_status = 'Charged Off')*100/
	  (select count(*) from loan),4) as Bad_loan_per

-----------------------------------------------------------------------------------

--Bad Loan Funded Amount
select Sum(loan_amount) as Bad_loan_FA from loan
where loan_status = 'Charged Off'

-----------------------------------------------------------------------------------

--Bad Loan Amount Recieved
select Sum(total_payment) as Good_loan_AR from loan
where loan_status = 'Charged Off'

-----------------------------------------------------------------------------------

--Money Lost In Bad Loan
select((select Sum(loan_amount) as Bad_loan_FA from loan
		where loan_status = 'Charged Off')-
		(select Sum(total_payment) as Good_loan_AR from loan
		where loan_status = 'Charged Off')) as Money_lost_BadLoan

-----------------------------------------------------------------------------------
					-------------------------------
					--           Tables          --
					-------------------------------
-----------------------------------------------------------------------------------

--Loan Status Table
select loan_status,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments,
	Count(id) as Applications,
	round(Avg(dti)*100,2) as AVG_DTI,
	round(AVg(int_rate)*100,2) as Avg_interest
 from loan
 group by loan_status

-----------------------------------------------------------------------------------

--MTD Loan Status Table
select loan_status,
	sum(loan_amount) as MTD_Funded_Amount,
	sum(total_payment) as MTD_Amount_Received
from loan
where Month(issue_date) = (select top 1 month(issue_date) 
						   from loan 
						   order by issue_date desc)
group by Loan_status

-----------------------------------------------------------------------------------

--Monthly Trends By Issue Date
select 
	FORMAT(issue_date,'MMM') as Month,
	Count(id) as Applications,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments	
from loan
group by FORMAT(issue_date,'MMM'),FORMAT(issue_date,'MM')
order by FORMAT(issue_date,'MM')

-----------------------------------------------------------------------------------

--Regional Analysis By State
select 
	address_state,
	Count(id) as Applications,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments	
from loan
group by address_state
order by Count(id) desc 

-----------------------------------------------------------------------------------

--Loan Term Analysis
select
	term,
	concat(
		format(
			round(
				cast(Count(id) as decimal)*100/(select cast(Count(id) as decimal) from loan),3),'.000'),' %') as Applications,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments
from loan
group by term
order by term  

-----------------------------------------------------------------------------------

--Employee Length Analysis
select 
	emp_length,
	count(id) as Applications,
	concat(
		format(
			round(
				cast(Count(id) as decimal)*100/(select cast(Count(id) as decimal) from loan),3),'.000'),' %') as Applications_Percentage,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments	
from loan
group by emp_length
order by count(id) desc

-----------------------------------------------------------------------------------

--Loan Purpose Breakdown
select 
	purpose,
	Count(id) as Applications,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments	
from loan
group by purpose
order by Count(id) desc 

-----------------------------------------------------------------------------------

--Home Ownership Analysis
select 
	home_ownership,
	Count(id) as Applications,
	sum(loan_amount) as Loan_amount,
	sum(total_payment) as Total_payments	
from loan
group by home_ownership
order by Count(id) desc 

-----------------------------------------------------------------------------------

--GRADE ANALYSIS
select 
	grade,
	count(id) as Applications,
	concat(
		format(
			round(
				cast(Count(id) as decimal)*100/(select cast(Count(id) as decimal) from loan),3),'0.000'),' %') as Applications_Percentage
from loan
group by grade
order by grade

------------------------------------*********--------------------------------------
------------------------------------*********--------------------------------------