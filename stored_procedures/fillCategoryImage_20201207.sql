USE db_settings;

DROP PROCEDURE IF EXISTS fillCategoryImage;

DELIMITER //

CREATE PROCEDURE fillCategoryImage(OUT p_bIsOk boolean)
BEGIN 
declare iCounter int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
declare iId int default 0;
declare sImagePath varchar(4000) default "";
declare iCategoryId int;

SET p_bIsOk = true;

DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_categoriesNoImage;
DROP TABLE IF EXISTS temp_products;
DROP TABLE IF EXISTS temp_products_logged;
DROP TABLE IF EXISTS temp_modified_dates;
DROP TABLE IF EXISTS temp_tracking;
DROP TABLE IF EXISTS temp_selected_random_number;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_categoriesNoImage (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id INT NOT NULL);

CREATE TEMPORARY TABLE temp_products (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id INT NOT NULL,
    tmp_product_id INT NOT NULL);

CREATE TEMPORARY TABLE temp_images (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_image_id INT NOT NULL,
    tmp_category_id INT NOT NULL,
    tmp_product_id INT NOT NULL, 
    tmp_path VARCHAR(255),
    tmp_random_number INT NOT NULL);

CREATE TEMPORARY TABLE temp_tracking (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_txt VARCHAR(4000));

CREATE TEMPORARY TABLE temp_selected_random_number (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id INT NOT NULL,
    tmp_random_number INT NOT NULL);

/**************************
*   populated with data   *
**************************/
INSERT INTO temp_categoriesNoImage (tmp_category_id)
SELECT category_id
FROM db_shoes.shoes_category 
WHERE TRIM(IFNULL(image, "")) = "";

INSERT INTO temp_products (
    tmp_category_id, 
    tmp_product_id)
SELECT
    c.category_id, 
    c.product_id 
FROM db_shoes.shoes_product_to_category As c
INNER JOIN temp_categoriesNoImage As t
ON c.category_id = t.tmp_category_id;

INSERT INTO temp_images (
    tmp_image_id,
    tmp_category_id,
    tmp_product_id,
    tmp_path, 
    tmp_random_number)
SELECT 
    i.product_image_id, 
    t.tmp_category_id,
    i.product_id,
    i.image, 
    CONVERT((RAND(i.product_image_id) * 1000000), SIGNED)
FROM db_shoes.shoes_product_image As i
INNER JOIN temp_products As t
ON i.product_id = t.tmp_product_id;

INSERT INTO temp_selected_random_number (
    tmp_category_id,
    tmp_random_number)
SELECT 
    tmp_category_id,
    MIN(tmp_random_number)
FROM temp_images 
GROUP BY tmp_category_id;

/****************************
*   Loop through the data   *
****************************/

IF EXISTS (SELECT * FROM temp_images) THEN
    SET iPosStart = (SELECT MIN(tmp_id) FROM temp_categoriesNoImage);
    SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_categoriesNoImage);
    SET iCounter = iPosStart;

    INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("iPosStart ", CONVERT(iPosStart, CHAR)));
    INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("iPosEnd ", CONVERT(iPosEnd, CHAR)));
    
    WHILE iCounter <= iPosEnd DO
        IF EXISTS (SELECT * FROM temp_categoriesNoImage WHERE tmp_id = iCounter) THEN
            INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("iCounter ", CONVERT(iCounter, CHAR)));

            SET iCategoryId = (SELECT tmp_category_id FROM temp_categoriesNoImage WHERE tmp_id = iCounter);
            INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("iCategoryId ", CONVERT(iCategoryId, CHAR)));
            
            SET iId = (SELECT MIN(tmp_id) 
                       FROM temp_images 
                       WHERE tmp_random_number IN (SELECT tmp_random_number 
                                                   FROM temp_selected_random_number 
                                                   WHERE tmp_category_id = iCategoryId));
            INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("iId ", CONVERT(iId, CHAR)));

            SET sImagePath = (SELECT tmp_path FROM temp_images WHERE tmp_category_id = iCategoryId AND tmp_id = iId); 
            INSERT INTO temp_tracking (tmp_txt) VALUES (CONCAT("sImagePath ", sImagePath));
            
            UPDATE db_shoes.shoes_category
            SET image = sImagePath
            WHERE category_id = iCategoryId;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;


/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_id,
        tmp_txt 
    FROM temp_tracking 
    ORDER BY tmp_id;

    SELECT
        tmp_id,  
        tmp_image_id,
        tmp_category_id,
        tmp_product_id,
        tmp_path, 
        tmp_random_number
    FROM temp_images;

ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


