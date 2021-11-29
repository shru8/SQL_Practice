
CREATE TABLE emp4(
category  varchar(20),
Sequence1  int )

INSERT INTO emp4 VALUES('A',1)
INSERT INTO emp4 VALUES('A',2)
INSERT INTO emp4 VALUES('A',3)
INSERT INTO emp4 VALUES('A',5)
INSERT INTO emp4 VALUES('A',6)
INSERT INTO emp4 VALUES('A',8)
INSERT INTO emp4 VALUES('A',9)
INSERT INTO emp4 VALUES('B',11)
INSERT INTO emp4 VALUES('C',1)
INSERT INTO emp4 VALUES('C',2)
INSERT INTO emp4 VALUES('C',3)

--Assign unique row number to each 

select category, Sequence1, row_number() over (partition by category order by sequence1) AS rnk 
from emp4

--determine group split

select category, Sequence1, sequence1 - row_number() over (partition by category order by sequence1) AS group_split
from emp4  

--compile both result sets to group by group_splits 

select category, MIN(sequence1), MAX(sequence1)
from
(
select category, Sequence1, sequence1 - row_number() over (partition by category order by sequence1) AS group_split
from emp4 ) A 

group by category, group_split 

--Alternate way :make another table
 
select category, MIN(sequence1), MAX(sequence1)
from 
(select category, Sequence1, Sequence1 -  row_number() over (partition by category order by sequence1) AS group_split
from emp4) rs  
group by category, group_split 

--why doesn't this work 
select category, MIN(sequence1), MAX(sequence1), Sequence1 - row_number() over (partition by category order by sequence1) AS group_split
from emp4 
group by group_split 

CREATE TABLE [dbo].[Transaction_Tbl](
 [CustID] [int] ,
 [TranID] [int] ,
 [TranAmt] [float] ,
 [TranDate] [date] 
) 

INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1001, 20001, 10000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1001, 20002, 15000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1001, 20003, 80000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1001, 20004, 20000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1002, 30001, 7000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1002, 30002, 15000, CAST('2020-04-25' AS Date))
INSERT [dbo].[Transaction_Tbl] ([CustID], [TranID], [TranAmt], [TranDate]) VALUES (1002, 30003, 22000, CAST('2020-04-25' AS Date))


select * from Transaction_Tbl

--calculating max tranAmt and ratio for every custID 

Select custID, TranAmt, max(TranAmt) over(partition by CustID) AS maxtranamt, TranAmt/(max(TranAmt) over(partition by CustID)) AS ratio 
from Transaction_Tbl 

select *, 
MaxTranAmt = max(TranAmt) over(partition by CustID),
Ratio = TranAmt / (max(TranAmt) over(partition by CustID)),
TranDate
from  Transaction_Tbl

--combining two result sets from CTE's 
--why doesn't this work 

WITH CTE (custID, tranID, tranAmt) AS
(
select custID, TranAmt, max(tranamt) over (partition by custID order by custID) AS max_tran_amt FROM Transaction_Tbl
), 

cte1(custID, ratio, TranAmt) AS
(
select custID, TranAmt, tranAmt/max_tran_amt AS ratio from CTE
) 

select custID, tranAmt, max_tran_amt, ratio 
from cte1 

CREATE TABLE Stu(
[Student_Name]  varchar(30),
[Total_Marks]  int ,
[Year]  int)

INSERT INTO Stu VALUES('Rahul',90,2010)
INSERT INTO Stu VALUES('Sanjay',80,2010)
INSERT INTO Stu VALUES('Mohan',70,2010)
INSERT INTO Stu VALUES('Rahul',90,2011)
INSERT INTO Stu VALUES('Sanjay',85,2011)
INSERT INTO Stu VALUES('Mohan',65,2011)
INSERT INTO Stu VALUES('Rahul',80,2012)
INSERT INTO Stu VALUES('Sanjay',80,2012)
INSERT INTO Stu VALUES('Mohan',90,2012)

select * from Stu


select student_name, total_marks 
from stu 
group by Student_Name, Total_Marks 

