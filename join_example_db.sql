-- JOIN EXAMPLE DATABASE
-- Q1: Use the join_example_db. Select all the records from both the users and roles tables.
USE join_example_db;

SELECT *
FROM roles;

-- There are four roles (1: admin, 2: author, 3: reviewer, 4: commenter)

SELECT *
FROM users;

-- There are six users (bob, joe, sally, adam, jane, mike)

-- Q2: Use join, left join, and right join to combine results from the users and roles tables as we did in the lesson. Before you run each query, guess the expected number of results.

-- Notes: The relationship between the two columns is in the "id" column in roles (roles.id) and the "role_id" column in users (users.role_id)
-- Inspection of the table info of the roles table shows that the PRIMARY KEY is "id"
-- Inspection of the table info of the users table shows that the FOREIGN KEY is "role_id" which REFERENCES the "id" column from roles
-- Keep in mind that in this database, the roles table has no NULL values while the users tables has NULL values (there are users with no assigned role)

-- In this first query, we are performing an INNER JOIN. Jane and Mike do not have roles, therefore they have no connection to the roles table and are not included in the results.
SELECT *
FROM users
JOIN roles ON users.role_id = roles.id;

-- In this second query, we are performing a LEFT JOIN. Because the users table is listed first, the users Jane and Mike are included in this output, even though they have no relationship with the roles table. Null values are shown for their users.role_id (and the related columns roles.id and roles.name)
SELECT *
FROM users
LEFT JOIN roles ON users.role_id = roles.id;

-- In this third query, we are performing a RIGHT JOIN. We've intentionally listed roles first. This means that every row from the users table will be included in the output. That means Jane and Mike are again shown in the output. While the layout of the output looks different from the previous query, the information contained within both results are identical. They are like mirror images of each other. 
SELECT *
FROM roles
RIGHT JOIN users ON users.role_id = roles.id;

-- In this fourth query, we are performing a LEFT JOIN with roles listed first. That means that all rows from roles will be included in the output. The commenter role is included despite nobody having that role assigned to them. In this case, while "commenter" is shown, Jane and Mike are nowhere in this output, as they have no relationship to the roles table. 
SELECT *
FROM roles
LEFT JOIN users ON users.role_id = roles.id;

-- In this fifth query, we are performing a RIGHT JOIN with users listed first. This means that all rows from roles will be included in the output, similar to the previous query. Commenter is included, and Jane and Mike are again missing from this output. 
SELECT *
FROM users
RIGHT JOIN roles ON users.role_id = roles.id;

-- Although not explicitly covered in the lesson, aggregate functions like count can be used with join queries. Use count and the appropriate join type to get a list of roles along with the number of users that has the role. Hint: You will also need to use group by in the query.
SELECT roles.name AS role_name, count(roles.name) AS number_of_users_assigned_to_this_role
FROM users
JOIN roles ON users.role_id = roles.id
GROUP BY roles.name;

-- EMPLOYEES DATABASE
-- Q1: Use the employees database.
USE employees;

-- Q2: Using the example in the Associative Table Joins section as a guide, write a query that shows each department along with the name of the current manager for that department.
SELECT departments.dept_name AS "Department Name", CONCAT(employees.first_name, " ", employees.last_name) AS "Department Manager"
FROM departments
	JOIN dept_manager 
		ON departments.dept_no = dept_manager.dept_no
	JOIN employees
		ON dept_manager.emp_no = employees.emp_no 
WHERE dept_manager.to_date = "9999-01-01"
ORDER BY departments.dept_name;

-- Q3: Find the name of all departments currently managed by women.
SELECT departments.dept_name AS "Department Name", CONCAT(employees.first_name, " ", employees.last_name) AS "Manager Name"
FROM departments
	JOIN dept_manager 
		ON departments.dept_no = dept_manager.dept_no
	JOIN employees
		ON dept_manager.emp_no = employees.emp_no 
WHERE dept_manager.to_date = "9999-01-01"
	AND employees.gender = "F"
ORDER BY departments.dept_name;

