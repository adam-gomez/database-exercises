-- Create a file named case_exercises.sql and craft queries to return the results for the following criteria:
USE employees;

-- Write a query that returns all employees (emp_no), their department number, their start date, their end date, and a new column 'is_current_employee' that is a 1 if the employee is still with the company and 0 if not.
SELECT emp_no "Employee", dept_no "Department Number", hire_date AS "Start Date", dept_emp.to_date = '9999-01-01' AS is_current_employee
FROM dept_emp
	JOIN employees USING (emp_no);

-- Write a query that returns all employee names, and a new column 'alpha_group' that returns 'A-H', 'I-Q', or 'R-Z' depending on the first letter of their last name. UPPER was added because of the way that SQL alphabetizes A-Z before a-z. Although in this dataset there were no last_name entries with a lowercase first letter, the UPPER was added for good practice anyway. 
SELECT last_name, CONCAT(first_name, " ", last_name) AS "Employee Name",
		CASE WHEN UPPER(last_name) < "I" THEN 'A-H'
			WHEN UPPER(last_name) < "R" THEN 'I-Q'
			ELSE 'R-Z'
			END AS 'alpha_group'
FROM employees
ORDER BY last_name;

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