use db_settings;

DROP PROCEDURE if exists insertFilter;

DELIMITER //

CREATE PROCEDURE insertFilter(OUT p_bIsOk boolean, OUT p_filter_id int, IN p_language_id int, IN p_filter_group_id int, IN p_name varchar(64), IN p_product_id INT)
BEGIN 

SET p_bIsOk = true;
SET p_filter_id = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_filter_description;
DROP TABLE IF EXISTS temp_filter;
DROP TABLE IF EXISTS temp_product_filter;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_filter_description (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_filter_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_filter_group_id int NOT NULL,
    tmp_name varchar(64) NOT NULL);

CREATE TEMPORARY TABLE temp_filter (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_filter_id int NOT NULL,
    tmp_filter_group_id int NOT NULL,
    tmp_sort_order int NOT NULL);

CREATE TEMPORARY TABLE temp_product_filter (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_filter_id int NOT NULL);

/**************************************
*   Get the filter description data   *
**************************************/
INSERT INTO temp_filter_description (
    tmp_filter_id,
    tmp_language_id,
    tmp_filter_group_id,
    tmp_name)
SELECT DISTINCT 
    d.filter_id,
    d.language_id,
    d.filter_group_id,
    d.name 
FROM db_shoes.shoes_filter_description As d
WHERE d.filter_group_id = p_filter_group_id
AND d.language_id = p_language_id
AND TRIM(UPPER(d.name)) = TRIM(UPPER(p_name));

/************************************************************
*   get the filter id if there is not a filter create one   *
************************************************************/
IF EXISTS (SELECT * FROM temp_filter_description) THEN
    SET p_filter_id = (SELECT MAX(tmp_filter_id) FROM temp_filter_description WHERE TRIM(UPPER(tmp_name)) = TRIM(UPPER(p_name)));
ELSE
    /*******************************************************************************
    *   Check if the filter has been added (for example in a different language)   *
    *******************************************************************************/
    INSERT INTO temp_product_filter (
        tmp_product_id,
        tmp_filter_id)
    SELECT DISTINCT 
        product_id, 
        filter_id
    FROM db_shoes.shoes_product_filter
    WHERE 
        product_id = p_product_id
    AND filter_id in (SELECT filter_id FROM db_shoes.shoes_filter WHERE filter_group_id = p_filter_group_id);
    
    IF EXISTS (SELECT * FROM temp_product_filter) THEN
        SET p_filter_id = (SELECT MAX(tmp_filter_id) FROM temp_product_filter);
    ELSE
        INSERT INTO db_shoes.shoes_filter (
            filter_group_id,
            sort_order)
        VALUES (p_filter_group_id, 0);
        
        SET p_filter_id = LAST_INSERT_ID();
    END IF;

    IF NOT EXISTS (SELECT * 
                   FROM db_shoes.shoes_filter_description 
                   WHERE filter_id = p_filter_id 
                   AND language_id = p_language_id) THEN
        INSERT INTO db_shoes.shoes_filter_description (
            filter_id,
            language_id,
            filter_group_id,
            name) 
        VALUES (
            p_filter_id,
            p_language_id,
            p_filter_group_id,
            p_name);
    END IF;
END IF;

/*******************************************
*   match up the product with the filter   *
*******************************************/
IF p_filter_id > 0 THEN
    DELETE FROM temp_product_filter;

    INSERT INTO temp_product_filter (
        tmp_product_id,
        tmp_filter_id)
    SELECT DISTINCT 
        product_id,
        filter_id
    FROM db_shoes.shoes_product_filter
    WHERE 
        product_id = p_product_id
    AND filter_id = p_filter_id;

/*    IF NOT EXISTS (SELECT * FROM db_shoes.shoes_product_filter WHERE product_id = p_product_id AND filter_id = p_filter_id) THEN*/
    IF NOT EXISTS (SELECT * FROM temp_product_filter) THEN
        INSERT INTO db_shoes.shoes_product_filter (
            product_id,
            filter_id)
        VALUES (
            p_product_id, 
            p_filter_id);
    END IF;
END IF;



/*
Check if an item is in shoes_filter_description

If not then use the product id to have a guess what it could be from another language

if we still don't know what it is then insert into shoes_filter fisrt 
and use the auto increment on the filter_id field to give you a value to use for 
inserting into shoes_filter_description

*/

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        tmp_filter_id As 'Filter_Id',
        tmp_language_id As 'Language_Id',
        tmp_filter_group_id As 'Filter_Group_Id',
        tmp_name As 'Name'
    FROM temp_filter_description;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;





