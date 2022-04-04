use db_settings;

DROP PROCEDURE if exists getAllStockStatusDetails;

DELIMITER //

CREATE PROCEDURE getAllStockStatusDetails(IN p_language_id INT, OUT p_bIsOk boolean)
BEGIN 

/*
SELECT tax_class_id, title, description, date_added, date_modified FROM db_shoes.shoes_tax_class
tax_class_id	title	description	date_added	date_modified
9 	Taxable Goods (Sold in EU) 	Taxed goods sold in EU 	2009-01-06 23:21:53 	2020-11-05 08:39:29
10 	Downloadable Products 	Downloadable 	2011-09-21 22:19:39 	2020-11-05 08:36:50
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_stock_status; 

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_stock_status (
  tmp_stock_status_id int(11) NOT NULL,
  tmp_language_id int(11) NOT NULL,
  tmp_name varchar(32) NOT NULL
);

/************************************************
*   Load stock status details into temp table   *
************************************************/
INSERT INTO temp_stock_status (tmp_stock_status_id, tmp_language_id, tmp_name)
SELECT stock_status_id, language_id, name
FROM db_shoes.shoes_stock_status
WHERE language_id = p_language_id;

/**************************************************
*   Check we have any entries in the temp table   *
**************************************************/
IF NOT EXISTS (SELECT * FROM temp_stock_status) THEN
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('stock status ID', 'No values found in the stock stuts table ', concat('Cant values for language ID ', CAST(p_language_id AS CHAR), ' in table db_shoes.shoes_stock_status'), "");
    set p_bIsOk = false;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of Stock status                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_stock_status_id As 'stock_status_id',
        tmp_language_id As 'language_id',
        tmp_name As 'name'
    FROM temp_stock_status;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


