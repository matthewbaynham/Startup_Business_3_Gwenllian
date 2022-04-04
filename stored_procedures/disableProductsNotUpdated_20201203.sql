use db_settings;

DROP PROCEDURE IF EXISTS disableProductsNotUpdated;

DELIMITER //

CREATE PROCEDURE disableProductsNotUpdated(OUT p_bIsOk boolean, IN p_upload_type_id int)
BEGIN 
DECLARE dteMaxDate date;
declare iCounter int;
declare iPosA int;
declare iPosB int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
declare iTemp int default 0;
declare sTemp varchar(4000) default "";

SET p_bIsOk = true;

DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_products_logged;
DROP TABLE IF EXISTS temp_modified_dates;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_products_logged (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_upload_type_id INT NOT NULL,
    tmp_product_id INT NOT NULL);

CREATE TEMPORARY TABLE temp_modified_dates (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_date_modified datetime NOT NULL);

/**************************
*   populated with data   *
**************************/

INSERT INTO temp_products_logged (
    tmp_upload_type_id, 
    tmp_product_id)
SELECT 
    pl_upload_type_id,
    pl_product_id 
FROM tbl_products_logged 
WHERE pl_upload_type_id = p_upload_type_id;

INSERT INTO temp_modified_dates (tmp_date_modified)
SELECT DISTINCT CONVERT(date_modified, date)
FROM db_shoes.shoes_product INNER JOIN temp_products_logged
ON product_id = tmp_product_id
WHERE tmp_upload_type_id = p_upload_type_id;

IF EXISTS (SELECT MAX(tmp_date_modified) FROM temp_modified_dates) THEN
    SET dteMaxDate = (SELECT MAX(tmp_date_modified) FROM temp_modified_dates);
ELSE
    SET p_bIsOk = false;

    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    VALUES ('Max Date', 'Max Date', 'Cound not get the max modified date', 'No Max Date');
END IF;

IF p_bIsOk THEN
    /***************************
    *   disable the products   *
    ***************************/
    IF EXISTS (SELECT * FROM temp_products_logged) THEN
        SET iPosStart = (SELECT MIN(tmp_id) FROM temp_products_logged);
        SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_products_logged);
    
        SET iCounter = iPosStart;

        WHILE iCounter <= iPosEnd DO
            SET iTemp = -1;
            
            IF EXISTS (SELECT * FROM temp_products_logged WHERE tmp_id = iCounter) THEN
                SET iTemp = (SELECT tmp_product_id FROM temp_products_logged WHERE tmp_id = iCounter);
            
                UPDATE db_shoes.shoes_product
                SET status = 0
                WHERE NOT CONVERT(date_modified, date) = dteMaxDate
                AND product_id = iTemp;
            END IF;
            
            SET iCounter = iCounter + 1;
        END WHILE;
    END IF;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT  
        tmp_id As 'id',
        tmp_date_modified As 'date_modified'
    FROM temp_modified_dates;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


