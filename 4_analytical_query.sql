--1 Car brand popularity
SELECT model,
	COUNT(a.car_id) count_product,
	COUNT(bid_id) count_bid
FROM cars c
FULL OUTER JOIN ads a USING(car_id)
FULL OUTER JOIN bids b USING(ad_id)
GROUP BY 1
ORDER BY 3 DESC
;

--2 Comparing car price depends on average price in every city
SELECT nama_kota,
	brand,
	model,
	car_year,
	price,
	AVG(price) OVER(PARTITION BY nama_kota) avg_car_city
FROM cars c
JOIN users u
	ON c.owner_id = u.user_id
JOIN cities ci
	ON ci.kota_id = u.city
JOIN ads a
	ON a.car_id = c.car_id
;

--3 
--Depends on a car model, find comparison between date bid and its price with next bid
SELECT model,
	user_id,
	FIRST_VALUE(date_bid) OVER(ORDER BY date_bid) first_bid_date,
	LEAD(date_bid) OVER(ORDER BY date_bid) next_bid_date,
	FIRST_VALUE(price) OVER(ORDER BY date_bid) first_bid_price,
	LEAD(price) OVER(ORDER BY date_bid) next_bid_price
FROM cars c
JOIN users u
	ON c.owner_id = u.user_id
JOIN ads a
	ON a.car_id = c.car_id
JOIN bids b
	ON b.ad_id = a.ad_id
WHERE model = 'Toyota Yaris'
;

--4 Comparing the percentage difference in the average car price 
--based on the model and the average bid price 
--offered by customers in the last 6 months. 
WITH avg_6mo AS
	(
		SELECT model,
			AVG(price)::float avg_price_6mo
		FROM cars c
		JOIN ads a
			USING(car_id)
		WHERE ad_date >= (SELECT MAX(ad_date) FROM ads) - INTERVAL '6 months' 
		-- WHERE ad_date >= '2023-06-01'
		GROUP BY 1
	),

avg_price AS
	(
		SELECT model,
			AVG(price)::float avg_price
		FROM cars c
		JOIN ads a
			USING(car_id)
		GROUP BY 1
	)

SELECT *,
	avg_price - avg_price_6mo difference,
	(avg_price - avg_price_6mo)/avg_price*100 difference_pct
FROM avg_price
JOIN avg_6mo
	USING(model)
;

select MAX(ad_date) from ads
	
--5 Create a window function for the average bid price of a car brand and model over the last 6 months.
--Example: Toyota Yaris cars over the last 6 months
WITH avg_bid_price_data AS (
 SELECT 
  brand, 
  model, 
  date_bid, 
  price,
  AVG(price::float) OVER (PARTITION BY brand, model ORDER BY DATE_TRUNC('month', date_bid) ASC) AS avg_price,
  EXTRACT(MONTH FROM (SELECT MAX(date_bid) FROM bids)) - EXTRACT(MONTH FROM DATE_TRUNC('month', date_bid)) AS month_diff
 FROM bids b
 INNER JOIN ads a
 USING (ad_id)
 INNER JOIN cars c
 USING (car_id)
 WHERE date_bid >= (SELECT MAX(date_bid) FROM bids) - INTERVAL '6 months' AND model = 'Toyota Yaris'
)

SELECT
  brand,
  model,
  MAX(CASE WHEN month_diff = 6 THEN avg_price ELSE NULL END) AS avg_bid_price_m_6,
  MAX(CASE WHEN month_diff = 5 THEN avg_price ELSE NULL END) AS avg_bid_price_m_5,
  MAX(CASE WHEN month_diff = 4 THEN avg_price ELSE NULL END) AS avg_bid_price_m_4,
  MAX(CASE WHEN month_diff = 3 THEN avg_price ELSE NULL END) AS avg_bid_price_m_3,
  MAX(CASE WHEN month_diff = 2 THEN avg_price ELSE NULL END) AS avg_bid_price_m_2,
  MAX(CASE WHEN month_diff = 1 THEN avg_price ELSE NULL END) AS avg_bid_price_m_1
FROM avg_bid_price_data
GROUP BY brand, model;