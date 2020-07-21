-- Q1: Create a new SQL script named limit_exercises.sql.
USE employees;

-- Q2: MySQL provides a way to return only unique results from our queries with the keyword DISTINCT. For example, to find all the unique titles within the company, we could run the following query:

-- SELECT DISTINCT title FROM titles;

-- List the first 10 distinct last name sorted in descending order. Your result should look like this:
-- Zykh
-- Zyda
-- Zwicker
-- Zweizig
-- Zumaque
-- Zultner
-- Zucker
-- Zuberek
-- Zschoche
-- Zongker

SELECT DISTINCT last_name 
FROM employees
ORDER BY last_name DESC
LIMIT 10;

-- Q3: Find your query for employees born on Christmas and hired in the 90s from order_by_exercises.sql. Update it to find just the first 5 employees. Their names should be:
-- Khun Bernini
-- Pohua Sudkamp
-- Xiaopeng Uehara
-- Irene Isaak
-- Dulce Wrigley

SELECT *
FROM employees
WHERE birth_date LIKE '%-12-25'
	AND hire_date BETWEEN '1990-01-01' AND '1999-12-31'
ORDER BY birth_date, hire_date DESC
LIMIT 5;

-- Q4: Try to think of your results as batches, sets, or pages. The first five results are your first page. The five after that would be your second page, etc. Update the query to find the tenth page of results. The employee names should be:
-- Piyawadee Bultermann
-- Heng Luft
-- Yuqun Kandlur
-- Basil Senzako
-- Mabo Zobel

SELECT *
FROM employees
WHERE birth_date LIKE '%-12-25'
	AND hire_date BETWEEN '1990-01-01' AND '1999-12-31'
ORDER BY birth_date, hire_date DESC
LIMIT 5 OFFSET 45;

-- LIMIT and OFFSET can be used to create multiple pages of data. What is the relationship between OFFSET (number of results to skip), LIMIT (number of results per page), and the page number?
-- In this context, LIMIT will set the number of records to include on each page. Records are zero-indexed, so as long as the offset is a multiple of the LIMIT, duplicate entries will not be made on multiple pages. The page number is equal to the following formula (OFFSET + LIMIT) / LIMIT 