-- Q4: Find the current titles of employees currently working in the Customer Service department.
-- Note: This seems to be overcounting Assistant Engineer, Engineer, Manager, Senior Staff, and Staff. Haven't pieced together why. 
SELECT titles.title AS "Title", COUNT(titles.title) AS "Count"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
WHERE departments.dept_name = 'Customer Service'
	AND dept_emp.to_date > curdate()
GROUP BY titles.title;

-- Note: Using the titles.to_date is better, but it is still overcounting Senior Staff and Staff.
SELECT titles.title AS "Title", COUNT(titles.title) AS "Count"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
WHERE departments.dept_name = 'Customer Service'
	AND titles.to_date > curdate()
GROUP BY titles.title;

-- Note: Using the salaries.to_date to determine current employment status also overcounts assistant engineer, engineer, manager, senior staff, and staff
SELECT titles.title AS "Title", COUNT(titles.title) AS "Count"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
WHERE departments.dept_name = 'Customer Service'
	AND salaries.to_date > curdate()
GROUP BY titles.title;

-- This uses all possible table.to_date columns simultaneously. It is the most conservative estimate of current employment status. It accurately reflects the true counts.  	
SELECT titles.title AS "Title", COUNT(titles.title) AS "Count"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
WHERE departments.dept_name = 'Customer Service'
	AND salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
GROUP BY titles.title;

-- Q5: Find the current salary of all current managers.
SELECT departments.dept_name AS "Department Name", CONCAT(employees.first_name, " ", employees.last_name) AS "Department Manager", salary
FROM departments
	JOIN dept_manager 
		ON departments.dept_no = dept_manager.dept_no
	JOIN employees
		ON dept_manager.emp_no = employees.emp_no 
	JOIN salaries
		ON dept_manager.emp_no = salaries.emp_no
WHERE salaries.to_date = "9999-01-01"
	AND dept_manager.to_date = "9999-01-01"
ORDER BY departments.dept_name;

-- Q6: Find the number of employees in each department.
SELECT departments.dept_no, departments.dept_name, COUNT(*)
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
GROUP BY departments.dept_name
ORDER BY departments.dept_no;

-- Q7: Which department has the highest average salary?
SELECT departments.dept_name, AVG(salaries.salary) AS "average_salary"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
GROUP BY departments.dept_name
ORDER BY average_salary DESC
LIMIT 1;

-- Q8: Who is the highest paid employee in the Marketing department?
SELECT employees.first_name, employees.last_name
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
	AND departments.dept_name = 'Marketing'
ORDER BY salaries.salary DESC
LIMIT 1;

-- Q9: Which current department manager has the highest salary?
SELECT employees.first_name, employees.last_name, salaries.salary, departments.dept_name
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
	JOIN dept_manager
		ON dept_manager.emp_no = employees.emp_no
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
	AND dept_manager.to_date > curdate()
ORDER BY salaries.salary DESC
LIMIT 1;

-- Q10 BONUS: UNFINISHED
SELECT DISTINCT CONCAT(employees.first_name, " ", employees.last_name) AS "Employee Name", departments.dept_name, department_manager AS "Manager Name"
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp 
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
	JOIN dept_manager
		ON dept_manager.emp_no = employees.emp_no
	JOIN (SELECT departments.dept_name AS "Department Name", CONCAT(employees.first_name, " ", employees.last_name) AS "department_manager"
FROM departments
	JOIN dept_manager 
		ON departments.dept_no = dept_manager.dept_no
	JOIN employees
		ON dept_manager.emp_no = employees.emp_no 
WHERE dept_manager.to_date = "9999-01-01"
ORDER BY departments.dept_name) AS manager_by_dept_table
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
ORDER BY dept_name;

-- SuperTable of Current Employees
SELECT *
FROM titles
	JOIN employees
		ON titles.emp_no = employees.emp_no
	JOIN dept_emp
		ON employees.emp_no = dept_emp.emp_no
	JOIN departments
		ON dept_emp.dept_no = departments.dept_no
	JOIN salaries
		ON salaries.emp_no = employees.emp_no
	JOIN dept_manager
		ON dept_manager.emp_no = employees.emp_no
WHERE salaries.to_date > curdate()
	AND titles.to_date > curdate()
	AND dept_emp.to_date > curdate()
LIMIT 10;