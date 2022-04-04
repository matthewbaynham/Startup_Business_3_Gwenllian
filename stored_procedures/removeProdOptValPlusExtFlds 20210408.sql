/*
SET @bIsOk = true;
SET @product_id = 3921;
SET @option_value_ids = "109|110|115|49";

CALL removeOptionPlusExtraFields( @bIsOk , @product_id,  @option_value_ids );


SET @bIsOk = true;
SET @product_id = 3918;
SET @option_value_ids = "|107|110|115|";

CALL removeOptionPlusExtraFields( @bIsOk , @product_id,  @option_value_ids );




*/




use db_settings;

DROP PROCEDURE if exists removeOptionPlusExtraFields;

DELIMITER //

CREATE PROCEDURE removeOptionPlusExtraFields(OUT p_bIsOk boolean, IN p_product_id int(11), IN p_option_value_ids VARCHAR(4000))
BEGIN 
declare sDelimiterTab VARCHAR(1) DEFAULT "|";
declare iCounter INT DEFAULT 0;
declare iPosStart INT DEFAULT 0;
declare iPosEnd INT DEFAULT 0;
declare bIsFinished bool;
declare sTemp VARCHAR(1000);
declare iTemp INT;

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_used_option_value_ids;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_used_option_value_ids(
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_option_value_id int not null default 0);

/************************************************************************************************
*   Populate temp_used_option_value_ids with all the option value ids from p_option_value_ids   *
*   so that we know which records not to delete                                                 *
************************************************************************************************/

IF NOT REPLACE(p_option_value_ids, sDelimiterTab, "") = "" THEN
    /****************************************************
    *   put all images in parameter into a temp table   *
    ****************************************************/
    SET iCounter = 0;
    SET iPosStart = 0;
    SET iPosEnd = 0;
    SET bIsFinished = false;

    WHILE iCounter < LENGTH(p_option_value_ids) AND NOT bIsFinished DO
        SET sTemp = "";

        IF iCounter = 0 THEN
            /*****************
            *   First item   *
            *****************/
            SET iPosEnd = LOCATE(sDelimiterTab, p_option_value_ids);
            
            IF iPosEnd > 0 THEN
                SET sTemp = LEFT(p_option_value_ids, iPosEnd - 1);
                
                IF NOT (sTemp = "" OR sTemp = sDelimiterTab) THEN
                    SET iTemp = cast(sTemp AS UNSIGNED);
                
                    IF iTemp > 0 THEN
                        INSERT INTO temp_used_option_value_ids(tmp_option_value_id) VALUES (iTemp);
                    END IF;
                END IF;
            END IF;
        ELSE
            /**************************************
            *   Not the first and not last item   *
            **************************************/
            SET iPosEnd = LOCATE(sDelimiterTab, p_option_value_ids, iPosEnd + 1);

            IF iPosEnd = 0 THEN
                SET sTemp = RIGHT(p_option_value_ids, LENGTH(p_option_value_ids) - iPosStart + 1);
            ELSE
                SET sTemp = MID(p_option_value_ids, iPosStart, iPosEnd - iPosStart);
            END IF;

            IF NOT (sTemp = "" OR sTemp = sDelimiterTab) THEN
                SET iTemp = cast(sTemp AS UNSIGNED);
                
                IF iTemp > 0 THEN
                    INSERT INTO temp_used_option_value_ids(tmp_option_value_id) VALUES (iTemp);
                END IF;
            END IF;
        END IF;
  
        IF iPosEnd = 0 THEN
            SET bIsFinished = true;
        END IF;
  
        SET iPosStart = iPosEnd + 1;
  
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;


/*******************
*   DELETE Stuff   * 
*******************/

UPDATE db_shoes.shoes_product_option_value As p
SET p.quantity = 0
WHERE p.product_id = p_product_id
AND NOT p.option_value_id IN (SELECT tmp_option_value_id FROM temp_used_option_value_ids);

/*
DELETE FROM db_settings.product_option_value_extra_details 
WHERE povxd_product_id = p_product_id
AND NOT povxd_option_value_id IN (SELECT tmp_option_value_id FROM temp_used_option_value_ids);
*/

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT tmp_option_value_id As option_value_id
    FROM temp_used_option_value_ids;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


