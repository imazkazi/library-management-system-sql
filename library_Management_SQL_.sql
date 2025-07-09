--Library Management System
--CREATING BRANCH TABLE
DROP TABLE IF EXISTS Branch;

CREATE TABLE Branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(10),
	contact_no VARCHAR(20)
);

ALTER TABLE Branch
ALTER COLUMN contact_no TYPE VARCHAR(20),
ALTER COLUMN branch_address TYPE VARCHAR(50);

--CREATING EMPLOYEE TABLE
DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee(
	emp_id	VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position	VARCHAR(25),
	salary	INT,
	branch_id VARCHAR(10)
);

ALTER TABLE Employee
ALTER COLUMN salary TYPE NUMERIC(10,2);



-- CREATE BOOKS TABLE
DROP TABLE IF EXISTS Books;

CREATE TABLE Books(
	isbn VARCHAR(25) PRIMARY KEY,
	book_title VARCHAR(75),
	category VARCHAR(15),
	rental_price FLOAT,	
	status VARCHAR(15),
	author VARCHAR(35),
	publisher VARCHAR(55)
);

ALTER TABLE Books
ALTER COLUMN category TYPE VARCHAR(30),
ALTER COLUMN status TYPE VARCHAR(30);

--CREATE MEMBERS TABLE
DROP TABLE IF EXISTS Members;

CREATE TABLE Members(
	member_id VARCHAR(15) PRIMARY KEY,
	member_name	VARCHAR(25),
	member_address	VARCHAR(75),
	reg_date DATE
);

--CREATE ISSUED_STATUS
DROP TABLE IF EXISTS Issued_status;

CREATE TABLE Issued_status(
	issued_id	VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10), --fk
	issued_book_name  VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(25), --fk
	issued_emp_id VARCHAR(10)  --fk
);

--CREATE TABLE RETURN_STATUS
DROP TABLE IF EXISTS Return_status;

CREATE TABLE Return_status(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(20)
);

-- FOREION KEY
ALTER TABLE Issued_status
ADD CONSTRAINT FK_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE Issued_status
ADD CONSTRAINT FK_Books
FOREIGN KEY (issued_book_isbn)
REFERENCES Books(isbn);

ALTER TABLE Issued_status
ADD CONSTRAINT FK_employees
FOREIGN KEY (issued_emp_id)
REFERENCES Employee(emp_id);

ALTER TABLE Employee
ADD CONSTRAINT FK_Branch
FOREIGN KEY (Branch_id)
REFERENCES Branch(branch_id);

ALTER TABLE Return_status
ADD CONSTRAINT FK_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);







-- CHECK THE DATA FOR EACH TABLE
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;



--PROJECT TASK \\ ANALYSIS OF DATASET
--CURD OPERATION 

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;


--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main st'
WHERE member_id = 'C101';
SELECT * FROM members;


--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;


--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_emp_id , COUNT(*)FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;


--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_count AS
SELECT isbn, book_title ,COUNT(issued_emp_id) FROM books AS b
JOIN 
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1 , 2;

SELECT * FROM book_issued_count;


--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';


--Task 8: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price),COUNT(*) FROM issued_status AS ist
JOIN books AS b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 2 DESC


--Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';


--Task 10: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE EXPENSIVE_Book AS 
SELECT * FROM books
WHERE rental_price <= 7.00;

SELECT * FROM EXPENSIVE_Book;


--Task 11: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


--Task 12:List Employees with Their Branch Manager's Name and their branch details:
SELECT e1.emp_id,e1.emp_name,e1.position,e1.salary, 
	b.*,e2.emp_name AS manager
FROM employee AS e1
JOIN 
branch AS b
ON e1.branch_id = b.branch_id
JOIN
employee AS e2
ON e2.emp_id = b.manager_id;


--Task 13. List all employees working at a specific branch
SELECT * FROM employee
WHERE branch_id = 'B001';


--Task 14. Show all books by a specific author
SELECT * FROM books
WHERE author = 'Charlotte Bronte'


--Task 15. Get the names and addresses of all members who live on 'Main st'
SELECT member_name ,member_address FROM members
WHERE member_address LIKE '%Main st%';


--Task 16. Count total number of books in each category
SELECT category, Count(*) AS total_BOOKS FROM books
GROUP BY category;


--Task 17. Calculate the average rental price per book category
SELECT Category,AVG(rental_price) AS avg_Price FROM books
GROUP BY category ;


--Task 18. Find the branch with the highest number of employees
SELECT branch_id ,Count(*) AS HIGHEST_emp FROM employee
GROUP BY branch_id
ORDER BY HIGHEST_emp DESC
LIMIT 1;


--Task 19. Show the book name, member name, and issue date for each issued book
SELECT b.book_title, m.member_name, ist.issued_date
FROM issued_status ist
JOIN books b ON ist.issued_book_isbn = b.isbn
JOIN members m ON ist.issued_member_id = m.member_id;


--Task 20. Find members who registered more than 2 years ago
SELECT * FROM members
WHERE reg_date < CURRENT_DATE - INTERVAL '2 years';







