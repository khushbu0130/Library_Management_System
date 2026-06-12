#creating databse 
create database library_managment;

#connecting databse
use library_managment;

#creating branch table
create table branch(
branch_id varchar(40) primary key,
manager_id	varchar(40),
branch_address	varchar(40),
contact_no varchar(40)
);

select * from books;

#creating table employees
create table employees(
emp_id	varchar(40) primary key,
emp_name varchar(40),
position	varchar(40),
salary	int,
branch_id varchar(40)
);

#creating table books
create table books(
isbn	varchar(50) primary key,
book_title	varchar(60),
category	varchar(60),
rental_price	float,
status	varchar(60),
author	varchar(60),
publisher varchar(60)
);

create table members(
member_id	varchar(40) ,
member_name	varchar(40),
member_address	varchar(40),
reg_date date);

select * from employees;

drop table return_status;
create table return_status(
return_id	varchar(40) primary key,
issued_id	varchar(40),
return_book_name	varchar(40),
return_date	date,
return_book_isbn varchar(40)
);

drop table issued_status;
create table issued_status(
issued_id	varchar(40) primary key,
issued_member_id	varchar(40),
issued_book_name	varchar(60),
issued_date	date,
issued_book_isbn varchar(60),	
issued_emp_id varchar(40)
);


#######Data Modling###########

alter table issued_status
add constraint fk_memebers
foreign key (issued_member_id)
references members(member_id);


alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);


ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id) 
REFERENCES employees(emp_id);


ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id) 
REFERENCES branch(branch_id);


alter TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id) 
REFERENCES issued_status(issued_id);


alter TABLE return_status
ADD CONSTRAINT fk_books_return
FOREIGN KEY (return_book_isbn) 
REFERENCES books(isbn);

##########quaires#########

select * from members;

#Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

#Task 2: Update an Existing Member's Address
update members
set member_address="444 Green St"
where member_id='C101';

#Task 3: Delete a Record from the Issued Status Table Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete  from issued_status 
where issued_id = 'IS121';

#Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from employees 
where emp_id='E101';

#Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id,
count(*) from issued_status
group by issued_emp_id
having count(*)>1;

######3. CTAS (Create Table As Select)#######

#Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table Book_issued_Count as
(
select b.book_title,count(i.issued_book_name) as No_of_book_issued
from books as b 
join issued_status as i on b.isbn=i.issued_book_isbn
group by b.book_title,i.issued_book_isbn
);

select * from book_issued_count order by No_of_book_issued desc;
select * from books;
##########4. Data Analysis & Findings##################

#Task 7. Retrieve All Books in a Specific Category:
select book_title from books 
where category="classic";

#Task 8: Find Total Rental Income by Category:
select category, sum(rental_price) as Total_rental,
count(category) as No_of_sales
from books 
group by category;

#Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL  180 DAY;

#Task 10: List Employees with Their Branch Manager's Name and their branch details:
select e.*,
e2.emp_name as manager,
b.branch_id
from employees as e
join branch as b
on b.branch_id=e.branch_id
join employees as e2
on b.manager_id=e2.emp_id;

#Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
create table book_rental
as
select book_title,
rental_price from books 
where rental_price>7;

select * from book_rental;

#Task 12: Retrieve the List of Books Not Yet Returned
select i.issued_book_name,
b.category,
i.issued_date,
b.status
from books as b
join issued_status as i
on b.isbn=i.issued_book_isbn
where status='no';

#############Advanced SQL Operations

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books 
(assume a 30-day return period). 
Display the member's_id, member's name, book title, 
issue date, and days overdue. */

select m.member_id,
m.member_name,
b.book_title,
i.issued_date,
#r.return_date,
datediff(curdate(),issued_date)as Days_overdue
from issued_status as i
join members as m 
on m.member_id=i.issued_member_id
join books as b on b.isbn=i.issued_book_isbn
left join return_status as r
on i.issued_id=r.issued_id
where return_date is null
and (current_date()-issued_date)>30
order by member_id;

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).*/

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

select brn.branch_id,
brn.manager_id, 
count(i.issued_id) as No_of_book_issued,
count(r.return_id) as No_of_book_return,
sum(b.rental_price) as Total_revenue
from issued_status as i
join employees as e on e.emp_id=i.issued_emp_id

join  branch as brn on brn.branch_id=brn.branch_id

left join return_status as r on r.issued_id=i.issued_id

join books as b on i.issued_book_isbn=b.isbn
group by 1,2;

/*Task Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to 
create a new table active_members containing 
members who have issued at least one book in the last 2 months.*/

create table Active_member 
as
select * from members 
where member_id in
(
select distinct issued_member_id
from issued_status
where issued_date<=current_date -interval 60 day
);

select * from active_member;

#Task 17: Find Employees with the Most Book Issues Processed
select e.emp_name,
b.*,
count(i.issued_id) as no_books_processed
from issued_status as i
join employees as e
on e.emp_id=i.issued_emp_id
join branch as b on e.branch_id=b.branch_id
group by 1,2;

#####End Here#####







