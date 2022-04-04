use db_settings;

DROP PROCEDURE if exists getAllWeightClassDetails;

DELIMITER //

CREATE PROCEDURE getAllWeightClassDetails(IN p_language_ID int, OUT p_bIsOk boolean)
BEGIN 

/*
SELECT `weight_class_id`, `language_id`, `title`, `unit` FROM `shoes_weight_class_description` WHERE 1
weight_class_id	language_id	title	unit
	1 	1 	Kilogram 	kg
	2 	1 	Gram 	g
	5 	1 	Pound 	lb
	6 	1 	Ounce 	oz
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_weight_class_details;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_weight_class_details (
    tmp_weight_class_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_title varchar(32) NOT NULL,
    tmp_unit varchar(4) NOT NULL,
    tmp_value decimal(15,8) NOT NULL
);

/*************************************
*   Load file type into temp table   *
*************************************/
INSERT INTO temp_weight_class_details (tmp_weight_class_id, tmp_language_id, tmp_title, tmp_unit, tmp_value)
SELECT weight_class_id, language_id, title, unit, 0.0
FROM db_shoes.shoes_weight_class_description
WHERE language_id = p_language_ID;

UPDATE temp_weight_class_details AS t
INNER JOIN db_shoes.shoes_weight_class AS w ON t.tmp_weight_class_id = w.weight_class_id
SET t.tmp_value = w.value;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_weight_class_id AS `weight_class_id`,
        tmp_language_id AS `language_id`,
        tmp_title AS `title`,
        tmp_unit AS `unit`,
        tmp_value As 'value'
    FROM temp_weight_class_details;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


