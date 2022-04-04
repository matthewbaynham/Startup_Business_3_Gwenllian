USE db_settings;

DROP PROCEDURE IF EXISTS getOptionValueId;

DELIMITER //

CREATE PROCEDURE getOptionValueId(OUT p_bIsOk boolean, OUT p_status VARCHAR(1000), OUT p_option_value_id int, OUT p_sort_order int, in p_option_id int, in p_image varchar(1000), in p_language_id int, in p_name varchar(1000))
BEGIN 
DECLARE iIdMin int;
DECLARE iIdMax int;
/*DECLARE iMaxSortOrder int;*/
DECLARE iNextSortOrder int;
DECLARE iCount int;

SET p_bIsOk = true;
SET p_status = "";
SET p_option_value_id = -1;

/*
p_status = blank means that the data was found all is OK
p_status = not blank will mean that data was added because the p_name was found and a new element had to be added.  With multiple lanugaes a human needs to check that this didn't create a second entry for the same thing but just in an other lanuage.  p_status should be reported to the user in the ClsProgressReport
*/

/*
SELECT option_value_id, option_id, image, sort_order FROM `shoes_option_value` WHERE `option_id` = 13

option_value_id	option_id	image	sort_order
68 	13 		20
67 	13 		19
66 	13 		18
65 	13 		17
64 	13 		16
63 	13 		15
62 	13 		14
61 	13 		13
60 	13 		12
59 	13 		11
58 	13 		10
57 	13 		9
56 	13 		8
55 	13 		7
54 	13 		6
53 	13 		5
52 	13 		4
51 	13 		3
50 	13 		1
49 	13 		0


SELECT option_value_id, language_id, option_id, name FROM `shoes_option_value_description` WHERE `option_id` = 13

option_value_id	language_id	option_id	name
68 	2 	13 	UK 13.0
68 	1 	13 	UK 13.0
67 	2 	13 	UK 12.5
67 	1 	13 	UK 12.5
66 	2 	13 	UK 12.0
66 	1 	13 	UK 12.0
65 	2 	13 	UK 11.5
65 	1 	13 	UK 11.5
64 	2 	13 	UK 11.0
64 	1 	13 	UK 11.0
63 	2 	13 	UK 10.5
63 	1 	13 	UK 10.5
62 	2 	13 	UK 10.0
62 	1 	13 	UK 10.0
61 	2 	13 	UK 9.5
61 	1 	13 	UK 9.5
60 	2 	13 	UK 9.0
60 	1 	13 	UK 9.0
59 	2 	13 	UK 8.5
59 	1 	13 	UK 8.5
58 	2 	13 	UK 8.0
58 	1 	13 	UK 8.0
57 	2 	13 	UK 7.5
57 	1 	13 	UK 7.5
56 	2 	13 	UK 7.0
56 	1 	13 	UK 7.0
55 	2 	13 	UK 6.5
55 	1 	13 	UK 6.5
54 	2 	13 	UK 6.0
54 	1 	13 	UK 6.0
53 	2 	13 	UK 5.5
53 	1 	13 	UK 5.5
52 	2 	13 	UK 5.0
52 	1 	13 	UK 5.0
51 	2 	13 	UK 4.5
51 	1 	13 	UK 4.5
50 	2 	13 	UK 4.0
50 	1 	13 	UK 4.0
49 	2 	13 	UK 3.5
49 	1 	13 	UK 3.5
*/


/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_option_value;
DROP TABLE IF EXISTS temp_option_value_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_option_value (
    tmp_option_value_id int NOT NULL,
    tmp_option_id int NOT NULL,
    tmp_image varchar(255) NOT NULL,
    tmp_sort_order int NOT NULL
);

CREATE TEMPORARY TABLE temp_option_value_description (
    tmp_option_value_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_option_id int NOT NULL,
    tmp_name varchar(128) NOT NULL
);

/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_option_value (
    tmp_option_value_id,
    tmp_option_id,
    tmp_image,
    tmp_sort_order)
SELECT 
    option_value_id, 
    option_id, 
    image, 
    IFNULL(sort_order, 0)
FROM db_shoes.shoes_option_value
WHERE option_id = p_option_id;

INSERT INTO temp_option_value_description (
    tmp_option_value_id,
    tmp_language_id,
    tmp_option_id,
    tmp_name)
SELECT
    option_value_id, 
    language_id, 
    option_id, 
    name
FROM db_shoes.shoes_option_value_description 
WHERE option_id = p_option_id
AND language_id = p_language_id 
AND UPPER(TRIM(name)) = UPPER(TRIM(p_name));

/*************************************************************************************************
*   if we dont have the data in db_shoes.shoes_option_value_description                          *
*   then add to db_shoes.shoes_option_value and add to db_shoes.shoes_option_value_description   *
*                                                                                                *
*   There is a problem when dealing with multiple languages.                                     *
*                                                                                                *
*   If we have one entry for one language we need to only add an entry in                        *
*   db_shoes.shoes_option_value_description but not
*************************************************************************************************/
IF EXISTS (SELECT * FROM temp_option_value_description) THEN
    SET iCount = (SELECT COUNT(*) FROM temp_option_value_description);
    
    IF iCount > 1 THEN
        set p_bIsOk = false;
    
        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        VALUES ('data', 'Dupicate data', 'There are mulitple records with matching option_id, language_id and name in the table db_shoes.shoes_option_value_description', CONCAT('p_option_id: ', CONVERT(p_option_id, CHAR), ' - p_language_id: ',  CONVERT(p_language_id, CHAR), ' - p_name: ', p_name));
    ELSE
        SET p_option_value_id = (SELECT MIN(tmp_option_value_id) FROM temp_option_value_description);

        IF EXISTS (SELECT * FROM db_shoes.shoes_option_value WHERE option_value_id = p_option_value_id) THEN
            SET p_sort_order = (SELECT MAX(sort_order) FROM db_shoes.shoes_option_value WHERE option_value_id = p_option_value_id);
        END IF;
    END IF;
ELSE
    IF EXISTS (SELECT * FROM temp_option_value) THEN
        SET iNextSortOrder = 0;
    ELSE
        SET iNextSortOrder = (SELECT MAX(tmp_sort_order) FROM temp_option_value) + 1;
    END IF;

    SET p_sort_order = iNextSortOrder;

    INSERT INTO db_shoes.shoes_option_value (option_id, image, sort_order)
    VALUES (p_option_id, p_image, IFNULL(iNextSortOrder, 0));
    

    SET p_option_value_id = LAST_INSERT_ID();

    INSERT INTO db_shoes.shoes_option_value_description (option_value_id, language_id, option_id, name) 
    VALUES (p_option_value_id, p_language_id, p_option_id, p_name);
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


