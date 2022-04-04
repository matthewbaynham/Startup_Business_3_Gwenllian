use db_settings;

DROP PROCEDURE IF EXISTS getAllExtraWebLinks;

DELIMITER //

CREATE PROCEDURE getAllExtraWebLinks(OUT p_bIsOk boolean)
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

CREATE TEMPORARY TABLE temp_Extra_Weblinks (
    tmp_id INT,
    tmp_language_id int, 
    tmp_entity_id int, 
    tmp_entity_type varchar(1024),
    tmp_type varchar(1024),
    tmp_text_prefix varchar(1024),
    tmp_text varchar(1024),
    tmp_text_suffix varchar(1024),
    tmp_url varchar(1024),
    tmp_sort_order int);

/*******************
*   Get the data   *
*******************/
INSERT INTO temp_Extra_Weblinks (
    tmp_id,
    tmp_language_id, 
    tmp_entity_id, 
    tmp_entity_type,
    tmp_type,
    tmp_text_prefix,
    tmp_text,
    tmp_text_suffix,
    tmp_url, 
    tmp_sort_order)
SELECT
    ew_id,
    ew_language_id, 
    ew_entity_id, 
    ew_entity_type,
    ew_type,
    ew_text_prefix,
    ew_text,
    ew_text_suffix,
    ew_url, 
    ew_sort_order
FROM db_settings.Extra_Weblinks;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT
        tmp_id As 'id',
        tmp_language_id As 'language_id', 
        tmp_entity_id As 'entity_id', 
        tmp_entity_type As 'entity_type',
        tmp_type As 'type',
        tmp_text_prefix As 'text_prefix',
        tmp_text As 'text',
        tmp_text_suffix As 'text_suffix',
        tmp_url As 'url',
        tmp_sort_order As 'sort_order'
    FROM temp_Extra_Weblinks
    ORDER BY
        tmp_id,
        tmp_language_id,
        tmp_sort_order;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


