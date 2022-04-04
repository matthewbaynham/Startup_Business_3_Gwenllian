use db_settings;

DROP PROCEDURE if exists getAttributeIds;

DELIMITER //

CREATE PROCEDURE getAttributeIds(IN p_Attribute_Name VARCHAR(255), IN p_Attribute_Group VARCHAR(255), IN p_language_id INT, OUT p_Attribute_ID int, OUT p_Attribute_Group_ID int, OUT p_bIsOk boolean)
BEGIN 
DECLARE i_Max_Attribute_Group_ID INT;
DECLARE i_Max_Attribute_ID INT;
DECLARE i_Max_Sort_Order INT;
DECLARE i_Max_Sort_Order_Group INT;

/*
SELECT `attribute_id`, `attribute_group_id`, `sort_order` FROM `shoes_attribute` 
SELECT `attribute_id`, `language_id`, `name` FROM `shoes_attribute_description` 
Eg. Length, Hieght, length, Weight
---------------------------------------------------------
SELECT `attribute_group_id`, `sort_order` FROM `shoes_attribute_group` 
SELECT `attribute_group_id`, `language_id`, `name` FROM `shoes_attribute_group_description` 
Eg. Shipping dimensions, items dimensions
---------------------------------------------------------
SELECT `product_id`, `attribute_id`, `language_id`, `text` FROM `shoes_product_attribute` 
*/

set p_bIsOk = true;

/******************************************************************************************
*  Simple proc made complex because it's best to keep the layout of all the ST the same   *
******************************************************************************************/



/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_attribute; 
DROP TABLE IF EXISTS temp_attribute_description; 
DROP TABLE IF EXISTS temp_attribute_group;
DROP TABLE IF EXISTS temp_attribute_group_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);


/*
SELECT `attribute_id`, `attribute_group_id`, `sort_order` FROM `shoes_attribute` 
SELECT `attribute_id`, `language_id`, `name` FROM `shoes_attribute_description` 
SELECT `attribute_group_id`, `sort_order` FROM `shoes_attribute_group` 
SELECT `attribute_group_id`, `language_id`, `name` FROM `shoes_attribute_group_description` 
*/

CREATE TEMPORARY TABLE temp_attribute (
    tmp_attribute_id int(11) NOT NULL,
    tmp_attribute_group_id int(11) NOT NULL,
    tmp_sort_order int(3) NOT NULL
);

CREATE TEMPORARY TABLE temp_attribute_description (
    tmp_attribute_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_name varchar(64) NOT NULL
); 

CREATE TABLE temp_attribute_group (
    tmp_attribute_group_id int(11) NOT NULL,
    tmp_sort_order int(3) NOT NULL
);

CREATE TABLE temp_attribute_group_description (
    tmp_attribute_group_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_name varchar(64) NOT NULL
);

/***************************
*   Sort out Group First   *
***************************/



/*********************************************
*   Load file type into temp table (Group)   *
*********************************************/

INSERT INTO temp_attribute_group_description (tmp_attribute_group_id, tmp_language_id, tmp_name)
SELECT DISTINCT attribute_group_id, language_id, name 
FROM db_shoes.shoes_attribute_group_description 
WHERE TRIM(UPPER(name)) = TRIM(UPPER(p_Attribute_Group));

INSERT INTO temp_attribute_group (tmp_attribute_group_id, tmp_sort_order)
SELECT DISTINCT attribute_group_id, sort_order 
FROM db_shoes.shoes_attribute_group 
WHERE attribute_group_id IN (SELECT attribute_group_id 
                             FROM db_shoes.shoes_attribute_group_description 
                             WHERE TRIM(UPPER(name)) = TRIM(UPPER(p_Attribute_Group)));


/*
(1) get the group id

(2) if the group ID doesn't exist then add it
*/
IF EXISTS (SELECT * FROM temp_attribute_group) THEN
    SET p_Attribute_Group_ID = (SELECT max(tmp_attribute_group_id) FROM temp_attribute_group);