--display only that data where prev_yr_marks < total_marks 

with CTE(Student_name, total_marks, [year], prev_yr_marks) AS
(select student_name, total_marks, [year], LAG(Total_Marks) over (partition by student_name order by [year]) AS prev_yr_marks  
from stu ) 

select student_name, total_marks, [year], prev_yr_marks  
from 
--(
--select student_name, total_marks, [year], LAG(Total_Marks) over (partition by student_name order by [year]) AS prev_yr_marks  
--from stu 
--) B 
CTE 
where prev_yr_marks <= Total_Marks 

--using self join

Select a.student_name ,a.total_marks , a.year, b.total_marks "prev_year_marks" 
From student a 
   inner join student b on a. student_name=b. Student_Name 
    AND  a. total_marks >= b.total_marks and a.year = b.year + 1


CREATE TABLE [Order_Tbl](
 [ORDER_DAY] date,
 [ORDER_ID] varchar(10) ,
 [PRODUCT_ID] varchar(10) ,
 [QUANTITY] int ,
 [PRICE] int 
) 

INSERT INTO [Order_Tbl]  VALUES ('2015-05-01','ODR1', 'PROD1', 5, 5)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-01','ODR2', 'PROD2', 2, 10)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-01','ODR3', 'PROD3', 10, 25)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-01','ODR4', 'PROD1', 20, 5)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR5', 'PROD3', 5, 25)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR6', 'PROD4', 6, 20)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR7', 'PROD1', 2, 5)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR8', 'PROD5', 1, 50)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR9', 'PROD6', 2, 50)
INSERT INTO [Order_Tbl]  VALUES ('2015-05-02','ODR10','PROD2', 4, 10)

select * from Order_Tbl

select [Quantity] * [Price] AS sold_amt, [Order_ID], [Product_ID], [order_day]
from Order_Tbl 

--Q1 Highest sold products along with product_ID and grouped by order_day 

--why doesn't this work 
select MAX(sold_amt),[PRODUCT_ID], [ORDER_DAY]
from 
(select [Quantity] * [Price] AS sold_amt, [Order_ID], [Product_ID], [order_day]
from Order_Tbl ) B
group by [ORDER_DAY] --[order_day], [PRODUCT_ID]


--compute maximum quantity and price in a result set 
select MAX([Quantity] * [Price]) AS sold_amt, [order_day]
from Order_Tbl
group by [ORDER_DAY]

--take respective product_id with highest sold in another result set

  select ([Quantity] * [Price]) AS sold_amt, [Order_Day], [Product_ID] 
  from Order_tbl 
  
 --combine both to get product_ID's of highest sold products 

select A.sold_amt, B.[PRODUCT_ID], A.[ORDER_DAY] 
from 
(
	select MAX([Quantity] * [Price]) AS sold_amt, [order_day]
	from Order_Tbl
	group by [ORDER_DAY]) as A 
inner join 
(
  select ([Quantity] * [Price]) AS sold_amt, [Order_Day], [Product_ID] 
  from Order_tbl 
 )  as B 
on A.sold_amt = B.sold_amt AND A.[ORDER_DAY] = B.[ORDER_DAY] 

--Using Window function

select [Order_DAY], amt_sold
from (
select ROW_NUMBER () over (partition by (order_day) order by (price * quantity) desc) as MAX_PRICE, [Order_DAY], (price * quantity) AS amt_sold
from Order_Tbl ) as A 
where A. MAX_Price = 1 

--window functions enable you to aggregate and filter in the same line

--all products total sales on 1rst and 2nd May adjacent to each other 

select * from Order_Tbl

product_ID, total_sales1, total_sales2 

select ROW_NUMBER () over (partition by [Order_Day] order by ([quantity]*[price]) desc) AS unique_no, [Order_Day], [product_ID] 
from Order_Tbl

SELECT product_ID, SUM(CASE WHEN [Order_Day] = '2015-05-01' THEN quantity * price ELSE 0 END) AS total_salesMay01,
SUM(CASE WHEN ORDER_DAY = '2015-05-02' THEN quantity * price ELSE 0 END) AS total_salesMay02
from Order_Tbl 
GROUP BY product_ID 

