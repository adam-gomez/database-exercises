-- Create a file named case_exercises.sql and craft queries to return the results for the following criteria:
USE employees;

-- Write a query that returns all employees (emp_no), their department number, their start date, their end date, and a new column 'is_current_employee' that is a 1 if the employee is still with the company and 0 if not.
-- STEP 1: Determining is_current_emp beofre adding in department number, as directly adding in department number to this group by will result in duplicate entries for employees who have worked in multiple departments
SELECT dept_emp.emp_no
		, max(employees.hire_date) AS hire_date
		, max(dept_emp.to_date) AS end_date
		, max(CASE WHEN dept_emp.to_date > curdate() THEN 1 ELSE 0 END) AS is_current_emp
FROM dept_emp
	JOIN employees USING (emp_no)
GROUP BY employees.emp_no;

-- STEP 2: We are now joining the query from the previous step to a new query that includes the department number only where the department to_date matches the employees end date, eliminating duplicates. 
SELECT emp.emp_no
	, d.dept_no
	, emp.start_date
	, emp.end_date
	, emp.is_current_emp 
FROM dept_emp AS d
JOIN(
	SELECT dept_emp.emp_no
		, max(employees.hire_date) AS start_date
		, max(dept_emp.to_date) AS end_date
		, max(CASE WHEN dept_emp.to_date > curdate() THEN 1 ELSE 0 END) AS is_current_emp
	FROM dept_emp
		JOIN employees USING (emp_no)
	GROUP BY dept_emp.emp_no
) AS emp
	ON d.emp_no = emp.emp_no AND d.to_date = emp.end_date;

-- Write a query that returns all employee names, and a new column 'alpha_group' that returns 'A-H', 'I-Q', or 'R-Z' depending on the first letter of their last name. UPPER was added because of the way that SQL alphabetizes A-Z before a-z. Although in this dataset there were no last_name entries with a lowercase first letter, the UPPER was added for good practice anyway. 
SELECT last_name, CONCAT(first_name, " ", last_name) AS "Employee Name",
		CASE WHEN UPPER(last_name) < "I" THEN 'A-H'
			WHEN UPPER(last_name) < "R" THEN 'I-Q'
			WHEN UPPER(last_name) > "Q" THEN 'R-Z'
			ELSE NULL
			END AS alpha_group
FROM employees
ORDER BY last_name;

-- Another way to use the operators is to limit last_name to only the first letter of the string:
SELECT first_name, 
	   last_name,
	   CASE WHEN SUBSTR(last_name, 1, 1) < 'I' THEN 'A-H'
	   		WHEN SUBSTR(last_name, 1, 1) < 'R' THEN 'I-Q'
	   		WHEN SUBSTR(last_name, 1, 1) > 'Q' THEN 'R-Z'
	   		ELSE NULL 
	   		END AS alpha_group
FROM employees
ORDER BY alpha_group;
 
-- Alternatively we can use REGEXP
SELECT first_name
		, last_name
		, SUBSTR(last_name, 1, 1) AS last_initial
		, CASE WHEN last_name REGEXP '^[A-H]' THEN 'A-H'
			WHEN last_name REGEXP '^[I-Q]' THEN 'I-Q'
			WHEN last_name REGEXP '^[R-Z]' THEN 'R-Z'
			ELSE NULL
			END AS alpha_group
FROM employees
ORDER BY last_initial;

-- Can you do it with BETWEEN? Yes, but you run the risk of miscategorizing a name that is out of the bounds of your between (e.g. Hzzzzzzz in the example below). Between is inclusive, so we would need to have the upper bound of the between statement be capable of capturing all last names that start with H. 
SELECT last_name, CONCAT(first_name, " ", last_name) AS "Employee Name",
		CASE WHEN UPPER(last_name) BETWEEN "A" AND "Hz" THEN 'A-H'
			WHEN UPPER(last_name)  BETWEEN "I" AND "Qz" THEN 'I-Q'
			ELSE 'R-Z'
			END AS 'alpha_group'
FROM employees
ORDER BY last_name;

-- How many employees were born in each decade?

SELECT MIN(birth_date), MAX(birth_date)
FROM employees;

SELECT COUNT(emp_no) AS "Num Employees",
	CASE WHEN YEAR(birth_date) BETWEEN 1950 AND 1959 THEN '1950s'
		WHEN YEAR(birth_date) BETWEEN 1960 AND 1969 THEN '1960s'
		END AS birth_decade
FROM employees
GROUP BY birth_decade;

-- Can you use BETWEEN? Yes

SELECT COUNT(emp_no) AS "Num Employees",
	CASE WHEN birth_date BETWEEN '1950-01-01' AND '1959-12-31' THEN '1950s'
		WHEN birth_date BETWEEN '1960-01-01' AND '1969-12-31' THEN '1960s'
		ELSE 'From the future...'
		END AS birth_decade
FROM employees
GROUP BY birth_decade;

-- Can you use SUBSTR? Yes
SELECT COUNT(birth_date) AS employees,
	CASE WHEN SUBSTR(birth_date, 3, 1) = 5 THEN '1950s'
		WHEN substr(birth_date, 3, 1) = 6 THEN '1960s'
		ELSE 'Other' END AS birth_decade
FROM employees
GROUP BY birth_decade;

-- Can you use LIKE/%? Yes
SELECT COUNT(birth_date) AS employees,
	CASE WHEN birth_date LIKE '195%' THEN '1950s'
		WHEN birth_date LIKE '196%' THEN '1960s'
		ELSE NULL
		END AS birth_decade
FROM employees
GROUP BY birth_decade;

-- What if you want the column headers to be the decades?
SELECT
	SUM(CASE WHEN YEAR(birth_date) >= 1950 AND YEAR(birth_date) < 1960 THEN 1 ELSE NULL END) AS 1950s,
	SUM(CASE WHEN YEAR(birth_date) >= 1960 AND YEAR(birth_date) < 1970 THEN 1 ELSE NULL END) AS 1960s
FROM employees; 

-- Confirmation using only the 1950s decade and LIKE

SELECT COUNT(emp_no) AS "Num Employees"
FROM employees
WHERE birth_date LIKE "195%-%%-%%";

/* BONUS

What is the average salary for each of the following department groups: R&D, Sales & Marketing, Prod & QM, Finance & HR, Customer Service?

+-------------------+-----------------+
| dept_group        | avg_salary      |
+-------------------+-----------------+
| Customer Service  |                 |
| Finance & HR      |                 |
| Sales & Marketing |                 |
| Prod & QM         |                 |
| R&D               |                 |
+-------------------+-----------------+ */

SELECT 
	CASE WHEN dept_name = 'Customer Service' THEN 'Customer Service'
		WHEN dept_name = 'Finance' OR dept_name = 'Human Resources' THEN 'Finance & HR'
		WHEN dept_name = 'Sales' OR dept_name = 'Marketing' THEN 'Sales & Marketing'
		WHEN dept_name = 'Production' OR dept_name = 'Quality Management' THEN 'Prod & QM'
		WHEN dept_name = 'Research' OR dept_name = 'Development' THEN 'R&D'
		ELSE 'Unknown Department'
		END AS dept_group
	, AVG(salary)
FROM departments
	JOIN dept_emp USING (dept_no)
	JOIN salaries USING (emp_no)
GROUP BY dept_group;

-- Confirmation using Finance and Human Resources

SELECT AVG(salary)
FROM salaries
	JOIN dept_emp USING (emp_no)
	JOIN departments USING (dept_no)
WHERE dept_name = 'Finance' OR dept_name = 'Human Resources';

SELECT SUBSTR("Adam", 2, 2);