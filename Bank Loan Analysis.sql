create database bank;
use bank;
select count(*) from finance1;
select count(*) from finance2;

-- Checking duplicates from Table 1
with e as(select *,row_number() over(partition by id, member_id, loan_amnt, funded_amnt, funded_amnt_inv, term, int_rate, 
installment, grade, sub_grade, emp_length, home_ownership, annual_inc, verification_status, issue_d, loan_status,
 purpose, zip_code, addr_state, dti) row_no
 from finance1)
 select * from e where row_no > 1;
 
 -- Checking duplicates from Table 2
 with e as(select *,row_number() over(partition by id, delinq_2yrs, earliest_cr_line, inq_last_6mths, mths_since_last_delinq, 
 mths_since_last_record, open_acc, pub_rec, revol_bal, revol_util, total_acc, out_prncp, out_prncp_inv, total_pymnt, 
 total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee, recoveries, collection_recovery_fee, last_pymnt_d,
 last_pymnt_amnt, next_pymnt_d, last_credit_pull_d) row_no
 from finance2)
 select * from e where row_no > 1;


-- Q1 Year wise loan amount Status
select year(issue_d) years,CONCAT(round(sum(loan_amnt/1000000),0),'M') Total_loan_amount
from finance1
group by years
order by years;


-- Q2 Grade and sub grade wise revol_bal
select f1.grade,f1.sub_grade,concat(round(sum(f2.revol_bal/1000000),0),'M')rev_bal
from finance1 f1
inner join finance2 f2
on f1.id = f2.id
group by f1.grade,f1.sub_grade
order by f1.grade,rev_bal desc;


-- Q3 Total Payment for Verified Status Vs Total Payment for Non Verified Status
select f1.verification_status, concat(round(sum(f2.total_pymnt/1000000),0),'M') total_pay,
CONCAT(ROUND(SUM(f2.total_pymnt) * 100 / SUM(SUM(f2.total_pymnt)) OVER(), 2), '%') AS percentage_of_total
from finance1 f1
inner join finance2 f2
on f1.id = f2.id
where f1.verification_status in('Verified','Not Verified')
group by f1.verification_status;


-- Q4 State and month wise loan status
select addr_state, monthname(issue_d) Months,loan_status,count(loan_status) Total_loan
from finance1 
group by addr_state,Months,loan_status
order by Total_loan desc;


-- Q5 Home ownership Vs last payment date status
select f1.home_ownership, count(f2.last_pymnt_d) Total_count
from finance1 f1
inner join finance2 f2
on f1.id = f2.id
group by f1.home_ownership
order by Total_count desc;