--count days that were ordered twice

select [Order_day], [PRODUCT_ID], count(*)  
from Order_Tbl 
group by 1,2 
having count(*) >= 1 

--recursive CTE 

 CREATE TABLE ORDER_TABLE
(
Order_ID VARCHAR(30),
Product_ID VARCHAR(30),
Quantity INT
)

--Drop table ORDER_TABLE

INSERT INTO ORDER_TABLE VALUES ('ODR1','PRD1',5)
INSERT INTO ORDER_TABLE VALUES ('ODR2','PRD2',1)
INSERT INTO ORDER_TABLE VALUES ('ODR3','PRD3',3)

select * from ORDER_TABLE 

--single row for every single unit quantity 

--make temporary base resultset 
with CTE AS
(
	select order_id, product_id, 1 AS quantity, 1 AS cnt 
	from ORDER_TABLE 

	UNION ALL 

	select A.Order_ID, A.Product_ID, B.cnt+1, B.quantity 
	from ORDER_TABLE A inner join CTE as B on  
	A.Product_ID = B.product_ID
	where B.cnt + 1 <= A.quantity
)

	select order_ID, product_ID, quantity 
	from CTE 
	order by product_ID, order_ID


CREATE Table Employee
(
EmpID INT,
EmpName Varchar(30),
Salary Float,
DeptID INT
)


INSERT INTO Employee VALUES(1001,'Mark',60000,2)
INSERT INTO Employee VALUES(1002,'Antony',40000,2)
INSERT INTO Employee VALUES(1003,'Andrew',15000,1)
INSERT INTO Employee VALUES(1004,'Peter',35000,1)
INSERT INTO Employee VALUES(1005,'John',55000,1)
INSERT INTO Employee VALUES(1006,'Albert',25000,3)
INSERT INTO Employee VALUES(1007,'Donald',35000,3) 

select * from Employee
--list employees with salaries more than the average salaries of the department 

select AVG() over (partition by DeptID order by DeptID) AS avg_salary_dept 
from Employee 

select A.EmpID, A.Salary, A.DeptID, A.avg_salary_dept, A.EmpName  
from (select EmpID, AVG(Salary) over (partition by DeptID order by DeptID) AS avg_salary_dept, Salary, DeptID, EmpName 
from Employee) A 
where A.Salary > A.avg_salary_dept 

--inner join 

select AVG(salary), DeptID 
from Employee 
group by deptID 

select A.empID, A.Empname, A.Salary, A. deptID  
from Employee A inner join (select AVG(salary) AS avg_salary_dept, DeptID 
from Employee 
group by deptID) B 
on A.DeptID = B.DeptID 
where A.Salary > B.avg_salary_dept 

--subquery 

select A.empID, A.Empname, A.Salary, A. deptID 
from employee A where Salary > (select AVG(salary) AS avg_salary_dept 
from Employee B where B.deptID = A.deptID ) 


Create Table Team(
ID INT,
TeamName Varchar(50)
);

INSERT INTO Team VALUES(1,'India'),(2,'Australia'),(3,'England'),(4,'NewZealand'); 

select * from Team 

--present all combinations of teams 

Select a.TeamName + 'VS' + b.TeamName, a.id, b.id 
 from Team a join Team b on a.id < b.id 
 
CREATE TABLE Table_First(
X int)

CREATE TABLE Table_Second(
Y int)

INSERT INTO Table_First VALUES(9);
INSERT INTO Table_First VALUES(8);
INSERT INTO Table_First VALUES(NULL);

INSERT INTO Table_Second VALUES(9);
INSERT INTO Table_Second VALUES(9);
INSERT INTO Table_Second VALUES(NULL);


select x, y 
from Table_First F full outer join Table_Second S 
on f.X = s.Y

--row duplication 


select * from ORDER_TABLE

select order_ID, product_ID, 1 AS quantity 
from ORDER_TABLE 


	with CTE AS
