--Find cars with year > 2015
SELECT *
FROM cars
WHERE car_year > 2015
ORDER BY car_year
;

--2 Add a new bid
INSERT INTO bids(bid_id,ad_id,bidder,bid_price,date_bid)
VALUES (101,50,50,500_000_000,'2022-04-15')
;

SELECT * FROM bids
ORDER BY 1 DESC
;


--3 Show all cars sold by an account, sorted by the newest.
--Ex. Cars sold by 'Adiarja Permadi'
SELECT c.car_id,
	brand,
	model,
	car_year,
	price,
	ad_date
FROM cars c
JOIN ads a USING (car_id)
JOIN users u
	ON u.user_id = c.owner_id
WHERE name = 'Adiarja Permadi'
ORDER BY 6 DESC
;

--4 Find the cheapest cars based on a keyword
--Ex: "yaris"
SELECT c.car_id,
	brand,
	model,
	car_year,
	price
FROM cars c
JOIN ads a USING (car_id)
WHERE model LIKE '%Yaris%'
ORDER BY 5
;

--5 Find cars based on the nearest location
--Ex: Nearest to location id 3173

--Create function to calculate distance using euclidean 
CREATE OR REPLACE FUNCTION euclidean_distance(point1 POINT, point2 POINT)
RETURNS FLOAT AS $$
DECLARE
    lon1 FLOAT := point1[0];
    lat1 FLOAT := point1[1];
    lon2 FLOAT := point2[0];
    lat2 FLOAT := point2[1];
    lon_diff FLOAT;
    lat_diff FLOAT;
    distance FLOAT;
BEGIN
    lon_diff := lon1 - lon2;
    lat_diff := lat1 - lat2;
    distance := SQRT(lon_diff * lon_diff + lat_diff * lat_diff);
    
    RETURN distance;
END;
$$ LANGUAGE plpgsql;

--CHECK THE FUNCTION WORKS WELL
SELECT *, 
	(SELECT long_lat FROM cities WHERE nama_kota = 'Kota Malang') point2,
	euclidean_distance(long_lat, 
					(SELECT long_lat FROM cities WHERE nama_kota = 'Kota Malang'))
FROM cities;

--Find cars with nearest distance with kota_id = 3173
SELECT c.car_id,
	brand,
	model,
	car_year,
	price,
	euclidean_distance(long_lat, (SELECT long_lat FROM cities WHERE kota_id = 3173)) distance
FROM cars c
JOIN users u
	ON c.owner_id = u.user_id
JOIN cities ci
	ON ci.kota_id = u.city
JOIN ads a
	ON a.car_id = c.car_id
WHERE euclidean_distance(long_lat, (SELECT long_lat FROM cities WHERE kota_id = 3173)) = 0
;



