ELSE
    SET i_Max_Attribute_Group_ID = (SELECT Max(g.Max_ID) FROM 
                                    (SELECT max(attribute_group_id) As Max_ID FROM db_shoes.shoes_attribute_group 
                                     UNION
                                     SELECT max(attribute_group_id) As Max_ID FROM db_shoes.shoes_attribute_group_description) As g);
    
    INSERT INTO db_shoes.shoes_attribute_group_description (attribute_group_id, language_id, name )
    VALUES (i_Max_Attribute_Group_ID + 1, p_language_id, p_Attribute_Group );
    
    IF EXISTS (SELECT * FROM db_shoes.shoes_attribute_group) THEN
        SET i_Max_Sort_Order_Group = (SELECT MAX(sort_order) FROM db_shoes.shoes_attribute_group);
    ELSE
        SET i_Max_Sort_Order_Group = 0;
    END IF;

    INSERT INTO db_shoes.shoes_attribute_group (attribute_group_id, sort_order)
    VALUES (i_Max_Attribute_Group_ID + 1, i_Max_Sort_Order_Group);
    
    SET p_Attribute_Group_ID = i_Max_Attribute_Group_ID + 1;
END IF;



/*************************************************
*   Load file type into temp table (not Group)   *
*************************************************/

INSERT INTO temp_attribute_description (tmp_attribute_id, tmp_language_id, tmp_name)
SELECT DISTINCT attribute_id, language_id, name 
FROM db_shoes.shoes_attribute_description
WHERE language_id = p_language_id
AND TRIM(UPPER(name)) = TRIM(UPPER(p_Attribute_Name))
AND attribute_id in (SELECT attribute_id 
                     FROM db_shoes.shoes_attribute 
                     WHERE attribute_group_id = p_Attribute_Group_ID);

INSERT INTO temp_attribute (tmp_attribute_id, tmp_attribute_group_id, tmp_sort_order)
SELECT DISTINCT attribute_id, attribute_group_id, sort_order 
FROM db_shoes.shoes_attribute
WHERE attribute_id IN (SELECT tmp_attribute_id
                       FROM temp_attribute_description);


/*
(3) get the attribute id
(4) if the attribute id doesn't exist then add it

SELECT `attribute_id`, `attribute_group_id`, `sort_order` FROM `shoes_attribute` 
SELECT `attribute_id`, `language_id`, `name` FROM `shoes_attribute_description` 

*/

IF EXISTS (SELECT * FROM temp_attribute) THEN
    set p_Attribute_ID = (SELECT MAX(tmp_attribute_id) FROM temp_attribute);
ELSE
    set i_Max_Attribute_ID = (SELECT max(A.Max_ID) FROM (SELECT MAX(attribute_id) AS Max_ID FROM db_shoes.shoes_attribute
                                                         UNION
                                                         SELECT MAX(attribute_id) AS Max_ID FROM db_shoes.shoes_attribute_description) AS A);
    
    IF EXISTS (SELECT * FROM db_shoes.shoes_attribute WHERE attribute_group_id = p_Attribute_Group_ID) THEN
        SET i_Max_Sort_Order = (SELECT MAX(sort_order) FROM db_shoes.shoes_attribute WHERE attribute_group_id = p_Attribute_Group_ID);
    ELSE
        SET i_Max_Sort_Order = 0;
    END IF;

    INSERT INTO db_shoes.shoes_attribute (attribute_id, attribute_group_id, sort_order)
    VALUES (i_Max_Attribute_ID + 1, p_Attribute_Group_ID, i_Max_Sort_Order + 1);
    
    SET p_Attribute_ID = i_Max_Attribute_ID + 1;
END IF;

IF NOT EXISTS (SELECT * FROM temp_attribute_description) THEN
    INSERT INTO db_shoes.shoes_attribute_description (attribute_id, language_id, name)
    VALUES (p_Attribute_ID, p_language_id, p_Attribute_Name);
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        A.tmp_attribute_id AS 'attribute_id', 
        D.tmp_name AS 'attribute_name', 
        G.tmp_attribute_group_id AS 'group_id', 
        G.tmp_name AS 'group_name'
    FROM temp_attribute_description AS D 
        INNER JOIN (temp_attribute AS A
            INNER JOIN temp_attribute_group_description AS G 
            ON A.tmp_attribute_group_id = G.tmp_attribute_group_id)
    ON D.tmp_attribute_id = A.tmp_attribute_id;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


