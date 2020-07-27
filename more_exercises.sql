-- Create a file named more_exercises.sql to do your work in.
-- EMPLOYEES DATABASE
USE employees;

-- Q1: How much do the current managers of each department get paid, relative to the average salary for the department?

-- Step 1: Get a list of emp_nos for the current managers to use with the salaries table
SELECT emp_no
FROM dept_manager
WHERE dept_manager.to_date > curdate(); 

-- Step 2: Get a table that links the current department managers emp_no (output from step 1) to their current salary
SELECT dept_manager.emp_no, dept_manager.dept_no, salaries.salary
FROM dept_manager
	JOIN salaries
		ON dept_manager.emp_no = salaries.emp_no
WHERE dept_manager.to_date > curdate()
	AND salaries.to_date > curdate();

-- Step 3: Determine the average salary for each department. Join salaries with dept_no to get a table linking dept_no to current salary (Output: dept_no, average_dept_salary)
SELECT dept_no, AVG(salaries.salary) AS "average_dept_salary"
FROM salaries
	JOIN dept_emp
		ON salaries.emp_no = dept_emp.emp_no
WHERE salaries.to_date > curdate()
	AND dept_emp.to_date > curdate()
GROUP BY dept_emp.dept_no;

-- Step 4 (FINAL): Join the output of step 2 (emp_no, dept_no, salary) with the output of step 3 (dept_no, average_dept_salary) by linking at dept_no
SELECT departments.dept_name, salaries.salary AS "Manager_salary", average_dept_salary, salaries.salary - average_dept_salary AS "difference"
FROM dept_manager
	JOIN salaries
		ON dept_manager.emp_no = salaries.emp_no
	JOIN (
			SELECT dept_no, AVG(salaries.salary) AS "average_dept_salary"
			FROM salaries
				JOIN dept_emp
					ON salaries.emp_no = dept_emp.emp_no
			WHERE salaries.to_date > curdate()
				AND dept_emp.to_date > curdate()
			GROUP BY dept_emp.dept_no	
	) AS avg_dept_sal
		ON dept_manager.dept_no = avg_dept_sal.dept_no
	JOIN departments
		ON departments.dept_no = dept_manager.dept_no
WHERE dept_manager.to_date > curdate()
	AND salaries.to_date > curdate();

-- Is there any department where the department manager gets paid less than the average salary? Yes, the production manager makes $11,189.30 less than the average and the customer service manager makes $8540.23 less than the average for their respective departments. 

-- WORLD DATABASE
-- Use the world database for the questions below.
USE world;

-- Q1: What languages are spoken in Santa Monica?
-- Step 1: Find which table Santa Monica is on
SELECT *
FROM city
WHERE name = "Santa Monica";

-- Step 2: The city table contains countrycode, which can be used to link the city table to the countrylanguage table
SELECT *
FROM city
	JOIN countrylanguage
		ON city.countrycode = countrylanguage.countrycode;
		
-- Step 3 (FINAL): Select only pertinent information about Santa Monica
SELECT countrylanguage.language, countrylanguage.percentage
FROM city
	JOIN countrylanguage
		ON city.countrycode = countrylanguage.countrycode
WHERE city.name = "Santa Monica"
ORDER BY percentage DESC;

-- Q2: How many different countries are in each region?
-- Step 1 (FINAL): Region is found on the country table. Doing a count(*) and grouping by the region should be sufficient
SELECT region, COUNT(*) AS "num_count"
FROM country
GROUP BY region
ORDER BY num_count;

-- Q3: What is the population for each region?
-- Step 1 (FINAL): Both region and population can be found on the country table. There are multiple identical regions with different populations. The population count will need to be summed and then grouped into each region
SELECT region AS "Region", SUM(population) AS "population"
FROM country
GROUP BY region
ORDER BY SUM(population) DESC;

-- Q4: What is the population for each continent?
-- Step 1 (FINAL): This is basically the same process as the previous question. We are now ordering by continent.
SELECT continent AS "Continent", SUM(population) AS "population"
FROM country
GROUP BY continent
ORDER BY SUM(population) DESC;

-- Q5: What is the average life expectancy globally?
-- Step 1 (Final): Information about life expectancy is found on the country table. We simply need to average the column.
SELECT AVG(LifeExpectancy)
FROM country;

