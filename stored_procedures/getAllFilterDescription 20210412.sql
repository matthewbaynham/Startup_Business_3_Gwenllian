use db_settings;

DROP PROCEDURE if exists getAllFilterDescription;

DELIMITER //

CREATE PROCEDURE getAllFilterDescription(OUT p_bIsOk boolean, IN p_language_id INT)
BEGIN 

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_filter_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_filter_description (
    tmp_filter_id int, 
    tmp_language_id int,
    tmp_filter_group_id int,
    tmp_name VARCHAR(64));


/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_filter_description (
    tmp_filter_id, 
    tmp_language_id,
    tmp_filter_group_id,
    tmp_name)
SELECT 
    filter_id, 
    language_id, 
    filter_group_id, 
    name
FROM db_shoes.shoes_filter_description
WHERE language_id = p_language_id;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT
        tmp_filter_id As 'filter_id', 
        tmp_language_id As 'language_id',
        tmp_filter_group_id As 'filter_group_id',
        tmp_name As 'name'
    FROM temp_filter_description;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


