use sakila;

-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.
select * from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
alter table actor add column ActorName VARCHAR(70);
update actor set ActorName = concat (first_name, ' ', last_name);
select * from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor where (first_name = 'Joe');

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like'%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
alter table actor order by actor_id, last_name, first_name,ActorName, last_update;
select * from actor where last_name like'%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor add middle_name varchar(30);
alter table actor modify column middle_name varchar (30) after first_name;
select * from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

-- 3c. Now delete the middle_name column.
alter table actor drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT    count(*), last_name
FROM      actor
GROUP BY  last_name
HAVING    count(*) > 0;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT    count(*), last_name
FROM      actor
GROUP BY  last_name
HAVING    count(*) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor
set first_name = replace(first_name, 'GROUCHO', 'HARPO');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor
set first_name = replace(first_name, 'HARPO', 'GROUCHO');

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- mysqldump sakila address > dump.sql
-- mysql sakila < dump.sql

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
Select a.address_id, a.first_name, a.last_name, b.address_id, b.address, b.address2, b.district, b.city_id, b.postal_code
From staff a
JOIN address b on a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
Select a.staff_id, a.first_name, a.last_name, b.payment_date, sum(b.amount) as TotalAmount 
From staff as a
JOIN payment as b on a.staff_id = b.staff_id and b.payment_date like '%2005-08%'
group by b.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
Select a.film_id, a.title, count(b.actor_id) as ActorCount 
From film as a
JOIN film_actor as b on a.film_id = b.film_id
group by b.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
Select a.film_id, a.title, count(b.inventory_id) as InventoryCount 
From film as a
JOIN inventory as b on a.film_id = b.film_id and a.title like 'Hunchback%'
group by b.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
Select a.first_name, a.last_name, sum(b.amount) as TotalAmountPaid 
From customer as a
JOIN payment as b on a.customer_id = b.customer_id
group by a.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and  Q whose language is English.
SELECT title
FROM film
WHERE language_id in (
Select language_id 
from language 
where language_id = 1 AND title like 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id in (
select actor_id
from film_actor
where film_id in (
Select film_id 
from film 
where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT a.first_name, a.last_name, a.email 
FROM customer a
JOIN address b ON a.address_id = b.address_id
JOIN city c ON b.city_id  = c.city_id
JOIN country d on c.country_id = d.country_id
where d.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title
FROM film
WHERE film_id in (
select film_id
from film_category
where category_id in (
Select category_id 
from category 
where name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
Select a.title, count(c.rental_id) as RentedMoviesCount
From film as a
JOIN inventory as b on a.film_id = b.film_id
JOIN rental as c on b.inventory_id = c.inventory_id
group by title order by RentedMoviesCount Desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
Select c.store_id, sum(a.amount) as TotalAmount
From payment as a
JOIN staff as b on a.staff_id = b.staff_id
JOIN store as c on b.store_id = c.store_id
group by c.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
Select a.store_id, c.city, d.country
From store as a
JOIN address as b on a.address_id = b.address_id
JOIN city as c on b.city_id = c.city_id
JOIN country as d on c.country_id = d.country_id
group by a.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
Select a.name, sum(e.amount) as GrossRevenue
From category as a
JOIN film_category as b on a.category_id = b.category_id
JOIN inventory as c on b.film_id = c.film_id
JOIN rental as d on c.inventory_id = d.inventory_id
JOIN payment as e on d.rental_id = e.rental_id
group by name order by GrossRevenue Desc limit 0,5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW executive AS SELECT a.name, sum(e.amount) as GrossRevenue 
from category as a
JOIN film_category as b on a.category_id = b.category_id
JOIN inventory as c on b.film_id = c.film_id
JOIN rental as d on c.inventory_id = d.inventory_id
JOIN payment as e on d.rental_id = e.rental_id
group by name order by GrossRevenue Desc limit 0,5;

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW executive;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view sakila.executive 