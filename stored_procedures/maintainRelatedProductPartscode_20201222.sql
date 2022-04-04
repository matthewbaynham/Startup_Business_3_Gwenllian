use db_settings;

DROP PROCEDURE if exists maintainRelatedProductPartscode;

DELIMITER //

CREATE PROCEDURE maintainRelatedProductPartscode(IN p_upload_type_id INT, OUT p_bIsOk boolean)
BEGIN
DECLARE iFinished INTEGER DEFAULT 0;
DECLARE temp_Partscode_txt VARCHAR(255);
DECLARE bIsFinished boolean;
DECLARE iCounter int;
DECLARE iPosStart int;
DECLARE iPosEnd int;
DECLARE sTemp VARCHAR(100);

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

DROP TABLE IF EXISTS temp_product_id_A;
DROP TABLE IF EXISTS temp_product_id_B;
DROP TABLE IF EXISTS temp_project_ids_allowed;
DROP TABLE IF EXISTS temp_Partscode;
DROP TABLE IF EXISTS temp_Partscode_allowed;

CREATE TEMPORARY TABLE temp_product_id_A (
    tmp_product_id int NOT NULL);

CREATE TEMPORARY TABLE temp_product_id_B (
    tmp_product_id int NOT NULL);

CREATE TEMPORARY TABLE temp_project_ids_allowed (
    tmp_product_id int NOT NULL);

CREATE TEMPORARY TABLE temp_Partscode_allowed (
    tmp_Partscode varchar(100));

CREATE TEMPORARY TABLE temp_Partscode (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_Partscode varchar(100));

/*********************************
*   manage product ids allowed   *
*********************************/
INSERT INTO temp_project_ids_allowed (tmp_product_id) 
SELECT DISTINCT pl_product_id
FROM db_settings.tbl_products_logged
WHERE pl_upload_type_id = p_upload_type_id;

/***************************
*   Get Partscode values   *
***************************/
INSERT INTO temp_Partscode (tmp_Partscode)
SELECT DISTINCT p.model
FROM db_shoes.shoes_product As p
INNER JOIN temp_project_ids_allowed As t
ON p.product_id = t.tmp_product_id;

/*****************************
*   Empty the final tables   *
*****************************/
DELETE FROM db_shoes.shoes_product_to_layout 
WHERE product_id in (SELECT tmp_product_id FROM temp_project_ids_allowed);

DELETE FROM db_shoes.shoes_product_related
WHERE product_id in (SELECT tmp_product_id FROM temp_project_ids_allowed);

/**********************************
*   Loop through temp_Partscode   *
**********************************/
IF EXISTS (SELECT * FROM temp_Partscode) THEN
    SET iPosStart = (SELECT MIN(P.tmp_id) FROM temp_Partscode As P);
    SET iPosEnd = (SELECT MAX(P.tmp_id) FROM temp_Partscode As P);
    SET iCounter = iPosStart;
    
    WHILE iCounter <= iPosEnd DO
        DELETE FROM temp_product_id_A;
        DELETE FROM temp_product_id_B;
        
        INSERT INTO temp_product_id_A (tmp_product_id)
        SELECT product_id
        FROM db_shoes.shoes_product
        WHERE model in (SELECT P.tmp_Partscode FROM temp_Partscode As P WHERE P.tmp_id = iCounter)
        AND product_id in (SELECT A.tmp_product_id FROM temp_project_ids_allowed As A);
        
        INSERT INTO temp_product_id_B (tmp_product_id)
        SELECT product_id
        FROM db_shoes.shoes_product
        WHERE model in (SELECT P.tmp_Partscode FROM temp_Partscode As P WHERE P.tmp_id = iCounter)
        AND product_id in (SELECT A.tmp_product_id FROM temp_project_ids_allowed As A);
        
        /*******************************************************************************
        *   insert all those product ids in the db_shoes.shoes_product_related table   *
        *******************************************************************************/  
        INSERT INTO db_shoes.shoes_product_related(product_id, related_id)
        SELECT A.tmp_product_id, B.tmp_product_id
        FROM temp_product_id_A As A, temp_product_id_B As B
        WHERE NOT A.tmp_product_id = B.tmp_product_id;
        
        IF EXISTS (SELECT * FROM temp_Partscode As P WHERE P.tmp_id = iCounter) THEN
            SET temp_Partscode_txt = (SELECT P.tmp_Partscode FROM temp_Partscode As P WHERE P.tmp_id = iCounter);
            
            /*************************************************************************
            *   insert product ids into the db_shoes.shoes_product_to_layout table   *
            *************************************************************************/
            IF EXISTS (SELECT * FROM db_shoes.shoes_store) THEN
                INSERT INTO db_shoes.shoes_product_to_layout (product_id, store_id, layout_id)
                SELECT P.product_id, S.store_id, 0 
                FROM db_shoes.shoes_product As P, db_shoes.shoes_store As S
                WHERE P.model = temp_Partscode_txt;
            ELSE
                INSERT INTO db_shoes.shoes_product_to_layout (product_id, store_id, layout_id)
                SELECT P.product_id, 0, 0 
                FROM db_shoes.shoes_product As P
                WHERE P.model = temp_Partscode_txt;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

if p_bIsOk then
    SELECT tmp_product_id 
    FROM temp_project_ids_allowed;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END//

DELIMITER ;





