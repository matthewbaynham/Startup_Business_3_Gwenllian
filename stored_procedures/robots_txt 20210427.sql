use db_settings;

DROP PROCEDURE IF EXISTS robot_txt;

DELIMITER //

CREATE PROCEDURE robot_txt(OUT p_bIsOk boolean)
BEGIN 
declare iCounter int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
DECLARE iProductId INT;
DECLARE iCategoryId INT;
DECLARE iParentCategoryId INT;
DECLARE sProductUrl varchar(1024);
DECLARE sCategoryUrl varchar(1024);
DECLARE sParentCategoryUrl varchar(1024);
DECLARE iTempId int;
DECLARE iLanguage_id int;

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

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_product (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_product_id int NOT NULL,
  tmp_category_id int NOT NULL DEFAULT '0',
  tmp_language_id int, 
  tmp_parent_category_id int NOT NULL DEFAULT '0', 
  tmp_url_text varchar(1024));

/*******************
*   Get products   *
*******************/

INSERT INTO temp_product (
  tmp_product_id,
  tmp_category_id,
  tmp_language_id, 
  tmp_parent_category_id, 
  tmp_url_text) 
SELECT
  P.product_id,
  0, 
  d.language_id,
  0, 
  ""
FROM db_shoes.shoes_product As P 
INNER JOIN db_shoes.shoes_product_description As d
ON P.product_id = d.product_id
WHERE P.status = 1;

IF EXISTS (SELECT * FROM temp_product) THEN
    SET iPosStart = (SELECT MIN(tmp_ID) FROM temp_product);
    SET iPosEnd = (SELECT MAX(tmp_ID) FROM temp_product);
    SET iCounter = iPosStart;
    
    WHILE iCounter <= iPosEnd DO
        SET iProductId = (SELECT MAX(tmp_product_id) FROM temp_product WHERE tmp_ID = iCounter);
        SET iLanguage_id = (SELECT MAX(tmp_language_id) FROM temp_product WHERE tmp_ID = iCounter);
        
        IF EXISTS (SELECT * FROM db_shoes.shoes_product_to_category WHERE product_id = iProductId) THEN
            SET iCategoryId = (SELECT MAX(category_id) FROM db_shoes.shoes_product_to_category WHERE product_id = iProductId);
            SET iParentCategoryId = (SELECT MAX(parent_id) 
                                     FROM db_shoes.shoes_category 
                                     WHERE category_id in (SELECT category_id 
                                                           FROM db_shoes.shoes_product_to_category 
                                                           WHERE product_id = iProductId));
        
            UPDATE temp_product
            SET 
                tmp_category_id = iCategoryId, 
                tmp_parent_category_id = iParentCategoryId
            WHERE tmp_ID = iCounter;
            
            SET sProductUrl = "";
            SET sCategoryUrl = "";
            SET sParentCategoryUrl = "";

            IF EXISTS (SELECT * FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("product_id=", CONVERT(iProductId, CHAR))) THEN
                SET iTempId = (SELECT MAX(s.seo_url_id) FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("product_id=", CONVERT(iProductId, CHAR)));
                
                SET sProductUrl = (SELECT s.keyword FROM db_shoes.shoes_seo_url As s WHERE s.seo_url_id = iTempId);
            END IF;

            IF EXISTS (SELECT * FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR))) THEN
                SET iTempId = (SELECT MAX(s.seo_url_id) FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("category_id=", CONVERT(iCategoryId, CHAR)));
                
                SET sCategoryUrl = (SELECT s.keyword FROM db_shoes.shoes_seo_url As s WHERE s.seo_url_id = iTempId);
            END IF;

            IF EXISTS (SELECT * FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("category_id=", CONVERT(iParentCategoryId, CHAR))) THEN
                SET iTempId = (SELECT MAX(s.seo_url_id) FROM db_shoes.shoes_seo_url As s WHERE s.language_id = iLanguage_id AND s.query = CONCAT("category_id=", CONVERT(iParentCategoryId, CHAR)));
                
                SET sParentCategoryUrl = (SELECT s.keyword FROM db_shoes.shoes_seo_url As s WHERE s.seo_url_id = iTempId);
            END IF;

            IF NOT (sProductUrl = "" OR sCategoryUrl = "" OR sParentCategoryUrl = "") THEN
                UPDATE temp_product
                SET 
                    tmp_url_text = CONCAT("https://www.gwenllian-retail.com/shop/", sParentCategoryUrl, "/", sCategoryUrl, "/", sProductUrl)
                WHERE tmp_ID = iCounter;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT DISTINCT
        tmp_url_text As 'url'
    FROM temp_product;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


