SELECT `language_id`, `name`, `code`, `locale`, `image`, `directory`, `sort_order`, `status` FROM `shoes_language` WHERE `name` = "English" or `code` = "X"

use db_settings;

DROP PROCEDURE if exists getLanguageID;

DELIMITER //

CREATE PROCEDURE getLanguageID(IN p_language_name VARCHAR(255), OUT p_language_ID int, OUT p_bIsOk boolean)
BEGIN 

set p_bIsOk = true;
set p_language_ID = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_language;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_language (
  tmp_language_id INT,
  tmp_name varchar(32) NOT NULL,
  tmp_code varchar(5) NOT NULL,
  tmp_locale varchar(255) NOT NULL,
  tmp_image varchar(64) NOT NULL,
  tmp_directory varchar(32) NOT NULL,
  tmp_sort_order int(3) NOT NULL DEFAULT '0',
  tmp_status tinyint(1) NOT NULL
);

/*************************************
*   Load file type into temp table   *
*************************************/
INSERT INTO temp_language (
  tmp_language_id,
  tmp_name,
  tmp_code,
  tmp_locale,
  tmp_image,
  tmp_directory,
  tmp_sort_order,
  tmp_status)
SELECT `language_id`, `name`, `code`, `locale`, `image`, `directory`, `sort_order`, `status`
FROM db_shoes.shoes_language
WHERE `name` LIKE CONCAT("%", p_language_name, "%")
OR `code` LIKE CONCAT("%", p_language_name, "%")
OR `locale` LIKE CONCAT("%", p_language_name, "%")
OR `directory` LIKE CONCAT("%", p_language_name, "%");

/*****************************************************************
*   Check temp table is populated,                               *
*   if not write an error in error temp table and flag an error  *
*****************************************************************/
if not exists (select * from temp_language) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'Cant find upload type ', concat('Cant find language ', p_language_name, ' in table db_shoes.shoes_language'), p_language_name);
    set p_bIsOk = false;
end if;

/************************************************
*   Check we don't have more than one result    *
*   There should be only one Language           *
************************************************/
if p_bIsOk then
    if (select count(*) from temp_language) > 1 then
        insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('settings', 'More than one language ', concat('Cant find language ', p_language_name , ' in table db_shoes.shoes_language matches criteria'), p_language_name);
        set p_bIsOk = false;
    end if;
end if;

/********************************************
*   Set upload file type ID out parameter   *
********************************************/
if p_bIsOk then
    set p_language_ID = (select max(tmp_language_id) from temp_language);
end if;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of language                     *
***********************************************************/
if p_bIsOk then
  SELECT 
      p_language_ID As `language_id`,
      tmp_name As `name`,
      tmp_code As `code`,
      tmp_locale As `locale`,
      tmp_image As `image`,
      tmp_directory As `directory`,
      tmp_sort_order As `sort_order`,
      tmp_status As `status`
    from temp_language;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


