use db_settings;

DROP PROCEDURE IF EXISTS updateModuleSetting;

DELIMITER //

CREATE PROCEDURE updateModuleSetting(OUT p_bIsOk boolean, IN p_name VARCHAR(64), IN p_code VARCHAR(32), IN p_setting TEXT)
BEGIN 
/*
declare iCounter int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
declare sImage VARCHAR(4000);
declare sUrl VARCHAR(4000);
declare iMaxRandom int;
*/
declare iCount int;

/* BEFORE TEST SELECT max(`banner_image_id`) FROM `shoes_banner_image` = 112*/

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
DROP TABLE IF EXISTS temp_module;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_module (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_module_id int(11) NOT NULL,
    tmp_name varchar(64) NOT NULL,
    tmp_code varchar(32) NOT NULL,
    tmp_setting text NOT NULL);

/***************
*   Get data   *
***************/
INSERT INTO temp_module (
    tmp_module_id,
    tmp_name,
    tmp_code,
    tmp_setting) 
SELECT 
    m.module_id,
    m.name,
    m.code,
    m.setting 
FROM db_shoes.shoes_module As m
WHERE 
    m.name = p_name
AND m.code = p_code;

/*****************
*   check data   *
*****************/
IF NOT EXISTS (SELECT * FROM temp_module) THEN
    SET p_bIsOk = false;

    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    VALUES ('No record', 'Couldnt update record because record doesnt exist', CONCAT('name: ', p_name, ' - code: ', p_code), '');
END IF;


IF p_bIsOk THEN
    SET iCount = (SELECT COUNT(*) FROM temp_module);
    
    
    IF NOT iCount = 1 THEN
        SET p_bIsOk = false;

        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        VALUES ('Too mand records', 'Couldnt update record because there are a multiple recordswhen we expected one record', CONCAT('name: ', p_name, ' - code: ', p_code), '');
    END IF;
END IF;

/**************************
*   Update the database   *
**************************/
IF p_bIsOk THEN
    UPDATE db_shoes.shoes_module 
    SET setting = p_setting
    WHERE 
        name = p_name
    AND code = p_code;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_id As 'id',
        tmp_module_id As 'module_id',
        tmp_name As 'name',
        tmp_code As 'code',
        tmp_setting As 'setting' 
    FROM temp_module;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;

