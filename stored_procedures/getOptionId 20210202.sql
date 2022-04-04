use db_settings;

DROP PROCEDURE if exists getOptionId;

DELIMITER //

CREATE PROCEDURE getOptionId(OUT p_bIsOk boolean, OUT p_id int, in p_name varchar(128))
BEGIN 
declare iIdMin int;
declare iIdMax int;
/*
SELECT * FROM `shoes_option` 

option_id	type	sort_order
13 	select 	11


SELECT * FROM `shoes_option_description` 

option_id	language_id	name
13 	1 	Shoe Size
13 	2 	Schuhgröße
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_option;
DROP TABLE IF EXISTS temp_option_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

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


