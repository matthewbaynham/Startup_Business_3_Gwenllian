use db_settings;

DROP PROCEDURE if exists insertProductCategoryMapping;

DELIMITER //

CREATE PROCEDURE insertProductCategoryMapping(IN p_product_id int, IN p_category_id int, IN p_parent_id INT, OUT p_bIsOk boolean)
BEGIN

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product_to_category;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_product_to_category (
  tmp_product_id int(11) NOT NULL,
  tmp_category_id int(11) NOT NULL);

/*SELECT `product_id`, `category_id` FROM `shoes_product_to_category`*/

/************************
*   Get existing data   *
************************/
INSERT INTO temp_product_to_category 
    (tmp_product_id, tmp_category_id)
SELECT product_id, category_id
FROM db_shoes.shoes_product_to_category
WHERE product_id = p_product_id 
AND category_id = p_category_id;

/*********************************************
*   Delete any data that shouldnt be there   *
*********************************************/
IF EXISTS (SELECT * FROM temp_product_to_category) THEN
    DELETE FROM db_shoes.shoes_product_to_category
    WHERE product_id = p_product_id 
    AND category_id = p_category_id;
END IF;

/************************************
*   Insert the data we need added   *
************************************/
IF NOT EXISTS (SELECT * FROM db_shoes.shoes_product_to_category WHERE product_id = p_product_id AND category_id = p_category_id) THEN
    INSERT INTO db_shoes.shoes_product_to_category (product_id, category_id)
    VALUES (p_product_id, p_category_id);
END IF;

/****************************************************
*   Add the category and parent to all the stores   *
****************************************************/
/*
DELETE FROM db_shoes.shoes_category_to_store 
WHERE category_id = p_category_id
OR category_id = p_parent_id;
*/
/*SELECT `category_id`, `store_id` FROM `shoes_category_to_store`*/

IF EXISTS (SELECT * FROM db_shoes.shoes_store) THEN
    INSERT INTO db_shoes.shoes_category_to_store (category_id, store_id)
    SELECT DISTINCT p_category_id, store_id FROM db_shoes.shoes_store;

    IF p_parent_id > 0 then
        INSERT INTO db_shoes.shoes_category_to_store (category_id, store_id)
        SELECT DISTINCT  p_parent_id, store_id FROM db_shoes.shoes_store;
    END IF;
ELSE
    IF NOT EXISTS(SELECT * FROM db_shoes.shoes_category_to_store WHERE category_id = p_category_id AND store_id = 0) THEN
        INSERT INTO db_shoes.shoes_category_to_store (category_id, store_id)
        VALUES (p_category_id, 0);
    END IF;
    
    IF p_parent_id > 0 then
        IF NOT EXISTS(SELECT * FROM db_shoes.shoes_category_to_store WHERE category_id = p_parent_id AND store_id = 0) THEN
            INSERT INTO db_shoes.shoes_category_to_store (category_id, store_id)
            VALUES (p_parent_id, 0);
        END IF;
    END IF;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT 
        tmp_product_id As 'product_id', 
        tmp_category_id As 'category_id'
    FROM temp_product_to_category; 
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


