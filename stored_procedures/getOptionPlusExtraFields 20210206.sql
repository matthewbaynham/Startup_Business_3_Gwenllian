use db_settings;

DROP PROCEDURE if exists getOptionPlusExtraFields;

DELIMITER //

CREATE PROCEDURE getOptionPlusExtraFields(OUT p_bIsOk boolean, IN p_product_id int(11))
BEGIN 
declare iTbl_shoes_product_option_value int default 1;
declare iTbl_product_option_value_extra_details int default 2;

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product_option_value;
DROP TABLE IF EXISTS temp_product_option_value_extra_details;
DROP TABLE IF EXISTS temp_results;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_step1 (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_option_id int(11) NOT NULL,
    tmp_product_id int(11) NOT NULL,
    tmp_option_id int(11) NOT NULL,
    tmp_option_value_id int not null,
    tmp_table_int int);

CREATE TEMPORARY TABLE temp_results (
    tmp_product_option_id int(11) NOT NULL,
    tmp_product_id int(11) NOT NULL,
    tmp_option_id int(11) NOT NULL,
    tmp_option_value_id int not null,
    tmp_shoes_product_option_value bool not null,
    tmp_product_option_value_extra_details bool not null);

/*****************************************
*                                        *
*   **********************************   *
*   *   shoes_product_option_value   *   *
*   *   ===== ======= ====== =====   *   *
*   *   Add an entry in this table   *   *
*   **********************************   *
*                                        *
*****************************************/
INSERT INTO temp_step1 (
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    tmp_table_int)
SELECT DISTINCT
    pov.product_option_id, 
    pov.product_id, 
    pov.option_id, 
    pov.option_value_id, 
    iTbl_shoes_product_option_value
FROM db_shoes.shoes_product_option_value As pov
WHERE 
    pov.product_id = p_product_id;

/***********************************************************************
*                                                                      *
*   ****************************************************************   *
*   *   db_settings.product_option_value_extra_details             *   *
*   *   == ======== ======= ====== ===== ===== =======             *   *
*   *   when ever an entry is made in shoes_product_option_value   *   *
*   *   then we need to add the extra data into my own table       *   *
*   ****************************************************************   *
*                                                                      *
***********************************************************************/
INSERT INTO temp_step1 (
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    tmp_table_int)
SELECT DISTINCT
    povxd_product_option_id,
    povxd_product_id,
    povxd_option_id,
    povxd_option_value_id,
    iTbl_product_option_value_extra_details
FROM db_settings.product_option_value_extra_details 
WHERE
    povxd_product_id = p_product_id;

/**********************************************************
*                                                         *
*   ***************************************************   *
*   *   Loop through temp_step1 to get temp_results   *   *
*   ***************************************************   *
*                                                         *
**********************************************************/
INSERT INTO temp_results (
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    tmp_shoes_product_option_value,
    tmp_product_option_value_extra_details)
SELECT DISTINCT
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    false, 
    false
FROM temp_step1;

UPDATE temp_step1 As S 
INNER JOIN temp_results As R 
ON 
    S.tmp_product_option_id = R.tmp_product_option_id
AND S.tmp_product_id = R.tmp_product_id
AND S.tmp_option_id = R.tmp_option_id
AND S.tmp_option_value_id = R.tmp_option_value_id
SET R.tmp_shoes_product_option_value = true
WHERE S.tmp_table_int = iTbl_shoes_product_option_value;

UPDATE temp_step1 As S 
INNER JOIN temp_results As R 
ON 
    S.tmp_product_option_id = R.tmp_product_option_id
AND S.tmp_product_id = R.tmp_product_id
AND S.tmp_option_id = R.tmp_option_id
AND S.tmp_option_value_id = R.tmp_option_value_id
SET R.tmp_product_option_value_extra_details = true
WHERE S.tmp_table_int = iTbl_product_option_value_extra_details;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
if p_bIsOk then
    SELECT 
        tmp_product_option_id As 'product_option_id',
        tmp_product_id As 'product_id',
        tmp_option_id As 'option_id',
        tmp_option_value_id As 'option_value_id',
        tmp_shoes_product_option_value As 'shoes_product_option_value',
        tmp_product_option_value_extra_details As 'product_option_value_extra_details'
    FROM temp_results;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


