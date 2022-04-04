use db_settings;

DROP PROCEDURE if exists deleteProductFilter;

DELIMITER //

CREATE PROCEDURE deleteProductFilter(OUT p_bIsOk boolean, OUT p_filter_id int, IN p_product_id INT)
BEGIN 

SET p_bIsOk = true;
SET p_filter_id = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product_filter;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_product_filter (
    tmp_product_id int NOT NULL,
    tmp_filter_id int NOT NULL);

/**************************************
*   Get the filter description data   *
**************************************/
INSERT INTO temp_product_filter (
    tmp_product_id,
    tmp_filter_id)
SELECT     
    product_id, 
    filter_id
FROM db_shoes.shoes_product_filter   
WHERE 
    product_id = p_product_id
AND filter_id = p_filter_id;

IF EXISTS (SELECT * FROM temp_product_filter) THEN
    DELETE FROM db_shoes.shoes_product_filter   
    WHERE 
        product_id = p_product_id
    AND filter_id = p_filter_id;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        tmp_product_id,
        tmp_filter_id 
    FROM temp_product_filter;
ELSE
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;





