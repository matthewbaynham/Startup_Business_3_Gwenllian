use db_settings;

DROP PROCEDURE if exists insertFilterGroup;

DELIMITER //

CREATE PROCEDURE insertFilterGroup(OUT p_bIsOk boolean, OUT p_filter_group_id int, IN p_language_id int, IN p_filter_group_name varchar(64), IN p_product_id INT)
BEGIN 

/*****************************************************************
*                                                                *
*   **********************************************************   *
*   *   Should do this manually without a stored procedure   *   *
*   *                                                        *   *
*   *   I wouldn't be able to match up new records if they   *   *
*   *   have already been added in a different language.     *   *
*   **********************************************************   *
*                                                                *
*****************************************************************/



SET p_bIsOk = true;
SET p_filter_group_id = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_filter_group;
DROP TABLE IF EXISTS temp_filter_group_description;
DROP TABLE IF EXISTS temp_filter;
DROP TABLE IF EXISTS temp_product_filter;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_filter_group (
    tmp_filter_group_id int NOT NULL,
    tmp_sort_order int NOT NULL);

CREATE TEMPORARY TABLE temp_filter_group_description (
    tmp_filter_group_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(64) NOT NULL);

CREATE TEMPORARY TABLE temp_filter (
  tmp_filter_id int NOT NULL,
  tmp_filter_group_id int NOT NULL,
  tmp_sort_order int NOT NULL);

CREATE TEMPORARY TABLE temp_product_filter (
    tmp_product_id int NOT NULL,
    tmp_filter_id int NOT NULL);

/*SELECT `product_id`, `filter_id` FROM `shoes_product_filter` WHERE 1*/


/*********************************
*   get the group descriptions   *
*********************************/
INSERT INTO temp_filter_group_description (
    tmp_filter_group_id,
    tmp_language_id,
    tmp_name)
SELECT    
    filter_group_id,
    language_id,
    name
FROM db_shoes.shoes_filter_group_description
WHERE
    language_id = p_language_id
AND TRIM(UPPER(name)) = TRIM(UPPER(p_filter_group_name));

/*
*
*/





IF EXISTS (SELECT * FROM temp_filter_description) THEN
    SET p_filter_group_id = (SELECT MAX(tmp_filter_group_id) FROM temp_filter_group_description WHERE TRIM(UPPER(name)) = TRIM(UPPER(p_filter_group_name)));
ELSE
    /*******************************************************************************
    *   Check if the filter has been added (for example in a different language)   *
    *******************************************************************************/
    INSERT INTO temp_product_filter (
        tmp_product_id,
        tmp_filter_id)
    SELECT
        product_id, 
        filter_id
    FROM db_shoes.shoes_product_filter
    WHERE 
        product_id = p_product_id
    AND filter_id in (SELECT filter_id FROM db_shoes.shoes_filter WHERE filter_group_id = p_filter_group_id);
    
    IF EXISTS (SELECT * FROM temp_product_filter) THEN
        SET p_filter_id = (SELECT MAX(tmp_filter_id) FROM temp_product_filter);
    ELSE
        INSERT INTO db_shoes.shoes_filter_group (sort_order)
        VALUES (0);

        SET p_filter_group_id = LAST_INSERT_ID();

        INSERT INTO db_shoes.shoes_filter (
            filter_group_id,
            sort_order)
        VALUES (p_filter_group_id, 0);
        
        SET p_filter_id = LAST_INSERT_ID();
        
    END IF;

    INSERT INTO db_shoes.shoes_filter (
        filter_group_id,
        sort_order)
    VALUES 
        p_filter_group_id,
        p_sort_order);

    SET p_filter_id = LAST_INSERT_ID();

    INSERT INTO db_shoes.shoes_filter_description 
        filter_id,
        language_id,
        filter_group_id,
        name 
    VALUES (
        p_filter_id,
        p_language_id,
        p_filter_group_id,
        p_name 
    );
FROM As d

END IF;


/*******************************************
*   match up the product with the filter   *
*******************************************/
DELETE FROM temp_product_filter;

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

/*IF NOT EXISTS (SELECT * FROM temp_product_filter) THEN*/
IF NOT EXISTS (SELECT * FROM db_shoes.shoes_product_filter WHERE product_id = p_product_id AND filter_id = p_filter_id) THEN
    INSERT INTO db_shoes.shoes_product_filter (
        product_id,
        filter_id)
    VALUES (
        p_product_id, 
        p_filter_id);
END IF;



/*
Check if an item is in shoes_filter_description

If not then use the product id to have a guess what it could be from another language

if we still don't know what it is then insert into shoes_filter fisrt 
and use the auto increment on the filter_id field to give you a value to use for 
inserting into shoes_filter_description

*/









INSERT INTO `shoes_filter` (`filter_id`, `filter_group_id`, `sort_order`) VALUES
(1, 1, 1),
(2, 1, 0),
(3, 1, 2);






CREATE TEMPORARY TABLE temp_option (
  tmp_option_id int(11) NOT NULL,
  tmp_type varchar(32) NOT NULL,
  tmp_sort_order int(3) NOT NULL
);

CREATE TEMPORARY TABLE temp_option_description (
  tmp_option_id int(11) NOT NULL,
  tmp_language_id int(11) NOT NULL,
  tmp_name varchar(128) NOT NULL
);

/********************************
*   Load data into temp table   *
********************************/

INSERT INTO temp_option_description (
  tmp_option_id,
  tmp_language_id,
  tmp_name)
SELECT 
  d.option_id,
  d.language_id,
  d.`name`
FROM db_shoes.shoes_option_description As d
WHERE UPPER(TRIM(d.`name`)) = UPPER(TRIM(p_name));

/*************************
*   check we have data   *
*************************/
IF p_bIsOk THEN
    IF NOT EXISTS (SELECT * FROM temp_option_description) THEN
        set p_bIsOk = false;
    
        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        VALUES ('data', 'Cant find option with name', 'Couldnt find any data in the table db_shoes.shoes_option_description', CONCAT('p_name: ', p_name));
    END IF;
END IF;

IF p_bIsOk THEN
    SET iIdMin = (SELECT MIN(tmp_option_id) FROM temp_option_description);
    SET iIdMax = (SELECT MAX(tmp_option_id) FROM temp_option_description);
    
    IF iIdMin = iIdMax THEN
        SET p_id = iIdMax;
    ELSE
        set p_bIsOk = false;
    
        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        VALUES ('data', 'too much data', 'the results set has different values for minimum id value and maximum id value when there should only be one id value', CONCAT('p_name: ', p_name));
    END IF;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_option_id As 'option_id',
        tmp_language_id As 'language_id',
        tmp_name As 'name'
    FROM temp_option_description;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;





