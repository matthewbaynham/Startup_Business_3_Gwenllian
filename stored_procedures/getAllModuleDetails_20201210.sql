use db_settings;

DROP PROCEDURE if exists getAllModuleDetails;

DELIMITER //

CREATE PROCEDURE getAllModuleDetails(OUT p_bIsOk boolean)
BEGIN

SET p_bIsOk = true;

/*
SELECT `module_id`, `name`, `code`, `setting` FROM `shoes_module`

module_id	name	code	setting
30	Category	banner	{"name":"Category","banner_id":"6","width":"182","height":"182","status":"1"}
29	Home Page	carousel	{"name":"Home Page","banner_id":"8","width":"130","height":"100","status":"1"}
28	Home Page	featured	{"name":"Home Page","product":["43","40","42","30"],"limit":"4","width":"200","height":"200","status":"1"}
27	Home Page	slideshow	{"name":"Home Page","banner_id":"7","width":"1140","height":"380","status":"1"}
31	Banner 1	banner	{"name":"Banner 1","banner_id":"6","width":"182","height":"182","status":"1"}

*/



/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_module;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_module (
    tmp_module_id int(11) NOT NULL,
    tmp_name varchar(64) NOT NULL,
    tmp_code varchar(32) NOT NULL,
    tmp_setting text NOT NULL);

/************************
*   Get existing data   *
************************/

INSERT INTO temp_module (
    tmp_module_id,
    tmp_name,
    tmp_code,
    tmp_setting)
SELECT 
    module_id,
    name, 
    code, 
    setting 
FROM db_shoes.shoes_module;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_module_id As 'module_id',
        tmp_name As 'name',
        tmp_code As 'code',
        tmp_setting As 'setting'
    FROM temp_module;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


