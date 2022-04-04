use db_settings;

DROP PROCEDURE IF EXISTS sitemap_xml;

DELIMITER //

CREATE PROCEDURE sitemap_xml(OUT p_bIsOk boolean)
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
DECLARE sPageUrl varchar(1024);
DECLARE dteDateModified date;

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
DROP TABLE IF EXISTS temp_results;

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
  tmp_date_modified date,
  tmp_url_text varchar(1024));

CREATE TEMPORARY TABLE temp_results (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_text varchar(4000));


/*******************
*   Get products   *
*******************/

INSERT INTO temp_product (
  tmp_product_id,
  tmp_category_id,
  tmp_language_id, 
  tmp_parent_category_id, 
  tmp_date_modified, 
  tmp_url_text) 
SELECT
  P.product_id,
  0, 
  d.language_id,
  0, 
  P.date_modified,
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

/****************************************************************************************************************************************
*   Loop through tmp_url_text and create a all the lines that will go into the xml file by inserting them into the table temp_results   *
****************************************************************************************************************************************/

/*
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

   <url>

      <loc>http://www.example.com/</loc>

      <lastmod>2005-01-01</lastmod>

      <changefreq>monthly</changefreq>

      <priority>0.8</priority>

   </url>

</urlset> 

CREATE TEMPORARY TABLE temp_results (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_text varchar(4000));

*/

IF EXISTS (SELECT * FROM temp_product) THEN
    SET iPosStart = (SELECT MIN(tmp_id) FROM temp_product);
    SET iPosEnd = (SELECT MAX(tmp_id) FROM temp_product);
    SET iCounter = iPosStart;

    INSERT INTO temp_results (tmp_text)
    VALUES ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

    INSERT INTO temp_results (tmp_text)
    VALUES ("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">");

    INSERT INTO temp_results (tmp_text)
    VALUES ("");

    
    WHILE iCounter <= iPosEnd DO
        IF EXISTS (SELECT * FROM temp_product WHERE tmp_id = iCounter) THEN
            SET sPageUrl = (SELECT tmp_url_text FROM temp_product WHERE tmp_id = iCounter);
            SET dteDateModified = (SELECT tmp_date_modified FROM temp_product WHERE tmp_id = iCounter);
            
            IF NOT sPageUrl = "" THEN
                INSERT INTO temp_results (tmp_text)
                VALUES ("   <url>");
    
                INSERT INTO temp_results (tmp_text)
                VALUES (CONCAT("      <loc>", sPageUrl, "</loc>"));
    
                INSERT INTO temp_results (tmp_text)
                VALUES (CONCAT("      <lastmod>", DATE_FORMAT(dteDateModified, '%Y-%m-%d'), "</lastmod>"));
    
                INSERT INTO temp_results (tmp_text)
                VALUES ("      <changefreq>daily</changefreq>");
    
                INSERT INTO temp_results (tmp_text)
                VALUES ("   </url>");
    
                INSERT INTO temp_results (tmp_text)
                VALUES ("");
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
    
    INSERT INTO temp_results (tmp_text)
    VALUES ("</urlset>");

END IF;


/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT 
        tmp_text As 'line'
    FROM temp_results
    ORDER BY tmp_id;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


