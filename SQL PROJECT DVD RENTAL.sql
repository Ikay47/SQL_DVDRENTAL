--Display the customer names that share the same address (e.g. husband and wife).

SELECT c1.first_name, c1.last_name , c2.first_name, c2.last_name
FROM customer c1
JOIN customer c2 ON c1.address_id = c2.address_id
WHERE c1.customer_id < c2.customer_id;

--This code was used to confirm no two customers have the same address

SELECT COUNT(address_id) AS freq
FROM customer
GROUP BY address_id
ORDER BY freq DESC


--What is the name of the customer who made the highest total payments.

SELECT CONCAT (first_name,' ', last_name) AS full_name , py.amount
FROM customer as cu JOIN payment as py ON cu.customer_id = py.customer_id
ORDER BY py.amount DESC LIMIT 1

--What is the movie(s) that was rented the most.

SELECT fm.title, tb.*
FROM film AS fm INNER JOIN 
(SELECT iv.film_id,COUNT(iv.film_id) AS cnt 
FROM rental AS rt FULL OUTER JOIN inventory AS iv ON rt.inventory_id = iv.inventory_id
GROUP BY iv.film_id
ORDER BY cnt DESC) AS tb ON fm.film_id = tb.film_id
ORDER BY tb.cnt DESC LIMIT 1




--Which movies have been rented so far.

SELECT fm.title, tb.rental_date
FROM film AS fm FULL OUTER JOIN 
(SELECT * FROM rental AS rt FULL OUTER JOIN inventory AS iv ON rt.inventory_id = iv.inventory_id) AS tb ON fm.film_id = tb.film_id
WHERE tb.rental_date IS NOT NULL




--Which movies have not been rented so far.

SELECT fm.title
FROM film AS fm FULL OUTER JOIN (SELECT * FROM rental AS rt FULL OUTER JOIN inventory AS iv ON rt.inventory_id = iv.inventory_id)
AS tb ON fm.film_id = tb.film_id
WHERE tb.rental_date IS NULL




--Which customers have not rented any movies so far.

SELECT CONCAT(cu.first_name, ' ', cu.last_name) AS full_name
FROM customer cu LEFT JOIN rental rt ON cu.customer_id = rt.customer_id
WHERE rt.rental_date IS NULL






--Display each movie and the number of times it got rented.

SELECT fm.title, tb.*
FROM film AS fm FULL OUTER JOIN 
(SELECT iv.film_id,COUNT(iv.film_id) AS cnt FROM rental AS rt 
FULL OUTER JOIN inventory AS iv ON rt.inventory_id = iv.inventory_id
GROUP BY iv.film_id
ORDER BY cnt DESC
) AS tb ON fm.film_id = tb.film_id
WHERE tb.cnt IS NOT NULL
ORDER BY tb.cnt DESC




--Show the first name and last name and the number of films each actor acted in.

WITH cnt AS ( SELECT actor_id, COUNT(actor_id)
FROM film_actor
GROUP BY actor_id) 

SELECT ac.first_name, ac.last_name , cnt.count
FROM cnt INNER JOIN actor ac ON cnt.actor_id = ac.actor_id







--Display the names of the actors that acted in more than 20 movies.

WITH cnt AS ( SELECT actor_id, COUNT(actor_id)
FROM film_actor
GROUP BY actor_id) 

SELECT ac.first_name, ac.last_name , cnt.count
FROM cnt INNER JOIN actor ac ON cnt.actor_id = ac.actor_id
WHERE cnt.count > 20
ORDER BY cnt.count DESC





--For all the movies rated "PG" show me the movie and the number of times it got rented.

SELECT fm.title, tb.cnt, fm.rating
FROM film AS fm FULL OUTER JOIN (SELECT iv.film_id,COUNT(iv.film_id) AS cnt FROM rental AS rt 
FULL OUTER JOIN inventory AS iv ON rt.inventory_id = iv.inventory_id
GROUP BY iv.film_id
ORDER BY cnt DESC
) AS tb ON fm.film_id = tb.film_id
WHERE tb.cnt IS NOT NULL AND fm.rating = 'PG'
ORDER BY tb.cnt DESC





--Display the movies offered for rent in store_id 1 and not offered in store_id 2.

SELECT fm.title, inv.store_id
FROM inventory inv INNER JOIN film fm ON inv.film_id = fm.film_id
WHERE inv.store_id = 1 AND inv.store_id != 2
GROUP BY fm.title, inv.store_id






--Display the movies offered for rent in any of the two stores 1 and 2.

SELECT fm.title, inv.store_id
FROM inventory inv INNER JOIN film fm ON inv.film_id = fm.film_id
WHERE inv.store_id = 1 OR inv.store_id = 2
GROUP BY fm.title, inv.store_id






--Display the movie titles of those movies offered in both stores at the same time.

SELECT fm.title, inv.store_id
FROM inventory inv INNER JOIN film fm ON inv.film_id = fm.film_id
WHERE inv.store_id = 1 OR inv.store_id = 2
GROUP BY fm.title, inv.store_id







--Display the movie title for the most rented movie in the store with store_id 1.

WITH rnt AS (SELECT * FROM rental rt INNER JOIN inventory inv ON rt.inventory_id = inv.inventory_id)

SELECT fm.title, COUNT(rnt.film_id) AS freq
FROM rnt INNER JOIN film fm ON rnt.film_id = fm.film_id
WHERE rnt.store_id = 1
GROUP BY fm.title
ORDER BY freq DESC LIMIT 1




--How many movies are not offered for rent in the stores yet. There are two stores only 1 and 2.

WITH rnt AS (SELECT * FROM rental rt INNER JOIN inventory inv ON rt.inventory_id = inv.inventory_id)
SELECT fm.title
FROM film fm LEFT JOIN rnt ON fm.film_id = rnt.film_id
WHERE rnt.store_id IS NULL
GROUP BY fm.title





--Show the number of rented movies under each rating.

WITH rnt AS (SELECT * FROM rental rt INNER JOIN inventory inv ON rt.inventory_id = inv.inventory_id)
SELECT fm.rating, COUNT(fm.rating)
FROM rnt INNER JOIN film fm ON rnt.film_id = fm.film_id
GROUP BY fm.rating





--Show the profit of each of the stores 1 and 2.

WITH rnt AS (SELECT * FROM rental rt INNER JOIN inventory inv ON rt.inventory_id = inv.inventory_id)
SELECT rnt.store_id, SUM(pay.amount)
FROM rnt LEFT JOIN payment pay ON rnt.rental_id = pay.rental_id
GROUP BY rnt.store_id
