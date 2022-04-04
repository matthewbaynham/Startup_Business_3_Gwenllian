use db_settings;

DROP PROCEDURE if exists fixCategoryFilter;

DELIMITER //

CREATE PROCEDURE fixCategoryFilter(OUT p_bIsOk boolean)
BEGIN 
declare iMin int;
declare iMax int;
declare iCounter int;
declare iCategoryId int;
declare iFilterId int;

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_category_filter;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_category_filter (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL,
    tmp_filter_id int NOT NULL);

INSERT INTO temp_category_filter (tmp_category_id, tmp_filter_id)
SELECT 
    pc.category_id, 
    pf.filter_id
FROM (db_shoes.shoes_product_to_category As pc
INNER JOIN db_shoes.shoes_product_filter As pf
ON pc.product_id = pf.product_id);

IF EXISTS (SELECT * FROM temp_category_filter) THEN
    SET iMin = (SELECT MIN(tmp_id) FROM temp_category_filter);
    SET iMax = (SELECT MAX(tmp_id) FROM temp_category_filter);
    SET iCounter = iMin;
    
    WHILE iCounter <= iMax DO
        IF EXISTS (SELECT * FROM temp_category_filter WHERE tmp_id = iCounter) THEN
            SET iCategoryId = (SELECT MAX(tmp_category_id) FROM temp_category_filter WHERE tmp_id = iCounter);
            SET iFilterId = (SELECT MAX(tmp_filter_id) FROM temp_category_filter WHERE tmp_id = iCounter);
       
            IF NOT EXISTS (SELECT * 
                           FROM db_shoes.shoes_category_filter 
                           WHERE category_id = iCategoryId AND filter_id = iFilterId) THEN
               INSERT INTO db_shoes.shoes_category_filter (category_id, filter_id)
               VALUES (iCategoryId, iFilterId);
           END IF;
       END IF;
       
       SET iCounter = iCounter + 1;
    END WHILE;
END IF;



/*
INSERT INTO db_shoes.shoes_category_filter (category_id, filter_id)
SELECT 
    tmp_category_id,
    tmp_filter_id
FROM temp_category_filter;
*/

if p_bIsOk then
    SELECT
        tmp_category_id As 'category_id',
        tmp_filter_id As 'filter_id'
    FROM temp_category_filter;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;





