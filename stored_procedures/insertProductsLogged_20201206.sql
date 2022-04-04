use db_settings;

DROP PROCEDURE if exists insertProductsLogged;

DELIMITER //

CREATE PROCEDURE insertProductsLogged(p_upload_type_id INT, IN p_product_id INT, OUT p_bIsOk boolean)
BEGIN 

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_products_logged;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_products_logged (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_upload_type_id INT NOT NULL,
    tmp_product_id INT NOT NULL);


/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_products_logged (tmp_upload_type_id, tmp_product_id)
SELECT pl_upload_type_id, pl_product_id 
FROM tbl_products_logged
WHERE pl_upload_type_id = p_upload_type_id
AND pl_product_id = p_product_id;

/*********************************************
*   If we dont have the record then add it   *
*********************************************/
IF NOT EXISTS (SELECT * FROM temp_products_logged) THEN
    INSERT INTO tbl_products_logged (pl_upload_type_id, pl_product_id)
    VALUES (p_upload_type_id, p_product_id);
END IF;

/*******************************
*   Check we have the record   *
*******************************/
DELETE FROM temp_products_logged;

INSERT INTO temp_products_logged (tmp_upload_type_id, tmp_product_id)
SELECT pl_upload_type_id, pl_product_id 
FROM tbl_products_logged
WHERE pl_upload_type_id = p_upload_type_id
AND pl_product_id = p_product_id;


IF NOT EXISTS (temp_products_logged) THEN
    SET p_bIsOk = true;

    INSERT INTO temp_errors (
        err_Category,
        err_Name,
        err_Long_Description,
        err_Values)
    VALUES ( 
        'updating tbl_products_logged failed',
        '',
        CONCAT('upload type id: ', CONVERT(p_upload_type_id, CHAR), ' - product id: ', CONVERT(p_product_id, CHAR)),
        '');
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_id As 'pl_id',
        tmp_upload_type_id As 'pl_upload_type_id',
        tmp_product_id As 'pl_product_id'
    FROM temp_products_logged;
ELSE
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
END IF;

END// 

DELIMITER ;


