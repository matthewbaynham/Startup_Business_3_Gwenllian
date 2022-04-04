use db_settings;

DROP PROCEDURE if exists getAllProductFilters;

DELIMITER //

CREATE PROCEDURE getAllProductFilters(OUT p_bIsOk boolean, in p_upload_type_id int, IN p_language_id INT)
BEGIN 

set p_bIsOk = true;

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
    tmp_product_id int,
    tmp_filter_id int,
    tmp_filter_name VARCHAR(64));

/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_product_filter (
    tmp_product_id,
    tmp_filter_id,
    tmp_filter_name)
SELECT f.product_id, f.filter_id, d.name 
FROM db_shoes.shoes_product_filter As f
INNER JOIN db_shoes.shoes_filter_description As d
ON f.filter_id = d.filter_id
WHERE d.language_id = p_language_id
AND f.product_id in (SELECT pl_product_id FROM db_settings.tbl_products_logged WHERE pl_upload_type_id = p_upload_type_id);



/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT 
        tmp_product_id As 'product_id',
        tmp_filter_id As 'filter_id',
        tmp_filter_name As 'filter_name'
    FROM temp_product_filter;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


