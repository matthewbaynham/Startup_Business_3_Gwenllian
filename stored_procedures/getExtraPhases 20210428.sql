use db_settings;

DROP PROCEDURE IF EXISTS getExtraPhrases;

DELIMITER //

CREATE PROCEDURE getExtraPhrases(OUT p_bIsOk boolean)
BEGIN 

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
DROP TABLE IF EXISTS temp_Extra_Weblinks;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_Extra_Phases (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_language_id int, 
    tmp_type varchar(1024),
    tmp_key varchar(1024),
    tmp_text varchar(1024));

/*******************
*   Get the data   *
*******************/
INSERT INTO temp_Extra_Phases (
    tmp_language_id, 
    tmp_type,
    tmp_key,
    tmp_text)
SELECT
    ep_language_id, 
    ep_type,
    ep_key,
    ep_text 
FROM db_settings.Extra_Phases;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_id As 'id', 
        tmp_language_id As 'language_id', 
        tmp_type As 'type',
        tmp_key As 'key',
        tmp_text As 'text'
    FROM temp_Extra_Phases;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;






