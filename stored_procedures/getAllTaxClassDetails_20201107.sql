use db_settings;

DROP PROCEDURE if exists getAllTaxClassDetails;

DELIMITER //

CREATE PROCEDURE getAllTaxClassDetails(OUT p_bIsOk boolean)
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
DROP TABLE IF EXISTS temp_tax_class;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_tax_class (
  tmp_tax_class_id int(11) NOT NULL,
  tmp_title varchar(32) NOT NULL,
  tmp_description varchar(255) NOT NULL,
  tmp_date_added datetime NOT NULL,
  tmp_date_modified datetime NOT NULL
);

/*************************************
*   Load file type into temp table   *
*************************************/

INSERT INTO temp_tax_class (tmp_tax_class_id, tmp_title, tmp_description, tmp_date_added, tmp_date_modified)
SELECT tax_class_id, title, description, date_added, CASE WHEN date_modified < '1900-01-01 01:01:01' THEN date_added ELSE date_modified END FROM db_shoes.shoes_tax_class;



/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        tmp_tax_class_id As 'tax_class_id',
        tmp_title As 'title',
        tmp_description As 'description',
        tmp_date_added As 'date_added',
        tmp_date_modified As 'date_modified' 
    FROM temp_tax_class;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;




