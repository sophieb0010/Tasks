-- #1
SELECT
	c."name",
	count(f.film_id) AS num_of_films
FROM
	film f
LEFT JOIN film_category fc 
ON
	f.film_id = fc.film_id
LEFT JOIN category c 
ON
	c.category_id = fc.category_id
GROUP BY
	c.name
ORDER BY
	count(*) DESC;


-- #2
SELECT
	a.first_name ||' '|| a.last_name AS full_name,
	count(r.rental_id) AS num_of_rents
FROM
	film f
LEFT JOIN film_actor fa 
ON
	f.film_id = fa.film_id
LEFT JOIN actor a 
ON
	fa.actor_id = a.actor_id
LEFT JOIN inventory i 
ON
	i.film_id = f.film_id
LEFT JOIN rental r 
ON
	r.inventory_id = i.inventory_id
GROUP BY
	full_name
ORDER BY
	count(r.rental_id) DESC 
FETCH FIRST 10 ROWS WITH TIES ;


-- #3 
SELECT
	c.name
FROM
	film f
LEFT JOIN film_category fc 
ON
	f.film_id = fc.film_id
LEFT JOIN category c 
ON
	c.category_id = fc.category_id
LEFT JOIN inventory i 
ON
	i.film_id = f.film_id
LEFT JOIN rental r 
ON
	i.inventory_id = r.inventory_id
LEFT JOIN payment p 
ON
	r.rental_id = p.rental_id
GROUP BY
	c.name
ORDER BY
	sum(p.amount) DESC 
FETCH FIRST 1 ROW WITH TIES;


-- #4
SELECT
	f.title 
FROM
	film f
LEFT JOIN inventory i 
ON
	f.film_id = i.film_id
WHERE
	i.inventory_id IS NULL;


-- #5
SELECT
	a.first_name || ' ' || a.last_name AS full_name,
	count(f.film_id)
FROM
	film f
LEFT JOIN film_category fc 
ON
	f.film_id = fc.category_id
RIGHT JOIN category c 
ON
	fc.category_id = c.category_id
	AND c."name" = 'Children'
LEFT JOIN film_actor fa 
ON
	f.film_id = fa.film_id
LEFT JOIN actor a 
ON
	fa.actor_id = a.actor_id
GROUP BY 
	full_name
ORDER BY
	count(f.film_id) DESC 
FETCH FIRST 3 ROWS WITH TIES;


-- #6
SELECT
	c2.city,
	count(c.customer_id) FILTER (WHERE c.active = 1) AS active_customers,
	count(c.customer_id) FILTER (WHERE c.active = 0) AS inactive_customers
FROM
	customer c
LEFT JOIN address a 
ON
	c.address_id = a.address_id
LEFT JOIN city c2 
ON
	a.city_id = c2.city_id
GROUP BY
	c2.city
ORDER BY
	inactive_customers DESC;


-- #7
SELECT 
	"name"
FROM
	(
	SELECT
		c3."name",
		RANK() OVER (
		ORDER BY sum(r.return_date::date - r.rental_date::date) FILTER (
		WHERE LOWER(LEFT(c2."city", 1)) = 'a') DESC) AS rank1,
		RANK() OVER(
		ORDER BY sum(r.return_date::date - r.rental_date::date) FILTER (
		WHERE c2."city" LIKE '%-%') DESC) AS rank2
	FROM
		film f
	LEFT JOIN film_category fc 
ON
		f.film_id = fc.film_id
	LEFT JOIN category c3 
ON
		fc.category_id = c3.category_id
	LEFT JOIN inventory i 
ON
		f.film_id = i.film_id
	LEFT JOIN rental r 
ON
		r.inventory_id = r.inventory_id
	LEFT JOIN customer c 
ON
		r.customer_id = c.customer_id
	LEFT JOIN address a 
ON
		a.address_id = c.address_id
	RIGHT JOIN city c2 
ON
		a.city_id = c2.city_id
	WHERE
		name IS NOT NULL
	GROUP BY
		c3."name") t
WHERE
	rank1 = 1
	OR rank2 = 1;
