DROP PROCEDURE getRandomImagePath;

DELIMITER //

CREATE DEFINER=root@localhost PROCEDURE getRandomImagePath(IN p_session_ID VARCHAR(255)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN 
DECLARE iToday  INT(8) DEFAULT 0;  
DECLARE iYesterday  INT(8) DEFAULT 0;  
DECLARE sToday  char(8) DEFAULT "        ";  
DECLARE sYesterday  char(8) DEFAULT "        ";  


set sToday = DATE_FORMAT(CURRENT_DATE(), "%Y%m%d");
set iToday = CONVERT( sToday , UNSIGNED );

set sYesterday = DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY), "%Y%m%d");
set iYesterday = CONVERT( sYesterday , UNSIGNED );



DELETE FROM db_misc.tbl_root_page_previous_pictures 
WHERE NOT (last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday);


CREATE TEMPORARY TABLE temp_old_product_id 
SELECT product_id 
FROM db_misc.tbl_root_page_previous_pictures 
WHERE last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday
ORDER BY last_displayed_timestamp DESC
LIMIT 5;

CREATE TEMPORARY TABLE temp_old_product_image_id 
SELECT product_image_id, product_id 
FROM db_misc.tbl_root_page_previous_pictures 
WHERE last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday
ORDER BY last_displayed_timestamp DESC
LIMIT 10;

DELETE FROM db_misc.tbl_root_page_previous_pictures 
WHERE NOT (last_displayed_date_as_int in (SELECT product_id FROM temp_old_product_id)
           or last_displayed_date_as_int in (SELECT product_image_id FROM temp_old_product_image_id));


/*
SELECT id, session_id, product_id, product_image_id, last_displayed_timestamp, last_displayed_date_as_int FROM tbl_root_page_previous_pictures WHERE 1
*/


SELECT I.image as Image_Path, 
       CONCAT('https://www.gwenllian-retail.com/shop/index.php?route=product/product&product_id=', P.product_id) as URL, 
       P.product_id as Product_id 
FROM db_shoes.shoes_product_image As I 
       INNER JOIN db_shoes.shoes_product As P 
       ON I.product_id = P.product_id 
WHERE I.product_id not in (SELECT product_id FROM temp_old_product_id) 
       AND I.product_image_id not in (SELECT product_image_id FROM temp_old_product_image_id)
ORDER BY RAND() 
LIMIT 1; 


INSERT INTO db_misc.tbl_root_page_previous_pictures ( session_id, product_id, product_image_id, last_displayed_date_as_int ) 
SELECT p_session_ID,  product_id, product_image_id, iToday FROM temp_old_product_image_id;

END// 

DELIMITER ;



