use db_settings;

DROP PROCEDURE if exists getAllCategoryDetails;

DELIMITER //

CREATE PROCEDURE getAllCategoryDetails(IN p_language_id int, OUT p_bIsOk boolean)
BEGIN

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_category;
DROP TABLE IF EXISTS temp_category_description;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_category (
    tmp_category_id int(11) NOT NULL,
    tmp_image varchar(255) DEFAULT NULL,
    tmp_parent_id int(11) NOT NULL DEFAULT '0',
    tmp_top tinyint(1) NOT NULL,
    tmp_column int(3) NOT NULL,
    tmp_sort_order int(3) NOT NULL DEFAULT '0',
    tmp_status tinyint(1) NOT NULL,
    tmp_date_added datetime NOT NULL,
    tmp_date_modified datetime NOT NULL
);

CREATE TEMPORARY TABLE temp_category_description (
    tmp_category_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_meta_title varchar(255) NOT NULL,
    tmp_meta_description varchar(255) NOT NULL,
    tmp_meta_keyword varchar(255) NOT NULL
);

/************************
*   Get existing data   *
************************/
INSERT INTO temp_category_description (
    tmp_category_id,
    tmp_language_id,
    tmp_name,
    tmp_description,
    tmp_meta_title,
    tmp_meta_description,
    tmp_meta_keyword)
SELECT
    category_id,
    language_id,
    name,
    description,
    meta_title,
    meta_description,
    meta_keyword
FROM db_shoes.shoes_category_description
WHERE language_id = p_language_id;

INSERT INTO temp_category (
    tmp_category_id,
    tmp_image,
    tmp_parent_id,
    tmp_top,
    tmp_column,
    tmp_sort_order,
    tmp_status,
    tmp_date_added,
    tmp_date_modified)
SELECT 
    C.category_id,
    C.image,
    C.parent_id,
    C.top,
    C.column,
    C.sort_order,
    C.status,
    C.date_added,
    C.date_modified
FROM db_shoes.shoes_category As C;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        C.tmp_category_id As 'cat_category_id',
        C.tmp_image As 'cat_image',
        C.tmp_parent_id As 'cat_parent_id',
        C.tmp_top As 'cat_top',
        C.tmp_column As 'cat_column',
        C.tmp_sort_order As 'cat_sort_order',
        C.tmp_status As 'cat_status',
        C.tmp_date_added As 'cat_date_added',
        C.tmp_date_modified As 'cat_date_modified',
        D.tmp_category_id As 'disc_category_id',
        D.tmp_language_id As 'disc_language_id',
        D.tmp_name As 'disc_name',
        D.tmp_description As 'disc_description',
        D.tmp_meta_title As 'disc_meta_title',
        D.tmp_meta_description As 'disc_meta_description',
        D.tmp_meta_keyword As 'disc_meta_keyword'
    FROM temp_category As C
    INNER JOIN temp_category_description As D
    ON C.tmp_category_id = D.tmp_category_id;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