(
	select order_id, product_id, 1 AS quantity, 1 AS cnt 
	from ORDER_TABLE 

	UNION ALL 

	select A.Order_ID, A.Product_ID, B.cnt+1, B.quantity 
	from ORDER_TABLE A inner join CTE as B on  
	A.Product_ID = B.product_ID
	where B.cnt + 1 <= A.quantity
)

	select order_ID, product_ID, quantity 
	from CTE 
	order by product_ID, order_ID

Create Table Match_Result (
Team_1 Varchar(20),
Team_2 Varchar(20),
Result Varchar(20)
)
Insert into Match_Result Values('India', 'Australia','India');
Insert into Match_Result Values('India', 'England','England');
Insert into Match_Result Values('SouthAfrica', 'India','India');
Insert into Match_Result Values('Australia', 'England',NULL);
Insert into Match_Result Values('England', 'SouthAfrica','SouthAfrica');
Insert into Match_Result Values('Australia', 'India','Australia');

Select * from Match_Result

--total matches played, match won, match tied , lost for each team 
with cte_matches_played AS 
(
select team, SUM(tot) as total_matches_played
from
(
select Team_1 as team, count(*) AS tot   
from Match_Result 
group by Team_1  
UNION ALL 
select Team_2, count(*) AS tot   
from Match_Result 
group by Team_2  
) A
group by team 
) 
--match won, match tied , lost for each team 

select Result, count(*) AS matches_won 
from Match_Result
where Result is not null 
group by  Result

select Result, count(*) AS matches_lost 
from Match_Result
where Result is null 
group by  Result

select Team,
       count(1) matchs,
       sum(case when Result= Team then 1 else 0 end) Wins,
       sum(case when Result!= Team then 1 else 0 end) Loss,
       sum(case when Result is null then 1 else 0 end) Ties
       from

       (select team_1  as Team , Result from Match_Result
union all select  Team_2 as Team ,Result from Match_Result
    )matches
group by  Team

create table transaction_table 
(
AccountNumber int,
Transaction_Time  datetime,
Transaction_ID int,
Balance Int 
);
insert into transaction_table values (550,'2020-05-12 05:29:44.120',1001,2000);
insert into transaction_table values (550,'2020-05-15 10:29:25.630',1002,8000);
insert into transaction_table values (460,'2020-03-15 11:29:23.620',1003,9000);
insert into transaction_table values (460,'2020-04-30 11:29:57.320',1004,7000);
insert into transaction_table values (460,'2020-04-30 12:32:44.233',1005,5000);
insert into transaction_table values (640,'2020-02-18 06:29:34.420',1006,5000);
insert into transaction_table values (640,'2020-02-18 06:29:37.120',1007,9000); 

select * from transaction_table 

select ac, max_trans_time, transaction_ID, balance 
from 
(
	select MAX(transaction_time) max_trans_time, AccountNumber AS ac 
	from transaction_table 
	group by AccountNumber  
) A 
inner join 
(
	select AccountNumber, transaction_ID, Balance, Transaction_Time 
	from transaction_table B  
) B 
on A.max_trans_time = B.Transaction_Time AND A.ac = B.AccountNumber 
order by  B.Transaction_Time desc 

Create Table Sales (
ID int,
Product Varchar(25),
SalesYear Int,
QuantitySold Int);


Insert into Sales Values(1,'Laptop',1998,2500),(2,'Laptop',1999,3600)
,(3,'Laptop',2000,4200)
,(4,'Keyboard',1998,2300)
,(5,'Keyboard',1999,4800)
,(6,'Keyboard',2000,5000)
,(7,'Mouse',1998,6000)
,(8,'Mouse',1999,3400)
,(9,'Mouse',2000,4600); 

select * from Sales 

select distinct SalesYear
from Sales 

select totalsales, C.salesyear
from 
(
	select SUM(QuantitySold) AS totalsales, SalesYear 
	from Sales A
	group by salesyear 
) B 

Inner join  

(
select distinct SalesYear as salesyear
from Sales ) C
on B.SalesYear  = C.salesyear 

