use db_settings;

DROP PROCEDURE if exists insertProdOpt;

DELIMITER //

CREATE PROCEDURE insertProdOpt(OUT p_bIsOk boolean, OUT p_product_option_id int, IN p_product_id int, IN p_option_id int, IN p_value text, IN p_required tinyint)
BEGIN 
/*
DROP TABLE IF EXISTS `shoes_product_option`;
CREATE TABLE `shoes_product_option` (
  `product_option_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `value` text NOT NULL,
  `required` tinyint(1) NOT NULL
);
SELECT `product_option_id`, `product_id`, `option_id`, `value`, `required` FROM `shoes_product_option` WHERE 1

product_option_id	product_id	option_id	value	required
227 	111869 	13 		1
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product_option;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_product_option (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_option_id int NOT NULL,
    tmp_product_id int NOT NULL,
    tmp_option_id int NOT NULL,
    tmp_value text NOT NULL,
    tmp_required tinyint NOT NULL
);


/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_product_option (
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_value,
    tmp_required)
SELECT
    po.product_option_id,
    po.product_id,
    po.option_id,
    po.value,
    po.required 
FROM db_shoes.shoes_product_option As po
WHERE 
    po.product_id = p_product_id
AND po.option_id = p_option_id;


/*******************************
*   Check there is an entry    *
*   if not then add an entry   *   
*******************************/
IF EXISTS (SELECT * FROM temp_product_option) THEN
    SET p_product_option_id = (SELECT MIN(tmp_product_option_id) FROM temp_product_option);
ELSE
    INSERT INTO db_shoes.shoes_product_option (product_id, option_id, value, required)
    VALUES (p_product_id, p_option_id, p_value, p_required);
    
    SET p_product_option_id = LAST_INSERT_ID();
    
    INSERT INTO temp_product_option (
        tmp_product_option_id,
        tmp_product_id,
        tmp_option_id,
        tmp_value,
        tmp_required)
    SELECT
        po.product_option_id,
        po.product_id,
        po.option_id,
        po.value,
        po.required 
    FROM db_shoes.shoes_product_option As po
    WHERE 
        po.product_id = p_product_id
    AND po.option_id = p_option_id;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT
        tmp_ID As 'id',
        tmp_product_option_id As 'product_option_id',
        tmp_product_id As 'product_id',
        tmp_option_id As 'option_id',
        tmp_value As 'value',
        tmp_required As 'required'
    FROM temp_product_option;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


