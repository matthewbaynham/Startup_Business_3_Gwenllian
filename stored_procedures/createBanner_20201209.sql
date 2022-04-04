use db_settings;

DROP PROCEDURE IF EXISTS createBanner;

DELIMITER //

CREATE PROCEDURE createBanner(OUT p_bIsOk boolean, IN p_language_id INT, IN p_banner_id INT)
BEGIN 
declare iCounter int;
declare iCounterInserted int;
declare iNoRecords int;
declare iTempId int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
declare sImage VARCHAR(4000);
declare sUrl VARCHAR(4000);
declare iMaxRandom int;

/* BEFORE TEST SELECT max(`banner_image_id`) FROM `shoes_banner_image` = 112*/

DECLARE exit handler for SQLEXCEPTION
 BEGIN
  GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
   @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
  SET p_bIsOk = false;
  SELECT 0 as err_ID, 
         CONCAT('MYSQL_ERRNO: ', @errno) As err_Category, 
         CONCAT('MYSQL_ERRNO: ', @sqlstate) as err_Name, 
         CONCAT('MESSAGE_TEXT: ', @text) As err_Long_Description, 
         '' As err_Values;
 END;

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_banner;
DROP TABLE IF EXISTS temp_product_id;
DROP TABLE IF EXISTS temp_prefix;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_banner (
    tmpB_id INT AUTO_INCREMENT PRIMARY KEY,
    tmpB_product_id int NOT NULL,
    tmpB_latest_category_id int NULL,
    tmpB_category_id_txt VARCHAR(4000) NOT NULL, 
    tmpB_url VARCHAR(4000) NOT NULL,
    tmpB_language_id int NOT NULL,
    tmpB_title VARCHAR(4000) NOT NULL,
    tmpB_image VARCHAR(4000) NOT NULL);

CREATE TEMPORARY TABLE temp_product_id (
    tmpP_id INT AUTO_INCREMENT PRIMARY KEY,
    tmpP_product_id int NOT NULL,
    tmpP_title VARCHAR(4000) NOT NULL,
    tmpP_prefix VARCHAR(4000) NOT NULL,
    tmpP_random_number int);

CREATE TEMPORARY TABLE temp_prefix (
    tmpX_id INT AUTO_INCREMENT PRIMARY KEY,
    tmpX_product_id int NOT NULL,
    tmpX_prefix VARCHAR(4000) NOT NULL,
    tmpX_random_number int);

/******************************************************
*   Fill rows with product id and first category id   *
******************************************************/
INSERT INTO temp_product_id (
    tmpP_product_id,
    tmpP_title,
    tmpP_prefix,
    tmpP_random_number)
SELECT
    d.product_id,
    d.name, 
    LEFT(d.name, LOCATE("-", REPLACE(REPLACE(d.name, "/", "-"), "(", "-"))),
    CONVERT((RAND(CONVERT(current_timestamp(), unsigned) + d.product_id)*10000000), SIGNED)
FROM db_shoes.shoes_product_description As d
WHERE language_id = p_language_id;

INSERT INTO temp_prefix (
    tmpX_product_id,
    tmpX_prefix,
    tmpX_random_number)
SELECT 
    0,
    tmpP_prefix,
    MAX(tmpP_random_number)
FROM temp_product_id
GROUP BY 
    tmpP_prefix;

IF EXISTS (SELECT * FROM temp_prefix) THEN
    SET iMaxRandom = (SELECT MAX(tmpX_random_number) FROM temp_prefix);

    DELETE FROM temp_prefix WHERE MOD(tmpX_random_number, 100) > 20;
END IF;

UPDATE temp_prefix As f
INNER JOIN temp_product_id as p
ON f.tmpX_prefix = p.tmpP_prefix 
AND f.tmpX_random_number = p.tmpP_random_number
SET f.tmpX_product_id = p.tmpP_product_id;

INSERT INTO temp_banner (
    tmpB_product_id,
    tmpB_latest_category_id,
    tmpB_category_id_txt, 
    tmpB_url, 
    tmpB_language_id,
    tmpB_title,
    tmpB_image)
SELECT DISTINCT
    pc.product_id, 
    pc.category_id, 
    "", 
    "", 
    pd.language_id, 
    pd.name, 
    p.image
FROM (((db_shoes.shoes_product_to_category As pc 
    INNER JOIN temp_prefix As t
    ON pc.product_id = t.tmpX_product_id)
    INNER JOIN db_shoes.shoes_category_description As cd
    ON pc.category_id = cd.category_id)
INNER JOIN db_shoes.shoes_product As p
ON pc.product_id = p.product_id) 
    INNER JOIN db_shoes.shoes_product_description As pd
