use db_settings;

DROP PROCEDURE if exists getAllFilterGroupDescription;

DELIMITER //

CREATE PROCEDURE getAllFilterGroupDescription(OUT p_bIsOk boolean)
BEGIN 

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_filter_group_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_filter_group_description (
    tmp_filter_group_id int,
    tmp_language_id int,
    tmp_name VARCHAR(64));

/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_filter_group_description (
    tmp_filter_group_id,
    tmp_language_id,
    tmp_name)
SELECT 
    filter_group_id, 
    language_id, 
    name
FROM db_shoes.shoes_filter_group_description;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT
        tmp_filter_group_id As 'filter_group_id',
        tmp_language_id As 'language_id',
        tmp_name As 'name'
    FROM temp_filter_group_description;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


