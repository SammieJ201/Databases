DROP SCHEMA IF EXISTS paintings;
CREATE SCHEMA IF NOT EXISTS paintings;
USE paintings;

CREATE TABLE gallery (
    id INT(10) NOT NULL UNIQUE, -- AUTO_INCREMENT
    owner VARCHAR(35),
    areacode VARCHAR(3),
    phone VARCHAR(8),
    rate DECIMAL(16 , 5 ),
    PRIMARY KEY (id)
);
INSERT INTO gallery VALUES (5,'L. R. Gilliam','901','123-4456','0.37');
INSERT INTO gallery VALUES ( 6,'G. G. Waters','405','353-2243','0.45');
INSERT INTO gallery VALUES  (7,'T. E. gallery','480','353-2243','0.45');


CREATE TABLE painter (
    id INT(10) NOT NULL UNIQUE,
    last_name VARCHAR(15),
    first_name VARCHAR(15),
    areacode VARCHAR(3),
    phone VARCHAR(8),
    PRIMARY KEY (id)
);
INSERT INTO painter VALUES (123,'Ross','Georgette','901','885-4567');
INSERT INTO painter VALUES (126,'Itero','Julio','901','346-1112');
INSERT INTO painter VALUES (125,'Notalent','Nora','928','346-1112');
INSERT INTO painter VALUES (127,'Geoff','George','615','221-4456');


CREATE TABLE painting (
    id INT(10) NOT NULL UNIQUE,
    title VARCHAR(35),
    price DECIMAL(16 , 4 ),
    painter_id INT(10),
    gallery_id INT(10),
    PRIMARY KEY (id),
    FOREIGN KEY (painter_id)
        REFERENCES painter (id),
    FOREIGN KEY (gallery_id)
        REFERENCES gallery (id)
);
INSERT INTO painting VALUES ('1338','Dawn Thunder','245.5',123,5);
INSERT INTO painting VALUES ('1339','A Faded Rose','6723',123,5);
INSERT INTO painting VALUES ('1340','The Founders','567.99',126,5);
INSERT INTO painting VALUES ('1341','Hasty Pudding Exit','145.5',123,6);
INSERT INTO painting VALUES ('1342','Plastic Paradise','8328.99',126,6);
INSERT INTO painting VALUES ('1343','Roamin''','785',127,6);
INSERT INTO painting VALUES ('1344','Wild Waters','999',127,5);
INSERT INTO painting VALUES ('1345','Stuff ''n Such ''n Some','9800',123,5);


-- convenient view
-- notice: ambiguous attributes in the SELECT need to be qualified (as well as in the join, of course)
CREATE VIEW art AS
( SELECT 
    painter.id AS 'painter_id', last_name, first_name, painting.id AS 'painting_id', title, price, gallery.id AS 'gallery_id'
FROM
    gallery
        INNER JOIN
    painting ON gallery.id = painting.gallery_id
        INNER JOIN
    painter ON painter.id = painting.painter_id
);

SELECT *
FROM art;

SELECT 
    painter.id AS 'painter_id', last_name, first_name, painting.id AS 'painting_id', title, price
FROM
    painting
        RIGHT OUTER JOIN
    painter ON painter.id = painting.painter_id
;

-- Question 1: Get all accessible info about Georgette Ross using
-- simple join and where clause
SELECT
	*
FROM
	gallery
		INNER JOIN
	painting ON painting.gallery_id = gallery.id
		INNER JOIN
	painter ON painter.id = painting.painter_id
WHERE
	painter.last_name = 'Ross' AND painter.first_name = 'Georgette'
	
;

-- Question 2: Achieve same results as question 1 using a subquerry
-- in where clause
SELECT *
FROM
	gallery
		INNER JOIN
	painting ON painting.gallery_id = gallery.id
		INNER JOIN
	painter ON painter.id = painting.painter_id
WHERE 
	EXISTS (SELECT id
		FROM painting
		WHERE painter.last_name = 'Ross' AND painter.first_name = 'Georgette')
;
-- Question 3: A simple query that returns the average price of all the paintings 	
SELECT
	AVG(price) AS 'AVG price'
FROM
	painting
;

-- Question 4: Return all accessible information about paintings that have a higher than average price
SELECT
	*
FROM
	gallery
		INNER JOIN
	painting ON painting.gallery_id = gallery.id
		INNER JOIN
	painter ON painter.id = painting.painter_id
WHERE
	price > (
		SELECT AVG(price) 
        FROM painting)
;

-- Question 5: Return all info on paintings of a painter higher than the average  painting for each painter
-- NOTE: need to use a view'
--
SELECT
	*
FROM
	art AS outer_query
WHERE 
	outer_query.price > (
		SELECT AVG(price)
        FROM art AS inner_query
        WHERE outer_query.painter_id = inner_query.painter_id)
;

-- Question 6: Return the most expensive per painter
SELECT
	*, MAX(price) AS 'max_price'
FROM
	gallery
		INNER JOIN
	painting ON painting.gallery_id = gallery.id
		INNER JOIN
	painter ON painter.id = painting.painter_id
GROUP BY
	painter.id
-- HAVING
-- 	MAX(price) = price
;


-- Question 7: See last problem, but use a correlated query & a view

SELECT
*
FROM
	art AS outer_query
WHERE
	outer_query.price = (
	SELECT
		MAX(price)
		FROM art AS inner_query
		WHERE inner_query.painter_id = outer_query.painter_id)


;

-- Question 8: See last problem but use join, group, and correlated subquerry
SELECT
	*
FROM(
	SELECT 
		painter.id AS 'painter_id',
        last_name,
        first_name,
        painting.id AS 'painting_id',
        title,
        price
	FROM
		painting
			INNER JOIN 
		painter ON painter.id = painting.painter_id
    )
AS table_one

INNER JOIN

(SELECT
	painter.id AS painter_id, MAX(price) AS max_price
FROM
	painting
		INNER JOIN
	painter ON painter.id = painting.painter_id
GROUP BY painter_id)
AS table_two

ON table_one.painter_id = table_two.painter_id AND table_one.price = table_two.max_price
;