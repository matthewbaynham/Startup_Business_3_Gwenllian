use db_settings;

DROP PROCEDURE if exists getDataCorrectionSizes;

DELIMITER //

CREATE PROCEDURE getDataCorrectionSizes(OUT p_bIsOk boolean, IN p_type VARCHAR(1024))
BEGIN 

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_data_correction_sizes;
                     
CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_data_correction_sizes (
    tmp_id INT NOT NULL,
    tmp_type VARCHAR(255) NOT NULL default '', 
    tmp_orig VARCHAR(255) NOT NULL default '', 
    tmp_new VARCHAR(255) NOT NULL default '');

/*************************************
*   Load file type into temp table   *
*************************************/
INSERT INTO temp_data_correction_sizes (tmp_id, tmp_type, tmp_orig, tmp_new)
SELECT dcs_id, dcs_type, dcs_orig, dcs_new
FROM db_settings.data_correction_sizes
WHERE UPPER(TRIM(dcs_type)) = UPPER(TRIM(p_type));

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_id As 'id',
        tmp_type As 'type', 
        tmp_orig As 'orig', 
        tmp_new As 'new'
    FROM temp_data_correction_sizes;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