-- Q6: What is the average life expectancy for each region, each continent? Sort the results from shortest to longest
-- Step 1: LifeExpectancy, region, and continent are all on the same table (country). We can simply SUM and order by region to answer the first part.
SELECT region AS "Region", AVG(LifeExpectancy) AS "life_expectancy"
FROM country
GROUP BY region
ORDER BY AVG(LifeExpectancy) ASC, Region ASC;

-- Step 2 (FINAL): Now we do the same for continent.
SELECT continent AS "Continent", AVG(LifeExpectancy) AS "life_expectancy"
FROM country
GROUP BY continent
ORDER BY AVG(LifeExpectancy) ASC;

-- B1: Find all the countries whose local name is different from the official name
-- Step 1 (FINAL): Name and Localname are both on the country table. We just need to produce a list of countries where the name and local name don't match. Oddly, Antarctica does not have a local name, but the local name is NOT NULL, it is some unknown length of spaces. It is removed directly from the results. I don't know what even is in the entry for Antarctica's localname. It doesn't even seem to be some number of spaces. Its also not no spaces. And its not NULL. Its a mystery. 
SELECT name, localname
FROM country
WHERE name != localname
	AND name != "Antarctica";

-- B2: How many countries have a life expectancy less than x?
-- Step 1 (FINAL): Define X. Let's say that X is 70. Both country name and lifeexpectancy is on the country table. 
SELECT name AS "County With Life Expectancy Below 70"
FROM country
WHERE lifeexpectancy < 70;

-- B3: What state is city X located in?
-- Step 1 (FINAL): Define X. Lets say that X is Newport News. The city table has the district column. SELECT the district column where the city.name = "Newport News" 
SELECT name AS "City Name", district AS "State"
FROM city
WHERE name = "Newport News";

-- B4: What region of the world is city x located in?
-- Step 1 (FINAL): Define X. We will use San Nicolás de los Arroyos. We simply need to 
SELECT country.region AS "Region Containing San Nicolás de los Arroyos"
FROM country
	JOIN city
		ON country.code = city.countrycode
WHERE city.name = "San Nicolás de los Arroyos";

-- B5: What country (use the human readable name) city x located in?
-- Step 1 (FINAL): We just need to join the country and city tables and then select the country name where the city name matches. 
SELECT country.name AS "Country Containing San Nicolás de los Arroyos"
FROM country
	JOIN city
		ON country.code = city.countrycode
WHERE city.name = "San Nicolás de los Arroyos";

-- B6: What is the life expectancy in city x?
-- Step 1: LifeExpectancy is on the country table, and the name of the city is on the city table, but they can be joined using the countrycode. Once joined, then we can select for just the named city.
SELECT city.name, country.lifeexpectancy
FROM city
	JOIN country
		ON city.countrycode = country.code
WHERE city.name = "San Nicolás de los Arroyos";

-- SAKILA DATABASE
USE sakila;

-- Q1: Display the first and last names in all lowercase of all the actors.
-- Step 1 (FINAL): We simply need to use LOWER in our select statement
SELECT LOWER(first_name), LOWER(last_name)
FROM actor;

-- Q2: You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you could use to obtain this information?
-- Step 1 (FINAL): We can use LIKE in the where statement.
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE "Joe";

-- Q3: Find all actors whose last name contain the letters "gen":
-- Step 1 (FINAL): We now just need to use the wildcard % in our LIKE
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%gen%";

-- Q4: Find all actors whose last names contain the letters "li". This time, order the rows by last name and first name, in that order.
-- Step 1 (FINAL): Same as the previous query, we just need to use ORDER BY
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

-- Q5: Using IN, display the country_id and country columns for the following countries: Afghanistan, Bangladesh, and China:
-- Step 1 (FINAL): All of this information is on the country table
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- Q6: List the last names of all the actors, as well as how many actors have that last name.
-- Step 1 (FINAL): We can use GROUP BY and COUNT to query this
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
ORDER BY COUNT(last_name) DESC;

-- Q7: List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-- Step 1 (FINAL): Same query, we just need to add a HAVING
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1
ORDER BY COUNT(last_name) DESC;

