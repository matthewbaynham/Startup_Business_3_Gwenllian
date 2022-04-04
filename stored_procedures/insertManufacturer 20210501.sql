use db_settings;

DROP PROCEDURE IF EXISTS insertManufacturer;

DELIMITER //

CREATE PROCEDURE insertManufacturer(OUT p_bIsOk boolean,
IN p_name varchar(64),
OUT p_id int, 
OUT p_isFound_manufacturer boolean, 
OUT p_isFound_manufacturer_to_store boolean, 
OUT p_status VARCHAR(4000))
BEGIN 
declare iStart int;
declare iEnd int;
declare iCounter int;
declare iLanguageId int;

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
SET p_id = -1;
SET p_isFound_manufacturer = false; 
SET p_isFound_manufacturer_to_store =false;
SET p_status = "Start|";

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_seo_url;
DROP TABLE IF EXISTS temp_manufacturer_to_store;
DROP TABLE IF EXISTS temp_manufacturer;
DROP TABLE IF EXISTS temp_language;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_seo_url (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_seo_url_id int NOT NULL,
    tmp_store_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_query varchar(255) NOT NULL,
    tmp_keyword varchar(255) NOT NULL);

CREATE TEMPORARY TABLE temp_manufacturer_to_store (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_manufacturer_id int NOT NULL,
    tmp_store_id int NOT NULL);

CREATE TEMPORARY TABLE temp_manufacturer (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_manufacturer_id int NOT NULL,
    tmp_name varchar(64) NOT NULL,
    tmp_image varchar(255) DEFAULT NULL,
    tmp_sort_order int NOT NULL);

CREATE TEMPORARY TABLE temp_language (
    tmp_language_id int NOT NULL,
    tmp_name varchar(32) NOT NULL,
    tmp_code varchar(5) NOT NULL,
    tmp_locale varchar(255) NOT NULL,
    tmp_image varchar(64) NOT NULL,
    tmp_directory varchar(32) NOT NULL,
    tmp_sort_order int NOT NULL DEFAULT '0',
    tmp_status int NOT NULL);

/*****************************************************************************
*   deal with db_shoes.shoes_manufacturer first so that I have an id value   *
*****************************************************************************/
INSERT INTO temp_manufacturer (
    tmp_manufacturer_id,
    tmp_name,
    tmp_image,
    tmp_sort_order)
SELECT
    m.manufacturer_id,
    m.name,
    m.image,
    m.sort_order
FROM db_shoes.shoes_manufacturer As m
WHERE trim(upper(m.name)) = trim(upper(p_name));

IF EXISTS (SELECT * FROM temp_manufacturer) THEN
    SET p_isFound_manufacturer = true; 
    SET p_id = (SELECT MAX(tmp_manufacturer_id) FROM temp_manufacturer); 
ELSE
    INSERT INTO db_shoes.shoes_manufacturer (
        name,
        image,
        sort_order)
    VALUES (
        TRIM(p_name), 
        "", 
        0);

    SET p_id = LAST_INSERT_ID(); 
END IF;

/*******************************************
*   db_shoes.shoes_manufacturer_to_store   *
*******************************************/

SET p_status = CONCAT(p_status, "p_id:", CONVERT(p_id, CHAR), "|");

IF p_id > 0 THEN
    SET p_status = CONCAT(p_status, "p_id > 0|");

    INSERT INTO temp_manufacturer_to_store (
        tmp_manufacturer_id,
        tmp_store_id)
    SELECT
        manufacturer_id,
        store_id 
    FROM db_shoes.shoes_manufacturer_to_store 
    WHERE manufacturer_id = p_id;

    IF EXISTS (SELECT * FROM temp_manufacturer_to_store) THEN
        SET p_isFound_manufacturer_to_store = true;
    ELSE
        SET p_status = CONCAT(p_status, "INSERT INTO db_shoes.shoes_manufacturer_to_store (|");

        INSERT INTO db_shoes.shoes_manufacturer_to_store (
            manufacturer_id,
            store_id)
        VALUES (
            p_id, 
            0);
    END IF;
END IF;

/****************************************************************
*   get all the languages and then loop through the languages   *
*    checking that for each one we have the temp_seo_url        *
****************************************************************/
INSERT INTO temp_language (
    tmp_language_id,
    tmp_name,
    tmp_code,
    tmp_locale,
    tmp_image,
    tmp_directory,
    tmp_sort_order,
    tmp_status)
SELECT  
    language_id,
    name,
    code,
    locale,
    image,
    directory,
    sort_order,
    status
FROM db_shoes.shoes_language;

INSERT INTO temp_seo_url (
    tmp_seo_url_id,
    tmp_store_id,
    tmp_language_id,
    tmp_query,
    tmp_keyword)
SELECT
    seo_url_id,
    store_id,
    language_id,
    query,
    keyword
FROM db_shoes.shoes_seo_url
WHERE query = CONCAT('manufacturer_id=', CONVERT(p_id, CHAR));

IF EXISTS (SELECT * FROM temp_language) THEN
    SET p_status = CONCAT(p_status, "IF EXISTS (SELECT * FROM temp_language) THEN|");

    SET iStart = (SELECT MIN(tmp_language_id) FROM temp_language);
    SET iEnd = (SELECT MAX(tmp_language_id) FROM temp_language);
    SET iCounter = iStart;

    WHILE iCounter <= iEnd DO
        SET p_status = CONCAT(p_status, "WHILE ", CONVERT(iCounter, CHAR), " < ", CONVERT(iEnd, CHAR), " DO|");

        IF EXISTS (SELECT * FROM temp_language WHERE tmp_language_id = iCounter) THEN
            SET iLanguageId = iCounter;
            
            IF NOT EXISTS (SELECT * FROM temp_seo_url WHERE tmp_language_id = iLanguageId) THEN
                SET p_status = CONCAT(p_status, "INSERT INTO db_shoes.shoes_seo_url (|");

                INSERT INTO db_shoes.shoes_seo_url (
                    store_id,
                    language_id,
                    query,
                    keyword)
                VALUES (
                    0,
                    iLanguageId,
                    CONCAT("manufacturer_id=", CONVERT(p_id, CHAR)),
                    CONCAT(TRIM(p_name), "-", CONVERT(iLanguageId, CHAR)));
            END IF;
        END IF;
        
        SET Icounter = iCounter + 1;
    END WHILE;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_manufacturer_id As 'manufacturer_id',
        tmp_name As 'name',
        tmp_image As 'image',
        tmp_sort_order As 'sort_order'
    FROM temp_manufacturer;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


