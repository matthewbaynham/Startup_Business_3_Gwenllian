use db_settings;

DROP PROCEDURE if exists deleteImageManagement;

DELIMITER //

CREATE PROCEDURE deleteImageManagement(IN p_url VARCHAR(4000), IN p_fullpath VARCHAR(4000), OUT p_bIsOk boolean)
BEGIN 
/*
CREATE TABLE tbl_image_management (
    im_id INT AUTO_INCREMENT PRIMARY KEY,
    im_url VARCHAR(4000) NOT NULL default '', 
    im_fullpath VARCHAR(4000) NOT NULL default '');
*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_image_management;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_image_management (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_url VARCHAR(4000) NOT NULL default '', 
    tmp_fullpath VARCHAR(4000) NOT NULL default '');

/********************************
*   Load data into temp table   *
********************************/
INSERT INTO temp_image_management (tmp_id, tmp_url, tmp_fullpath)
SELECT im_id, im_url, im_fullpath 
FROM tbl_image_management
WHERE TRIM(UPPER(im_url)) = TRIM(UPPER(p_url)) 
AND TRIM(UPPER(im_fullpath)) = TRIM(UPPER(p_fullpath));

DELETE FROM tbl_image_management
WHERE im_id in (SELECT tmp_id FROM temp_image_management);

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        tmp_id As 'im_id',
        tmp_url As 'im_url', 
        tmp_fullpath As 'im_fullpath'
    FROM temp_image_management;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