-- Q8: You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Step 1 (FINAL): Use SHOW CREATE TABLE
SHOW CREATE TABLE address;

-- Q9: Use JOIN to display the first and last names, as well as the address, of each staff member.
-- Step 1 (FINAL): Ok. Yep
SELECT first_name, last_name, address
FROM staff
	JOIN address
		ON staff.address_id = address.address_id;
		
-- Q10: Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Step 1 (FINAL): You can use LIKE and % to select for a specific month. 
SELECT staff_id, SUM(amount)
FROM payment
WHERE payment_date LIKE "2005-08-%%"
GROUP BY staff_id;

-- Q11: List each film and the number of actors who are listed for that film.
-- Step 1 (FINAL): The film list contains the titles we need and the film_actor list contains the actors. We can combine these tables using film_id
SELECT film.title, COUNT(film.title) AS "Number of Actors"
FROM film_actor
	JOIN film
		ON film_actor.film_id = film.film_id
GROUP BY film.title;

-- Q12: How many copies of the film Hunchback Impossible exist in the inventory system?
-- Step 1 (FINAL): The inventory table has film_id and we can join that to the film table to get the name "Hunchback Impossible"
SELECT film.title, COUNT(film.title) AS "Copies in Inventory"
FROM film
	JOIN inventory
		ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible'
GROUP BY film.title;

-- Q13: The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- Step 1: Find all of the films whose name starts with K and Q
SELECT *
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%";
-- Step 2 (FINAL) : The film table also contains language_id which can be used to match the language_id for "English". Since we need to use subquery, we can use WHERE IN a subquery table that only outputs the language_id that matches english. 
SELECT *
FROM film
WHERE language_id IN (
	SELECT language_id 
	FROM language
	WHERE name = 'English'
) 
	AND title LIKE "K%"
	OR title LIKE "Q%";
	
-- Q14: Use subqueries to display all actors who appear in the film Alone Trip.
-- Step 1: Use a query to generate only the film_id for the Alone Trip film
SELECT film_id
FROM film
WHERE title = "Alone Trip";
-- Step 2: Using the film_id output from the previous query, we can use a subquery to generate the actor_id that is connected with that film_id
SELECT actor_id
FROM film_actor
WHERE film_id IN (
	SELECT film_id
	FROM film
	WHERE title = "Alone Trip"
);
-- Step 3 (FINAL): Now that we have an output of actor_ids we can wrap yet another subquery around our results to get what we are looking for
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = "Alone Trip"
	)
);

-- Q15: You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Step 1 (FINAL): On the customers table, we find the email address, but only their address_id. This address_id can JOIN to the address table to find the related city_id. The city_id can link to the city table to find the related country_id. Finally, the country_id can match us to the country of Canada. We can join all of these tables together and then select for the names and email addresses where the country = 'Canada'
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
	JOIN address
		ON customer.address_id = address.address_id
	JOIN city
		ON address.city_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- Q16: Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
-- Step 1: The category table will link the category_id to "Family". We can join that to the film_category table via the category_id.
SELECT *
FROM category
	JOIN film_category
		ON category.category_id = film_category.category_id;

-- Step 2: Now we JOIN to the film table to get the names included in our output and pare down results to only include family category
SELECT *
FROM category
	JOIN film_category
		ON category.category_id = film_category.category_id
	JOIN film
		ON film_category.film_id = film.film_id
WHERE category.name = 'Family';

-- Step 3 (FINAL): Now we just need to get the names of these movies
SELECT film.title AS "Family Movies"
FROM category
	JOIN film_category
		ON category.category_id = film_category.category_id
	JOIN film
		ON film_category.film_id = film.film_id
WHERE category.name = 'Family';

-- Q17: Write a query to display how much business, in dollars, each store brought in.
-- Step 1: There are only two stores (store_id = 1, store_id = 2). Each store is run by a single staff member. We can link the stores to the staff table, by using the store_id. Then link to the payment table using the staff_id they both have in common. Then we can sum up all payments and group by store_id. 
SELECT *
FROM store
	JOIN staff
		ON store.store_id = staff.store_id
	JOIN payment
		ON staff.staff_id = payment.staff_id;

