-- Create a file named temporary_tables.sql to do your work for this exercise.
USE darden_1028;

-- Using the example from the lesson, re-create the employees_with_departments table.
CREATE TEMPORARY TABLE employees_with_departments
SELECT ee.emp_no, ee.first_name, ee.last_name, ede.dept_no, ed.dept_name
FROM employees.employees AS ee
	JOIN employees.dept_emp AS ede USING (emp_no)
	JOIN employees.departments AS ed USING (dept_no)
LIMIT 100;

-- Add a column named full_name to this table. It should be a VARCHAR whose length is the sum of the lengths of the first name and last name columns
ALTER TABLE employees_with_departments 
ADD full_name VARCHAR(31);

-- Update the table so that full name column contains the correct data
UPDATE employees_with_departments
SET full_name = CONCAT(first_name, " ", last_name);

-- Remove the first_name and last_name columns from the table.
ALTER TABLE employees_with_departments
DROP COLUMN first_name;

ALTER TABLE employees_with_departments
DROP COLUMN last_name;

-- What is another way you could have ended up with this same table?
CREATE TEMPORARY TABLE employees_with_departments_2
SELECT ee.emp_no, ede.dept_no, ed.dept_name, CONCAT(ee.first_name, " ", ee.last_name) AS full_name
FROM employees.employees AS ee
	JOIN employees.dept_emp AS ede USING (emp_no)
	JOIN employees.departments AS ed USING (dept_no)
LIMIT 100;

-- Create a temporary table based on the payment table from the sakila database.
-- Write the SQL necessary to transform the amount column such that it is stored as an integer representing the number of cents of the payment. For example, 1.99 should become 199.
CREATE TEMPORARY TABLE payment_temp
SELECT sp.payment_id, sp.customer_id, sp.staff_id, sp.rental_id, sp.amount, sp.payment_date, sp.last_update
FROM sakila.payment AS sp;

ALTER TABLE payment_temp ADD amount_int INT UNSIGNED NOT NULL;

UPDATE payment_temp
SET amount_int = amount * 100;

ALTER TABLE payment_temp
DROP COLUMN amount;

ALTER TABLE payment_temp
ADD amount INT UNSIGNED NOT NULL;

UPDATE payment_temp
SET amount = amount_int;

ALTER TABLE payment_temp
DROP COLUMN amount_int;

SELECT *
FROM payment_temp;

-- Find out how the average pay in each department compares to the overall average pay. In order to make the comparison easier, you should use the Z-score for salaries. 
-- STEP 1: Determine overall average pay (we will go with historical)
SELECT AVG(salary)
FROM employees.salaries;

-- STEP 2: Determine STDDEV of salaries (we will go with historical again, STDDEV = 16904.82828800014)
SELECT STD(salary)
FROM employees.salaries;

-- STEP 3: Create a temporary table that shows dept_name (from departments) and salary z-score (which is average salary per department/the standard deviation)

CREATE TEMPORARY TABLE pay_comparison
SELECT ed.dept_name, AVG(es.salary) AS "dept_average_salary"
FROM employees.departments AS ed
JOIN employees.dept_emp AS ede USING (dept_no)
JOIN employees.employees AS ee ON ede.emp_no = ee.emp_no
JOIN employees.salaries AS es ON es.emp_no = ee.emp_no
GROUP BY ed.dept_name;

SELECT *
FROM pay_comparison;

-- STEP 4: Add a column showing the difference between the department salary and the companywide average salary
ALTER TABLE pay_comparison ADD salary_diff DECIMAL (9,4);

SELECT *
FROM pay_comparison; 

UPDATE pay_comparison
SET salary_diff = dept_average_salary - (SELECT AVG(salary) FROM employees.salaries);

SELECT *
FROM pay_comparison;

-- STEP 5: Add a colum showing the z-score by dividing the difference by the standard deviation
ALTER TABLE pay_comparison ADD salary_z_score DECIMAL(8,6);

SELECT *
FROM pay_comparison;

UPDATE pay_comparison
SET salary_z_score = salary_diff / (SELECT STD(salary) FROM employees.salaries);

SELECT * 
FROM pay_comparison;

-- STEP 6: Select for the variables you need (dept_name, salary_z_score)
SELECT dept_name, salary_z_score
FROM pay_comparison;

-- In terms of salary, what is the best department to work for? The worst? Best department = Sales, worst department = Human Resources

-- STEP 7: Lets try and do everything in one table if possible...

CREATE TEMPORARY TABLE pay_comparison_2
SELECT ed.dept_name, AVG(es.salary) AS "dept_average_salary", AVG(es.salary) - (SELECT AVG(salary) FROM employees.salaries) AS "salary_diff", (AVG(es.salary) - (SELECT AVG(salary) FROM employees.salaries)) / (SELECT STD(salary) FROM employees.salaries) AS "salary_z_score"
FROM employees.departments AS ed
JOIN employees.dept_emp AS ede USING (dept_no)
JOIN employees.employees AS ee USING (emp_no)
JOIN employees.salaries AS es USING(emp_no)
GROUP BY ed.dept_name;

SELECT * FROM pay_comparison_2;

-- STEP 8: Now lets remove the dept_average_salary and salary_diff columns in our next temporary table

CREATE TEMPORARY TABLE pay_comparison_z_score_by_dept
SELECT ed.dept_name, 
		(AVG(es.salary) -- Average of the salary column, but since the query is grouping by dept_name, it becomes average per dept
		- 
		(SELECT AVG(salary) FROM employees.salaries)) -- Average of the entire salary column
		/ 
		(SELECT STD(salary) FROM employees.salaries) -- Standard deviation of the entire salary column
		AS "salary_z_score"
FROM employees.departments AS ed
JOIN employees.dept_emp AS ede USING (dept_no)
JOIN employees.employees AS ee USING (emp_no)
JOIN employees.salaries AS es USING (emp_no)
GROUP BY ed.dept_name;

SELECT *
FROM pay_comparison_z_score_by_dept;

DROP TABLE pay_comparison;
DROP TABLE pay_comparison_2;
DROP TABLE pay_comparison_z_score_by_dept;