Create Table Account_Table(
TranDate DateTime,
TranID Varchar(20),
TranType Varchar(10),
Amount Float)

INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-12T05:29:44.120', 'A10001','Credit', 50000)
INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-13T10:30:20.100', 'B10001','Debit', 10000)
INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-13T11:27:50.130', 'B10002','Credit', 20000)
INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-14T08:35:30.123', 'C10001','Debit', 5000)
INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-14T09:43:51.100', 'C10002','Debit', 5000)
INSERT [dbo].[Account_Table] ([TranDate], [TranID], [TranType], [Amount]) VALUES ('2020-05-15T05:51:11.117', 'D10001','Credit', 30000)

select * from Account_Table;
--my solution that doesn't work 

SELECT *, SUM(Amount * CASE WHEN Trantype = 'Credit' THEN 1 WHEN Trantype = 'Debit' THEN -1 ELSE 0 END) OVER(ORDER BY TranDate) AS Net_Balance FROM Account_Table

OR

SELECT trandate,tranid,trantype,amount,sum(case when trantype ='Debit' then Amount*-1 else Amount*1 end)
over (order by trandate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
as "Net_Balance"
from account_table;

select *, LAG(amount, 1) over (order by amount) as prev_amount, LAG(trantype, 1, TranType) over (order by trantype) AS prev_credit
from Account_Table 

Create Table Travel_Table(
Start_Location Varchar(30),
End_Location Varchar(30),
Distance int)

Insert into Travel_Table Values('Delhi','Pune',1400);
Insert into Travel_Table Values('Pune','Delhi',1400);
Insert into Travel_Table Values('Bangalore','Chennai',350);
Insert into Travel_Table Values('Mumbai','Ahmedabad',500);
Insert into Travel_Table Values('Chennai','Bangalore',350);
Insert into Travel_Table Values('Patna','Ranchi',300); 

select * from Travel_Table

Create table Emp_Detail
(
EmpName Varchar(25),
Age int,
Salary Bigint,
Department Varchar(20)
)

Insert into Emp_Detail Values('James',25,25000,'Admin')
Insert into Emp_Detail Values('Robert',33,39000,'Admin')
Insert into Emp_Detail Values('Richard',41,48000,'Admin')
Insert into Emp_Detail Values('Thomas',28,30000,'Admin')
Insert into Emp_Detail Values('Tom',40,55000,'Finance')
Insert into Emp_Detail Values('Donald',35,38000,'Finance')
Insert into Emp_Detail Values('Sara',32,44000,'Finance')
Insert into Emp_Detail Values('Mike',28,25000,'HR')
Insert into Emp_Detail Values('John',35,45000,'HR')
Insert into Emp_Detail Values('Mary',23,30000,'HR')
Insert into Emp_Detail Values('David',32,43000,'HR')
 
select * from Emp_Detail
--fetch the highest and second highest slaary in the department 

-- how to fetch the largest and second largest salary in a department 

select * from
(select *, ROW_NUMBER () over (partition by department order by Salary desc) AS rank_per_department 
from Emp_Detail) A
where rank_per_department <= 2 


select MAX(salary) AS highest, Department 
from Emp_Detail 
group by Department


UNION ALL 

select MAX(salary) AS second_highest, Department 
from Emp_Detail e1
where salary < (select MAX(salary) 
				from Emp_Detail e2 
				where e1.Department = e2.Department) 
group by Department
order by Department


--third highest salary 

select MAX(salary), Department
from Emp_Detail e1 
where 2 < (select count(salary)
			from Emp_Detail e2
			where e1.department = e2.department) 
group by Department

Create Table Phone_Log(
Source_Phone_Nbr Bigint,
Destination_Phone_Nbr Bigint,
Call_Start_DateTime Datetime) ;

Insert into Phone_Log Values (2345,6789,'2012-07-01 10:00')
Insert into Phone_Log Values (2345,1234,'2012-07-01 11:00')
Insert into Phone_Log Values (2345,4567,'2012-07-01 12:00')
Insert into Phone_Log Values (2345,4567,'2012-07-01 13:00')
Insert into Phone_Log Values (2345,6789,'2012-07-01 15:00')
Insert into Phone_Log Values (3311,7890,'2012-07-01 10:00')
Insert into Phone_Log Values (3311,6543,'2012-07-01 12:00')
Insert into Phone_Log Values (3311,1234,'2012-07-01 13:00') 

select *
from Phone_Log

--Problem Statement :-  Write a SQL to display the Source_Phone_Nbr and a flag where the flag needs to be set to ‘Y’ 
--if first called number and last called number are the same and ‘N’ if first called number and last called number are different 

select source_phone_nbr, destination_phone_nbr,
MAX(case when
from
(
	select *, ROW_NUMBER () over (partition by Source_Phone_Nbr order by call_start_datetime) AS first_rank, 
	ROW_NUMBER () over (partition by Source_Phone_Nbr order by call_start_datetime desc) AS last_rank 
	from Phone_Log
) A 
 
Create Table StudentInfo_1
(
StudentName Varchar(30),
Subjects Varchar(30),
Marks Bigint
)

insert into StudentInfo_1 Values ('David', 'English', 85)
insert into StudentInfo_1 Values ('David', 'Maths', 90)
insert into StudentInfo_1 Values ('David', 'Science', 88)
insert into StudentInfo_1 Values ('John', 'English', 75)
insert into StudentInfo_1 Values ('John', 'Maths', 85)
insert into StudentInfo_1 Values ('John', 'Science', 80)
insert into StudentInfo_1 Values ('Tom', 'English', 83)
insert into StudentInfo_1 Values ('Tom', 'Maths', 80)
insert into StudentInfo_1 Values ('Tom', 'Science', 92)

select * from StudentInfo_1

select StudentName, english, maths, science 
from
(select StudentName, Subjects, marks from StudentInfo_1) AS source_table 
PIVOT 
(

	MAX(marks) 
	for subjects IN (English, Maths, Science) 

) AS pivot_table 



select studentname, English, Maths, Science
from

(select studentname, subjects, marks 
from StudentInfo_1) AS Sourcetable
PIVOT
(
	MAX(marks) 
	for subjects IN (English, Maths, Science) 
) AS pivottable 

--select max and minumum salary for each department # 

Create Table Employee_2(
EmpName Varchar(30),
DeptName Varchar(25),
DeptNo Bigint,
Salary Bigint);

Insert into Employee_2 Values('Mark','HR',101,30000);
Insert into Employee_2 Values('John','Accountant',101,20000);
Insert into Employee_2 Values('Smith','Analyst',101,25000);
Insert into Employee_2 Values('Donald','HR',201,40000);
Insert into Employee_2 Values('James','Analyst',201,22000);
Insert into Employee_2 Values('Maria','Analyst',201,38000);
Insert into Employee_2 Values('David','Manager',201,33000);
Insert into Employee_2 Values('Martin','Analyst',301,22000);
Insert into Employee_2 Values('Robert','Analyst',301,56000);
Insert into Employee_2 Values('Michael','Manager',301,34000);
Insert into Employee_2 Values('Robert','Accountant',301,37000);
Insert into Employee_2 Values('Michael','Analyst',301,28000);

select * from Employee_2 

--select max and minumum salary for each department #  

select A.EmpName, A.deptname, A.DeptNo, A.Salary 
from Employee_2 A inner join 
(
	select deptno, MAX(Salary) AS max_salary_perdept, MIN(salary) AS min_salary_per_dept 
	from Employee_2
	group by deptno
) B on A.DeptNo = B.DeptNo AND A.Salary IN (B.min_salary_per_dept, B.max_salary_perdept)

--OR

select EmpName,DeptName, DeptNo, Salary 
from
	(select EmpName,DeptName, DeptNo, Salary,
	rank() over(partition by deptno order by salary desc) AS top_rank_dept,
	rank() over(partition by deptno order by salary) AS bottom_rank_dept
	from Employee_2
	) A 
where top_rank_dept = 1 OR bottom_rank_dept = 1 

select EmpName, DeptName, DeptNo, Salary 
from
	(select EmpName, DeptName, DeptNo, Salary, 
	MAX(Salary) over(partition by deptno) AS max_salary_dept,
	MIN(Salary) over(partition by deptno) AS min_salary_dept
	from Employee_2
	) A 
where Salary IN (min_salary_dept, max_salary_dept) 

create table OrderStatus
(
Quote_Id varchar(5),
Order_Id varchar(5),
Order_Status Varchar(20)
)

Insert into OrderStatus Values ('A','A1','Delivered') 
Insert into OrderStatus Values ('A','A2','Delivered') 
Insert into OrderStatus Values ('A','A3','Delivered') 
Insert into OrderStatus Values ('B','B1','Submitted') 
Insert into OrderStatus Values ('B','B2','Delivered') 
Insert into OrderStatus Values ('B','B3','Created') 
Insert into OrderStatus Values ('C','C1','Submitted') 
Insert into OrderStatus Values ('C','C2','Created') 
Insert into OrderStatus Values ('C','C3','Submitted') 
Insert into OrderStatus Values ('D','D1','Created')  

select * from OrderStatus
--complete, in delivery, waiting for submission, awaiting for entry 

select quote_id,  
	case when delivered = order_cnt then 'complete'
	when order_cnt <> Delivered and Delivered >=1 then 'In Delivery'
	when order_cnt <> Delivered and Submitted >=1 then 'Awaiting for Submission'
	else 'Awaiting for Entry'
    END AS status
from 
(
	select quote_id, count(Order_Id) as order_cnt,
	sum(case when Order_Status='Delivered' then 1 else 0 end) as Delivered, 
	sum(case when Order_Status='Submitted' then 1 else 0  end) as Submitted,
	sum(case when Order_Status='Created' then 1  else 0 end) as Created
	from OrderStatus
	group by quote_id
)a 

Create Table Employees
(
Employee_no BigInt,
Birth_date Date,
First_name Varchar(50),
Last_name Varchar(50),
Joining_date Date
)

INSERT INTO Employees Values(1001,CAST('1988-08-15' AS Date),'ADAM','WAUGH', CAST('2013-04-12' AS Date))
INSERT INTO Employees Values(1002,CAST('1990-05-10' AS Date),'Mark','Jennifer', CAST('2010-06-25' AS Date))
INSERT INTO Employees Values(1003,CAST('1992-02-07' AS Date),'JOHN','Waugh', CAST('2016-02-07' AS Date))
INSERT INTO Employees Values(1004,CAST('1985-06-12' AS Date),'SOPHIA TRUMP','', CAST('2016-02-15' AS Date))
INSERT INTO Employees Values(1005,CAST('1995-03-25' AS Date),'Maria','Gracia', CAST('2011-04-09' AS Date))
INSERT INTO Employees Values(1006,CAST('1994-06-23' AS Date),'ROBERT','PATRICA', CAST('2015-06-23' AS Date))
INSERT INTO Employees Values(1007,CAST('1993-04-05' AS Date),'MIKE JOHNSON','', CAST('2014-03-09' AS Date))
INSERT INTO Employees Values(1008,CAST('1989-04-05' AS Date),'JAMES','OLIVER', CAST('2017-01-15' AS Date))

select * from Employees

select first_name 
from Employees 
where first_name IN(select LOWER(first_name) 
					from Employees) 

SELECT Employee_no, birth_date, LEFT(First_name, charindex(' ', First_name) - 1) AS First_Name, 
RIGHT(First_name, charindex(' ', First_name) - 1) AS last_name, Joining_date
FROM Employees 
WHERE last_name =  ' ' 

--< 1 yr, 1-3, 3-5, 5+ yr, employee_counts
--30th june 2017 
--why doesn't this work
SELECT tenure in years AS 'tenure in years', employee_counts
FROM
(
	SELECT SUM(case when DATEDIFF(year,joining_date,'2017-06-30') < 1 then 1  
			   when datediff(year,joining_date,'2017-06-30') > 1 AND datediff(year,joining_date,'2017-06-30') < 3 then 1
			   when datediff(year,joining_date, '2017-06-30') > 3 AND datediff(year,joining_date,'2017-06-30') < 5 then 1
			   when datediff(year,joining_date, '2017-06-30') > 5 then 1 else 0
			   END) AS empcount, joining_date
FROM Employees
GROUP BY Joining_date

SELECT Tenure_in_years, count(*) from 
(select *, CASE
       WHEN Years < 1 THEn '< 1 year'
	   WHEN (1 < Years and 3 > Years) THEN '1-3 year'
	   WHEN (3 < Years and 5 > Years) THEN '3-5 year'
	   WHEN 5 < Years  THEN '5+ year' end AS 'Tenure_in_years'
	   FROM
		(SELECT employee_no, cast(datediff(month, Joining_date, '2017-06-30')
		as float)/12 as 'Years' from employees)a) 
	B 
	group by Tenure_in_years

--employees with birth_date same as work annniversary 

select employee_no, Joining_date, Birth_date
from Employees
where DAY(Birth_date) = DAY(Joining_date) AND  MONTH(Birth_date) = MONTH(Joining_date) 
--datepart(mm, birth_date), datepart(dd, birth_date)

--youngest employee with tenure more than 5 years on the 30th june 2017

Select datediff(YEAR, birthdate_need, '2017-06-30')--, Employee_no, First_name, Last_name
from
	(select MAX(birth_date) AS birthdate_need  
	FROM Employees
	where CAST(DATEDIFF(month, joining_date, '2017-06-30') AS float) / 12 > 5 
	) a 
      

Create Table SeatArrangement (
ID int,
StudentName Varchar(30)
)

Insert into SeatArrangement Values (1,'Emma')
Insert into SeatArrangement Values (2,'John')
Insert into SeatArrangement Values (3,'Sophia')
Insert into SeatArrangement Values (4,'Donald')
Insert into SeatArrangement Values (5,'Tom')

delete 
from seatarrangement 
where ID = 5; 

select *
from SeatArrangement

--if odd and last then id stays the same
--if odd then id = id+1 
--if even then id = id-1

with totaln AS
(
	select count(*) AS total 
	from SeatArrangement
)  

SELECT 
	
	case when total % 2 <> 0 AND total = id then id
	when total % 2 <> 0  then id+1 
    when total % 2 = 0 then id - 1 

	END AS ID, StudentName
from totaln, SeatArrangement  

Create Table SalesInfo(
Continents varchar(30),
Country varchar(30),
Sales Bigint
)

Insert into SalesInfo Values('Asia','India',50000)
Insert into SalesInfo Values('Asia','India',70000)
Insert into SalesInfo Values('Asia','India',60000)
Insert into SalesInfo Values('Asia','Japan',10000)
Insert into SalesInfo Values('Asia','Japan',20000)
Insert into SalesInfo Values('Asia','Japan',40000)
Insert into SalesInfo Values('Asia','Thailand',20000)
Insert into SalesInfo Values('Asia','Thailand',30000)
Insert into SalesInfo Values('Asia','Thailand',40000)
Insert into SalesInfo Values('Europe','Denmark',40000)
Insert into SalesInfo Values('Europe','Denmark',60000)
Insert into SalesInfo Values('Europe','Denmark',10000)
Insert into SalesInfo Values('Europe','France',60000)
Insert into SalesInfo Values('Europe','France',30000)
Insert into SalesInfo Values('Europe','France',40000)

SELECT * from SalesInfo 

--aggregate by sales country and then maximum in each continent 

WITH cte_sales AS 
(
	select sum(sales) AS totalsales, country, Continents 
	from SalesInfo 
	group by continents, country
), cte_rank AS 
(
	SELECT Continents, country, totalsales, DENSE_RANK() over (partition by continents order by totalsales desc) AS ranking 
	from cte_sales
) 

select continents, country, totalsales 
from cte_rank
where ranking = 1