-- Step 2 (FINAL): Now we can select for the SUM of the amount column and order by store_id
SELECT store.store_id AS "Store ID", SUM(payment.amount) AS "Sales Revenue"
FROM store
	JOIN staff
		ON store.store_id = staff.store_id
	JOIN payment
		ON staff.staff_id = payment.staff_id
GROUP BY store.store_id;

-- Q18: Write a query to display for each store its store ID, city, and country.
-- Step 1: Store table has both store_id and address_id. We can JOIN to the address table using the address_id. Then we can join to the city table using city_id. Then we can join to the country table using country_id. Then we can select the requested information. 
SELECT store.store_id AS "Store ID", city.city AS "City", country.country AS "Country"
FROM store
	JOIN address
		ON store.address_id = address.address_id
	JOIN city
		ON address.city_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id;

-- Q19: List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- Step 1 (FINAL): Lets create a supertable. Because why not. Then we have everything we need and can just select, group by, order by, and limit. 
SELECT category.name AS "Genre", SUM(payment.amount) AS "Gross Revenue"
FROM category
	JOIN film_category
		ON category.category_id = film_category.category_id
	JOIN inventory
		ON film_category.film_id = inventory.film_id
	JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	JOIN payment
		ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- SELECT statements

-- Select all columns from the actor table.
SELECT *
FROM actor;
-- Select only the last_name column from the actor table.
SELECT last_name
FROM actor;
-- Select only the following columns from the film table.
-- Unable to complete. 

-- DISTINCT operator

-- Select all distinct (different) last names from the actor table.
SELECT DISTINCT last_name
FROM actor;
-- Select all distinct (different) postal codes from the address table.
SELECT DISTINCT postal_code
FROM address;
-- Select all distinct (different) ratings from the film table.
SELECT DISTINCT rating
from film;

-- WHERE clause

-- Select the title, description, rating, movie length columns from the films table that last 3 hours or longer.
SELECT title, description, rating, length
FROM film
WHERE length > 180;
-- Select the payment id, amount, and payment date columns from the payments table for payments made on or after 05/27/2005.
SELECT payment_id, amount, payment_date
FROM payment
WHERE payment_date >= '2005-05-27';
-- Select the primary key, amount, and payment date columns from the payment table for payments made on 05/27/2005.
SELECT payment_id AS "Primary Key", amount, payment_date
FROM payment
WHERE payment_date >= '2005-05-27';
-- Select all columns from the customer table for rows that have a last names beginning with S and a first names ending with N.
SELECT *
FROM customer
WHERE last_name LIKE "S%"
	AND first_name LIKE "%N";
-- Select all columns from the customer table for rows where the customer is inactive or has a last name beginning with "M".
SELECT *
FROM customer
WHERE active = 0
	OR last_name LIKE "M%";
-- Select all columns from the category table for rows where the primary key is greater than 4 and the name field begins with either C, S or T.
SELECT *
FROM category
WHERE category_id > 4
	AND name LIKE "C%" OR name LIKE "S%" OR name LIKE "T%";
-- Select all columns minus the password column from the staff table for rows that contain a password.
SELECT staff_id, first_name, last_name, address_id, picture, email, store_id, active, username, last_update
FROM staff
WHERE password IS NOT NULL;
-- Select all columns minus the password column from the staff table for rows that do not contain a password.
SELECT staff_id, first_name, last_name, address_id, picture, email, store_id, active, username, last_update
FROM staff
WHERE password IS NULL;

-- IN operator

-- Select the phone and district columns from the address table for addresses in California, England, Taipei, or West Java.
SELECT phone, district
FROM address
WHERE district IN ('California', 'England', 'Taipei', 'West Java');
-- Select the payment id, amount, and payment date columns from the payment table for payments made on 05/25/2005, 05/27/2005, and 05/29/2005. (Use the IN operator and the DATE function, instead of the AND operator as in previous exercises.)
SELECT payment_id, amount, payment_date
FROM payment
WHERE DATE(payment_date) IN ('2005-05-25', '2005-05-27', '2005-05-29');
-- Select all columns from the film table for films rated G, PG-13 or NC-17
SELECT *
FROM film
WHERE rating IN ('G', 'PG-13', 'NC-17');

-- BETWEEN operator

