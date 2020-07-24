USE employees;

-- Q1: Find all the employees with the same hire date as employee 101010 using a sub-query.
SELECT *
FROM employees
WHERE hire_date IN (
	SELECT hire_date
	FROM employees
	WHERE emp_no = 101010
);

-- Q2: Find all the titles held by all employees with the first name Aamod.
SELECT COUNT(titles.title) AS "Total Titles", COUNT(DISTINCT titles.title) AS "Distinct Titles"
FROM titles
WHERE titles.emp_no IN (
	SELECT emp_no
	FROM employees
	WHERE first_name = "Aamod"
	);
	
-- Q3: How many people in the employees table are no longer working for the company?
-- Step 1: Create a query that only lists emp_nos of people currently working for the company
SELECT emp_no
FROM salaries
WHERE to_date > curdate();

-- Now create a query that checks all emp_nos and lists those that are not IN the output of the previous query
SELECT emp_no
FROM salaries
WHERE emp_no NOT IN (
	SELECT emp_no
	FROM salaries
	WHERE to_date > curdate()
);

-- Now get a distinct count of those emp_nos
SELECT COUNT(DISTINCT emp_no) AS "Number of Former Employees"
FROM salaries
WHERE emp_no NOT IN (
	SELECT emp_no
	FROM salaries
	WHERE to_date > curdate()
);

-- Q4: Find all the current department managers that are female.
-- Step 1: Create a query that shows the emp_nos of current managers
SELECT emp_no
FROM dept_manager
WHERE to_date > curdate();

-- Step 2: Using the emp_nos in this query, match them to the first_name and last_name from the employees table

SELECT first_name, last_name
FROM employees
WHERE employees.emp_no IN 
(
	SELECT emp_no
	FROM dept_manager
	WHERE to_date > curdate()
)
	AND gender = 'F';
	
-- Q5: Find all the employees that currently have a higher than average salary.
-- STEP 1: Find the average salary
SELECT AVG(salary)
FROM salaries;

-- STEP 2: Find current emp_nos who have a higher than average salary
SELECT first_name, last_name, salary
FROM salaries
	JOIN employees
		ON salaries.emp_no = employees.emp_no
WHERE salary > (
		SELECT AVG(salaries.salary)
		FROM salaries
		)
	AND salaries.to_date > curdate();
	
-- Q6: How many current salaries are within 1 standard deviation of the highest salary? (Hint: you can use a built in function to calculate the standard deviation.) What percentage of all salaries is this?

-- Step 1: Determine highest historical salary (158220)
SELECT MAX(salary)
FROM salaries;

-- Step 2: Determine range of std deviation of historic salaries (+- 16904.82828800014)
SELECT STD(salary)
FROM salaries;

-- Step 3: Set up table of salaries that are within 1 STD DEV of MAX (78 salaries)
SELECT *
FROM salaries
WHERE salary > ((SELECT MAX(salary) FROM salaries) - (SELECT STD(salary) FROM salaries))
	AND salary < ((SELECT MAX(salary) FROM salaries) + (SELECT STD(salary) FROM salaries))
	AND to_date > curdate();
-- Determine the percentage of salaries that 78 represents out of all current salaries.	
-- Step 4: Determine total number of current salaries (Current salaries 240124)
SELECT COUNT(*)
FROM salaries
WHERE to_date > curdate();
-- Step 5: Divide the output from step 3 (78 salaries) by the output of step 4 (240124) and multiply by 100
-- 78/240124*100 = .0325%
-- The query below produces the number 78
SELECT COUNT(*) 
FROM salaries
WHERE salary > ((SELECT MAX(salary) FROM salaries) - (SELECT STD(salary) FROM salaries))
	AND salary < ((SELECT MAX(salary) FROM salaries) + (SELECT STD(salary) FROM salaries))
	AND to_date > curdate();
	
-- BONUS 1: Find all the department names that currently have female managers.
-- Step 1: This shows the emp_nos of current female department managers
SELECT emp_no
FROM employees
WHERE employees.emp_no IN 
(
	SELECT emp_no
	FROM dept_manager
	WHERE to_date > curdate()
)
	AND gender = 'F';

-- Step 2: Join dept_emp to departments
SELECT *
FROM dept_emp
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no;
-- Step 3: Only select for the emp_nos that match the current female department managers
SELECT *
FROM dept_emp
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
WHERE emp_no IN (
SELECT emp_no
FROM employees
WHERE employees.emp_no IN 
(
	SELECT emp_no
	FROM dept_manager
	WHERE to_date > curdate()
)
	AND gender = 'F'
);
-- Step 4: Reduce the columns and order by dept_name
SELECT dept_name
FROM dept_emp
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
WHERE emp_no IN (
SELECT emp_no
FROM employees
WHERE employees.emp_no IN 
(
	SELECT emp_no
	FROM dept_manager
	WHERE to_date > curdate()
)
	AND gender = 'F'
)
ORDER BY dept_name;

-- BONUS 2: Find the first and last name of the employee with the highest salary.
-- Step 1: Find the highest salary (158220)
SELECT MAX(salary) FROM salaries;
-- Step 2: Find the emp_no of the person with the highest salary (43624)
SELECT emp_no
FROM salaries
WHERE salary = (SELECT MAX(salary) FROM salaries); 
-- Step 3: Join employees table with the salaries table
SELECT *
FROM employees
	JOIN salaries
		ON employees.emp_no = salaries.emp_no;
-- Step 4: Select for first_name and last_name where the emp_no matches the output from Step 2 and limit output to one pairing
SELECT first_name, last_name
FROM employees
	JOIN salaries
		ON employees.emp_no = salaries.emp_no
	WHERE employees.emp_no = (
								SELECT emp_no
								FROM salaries
								WHERE salary = (SELECT MAX(salary) FROM salaries)
)
LIMIT 1;

-- BONUS 3: Find the department name that the employee with the highest salary works in.
-- Step 1: Find the emp_no of the employee with the highest salary from the salaries table (did this already)
SELECT emp_no
FROM salaries
WHERE salary = (SELECT MAX(salary) FROM salaries);
-- Step 2: The dept_emp table can link the emp_no to dept_no. Then the departments table can link dept_no to dept_name. Therefore these tables must be linked. 
SELECT *
FROM employees
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no;
-- Step 3: Return the department name where emp_no is the same as emp_no from step 1
SELECT departments.dept_name
FROM employees
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
WHERE employees.emp_no = (
						SELECT emp_no
						FROM salaries
						WHERE salary = (SELECT MAX(salary) FROM salaries)
);