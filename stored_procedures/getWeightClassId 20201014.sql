use db_settings;

DROP PROCEDURE if exists getWeightClassId;

DELIMITER //

CREATE PROCEDURE getWeightClassId(IN p_weight_text VARCHAR(255), OUT p_weight_class_ID int, OUT p_bIsOk boolean)
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
set p_weight_class_ID = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_weight_class_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_weight_class_description (
    tmp_weight_class_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_title varchar(32) NOT NULL,
    tmp_unit varchar(4) NOT NULL
);

/*************************************
*   Load file type into temp table   *
*************************************/
INSERT INTO temp_weight_class_description (tmp_weight_class_id, tmp_language_id, tmp_title, tmp_unit)
SELECT weight_class_id, language_id, title, unit
FROM db_shoes.shoes_weight_class_description
WHERE trim(lower(title)) = trim(lower(p_weight_text))
OR trim(lower(unit)) = trim(lower(p_weight_text));

/*****************************************************************
*   Check temp table is populated,                               *
*   if not write an error in error temp table and flag an error  *
*****************************************************************/
if not exists (select * from temp_weight_class_description) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'Cant find upload type ', concat('Cant find weight class ', p_weight_text, ' in table db_shoes.shoes_weight_class_description'), p_weight_text);
    set p_bIsOk = false;
end if;

/************************************************
*   Check we don't have more than one result    *
*   There should be only one weight class       *
************************************************/
if p_bIsOk then
    if (select count(*) from temp_weight_class_description) > 1 then
        insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('settings', 'More than one language ', concat('Cant find weight class ', p_weight_text , ' in table db_shoes.shoes_weight_class_description matches criteria'), p_weight_text);
        set p_bIsOk = false;
    end if;
end if;

/********************************************
*   Set upload file type ID out parameter   *
********************************************/
if p_bIsOk then
    set p_weight_class_ID = (select max(tmp_weight_class_id) from temp_weight_class_description);
end if;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_weight_class_id AS `weight_class_id`,
        tmp_language_id AS `language_id`,
        tmp_title AS `title`,
        tmp_unit AS `unit`
    FROM temp_weight_class_description;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


