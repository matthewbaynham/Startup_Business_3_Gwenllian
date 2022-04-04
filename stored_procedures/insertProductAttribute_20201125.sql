use db_settings;

DROP PROCEDURE if exists insertProductAttribute;

DELIMITER //

CREATE PROCEDURE insertProductAttribute(IN p_product_id int, IN p_language_id int, IN p_attribute_id INT, IN p_text text, OUT p_bIsOk boolean)
BEGIN

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_shoes_product_attribute;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_shoes_product_attribute (
    tmp_product_id int(11) NOT NULL,
    tmp_attribute_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_text text NOT NULL
);

/************************
*   Get existing data   *
************************/
INSERT INTO temp_shoes_product_attribute (
    tmp_product_id,
    tmp_attribute_id,
    tmp_language_id,
    tmp_text)
SELECT 
    A.product_id, 
    A.attribute_id, 
    A.language_id, 
    A.text 
FROM db_shoes.shoes_product_attribute As A  
WHERE
    A.product_id = p_product_id
AND A.attribute_id = p_attribute_id
AND A.language_id = p_language_id;

/*********************************************
*   Delete any data that shouldnt be there   *
*********************************************/
IF EXISTS (SELECT * FROM temp_shoes_product_attribute) THEN
    DELETE 
    FROM db_shoes.shoes_product_attribute As A  
    WHERE
        A.product_id = p_product_id
    AND A.attribute_id = p_attribute_id
    AND A.language_id = p_language_id;
END IF;

/************************************
*   Insert the data we need added   *
************************************/
INSERT INTO db_shoes.shoes_product_attribute (product_id, attribute_id, language_id, text)
VALUES (p_product_id, p_attribute_id, p_language_id, p_text);


/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT 
        A.product_id As 'product_id', 
        A.attribute_id As 'attribute_id', 
        A.language_id As 'language_id', 
        A.text As 'text' 
    FROM db_shoes.shoes_product_attribute As A  
    WHERE
        A.product_id = p_product_id
    AND A.attribute_id = p_attribute_id
    AND A.language_id = p_language_id;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


