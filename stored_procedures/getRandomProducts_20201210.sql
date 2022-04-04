use db_settings;

DROP PROCEDURE if exists getRandomProducts;

DELIMITER //

CREATE PROCEDURE getRandomProducts(OUT p_bIsOk boolean, in iNumberResults INT)
BEGIN
declare iCounter int;
declare iCounterA int;
declare iCounterB int;
declare iPosStart int;
declare iPosEnd int;
declare iId int;
declare iGeneration int;
declare iCount int;

SET p_bIsOk = true;

/*
get parent catergory, meaning category with a parent ID = 0 (max count of iNumberResults)
get next generation of category (max count of iNumberResults)
get products from last category (max count of iNumberResults)
*/

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_categories;
DROP TABLE IF EXISTS temp_used_categories;
DROP TABLE IF EXISTS temp_categories_previous_gen;
DROP TABLE IF EXISTS temp_products;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_categories (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL,
    tmp_parent_id int NOT NULL,
    tmp_generation int NOT NULL);

CREATE TEMPORARY TABLE temp_used_categories (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL);

CREATE TEMPORARY TABLE temp_categories_previous_gen (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL,
    tmp_parent_id int NOT NULL);

CREATE TEMPORARY TABLE temp_products (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_category_id int NOT NULL);

CREATE TEMPORARY TABLE temp_used_products (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL);

/********************
*   Get parent ID   *
********************/
INSERT INTO temp_categories (
    tmp_category_id,
    tmp_parent_id, 
    tmp_generation)
SELECT 
    C.category_id, 
    C.parent_id, 
    1
FROM db_shoes.shoes_category As C
WHERE C.parent_id = 0 
AND C.status = 1 
ORDER BY RAND(CONVERT(current_timestamp(), UNSIGNED)) 
LIMIT iNumberResults;

SET iGeneration = 1;

IF EXISTS (SELECT * FROM temp_categories WHERE tmp_generation = iGeneration) THEN
    SET iCount = 0;
    SET iCounterA = 0;
    
    WHILE iCount <= iNumberResults AND iCounterA < 10 DO
        SET iPosStart = (SELECT MIN(tmp_id) FROM temp_categories WHERE tmp_generation = iGeneration);
        SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_categories WHERE tmp_generation = iGeneration);
        SET iCounter = iPosStart;

        SET iCounterB = 0;

        WHILE iCount < iNumberResults AND iCounter < iPosEnd AND iCounterB < 50 DO
            DELETE FROM temp_used_categories;
            
            INSERT INTO temp_used_categories (tmp_category_id)
            SELECT tmp_category_id
            FROM temp_categories;
            
            DELETE FROM temp_categories_previous_gen;

            INSERT INTO temp_categories_previous_gen (
                tmp_category_id,
                tmp_parent_id)
            SELECT 
                tmp_category_id, 
                tmp_parent_id
            FROM temp_categories 
            WHERE tmp_generation = iGeneration;

            INSERT INTO temp_categories (
                tmp_category_id,
                tmp_parent_id, 
                tmp_generation)
            SELECT 
                C.category_id, 
                C.parent_id, 
                iGeneration + 1
            FROM db_shoes.shoes_category As C
            INNER JOIN temp_categories_previous_gen As t
            ON t.tmp_category_id = C.parent_id
            WHERE C.status = 1 
            AND NOT C.category_id IN (SELECT tmp_category_id from temp_used_categories)
            ORDER BY RAND(CONVERT(current_timestamp(), UNSIGNED)) 
            LIMIT 1;

            SET iCount = (SELECT COUNT(*) FROM temp_categories WHERE tmp_parent_id > 0 AND tmp_generation = iGeneration + 1);
            
            SET iCounter = iCounter + 1;
            SET iCounterB = iCounterB + 1;
        END WHILE;

        SET iCounterA = iCounterA + 1;
    END WHILE;
END IF;


IF EXISTS (SELECT * FROM temp_categories WHERE tmp_generation = iGeneration + 1) THEN
    SET iCounterA = 0;
    
    WHILE iCounterA < iNumberResults DO
        SET iPosStart = (SELECT MIN(tmp_id) FROM temp_categories WHERE tmp_generation = iGeneration + 1);
        SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_categories WHERE tmp_generation = iGeneration + 1);
        SET iCounter = iPosStart;

        IF EXISTS (SELECT * FROM temp_categories WHERE tmp_generation = iGeneration + 1 AND tmp_id = iCounter) THEN
            WHILE iCounter <= iPosEnd DO
                IF iCount < iNumberResults THEN
                    DELETE FROM temp_used_products;
                    
                    INSERT INTO temp_used_products (tmp_product_id)
                    SELECT tmp_product_id
                    FROM temp_products;

                    INSERT INTO temp_products (
                        tmp_product_id,
                        tmp_category_id)
                    SELECT 
                        pc.product_id,
                        pc.category_id
                    FROM db_shoes.shoes_product_to_category As pc
                    INNER JOIN temp_categories As tc
                    ON tc.tmp_category_id = pc.category_id
                    INNER JOIN db_shoes.shoes_product As p
                    ON pc.product_id = p.product_id
                    WHERE p.status = 1
                    AND NOT pc.product_id IN (SELECT tmp_product_id FROM temp_used_products)
                    AND tc.tmp_id = iCounter
                    ORDER BY RAND(CONVERT(current_timestamp(), UNSIGNED))
                    LIMIT 1;
                END IF;
              
                SET iCount = (SELECT COUNT(*) FROM temp_products);
                SET iCounter = iCounter + 1;
            END WHILE;
        END IF;
    
        SET iCounterA = iCounterA + 1;
    END WHILE;
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        tmp_id As id,
        tmp_product_id As 'product_id',
        tmp_category_id As 'category_id' 
    FROM temp_products;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


