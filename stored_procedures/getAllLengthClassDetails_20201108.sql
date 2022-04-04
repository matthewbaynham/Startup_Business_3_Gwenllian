use db_settings;

DROP PROCEDURE if exists getAllLengthClassDetails;

DELIMITER //

CREATE PROCEDURE getAllLengthClassDetails(IN p_language_ID int, OUT p_bIsOk boolean)
BEGIN 
/*
SELECT `length_class_id`, `value` FROM `shoes_length_class` WHERE 1
length_class_id	value
1 	1.00000000
2 	10.00000000
3 	0.39370000	

SELECT `length_class_id`, `language_id`, `title`, `unit` FROM `shoes_length_class_description` WHERE 1
length_class_id	language_id	title	unit
1 	1 	Centimeter 	cm
2 	1 	Millimeter 	mm
3 	1 	Inch 	in
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_length_class_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_length_class_description (
    tmp_length_class_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_title varchar(32) NOT NULL,
    tmp_unit varchar(4) NOT NULL,
    tmp_value decimal(15,8) NOT NULL
);

/*************************************
*   Load file type into temp table   *
*************************************/
INSERT INTO temp_length_class_description (tmp_length_class_id, tmp_language_id, tmp_title, tmp_unit, tmp_value)
SELECT length_class_id, language_id, title, unit, 0 
FROM db_shoes.shoes_length_class_description 
WHERE language_id = p_language_ID;

UPDATE temp_length_class_description AS t
INNER JOIN db_shoes.shoes_length_class AS l ON t.tmp_length_class_id = l.length_class_id
SET t.tmp_value = l.value;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_length_class_id AS `length_class_id`,
        tmp_language_id AS `language_id`,
        tmp_title AS `title`,
        tmp_unit AS `unit`,
        tmp_value As 'value'
    FROM temp_length_class_description;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