-- Select all columns from the payment table for payments made between midnight 05/25/2005 and 1 second before midnight 05/26/2005.
SELECT *
FROM payment
WHERE payment_date BETWEEN '2005-05-25 00:00:00' AND '2005-05-26 23:59:59';
-- Select the following columns from the film table for films where the length of the description is between 100 and 120.
-- Columns not specified
SELECT *
FROM film
WHERE LENGTH(description) BETWEEN 100 AND 120;
-- Hint: total_rental_cost = rental_duration * rental_rate
-- This hint makes no sense

-- LIKE operator

-- Select the following columns from the film table for rows where the description begins with "A Thoughtful".
SELECT *
FROM film
WHERE description LIKE "A Thoughtful%";
-- Select the following columns from the film table for rows where the description ends with the word "Boat".
SELECT *
FROM film
WHERE description LIKE "%Boat";
-- Select the following columns from the film table where the description contains the word "Database" and the length of the film is greater than 3 hours.
SELECT *
FROM film
WHERE description LIKE "%database%"
	AND length > 180;
	
-- LIMIT Operator

-- Select all columns from the payment table and only include the first 20 rows.
SELECT *
FROM payment
LIMIT 20;
-- Select the payment date and amount columns from the payment table for rows where the payment amount is greater than 5, and only select rows whose zero-based index in the result set is between 1000-2000.
-- I HAVE NO IDEA HOW THIS IS DONE AND GOOGLE ISNT HELPING. I guess its this? If the results themselves are zero indexed, then the payment_id 1 = index 0. So then payment_id 1001 = index 1000. But in this case do they mean between inclusive or exclusive? Because that changes what our limit should be. Because payment_id 2001 = index 2000. I don't think they intended this problem to be based on semantics, but really is just meant to check if we can use OFFSET. 
SELECT *
FROM payment
LIMIT 1000 OFFSET 1000;
-- Select all columns from the customer table, limiting results to those where the zero-based index is between 101-200. Index 0 = Customer_id 1, index 101 = customer_id 102, index 200 = customer_id 201
SELECT *
FROM customer
LIMIT 100 OFFSET 101;

-- ORDER BY statement

-- Select all columns from the film table and order rows by the length field in ascending order.
SELECT *
FROM film
ORDER BY length ASC;
-- Select all distinct ratings from the film table ordered by rating in descending order. Why is NC-17 before R??? 
SELECT DISTINCT rating
FROM film
ORDER BY rating DESC;
-- Select the payment date and amount columns from the payment table for the first 20 payments ordered by payment amount in descending order.
SELECT payment_date, amount
FROM payment
ORDER BY amount DESC
LIMIT 20;
-- Select the title, description, special features, length, and rental duration columns from the film table for the first 10 films with behind the scenes footage under 2 hours in length and a rental duration between 5 and 7 days, ordered by length in descending order.
SELECT title, description, special_features, length, rental_duration
FROM film
WHERE special_features LIKE "%Behind The Scenes%"
	AND length < 120
	AND rental_duration BETWEEN 5 AND 7
ORDER BY length DESC;

-- JOINs

-- Select customer first_name/last_name and actor first_name/last_name columns from performing a left join between the customer and actor column on the last_name column in each table. (i.e. customer.last_name = actor.last_name)
-- Label customer first_name/last_name columns as customer_first_name/customer_last_name
-- Label actor first_name/last_name columns in a similar fashion.
-- returns correct number of records: 599

-- Select the customer first_name/last_name and actor first_name/last_name columns from performing a /right join between the customer and actor column on the last_name column in each table. (i.e. customer.last_name = actor.last_name)
-- returns correct number of records: 200

-- Select the customer first_name/last_name and actor first_name/last_name columns from performing an inner join between the customer and actor column on the last_name column in each table. (i.e. customer.last_name = actor.last_name)
-- returns correct number of records: 43

-- Select the city name and country name columns from the city table, performing a left join with the country table to get the country name column.
-- Returns correct records: 600

-- Select the title, description, release year, and language name columns from the film table, performing a left join with the language table to get the "language" column.
-- Label the language.name column as "language"
-- Returns 1000 rows

-- Select the first_name, last_name, address, address2, city name, district, and postal code columns from the staff table, performing 2 left joins with the address table then the city table to get the address and city related columns.
-- returns correct number of rows: 2