ON p.product_id = pd.product_id
WHERE p.status = 1
AND pd.language_id = p_language_id
AND cd.language_id = p_language_id
ORDER BY RAND(100000);

/**************************************************************
*   We don't want too many entries in temp_banner             *
*   otherwise the main page just has too many banners on it   *
**************************************************************/

/*
IF EXISTS (SELECT * FROM temp_banner) THEN
    SET iNoRecords = (SELECT COUNT(*) FROM temp_banner);
    SET iCounter = 0;
    
    WHILE iNoRecords > 120 AND iCounter < 1000 DO
        SET iTempId = (SELECT MIN(tmpB_id) FROM temp_banner As p order by RAND(10 * iNoRecords + iCounter) LIMIT 1);
        
        DELETE FROM temp_banner WHERE tmpB_id = iTempId;

        SET iNoRecords = (SELECT COUNT(*) FROM temp_banner);
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;
*/

/*****************************************************************************************
*   loop through the parent category id and back through the generations of categories   *
*****************************************************************************************/
SET iCounter = 0;

WHILE EXISTS (SELECT * FROM temp_banner WHERE tmpB_latest_category_id > 0) AND iCounter < 10 DO
    DELETE FROM temp_banner
    WHERE tmpB_latest_category_id IN (SELECT category_id FROM db_shoes.shoes_category WHERE NOT status = 1);

    UPDATE temp_banner
    SET tmpB_category_id_txt = CASE WHEN tmpB_category_id_txt = "" THEN
                                  CONVERT(tmpB_latest_category_id, CHAR)
                              ELSE
                                  CONCAT(CONVERT(tmpB_latest_category_id, CHAR), "_", tmpB_category_id_txt)
                              END
    WHERE tmpB_latest_category_id > 0;

    UPDATE temp_banner AS b
    INNER JOIN db_shoes.shoes_category AS c ON b.tmpB_latest_category_id = c.category_id
    SET b.tmpB_latest_category_id = c.parent_id
    WHERE b.tmpB_latest_category_id > 0;

    DELETE FROM temp_banner
    WHERE tmpB_latest_category_id IN (SELECT category_id FROM db_shoes.shoes_category WHERE NOT status = 1);
    
    SET iCounter = iCounter + 1;
END WHILE;

/*****************
*   create URL   *
*****************/
UPDATE temp_banner
SET tmpB_url = CONCAT("index.php?route=product/product&path=", tmpB_category_id_txt, "&product_id=", CONVERT(tmpB_product_id, CHAR));

/*****************************
*   Insert in banner image   *
*****************************/
IF EXISTS (SELECT * FROM temp_banner) THEN
    DELETE FROM db_shoes.shoes_banner_image 
    WHERE banner_id = p_banner_id 
    AND language_id = p_language_id;

    SET iPosStart = (SELECT MIN(tmpB_id) FROM temp_banner);
    SET iPosEnd = (SELECT MAX(tmpB_id) FROM temp_banner);
    SET iCounter = iPosStart;
    
    SET iCounterInserted = 0;
    
    WHILE iCounter <= iPosEnd AND iCounterInserted < 30 DO
        IF EXISTS (SELECT * FROM temp_banner WHERE tmpB_id = iCounter) THEN
            SET sImage = (SELECT tmpB_image FROM temp_banner WHERE tmpB_id = iCounter);
            SET sUrl = (SELECT tmpB_url FROM temp_banner WHERE tmpB_id = iCounter);

            IF NOT EXISTS (SELECT * 
                           FROM db_shoes.shoes_banner_image 
                           WHERE banner_id = p_banner_id
                           AND (TRIM(UPPER(image)) = TRIM(UPPER(sImage)) 
                           OR TRIM(UPPER(link)) = TRIM(UPPER(sUrl)))) THEN
                INSERT INTO db_shoes.shoes_banner_image (
                    banner_id, 
                    language_id, 
                    title, 
                    link, 
                    image, 
                    sort_order)
                SELECT 
                    p_banner_id,
                    tmpB_language_id,
                    LEFT(tmpB_title, 64),
                    LEFT(tmpB_url, 255), 
                    LEFT(tmpB_image, 255),
                    0
                FROM temp_banner 
                WHERE tmpB_id = iCounter;
                
                SET iCounterInserted = iCounterInserted + 1;
            END IF;
        END IF;

        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmpB_id As 'id',
        tmpB_product_id As 'product_id',
        tmpB_latest_category_id As 'latest_category_id',
        tmpB_category_id_txt As 'category_id_txt', 
        tmpB_url As 'url', 
        tmpB_language_id As 'language_id', 
        tmpB_title As 'title', 
        tmpB_image As 'image'
    FROM temp_banner;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


