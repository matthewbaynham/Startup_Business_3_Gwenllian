use db_settings;

DROP PROCEDURE IF EXISTS fix_categories_seo;

DELIMITER //

CREATE PROCEDURE fix_categories_seo(OUT p_bIsOk boolean)
BEGIN 
declare iCounter int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
DECLARE iProductId INT;
DECLARE iCategoryId INT;
DECLARE iParentCategoryId INT;
DECLARE sTextReplace_orig varchar(255);
DECLARE sTextReplace_new varchar(255);
DECLARE iLanguageId int;
DECLARE sName varchar(255);

DECLARE exit handler for SQLEXCEPTION
 BEGIN
  GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
   @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
  SET p_bIsOk = false;
  SELECT 0 as err_ID, 
         CONCAT('MYSQL_ERRNO: ', @errno) As err_Category, 
         CONCAT('MYSQL_ERRNO: ', @sqlstate) as err_Name, 
         CONCAT('MESSAGE_TEXT: ', @text) As err_Long_Description, 
         '' As err_Values;
 END;

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product;
DROP TABLE IF EXISTS temp_category_description;
DROP TABLE IF EXISTS temp_category_dupicates;
DROP TABLE IF EXISTS temp_problems;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_category_description (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_meta_title varchar(255) NOT NULL,
    tmp_meta_description varchar(255) NOT NULL,
    tmp_meta_keyword varchar(255) NOT NULL, 
    tmp_duplicate_name bool);

CREATE TEMPORARY TABLE temp_category_dupicates (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_name varchar(255) NOT NULL,
    tmp_count INT);

CREATE TEMPORARY TABLE temp_problems (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_text varchar(1024) NOT NULL,
    tmp_status varchar(1024) NOT NULL);

/*********************
*   Get categories   *
*********************/
INSERT INTO temp_category_description (
    tmp_category_id,
    tmp_language_id,
    tmp_name,
    tmp_description,
    tmp_meta_title,
    tmp_meta_description,
    tmp_meta_keyword, 
    tmp_duplicate_name)
SELECT
    d.category_id,
    d.language_id,
    trim(lower(d.name)), 
    d.description,
    d.meta_title,
    d.meta_description,
    d.meta_keyword, 
    false
FROM db_shoes.shoes_category_description As d;

UPDATE temp_category_description
SET tmp_name = trim(lower(tmp_name));

IF EXISTS (SELECT * FROM db_settings.text_to_replace) THEN
    SET iPosStart = (SELECT MIN(id) FROM db_settings.text_to_replace);
    SET iPosEnd = (SELECT MAX(id) FROM db_settings.text_to_replace);
    SET iCounter = iPosStart;
    
    WHILE iCounter <= iPosEnd DO
        IF EXISTS (SELECT * FROM db_settings.text_to_replace WHERE id = iCounter) THEN
            SET sTextReplace_orig = (SELECT orig FROM db_settings.text_to_replace WHERE id = iCounter);
            SET sTextReplace_new = (SELECT new FROM db_settings.text_to_replace WHERE id = iCounter);
            SET iLanguageId = (SELECT language_id FROM db_settings.text_to_replace WHERE id = iCounter);
            
            UPDATE temp_category_description
            SET tmp_name = REPLACE(tmp_name, sTextReplace_orig, sTextReplace_new)
            WHERE tmp_language_id = iLanguageId;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

INSERT INTO temp_category_dupicates (
    tmp_name,
    tmp_count)
SELECT
    tmp_name, 
    COUNT(tmp_ID)
FROM temp_category_description
GROUP BY tmp_name;

INSERT INTO temp_problems (tmp_text, tmp_status)
SELECT
    CONCAT(Sub.category_name, " is dulicated with ", CONVERT(Sub.Count, CHAR), " records"), 
    "PROBLEM" 
FROM
    (SELECT
        tmp_name As 'category_name',
        tmp_count As 'Count'
    FROM temp_category_dupicates 
    WHERE tmp_count > 1) As Sub;

IF EXISTS (SELECT * FROM temp_category_dupicates) THEN
    SET iPosStart = (SELECT MIN(tmp_id) FROM temp_category_dupicates);
    SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_category_dupicates);
    SET iCounter = iPosStart;
    
    WHILE iCounter <= iPosEnd DO
        IF EXISTS (SELECT * FROM temp_category_dupicates WHERE tmp_id = iCounter AND tmp_count = 1) THEN
            SET sName = (SELECT tmp_name FROM temp_category_dupicates WHERE tmp_id = iCounter AND tmp_count = 1);
            SET iCategoryId = (SELECT MAX(tmp_category_id) FROM temp_category_description WHERE tmp_name = sName);
            SET iLanguageId = (SELECT MAX(tmp_language_id) FROM temp_category_description WHERE tmp_name = sName);
            
            IF EXISTS (SELECT *
                       FROM db_shoes.shoes_seo_url As s 
                       WHERE s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR))
                       AND s.keyword = sName
                       AND s.language_id = iLanguageId) THEN
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT(sName, " already in table with correct category ID correct language id"), "OK");
            ELSEIF EXISTS (SELECT *
                           FROM db_shoes.shoes_seo_url As s 
                           WHERE s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR))
                           AND s.keyword = sName
                           AND NOT s.language_id = iLanguageId) THEN
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT(sName, " already in table with correct category ID but WRONG language id"), "ERROR");
            ELSEIF EXISTS (SELECT *
                           FROM db_shoes.shoes_seo_url As s 
                           WHERE s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR))
                           AND NOT s.keyword = sName
                           AND s.language_id = iLanguageId) THEN
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT("category ID ", CONVERT(iCategoryId, CHAR), " is already in the table with the language id ", CONVERT(iLanguageId, CHAR), " already there with a different name ", sName), "Different name not error");
            ELSEIF EXISTS (SELECT *
                           FROM db_shoes.shoes_seo_url As s 
                           WHERE NOT s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR))
                           AND s.keyword = sName
                           AND s.language_id = iLanguageId) THEN
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT("category ID is WRONG ", CONVERT(iCategoryId, CHAR), " is already in the table with the language id ", CONVERT(iLanguageId, CHAR), " however the name is right ", sName), "ERROR");
            ELSEIF NOT EXISTS (SELECT *
                               FROM db_shoes.shoes_seo_url As s 
                               WHERE s.keyword = sName) THEN
                INSERT INTO db_shoes.shoes_seo_url (
                    store_id, 
                    language_id, 
                    query, 
                    keyword)
                VALUES (
                    0, 
                    iLanguageId, 
                    CONCAT("category_id=", CONVERT(iCategoryId, CHAR)), 
                    sName);
                    
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT("All OK just added a new record - category ID ", CONVERT(iCategoryId, CHAR), " - language id ", CONVERT(iLanguageId, CHAR), " Name ", sName), "ADDED");
            ELSE
                INSERT INTO temp_problems (tmp_text, tmp_status)
                VALUES (CONCAT("ERROR didnt expect to do this - category ID ", CONVERT(iCategoryId, CHAR), " - language id ", CONVERT(iLanguageId, CHAR), " Name ", sName), "UNKNOWN PROBLEM");
            END IF;
        END IF;

        SET iCounter = iCounter + 1;
    END WHILE;
END IF;





/*********************************************************************
*   Loop through the category names where there are not duplicates   *
*********************************************************************/



/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_ID,
        tmp_text,
        tmp_status
    FROM temp_problems;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


