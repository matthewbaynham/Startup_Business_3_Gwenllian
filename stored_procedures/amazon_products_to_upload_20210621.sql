use db_settings;

DROP PROCEDURE IF EXISTS amazon_products_to_upload;

DELIMITER //

CREATE PROCEDURE amazon_products_to_upload(OUT p_bIsOk boolean, IN p_language_id int, IN p_min_quantity INT, IN p_days_remaining_on_descount INT)
BEGIN 
DECLARE ilanguageEngId INT;
DECLARE iProduct_ID INT;
DECLARE iCategory_ID INT;
DECLARE iStart INT;
DECLARE iEnd INT;
DECLARE iCounter INT;
DECLARE iImageStart INT;
DECLARE iImageEnd INT;
DECLARE iImageCounter INT;
DECLARE iImageTotal INT;
DECLARE dTemp decimal(15,4);
DECLARE sTemp varchar(1024);
DECLARE tTemp text;
DECLARE iTemp INT;
DECLARE iAttributeId_Gender int default -1;
DECLARE iAttributeId_Material int default -1;
DECLARE iAttributeId_ShoulderStrap int default -1;
DECLARE iAttributeId_InternalLining int default -1;
DECLARE iFilterGroupId_Colour int default -1;
DECLARE sUrlImagePrefix varchar(1024) default "https://www.gwenllian-retail.com/shop/image/";
DECLARE sUrl varchar(1024);
DECLARE sSeparatorCharacter varchar(1024);
DECLARE dVATTax decimal(15,4) default 1.19;

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
SET sSeparatorCharacter = char(124);

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product;
DROP TABLE IF EXISTS temp_product_description;
DROP TABLE IF EXISTS temp_product_special;
DROP TABLE IF EXISTS temp_product_image;
DROP TABLE IF EXISTS temp_result;
DROP TABLE IF EXISTS temp_product_option_value;
DROP TABLE IF EXISTS temp_product_option_value_extra_details;
DROP TABLE IF EXISTS temp_attributes;
DROP TABLE IF EXISTS temp_product_attribute;
DROP TABLE IF EXISTS temp_category_description;
DROP TABLE IF EXISTS temp_filter_group_description;
DROP TABLE IF EXISTS temp_filter_description;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '') ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_result (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_load bool,
    tmp_product_id int NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_sku varchar(1024),
    tmp_manufacturer_id int,
    tmp_manufacturer_name varchar(1024),
    tmp_barcode varchar(1024),
    tmp_category_id int NOT NULL,
    tmp_category_name varchar(1024), 
    tmp_parent_category_id int NOT NULL,
    tmp_parent_category_name varchar(1024), 
    tmp_original_price_exclude_VAT decimal(15,4) NOT NULL DEFAULT '0.0000',
    tmp_price_exclude_VAT decimal(15,4) NOT NULL DEFAULT '0.0000',
    tmp_quantity int NOT NULL DEFAULT '0',
    tmp_gender varchar(1024),
    tmp_material varchar(1024),
    tmp_colour varchar(1024),
    tmp_tab_delimited_full_result text) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_product (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_model varchar(64) NOT NULL,
    tmp_sku varchar(64) NOT NULL,
    tmp_upc varchar(12) NOT NULL,
    tmp_ean varchar(14) NOT NULL,
    tmp_jan varchar(13) NOT NULL,
    tmp_isbn varchar(17) NOT NULL,
    tmp_mpn varchar(64) NOT NULL,
    tmp_location varchar(128) NOT NULL,
    tmp_quantity int NOT NULL DEFAULT '0',
    tmp_stock_status_id int NOT NULL,
    tmp_image varchar(255) DEFAULT NULL,
    tmp_manufacturer_id int NOT NULL,
    tmp_shipping tinyint NOT NULL DEFAULT '1',
    tmp_price decimal(15,4) NOT NULL DEFAULT '0.0000',
    tmp_points int NOT NULL DEFAULT '0',
    tmp_tax_class_id int NOT NULL,
    tmp_date_available date DEFAULT NULL,
    tmp_weight decimal(15,8) NOT NULL DEFAULT '0.00000000',
    tmp_weight_class_id int NOT NULL DEFAULT '0',
    tmp_length decimal(15,8) NOT NULL DEFAULT '0.00000000',
    tmp_width decimal(15,8) NOT NULL DEFAULT '0.00000000',
    tmp_height decimal(15,8) NOT NULL DEFAULT '0.00000000',
    tmp_length_class_id int NOT NULL DEFAULT '0',
    tmp_subtract tinyint NOT NULL DEFAULT '1',
    tmp_minimum int NOT NULL DEFAULT '1',
    tmp_sort_order int NOT NULL DEFAULT '0',
    tmp_status tinyint NOT NULL DEFAULT '0',
    tmp_viewed int NOT NULL DEFAULT '0',
    tmp_date_added datetime,
    tmp_date_modified datetime) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_product_description (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_tag text NOT NULL,
    tmp_meta_title varchar(255) NOT NULL,
    tmp_meta_description varchar(255) NOT NULL,
    tmp_meta_keyword varchar(255) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_product_special (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_special_id int NOT NULL,
    tmp_product_id int NOT NULL,
    tmp_customer_group_id int NOT NULL,
    tmp_priority int NOT NULL DEFAULT '1',
    tmp_price decimal(15,4) NOT NULL DEFAULT '0.0000',
    tmp_date_start date NOT NULL,
    tmp_date_end date NOT NULL);

CREATE TEMPORARY TABLE temp_product_image (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_image_id int NOT NULL,
    tmp_product_id int NOT NULL,
    tmp_image varchar(255) DEFAULT NULL,
    tmp_sort_order int NOT NULL DEFAULT '0') ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;
    
CREATE TEMPORARY TABLE temp_product_option_value (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_option_value_id int NOT NULL,
    tmp_product_option_id int NOT NULL,
    tmp_product_id int NOT NULL,
    tmp_option_id int NOT NULL,
    tmp_option_value_id int NOT NULL,
    tmp_quantity int NOT NULL,
    tmp_subtract tinyint NOT NULL,
    tmp_price decimal(15,4) NOT NULL,
    tmp_price_prefix varchar(1) NOT NULL,
    tmp_points int NOT NULL,
    tmp_points_prefix varchar(1) NOT NULL,
    tmp_weight decimal(15,8) NOT NULL,
    tmp_weight_prefix varchar(1) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;
    

CREATE TEMPORARY TABLE temp_product_option_value_extra_details (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_povxd_id int NOT NULL,
    tmp_product_option_value_id int NOT NULL,
    tmp_product_option_id int NOT NULL,
    tmp_product_id int NOT NULL,
    tmp_option_id int NOT NULL,
    tmp_option_value_id int NOT NULL,
    tmp_model varchar(64) NOT NULL,
    tmp_Model_id int DEFAULT NULL,
    tmp_Barcode varchar(1000) NOT NULL,
    tmp_Product_code varchar(1000) NOT NULL,
    tmp_sku varchar(64) NOT NULL,
    tmp_upc varchar(12) NOT NULL,
    tmp_ean varchar(14) NOT NULL,
    tmp_jan varchar(13) NOT NULL,
    tmp_isbn varchar(17) NOT NULL,
    tmp_mpn varchar(64) NOT NULL,
    tmp_location varchar(128) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_attributes (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_attribute_id int NOT NULL,
    tmp_attribute_group_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(64) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_product_attribute (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_attribute_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_text text NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_category_description (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_category_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_meta_title varchar(255) NOT NULL,
    tmp_meta_description varchar(255) NOT NULL,
    tmp_meta_keyword varchar(255) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_filter_group_description (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_filter_group_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_name varchar(64) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

CREATE TEMPORARY TABLE temp_filter_description (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_filter_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_filter_group_id int NOT NULL,
    tmp_name varchar(64) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=UTF8MB4;

SET ilanguageEngId = -1;

IF EXISTS (SELECT * FROM db_shoes.shoes_language WHERE name = "English") THEN
    SET ilanguageEngId = (SELECT MAX(language_id) FROM db_shoes.shoes_language WHERE name = "English");
END IF;

/********************
*   Get some data   *
********************/
INSERT INTO temp_product (
    tmp_product_id,
    tmp_model,
    tmp_sku,
    tmp_upc,
    tmp_ean,
    tmp_jan,
    tmp_isbn,
    tmp_mpn,
    tmp_location,
    tmp_quantity,
    tmp_stock_status_id,
    tmp_image,
    tmp_manufacturer_id,
    tmp_shipping,
    tmp_price,
    tmp_points,
    tmp_tax_class_id,
    tmp_date_available,
    tmp_weight,
    tmp_weight_class_id,
    tmp_length,
    tmp_width,
    tmp_height,
    tmp_length_class_id,
    tmp_subtract,
    tmp_minimum,
    tmp_sort_order,
    tmp_status,
    tmp_viewed,
    tmp_date_added,
    tmp_date_modified)
SELECT p.product_id, p.model, p.sku, p.upc, p.ean, p.jan, p.isbn, p.mpn, p.location, p.quantity, p.stock_status_id, p.image, p.manufacturer_id, p.shipping, p.price, p.points, p.tax_class_id, p.date_available, p.weight, p.weight_class_id, p.length, p.width, p.height, p.length_class_id, p.subtract, p.minimum, p.sort_order, p.status, p.viewed, p.date_added, p.date_modified 
FROM db_shoes.shoes_product As p
WHERE p.status = 1
AND p.quantity >= p_min_quantity;

INSERT INTO temp_product_description (
    tmp_product_id,
    tmp_language_id,
    tmp_name,
    tmp_description,
    tmp_tag,
    tmp_meta_title,
    tmp_meta_description,
    tmp_meta_keyword)
SELECT d.product_id, d.language_id, d.name, d.description, d.tag, d.meta_title, d.meta_description, d.meta_keyword 
FROM db_shoes.shoes_product_description As d
WHERE d.product_id in (SELECT tmp_product_id FROM temp_product)
AND language_id = p_language_id;

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<br>", " ");

/*<div class='pdbDescContainer'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class='pdbDescContainer'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=''pdbDescContainer''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"pdbDescContainer\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"\"pdbDescContainer\"\">", " ");

/*<div class='pdbDescContainer'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class='pdbDescContainer'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=''pdbDescContainer''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"pdbDescContainer\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"\"pdbDescContainer\"\">", " ");

/*<div class='pdbDescSection'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class='pdbDescSection'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=''pdbDescSection''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"pdbDescSection\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<div class=\"\"pdbDescSection\"\">", " ");

/*</div>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "</div>", ", ");

/*<span class='pdbDescSectionTitle'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class='pdbDescSectionTitle'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=''pdbDescSectionTitle''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"pdbDescSectionTitle\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"\"pdbDescSectionTitle\"\">", " ");

/*<span class='pdbDescSectionText'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class='pdbDescSectionText'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=''pdbDescSectionText''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"pdbDescSectionText\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"\"pdbDescSectionText\"\">", " ");

/*<span class='pdbDescSectionList'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class='pdbDescSectionList'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=''pdbDescSectionList''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"pdbDescSectionList\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"\"pdbDescSectionList\"\">", " ");

/*<span class='pdbDescSectionItem'>*/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class='pdbDescSectionItem'>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=''pdbDescSectionItem''>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"pdbDescSectionItem\">", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "<span class=\"\"pdbDescSectionItem\"\">", " ");

/**/
UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "</span>", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "    ", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "   ", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, "  ", " ");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, " ,", ",");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, ",,,", ",");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, ",,", ",");

UPDATE temp_product_description
SET tmp_description = CONCAT(TRIM(tmp_description), ".");

UPDATE temp_product_description
SET tmp_description = REPLACE(tmp_description, ",.", ".");

/*
<div class='pdbDescContainer'>
<div class='pdbDescSection'>

<span class='pdbDescSectionTitle'>
<span class='pdbDescSectionText'>
<span class='pdbDescSectionList'>
<span class='pdbDescSectionItem'>

</span>
</div>
*/


INSERT INTO temp_product_special (
    tmp_product_special_id,
    tmp_product_id,
    tmp_customer_group_id,
    tmp_priority,
    tmp_price,
    tmp_date_start,
    tmp_date_end)
SELECT S.product_special_id, S.product_id, S.customer_group_id, S.priority, S.price, S.date_start, S.date_end 
FROM db_shoes.shoes_product_special As S 
INNER JOIN (SELECT ps.product_id, MAX(ps.priority) As max_priority
            FROM db_shoes.shoes_product_special As ps
            WHERE CURDATE() BETWEEN ps.date_start AND ps.date_end
            GROUP BY ps.product_id) As p
ON S.product_id = p.product_id
AND S.priority = p.max_priority
WHERE S.product_id in (SELECT tmp_product_id FROM temp_product)
AND CURDATE() BETWEEN S.date_start AND S.date_end;

INSERT INTO temp_product_image (
    tmp_product_image_id,
    tmp_product_id,
    tmp_image,
    tmp_sort_order)
SELECT I.product_image_id, I.product_id, I.image, I.sort_order 
FROM db_shoes.shoes_product_image As I
WHERE I.product_id in (SELECT tmp_product_id FROM temp_product);

INSERT INTO temp_product_option_value (
    tmp_product_option_value_id,
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    tmp_quantity,
    tmp_subtract,
    tmp_price,
    tmp_price_prefix,
    tmp_points,
    tmp_points_prefix,
    tmp_weight,
    tmp_weight_prefix)
SELECT
    o.product_option_value_id,
    o.product_option_id,
    o.product_id,
    o.option_id,
    o.option_value_id,
    o.quantity,
    o.subtract,
    o.price,
    o.price_prefix,
    o.points,
    o.points_prefix,
    o.weight,
    o.weight_prefix
FROM db_shoes.shoes_product_option_value As o
WHERE o.product_id in (SELECT tmp_product_id FROM temp_product);

INSERT INTO temp_product_option_value_extra_details (
    tmp_povxd_id,
    tmp_product_option_value_id,
    tmp_product_option_id,
    tmp_product_id,
    tmp_option_id,
    tmp_option_value_id,
    tmp_model,
    tmp_Model_id,
    tmp_Barcode,
    tmp_Product_code,
    tmp_sku,
    tmp_upc,
    tmp_ean,
    tmp_jan,
    tmp_isbn,
    tmp_mpn,
    tmp_location)
SELECT
    povxd_id,
    povxd_product_option_value_id,
    povxd_product_option_id,
    povxd_product_id,
    povxd_option_id,
    povxd_option_value_id,
    povxd_model,
    povxd_Model_id,
    povxd_Barcode,
    povxd_Product_code,
    povxd_sku,
    povxd_upc,
    povxd_ean,
    povxd_jan,
    povxd_isbn,
    povxd_mpn,
    povxd_location 
FROM db_settings.product_option_value_extra_details
WHERE povxd_product_id in (SELECT tmp_product_id FROM temp_product);

INSERT INTO temp_product_attribute (
    tmp_product_id,
    tmp_attribute_id,
    tmp_language_id,
    tmp_text)
SELECT DISTINCT
    pa.product_id,
    pa.attribute_id,
    pa.language_id,
    trim(pa.text) 
FROM db_shoes.shoes_product_attribute As pa
WHERE pa.product_id in (SELECT tmp_product_id FROM temp_product);

INSERT INTO temp_attributes (
    tmp_attribute_id,
    tmp_attribute_group_id,
    tmp_language_id,
    tmp_name)
SELECT DISTINCT 
    d.attribute_id,
    a.attribute_group_id,
    d.language_id,
    d.name
FROM 
 db_shoes.shoes_attribute As a
INNER JOIN db_shoes.shoes_attribute_description As d
ON a.attribute_id = d.attribute_id;

INSERT INTO temp_category_description (
    tmp_category_id,
    tmp_language_id,
    tmp_name,
    tmp_description,
    tmp_meta_title,
    tmp_meta_description,
    tmp_meta_keyword)
SELECT
    d.category_id,
    d.language_id,
    d.name,
    d.description,
    d.meta_title,
    d.meta_description,
    d.meta_keyword
FROM db_shoes.shoes_category_description As d;

INSERT INTO temp_filter_group_description (
    tmp_filter_group_id,
    tmp_language_id,
    tmp_name)
SELECT
    f.filter_group_id,
    f.language_id,
    f.name 
FROM db_shoes.shoes_filter_group_description As f
WHERE f.language_id = p_language_id;

INSERT INTO temp_filter_description (
    tmp_filter_id,
    tmp_language_id,
    tmp_filter_group_id,
    tmp_name)
SELECT
    f.filter_id,
    f.language_id,
    f.filter_group_id,
    f.name
FROM db_shoes.shoes_filter_description As f
WHERE f.language_id = p_language_id;





SET iAttributeId_Gender = -1;

IF EXISTS (SELECT * FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND (TRIM(LOWER(tmp_name)) = TRIM(LOWER("Gender")) OR TRIM(LOWER(tmp_name)) = TRIM(LOWER("Geschlecht")))) THEN
    SET iAttributeId_Gender = (SELECT MIN(tmp_attribute_id) FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND (TRIM(LOWER(tmp_name)) = TRIM(LOWER("Gender")) OR TRIM(LOWER(tmp_name)) = TRIM(LOWER("Geschlecht"))));
END IF;

SET iAttributeId_Material = -1;

IF EXISTS (SELECT * FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND TRIM(LOWER(tmp_name)) = TRIM(LOWER("Material"))) THEN
    SET iAttributeId_Material = (SELECT MIN(tmp_attribute_id) FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND TRIM(LOWER(tmp_name)) = TRIM(LOWER("Material")));
END IF;

SET iAttributeId_ShoulderStrap = -1;

IF EXISTS (SELECT * FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND TRIM(LOWER(tmp_name)) = TRIM(LOWER("Material"))) THEN
    SET iAttributeId_ShoulderStrap = (SELECT MIN(tmp_attribute_id) FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND TRIM(LOWER(tmp_name)) = TRIM(LOWER("Shoulder strap")));
END IF;


SET iAttributeId_InternalLining = -1;

IF EXISTS (SELECT * FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND TRIM(LOWER(tmp_name)) = TRIM(LOWER("Material"))) THEN
    SET iAttributeId_InternalLining = (SELECT MIN(tmp_attribute_id) FROM temp_attributes WHERE tmp_language_id = ilanguageEngId AND (TRIM(LOWER(tmp_name)) = TRIM(LOWER("Internal lining")) OR  TRIM(LOWER(tmp_name)) = TRIM(LOWER("Intern"))));
END IF;

SET iFilterGroupId_Colour = -1;

IF EXISTS (SELECT * FROM temp_filter_group_description WHERE trim(upper(tmp_name)) = trim(upper("colour")) OR trim(upper(tmp_name)) = trim(upper("farbe"))) THEN
    SET iFilterGroupId_Colour = (SELECT MAX(tmp_filter_group_id) 
                                 FROM temp_filter_group_description 
                                 WHERE trim(upper(tmp_name)) = trim(upper("Colour")) 
                                 OR trim(upper(tmp_name)) = trim(upper("Farbe")));
END IF;

/*SELECT `filter_group_id`, `language_id`, `name` FROM `shoes_filter_description` WHERE 1*/






/*

SELECT povxd_id, povxd_product_option_value_id, povxd_product_option_id, povxd_product_id, povxd_option_id, povxd_option_value_id, povxd_model, povxd_Model_id, povxd_Barcode, povxd_Product_code, povxd_sku, povxd_upc, povxd_ean, povxd_jan, povxd_isbn, povxd_mpn, povxd_location FROM product_option_value_extra_details 
*/


/*
SELECT product_id, category_id 
FROM db_shoes.shoes_product_to_category 
*/

/*
SELECT category_id, language_id, name, description, meta_title, meta_description, meta_keyword 
FROM db_shoes.shoes_category_description 
*/




/****************************
*   Calculate the results   *
****************************/
INSERT INTO temp_result (
    tmp_load,
    tmp_product_id,
    tmp_name,
    tmp_description,
    tmp_sku,
    tmp_manufacturer_id,
    tmp_manufacturer_name,
    tmp_barcode,
    tmp_category_id,
    tmp_category_name, 
    tmp_parent_category_id,
    tmp_parent_category_name, 
    tmp_original_price_exclude_VAT,
    tmp_price_exclude_VAT,
    tmp_quantity, 
    tmp_gender,
    tmp_material,
    tmp_colour,
    tmp_tab_delimited_full_result)
SELECT
    true,
    tmp_product_id,
    "", 
    "", 
    tmp_sku, 
    tmp_manufacturer_id,
    "", 
    tmp_location,
    0, 
    "", 
    0, 
    "", 
    tmp_price,
    0,
    tmp_quantity,
    "",
    "",
    "",
    ""
FROM temp_product 
WHERE NOT tmp_product_id IN (SELECT tmp_product_id FROM temp_product_option_value);

INSERT INTO temp_result (
    tmp_load,
    tmp_product_id,
    tmp_name,
    tmp_description,
    tmp_sku,
    tmp_manufacturer_id,
    tmp_manufacturer_name,
    tmp_category_id,
    tmp_category_name, 
    tmp_parent_category_id,
    tmp_parent_category_name, 
    tmp_original_price_exclude_VAT,
    tmp_price_exclude_VAT,
    tmp_quantity, 
    tmp_tab_delimited_full_result)
SELECT
    true,
    p.tmp_product_id,
    "", 
    "", 
    d.tmp_sku, 
    p.tmp_manufacturer_id,
    "", 
    0, 
    "", 
    0, 
    "", 
    p.tmp_price,
    0,
    o.tmp_quantity,
    ""
FROM (temp_product As p
INNER JOIN temp_product_option_value As o
ON p.tmp_product_id = o.tmp_product_id)
INNER JOIN temp_product_option_value_extra_details As d
ON p.tmp_product_id = d.tmp_product_id
AND d.tmp_product_id = o.tmp_product_id
AND d.tmp_product_option_value_id = o.tmp_product_option_value_id
AND d.tmp_product_option_id = o.tmp_product_option_id
AND d.tmp_option_id = o.tmp_option_id
AND d.tmp_option_value_id = o.tmp_option_value_id;

/***********************
*   Description data   *
***********************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_id = iCounter);

            IF EXISTS (SELECT * FROM temp_product_description WHERE tmp_product_id = iProduct_ID AND tmp_language_id = p_language_id) THEN
                SET sTemp = (SELECT tmp_name FROM temp_product_description WHERE tmp_product_id = iProduct_ID AND tmp_language_id = p_language_id);
                SET tTemp = (SELECT tmp_description FROM temp_product_description WHERE tmp_product_id = iProduct_ID AND tmp_language_id = p_language_id);
                
                UPDATE temp_result 
                SET 
                    tmp_name = sTemp,
                    tmp_description = tTemp
                WHERE tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

/****************************
*   Get the category data   *
****************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_id = iCounter);
            
            IF EXISTS (SELECT * FROM db_shoes.shoes_product_to_category WHERE product_id = iProduct_ID) THEN
                SET iCategory_ID =  (SELECT MAX(category_id) FROM db_shoes.shoes_product_to_category WHERE product_id = iProduct_ID);
            
                UPDATE temp_result
                SET tmp_category_id = iCategory_ID
                WHERE tmp_product_id = iProduct_ID;
                
                IF EXISTS (SELECT * FROM db_shoes.shoes_category_description WHERE category_id = iCategory_ID AND language_id = p_language_id) THEN
                    UPDATE temp_result 
                    SET tmp_category_name = (SELECT D.name FROM db_shoes.shoes_category_description As D WHERE D.category_id = iCategory_ID AND D.language_id = p_language_id)
                    WHERE tmp_product_id = iProduct_ID;
                END IF;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

/*****************************
*   Get the category stuff   *
*****************************/
UPDATE temp_result As R 
INNER JOIN db_shoes.shoes_category As C ON R.tmp_category_id = C.category_id
SET R.tmp_parent_category_id = C.parent_id;

UPDATE temp_result As R 
INNER JOIN db_shoes.shoes_category_description As D ON R.tmp_parent_category_id = D.category_id
SET R.tmp_parent_category_name = D.name
WHERE D.language_id = p_language_id;

/***************************
*   Get the manufacturer   *
***************************/
UPDATE temp_result As R 
INNER JOIN db_shoes.shoes_manufacturer As M ON R.tmp_manufacturer_id = M.manufacturer_id
SET R.tmp_manufacturer_name = M.name;


/*************************
*   Get the reductions   *
*************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result
                SET tmp_price_exclude_VAT = dTemp
                WHERE tmp_product_id = iProduct_ID;
                
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

/********************************************************
*   Remove any product if the discount its too short   *
********************************************************/

UPDATE temp_result
SET tmp_load = false
WHERE NOT tmp_product_id IN (SELECT tmp_product_id 
                             FROM temp_product_special 
                             WHERE tmp_date_start <= CURDATE()
                             AND DATE_ADD(CURDATE(), INTERVAL p_days_remaining_on_descount DAY) >= tmp_date_end);

/*****************
*   Attributes   *
*****************/
UPDATE temp_result
SET tmp_gender = "Unknown",
    tmp_material = "Unknown";

UPDATE temp_result As R
INNER JOIN (SELECT
                tmp_product_id,
                tmp_text
            FROM temp_product_attribute
            WHERE tmp_attribute_id = iAttributeId_Gender
            AND tmp_language_id = p_language_id) As A
ON R.tmp_product_id = A.tmp_product_id
SET tmp_gender = tmp_text;

UPDATE temp_result As R
INNER JOIN (SELECT
                tmp_product_id,
                tmp_text
            FROM temp_product_attribute
            WHERE tmp_attribute_id = iAttributeId_Material
            AND tmp_language_id = p_language_id) As A
ON R.tmp_product_id = A.tmp_product_id
SET tmp_material = A.tmp_text;



/*
CREATE TEMPORARY TABLE temp_product_attribute (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int NOT NULL,
    tmp_attribute_id int NOT NULL,
    tmp_language_id int NOT NULL,
    tmp_text text NOT NULL);


SELECT
    tmp_product_id int NOT NULL,
    tmp_text text NOT NULL);
FROM temp_product_attribute
WHERE tmp_attribute_id = 
AND tmp_language_id = p_language_id;

*/



/**********************************************
*   build the tmp_tab_delimited_full_result   *
**********************************************/


/*
SELECT c.parent_id, d.category_id, d.language_id, d.name, 
FROM db_shoes.shoes_category As c
INNER JOIN db_shoes.shoes_category_description As d 
ON d.category_id = c.category_id
ORDER BY c.parent_id, d.category_id, d.language_id



Bags
32	33	1	Clutch bags	
32	33	2	Clutches	
32	34	1	Shopping bags	
32	34	2	Shopper	
32	35	1	Crossbody Bags	
32	35	2	Umhängetaschen	
32	36	1	Handbags	
32	36	2	Handtaschen	
32	37	1	Shoulder bags	
32	37	2	Schultertaschen	
32	38	1	Travel bags	
32	38	2	Reisetaschen	
32	45	1	Rucksacks	
32	45	2	Rucksäcke	
32	48	1	Briefcases	
32	48	2	Aktentaschen	
32	52	1	Beauty case	
32	52	2	Beauty case	
*/



/************************
*   feed_product_type   *
*   "backpack"          *
*   "handbag"           *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksacks" OR tmp_category_name = "Rucksäcke" then 
                                                   "backpack"
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                   "handbag"
                                               else
                                                   CONCAT("Error (category_name):", tmp_category_name) 
                                                   end, 
                                           sSeparatorCharacter);
 
/**********
*   sku   *
**********/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_sku, sSeparatorCharacter);


/************
*   Brand   *
************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_manufacturer_name, sSeparatorCharacter);



/****************************************
*   Manufacturer barcode                *
*   external_product_id                 *
*   and                                 *
*   Barcode type                        *
*   external_product_id_type            *
*                                       *
*   If this doesnt work then look at    *
*   Model ID = UPC                      *
*   barcode = EAN13                     *
****************************************/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_barcode, sSeparatorCharacter, "EAN", sSeparatorCharacter);


/*******************************
*   Product name = item_name   *
*******************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tmp_name, "<br>", " "), "<small>", ""), "</small>", ""), "<i>", ""), "</i>", ""), sSeparatorCharacter);



/****************************************
*   Produktkategorisierung (Suchpfad)   *
*   recommended_browse_nodes            *
*****************************************

Browse Node	Pfad durchsuchen
1760243031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Rucksackhandtaschen
1760240031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Clutches
1760244031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Schultertaschen
1760247031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Umhängetaschen
1760241031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Henkeltaschen
1760237031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Andere
1760245031	Schuhe & Handtaschen > Handtaschen > Damenhandtaschen > Shopper

1760249031	Schuhe & Handtaschen > Handtaschen > Herrentaschen > Andere
1760253031	Schuhe & Handtaschen > Handtaschen > Herrentaschen > Schultertaschen
1760251031	Schuhe & Handtaschen > Handtaschen > Herrentaschen > Henkeltaschen
1760250031	Schuhe & Handtaschen > Handtaschen > Herrentaschen > Handgelenkstaschen

*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when LOWER(tmp_gender) = "woman" OR LOWER(tmp_gender) = "damen" then
                                                   case when tmp_category_name = "Rucksacks" OR tmp_category_name = "Rucksäcke" then 
                                                           "1760243031"
                                                       when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" then
                                                           "1760241031"  /* this one is different between men and women*/
                                                       when tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" then
                                                           "1760240031"
                                                       when tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" then
                                                           "1760245031"
                                                       when tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" then  
                                                           "1760247031"
                                                       when tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" then  
                                                           "1760247031"
                                                       else
                                                           CONCAT("Error (category_name):", tmp_category_name)
                                                       end
                                               when LOWER(tmp_gender) = "man" OR LOWER(tmp_gender) = "herren" then
                                                   case when tmp_category_name = "Rucksacks" OR tmp_category_name = "Rucksäcke" then 
                                                           "1760243031"
                                                       when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" then
                                                           "1760251031"  /* this one is different between men and women*/
                                                       when tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" then
                                                           "1760240031"
                                                       when tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" then
                                                           "1760245031"
                                                       when tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" then  
                                                           "1760247031"
                                                       when tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" then  
                                                           "1760247031"
                                                       else
                                                           CONCAT("Error (category_name):", tmp_category_name)
                                                       end
                                               else
                                                   CONCAT("Error (gender):", tmp_gender)
                                               end, 
                                           sSeparatorCharacter);






UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksäcke" or tmp_category_name = "Rucksacke" or tmp_category_name = "Rucksack" or tmp_category_name = "Rucksacks" then 
                                                case when tmp_material = "leather" or tmp_material = "leder" then
                                                        "Leder"
                                                    when tmp_material = "polyurethane" or tmp_material = "polyurethan" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic leather" or tmp_material = "kunstleder" then
                                                        "Synthetikleder"
                                                    when tmp_material = "synthetic material, fabric" or tmp_material = "synthetisches Material, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, leather" OR tmp_material = "synthetisches Material, Leder" then
                                                        "leather"
                                                    when tmp_material = "synthetic material" OR tmp_material = "synthetisches Material" then
                                                        "Synthetik"
                                                    when tmp_material = "polyester" then
                                                        "Synthetik"
                                                    when tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                        "Leder"
                                                    when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" then
                                                        "Leder"
                                                    when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, leather, fabric" or tmp_material = "synthetisches Material, Leder, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                        "Leder" 
                                                    when tmp_material = "synthetic leather, fabric" OR tmp_material = "kunstleder, textiles Material" then
                                                        "Synthetikleder"
                                                    else
                                                        CONCAT("Error (material):", tmp_material) 
                                                    end
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                case when tmp_material = "leather" or tmp_material = "leder" then
                                                        "Leder"
                                                    when tmp_material = "polyurethane" or tmp_material = "polyurethan" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic leather" or tmp_material = "kunstleder" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, fabric" or tmp_material = "synthetisches Material, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, leather" OR tmp_material = "synthetisches Material, Leder" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material" OR tmp_material = "synthetisches Material" then
                                                        "Synthetik"
                                                    when tmp_material = "polyester" then
                                                        "Synthetik"
                                                    when tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                        "Leder"
                                                    when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" then
                                                        "Wildleder"
                                                    when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                        "Lackleder"
                                                    when tmp_material = "synthetic material, leather, fabric" or tmp_material = "synthetisches Material, Leder, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                        "Wildleder"
                                                    when tmp_material = "synthetic leather, fabric" OR tmp_material = "kunstleder, textiles Material" then
                                                        "Synthetik"
                                                    else
                                                        CONCAT("Error (material):", tmp_material) 
                                                    end
                                               else
                                                   CONCAT("Error (category_name):", tmp_category_name) 
                                                   end, 
                                           sSeparatorCharacter);





/*****************
*   color_name   *
*****************/
UPDATE temp_result As R
INNER JOIN (SELECT
                p.product_id,
                f.tmp_name
            FROM temp_filter_description As f
            INNER JOIN db_shoes.shoes_product_filter As p
            ON p.filter_id = f.tmp_filter_id
            WHERE f.tmp_filter_group_id = iFilterGroupId_Colour
            AND f.tmp_language_id = p_language_id) As pf
ON R.tmp_product_id = pf.product_id
SET tmp_colour = pf.tmp_name;

/*
UPDATE temp_result As R
INNER JOIN db_shoes.shoes_product_filter As p
ON R.tmp_product_id = p.product_id
INNER JOIN temp_filter_description As f
ON f.tmp_filter_id = p.filter_id
SET tmp_colour = CONCAT("Colour:", f.tmp_name)
WHERE f.tmp_filter_group_id = iFilterGroupId_Colour;
*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_colour, sSeparatorCharacter);

/*
SELECT `filter_id`, `language_id`, `filter_group_id`, `name` FROM `shoes_filter_description` WHERE 1
SELECT `filter_group_id`, `language_id`, `name` FROM `shoes_filter_group_description` WHERE 1

`shoes_filter_group_description` will give the group id for colours so that `shoes_filter_description`.`filter_group_id` can be filtered.




`shoes_filter_description`.`name` gives the colour name



SELECT `product_id`, `filter_id` FROM `shoes_product_filter` WHERE 1





*/






/****************
*   color_map   *
****************/

/*
backpack
color_map
---------
Bronze
Türkis
Blau
Gold
Silber
Durchsichtig
Schwarz
Orange
Rosa
Weiß
Beige
Gelb
Lila
Rot
Mehrfarbig
Cremefarben
Braun
Grau
Metallisch
Grün



handbag
color_map
---------
Beige
Blau
Braun
Elfenbein
Gelb
Gold
Grau
Grün
Mehrfarbig
Orange
Pink
Rot
Schwarz
Silber
Transparent
Türkis
Violett
Weiß
Bronze
Lila
Durchsichtig
Cremefarben
Rosa
Metallisch

*/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksäcke" or tmp_category_name = "Rucksacke"  or tmp_category_name = "Rucksack" or tmp_category_name = "Rucksacks" then 
                                                   case when tmp_colour = "Black" or tmp_colour = "Schwarz" then
                                                           "Schwarz"
                                                       when tmp_colour = "Blue" or tmp_colour = "Blau" then
                                                           "Blau"
                                                       when tmp_colour = "White" or tmp_colour = "Weiß" then
                                                           "Weiß"
                                                       when tmp_colour = "Red" or tmp_colour = "Rot" then
                                                           "Rot"
                                                       when tmp_colour = "Yellow" or tmp_colour = "Gelb" then
                                                           "Gelb"
                                                       when tmp_colour = "Grey" or tmp_colour = "Grau" then
                                                           "Grau"
                                                       when tmp_colour = "Pink" or tmp_colour = "Rosa" then
                                                           "Blau"
                                                       when tmp_colour = "Brown" or tmp_colour = "Braun" then
                                                           "Braun"
                                                       when tmp_colour = "Orange" or tmp_colour = "Orange" then
                                                           "Orange"
                                                       when tmp_colour = "Green" or tmp_colour = "Grün" then
                                                           "Grün"
                                                       when tmp_colour = "Violet" or tmp_colour = "Violett" then
                                                           "Lila"
                                                       else
                                                           CONCAT("Error (colour):", tmp_colour)
                                                       end
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                   case when tmp_colour = "Black" or tmp_colour = "Schwarz" then
                                                           "Schwarz"
                                                       when tmp_colour = "Blue" or tmp_colour = "Blau" then
                                                           "Blau"
                                                       when tmp_colour = "White" or tmp_colour = "Weiß" then
                                                           "Weiß"
                                                       when tmp_colour = "Red" or tmp_colour = "Rot" then
                                                           "Rot"
                                                       when tmp_colour = "Yellow" or tmp_colour = "Gelb" then
                                                           "Gelb"
                                                       when tmp_colour = "Grey" or tmp_colour = "Grau" then
                                                           "Grau"
                                                       when tmp_colour = "Pink" or tmp_colour = "Rosa" then
                                                           "Blau"
                                                       when tmp_colour = "Brown" or tmp_colour = "Braun" then
                                                           "Braun"
                                                       when tmp_colour = "Orange" or tmp_colour = "Orange" then
                                                           "Orange"
                                                       when tmp_colour = "Green" or tmp_colour = "Grün" then
                                                           "Grün"
                                                       when tmp_colour = "Violet" or tmp_colour = "Violett" then
                                                           "Violett"
                                                       else
                                                           CONCAT("Error (colour):", tmp_colour)
                                                       end
                                               else
                                                    CONCAT("Error (category_name):", tmp_category_name)
                                               end,
                                           sSeparatorCharacter);

/****************************************************************
*   Amazon calls this field "department" or "department_name"   *
*   but they mean tmp_gender                                    *
****************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_gender, sSeparatorCharacter);


/***************
*   quantity   *
***************/
UPDATE temp_result As R 
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(tmp_quantity, CHAR), sSeparatorCharacter);


/*******************
*   Main picture   *
*******************/
UPDATE temp_result As R
INNER JOIN temp_product As p
ON R.tmp_product_id = p.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sUrlImagePrefix, CONVERT(p.tmp_image USING utf8), sSeparatorCharacter);



/****************************
*   age_range_description   *
*****************************

Note backpack and hand bag both seem to use the same list

backpack
age_range_description
---------------------
Erwachsener
Kleinkind
Kind
Baby

SELECT * FROM `shoes_filter_description` WHERE `filter_group_id` = 1 ORDER BY `filter_id` ASC
filter_id   	language_id	filter_group_id	name	
1	1	1	Male	
1	2	1	Männlich	
2	1	1	Female	
2	2	1	Weiblich	
3	1	1	Kids	
3	2	1	Kinder	

*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksäcke" or tmp_category_name = "Rucksacke"  or tmp_category_name = "Rucksack" or tmp_category_name = "Rucksacks" then 
                                                   case when tmp_gender = "Male" or tmp_gender = "Männlich" OR tmp_gender = "Female" or tmp_gender = "Weiblich" then
                                                           "Erwachsener"
                                                       when tmp_gender = "Kids" or tmp_gender = "Kinder" then
                                                           "Kind"
                                                       else
                                                           "Erwachsener"
                                                       end
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                   case when tmp_gender = "Male" or tmp_gender = "Männlich" OR tmp_gender = "Female" or tmp_gender = "Weiblich" then
                                                           "Erwachsener"
                                                       when tmp_gender = "Kids" or tmp_gender = "Kinder" then
                                                           "Kind"
                                                       else
                                                           "Erwachsener"
                                                       end
                                               else
                                                   CONCAT("error (category_name):", tmp_category_name)
                                               end,
                                           sSeparatorCharacter);


/********************
*   Geschlecht      *
*   target_gender   *
*********************

Note backpack and hand bag both seem to use the same list

Männlich
Unisex
Weiblich


SELECT * FROM `shoes_filter_description` WHERE `filter_group_id` = 1 ORDER BY `filter_id` ASC
filter_id   	language_id	filter_group_id	name	
1	1	1	Male	
1	2	1	Männlich	
2	1	1	Female	
2	2	1	Weiblich	
3	1	1	Kids	
3	2	1	Kinder	

*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksäcke" or tmp_category_name = "Rucksacke"  or tmp_category_name = "Rucksack" or tmp_category_name = "Rucksacks" then 
                                                   case when tmp_gender = "Male" or tmp_gender = "Männlich" then
                                                           "Männlich"
                                                       when tmp_gender = "Female" or tmp_gender = "Weiblich" then
                                                           "Weiblich"
                                                       when tmp_gender = "Kids" or tmp_gender = "Kinder" then
                                                           "Unisex"
                                                       else
                                                           "Unisex"
                                                       end
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                   case when tmp_gender = "Male" or tmp_gender = "Männlich" then
                                                           "Männlich"
                                                       when tmp_gender = "Female" or tmp_gender = "Weiblich" then
                                                           "Weiblich"
                                                       when tmp_gender = "Kids" or tmp_gender = "Kinder" then
                                                           "Unisex"
                                                       else
                                                           "Unisex"
                                                       end
                                               else
                                                   CONCAT("error (category_name):", tmp_category_name)
                                               end,
                                           sSeparatorCharacter);

IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_result);
        SET iImageTotal = 0;

        SET iImageStart = (SELECT MIN(tmp_id) FROM temp_product_image WHERE tmp_product_id = iProduct_ID);
        SET iImageEnd = (SELECT MAX(tmp_id) FROM temp_product_image WHERE tmp_product_id = iProduct_ID);
        SET iImageCounter = iImageStart;
        
        /*add first 8 images and no more*/
        WHILE iImageTotal < 8 AND iImageCounter <= iImageEnd DO
            IF EXISTS (SELECT * FROM temp_product_image WHERE tmp_product_id = iProduct_ID AND tmp_id = iImageCounter) THEN
                SET sUrl = (SELECT tmp_image FROM temp_product_image WHERE tmp_product_id = iProduct_ID AND tmp_id = iImageCounter);
                
                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sUrlImagePrefix, sUrl, sSeparatorCharacter)
                WHERE R.tmp_id = iCounter;

                SET iImageTotal = iImageTotal + 1;
            END IF;
            SET iImageCounter = iImageCounter + 1;
        END WHILE;
        
        /*if we have added less than 8 images then add additional delimiters to make the */
        WHILE iImageTotal < 8 DO
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter)
            WHERE R.tmp_id = iCounter;

            SET iImageTotal = iImageTotal + 1;
        END WHILE;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;


/***********************
*   URL sample image   *
*   swatch_image_url   *
***********************/
UPDATE temp_result As R
INNER JOIN temp_product As p
ON R.tmp_product_id = p.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sUrlImagePrefix, CONVERT(p.tmp_image USING utf8), sSeparatorCharacter);


/************************
*   Variant component   *
*   parent_child        *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);


/*************************
*   Parent product SKU   *
*   parent_sku           *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Product relationship type   *
*   relationship_type           *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************
*   Variant design    *
*   variation_theme   *
**********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************
*   Update / delete   *
*   update_delete     *
**********************/


/*

backpack
update_delete
-------------
Löschung
Partielle Aktualisierung
Aktualisierung

handbag
update_delete
-------------
Aktualisierung
Partielle Aktualisierung
Löschung

*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, "Aktualisierung", sSeparatorCharacter);


/**************************
*   Product description   *
*   product_description   *
**************************/
UPDATE temp_result As R
INNER JOIN temp_product_description As d
ON R.tmp_product_id = d.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, d.tmp_description, sSeparatorCharacter);

/*******************
*   Model number   *
*   model          *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************
*   item number   *
*   part_number   *
******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Inner material        *
*   inner_material_type   *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************
*   Closure type / shoe closure type   *
*   closure_type                       *
***************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);


/*****************
*   Model name   *
*   model_name   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_name, sSeparatorCharacter);

/*******************
*   Manufacturer   *
*   manufacturer   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, tmp_manufacturer_name, sSeparatorCharacter);

/*****************
*   Model year   *
*   model_year   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   gtin_exemption_reason   *
*   gtin_exemption_reason   *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   Care instructions   *
*   care_instructions   *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   general keywords   *
*   generic_keywords   *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, TRIM(tmp_parent_category_name), " ", TRIM(tmp_category_name), " ", TRIM(tmp_colour), sSeparatorCharacter);

/*******************
*   template       *
*   pattern_name   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Special features   *
*   special_features   *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   attribute       *
*   bullet_point1   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   attribute       *
*   bullet_point2   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   attribute       *
*   bullet_point3   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   attribute       *
*   bullet_point4   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   attribute       *
*   bullet_point5   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Platinum Keywords    *
*   platinum_keywords1   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Platinum Keywords    *
*   platinum_keywords2   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Platinum Keywords    *
*   platinum_keywords3   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Platinum Keywords    *
*   platinum_keywords4   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Platinum Keywords    *
*   platinum_keywords5   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Belt length           *
*   shoulder_strap_drop   *
**************************/
UPDATE temp_result As R
INNER JOIN (SELECT
                tmp_product_id,
                tmp_text
            FROM temp_product_attribute
            WHERE tmp_attribute_id = iAttributeId_ShoulderStrap
            AND tmp_language_id = p_language_id) As A
ON R.tmp_product_id = A.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, A.tmp_text);

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************************
*   Unit of belt length                   *
*   shoulder_strap_drop_unit_of_measure   *
******************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   Style / shape   *
*   style_name      *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Is signed        *
*   is_autographed   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   Sales description   *
*   item_type_name      *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type1        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type2        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type3        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type4        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type5        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type6        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type7        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type8        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type9        *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type10       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type11       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type12       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type13       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type14       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type15       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type16       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type17       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type18       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type19       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type20       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type21       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type22       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type23       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type24       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type25       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type26       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Occasion & occasion   *
*   occasion_type27       *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************
*   sport         *
*   sport_type1   *
******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************
*   sport         *
*   sport_type2   *
******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************
*   Seasons   *
*   seasons   *
**************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************
*   player    *
*   athlete   *
**************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************
*   Team name   *
*   team_name   *
****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************
*   Collection (season + year)   *
*   collection_name              *
*********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************************************
*   material (3 columns)                                   *
*   material_type1 and material_type1 and material_type1   *
***********************************************************/

/*
handbag	-	handbag
material_type1	-	material_type1
--------------	-	--------------
100-percent-cotton	-	100 percent cotton
Baumwolle	-	cotton
Daunen	-	down
Gummi	-	rubber
Pelz	-	fur
acetate	-	acetate
acrylic	-	acrylic
alpaca	-	alpaca
angora	-	Angora
blend	-	blend
buckskin	-	buckskin
calfskin	-	calfskin
cashmere	-	cashmere
cashmere-blend	-	cashmere blend
chamois	-	chamois
cotton-blend	-	cotton blend
cotton-rich	-	cotton-rich
crocodile	-	crocodile
dacron	-	dacron
egyptian-cotton	-	egyptian cotton
fabric	-	fabric
fabric-and-leather	-	fabric-and-leather
fabric-and-synthetic	-	fabric-and-synthetic
faux-fur	-	faux-fur
fleece	-	fleece
gore-tex	-	gore-tex
kevlar	-	kevlar
kidskin	-	kidskin
lambskin	-	lambskin
leather	-	leather
linen	-	linen
linen-blend	-	linen blend
lizard	-	lizard
lurex	-	lurex
lycra	-	lycra
lycra-blend	-	lycra blend
mercerized-cotton	-	mercerized cotton
merino-wool	-	merino wool
microfiber	-	microfiber
microsuede	-	microsuede
mohair	-	mohair
nappa-leather	-	nappa leather
neoprene	-	neoprene
nubuck	-	nubuck
nylon	-	nylon
ostrich	-	ostrich
patent-leather	-	patent leather
pima-cotton	-	pima-cotton
plainweave	-	plainweave
plastic	-	plastic
pleather	-	pleather
polartec-fleece	-	polartec fleece
poly-cotton	-	poly-cotton
poly-rayon	-	poly-rayon
polyester	-	polyester
polyester-blend	-	polyester blend
polypropylene	-	polypropylene
pony	-	pony
rayon	-	rayon
rayon-blend	-	rayon blend
satin	-	satin
sequin	-	sequin
shearling	-	shearling
sheepskin	-	sheepskin
shetland	-	shetland
silk	-	silk
silk-blend	-	silk blend
snakeskin	-	snakeskin
spandex	-	spandex
straw	-	straw
suede	-	suede
synthetic	-	synthetic
tencel	-	tencel
thinsulate	-	thinsulate
ultrasuede	-	ultrasuede
urethane	-	urethane
velcro	-	velcro
vinyl	-	vinyl
viscose	-	viscose
viscose-rayon	-	viscose rayon
watersnake	-	watersnake
wool	-	wool
wool-blend	-	wool blend
worsted-wool	-	worsted-wool
Acryl	-	acrylic
Stroh	-	straw
Harz	-	resin
Leder	-	leather
Rattan	-	rattan
Canvas	-	Canvas
Wildleder	-	Suede
Pelzimitat	-	Faux fur
Samt	-	velvet
Wolle	-	Wool
Hanf	-	hemp
Neopren	-	Neoprene
Leinen	-	linen
Polyurethan	-	Polyurethane
Seide	-	silk
Bambus	-	bamboo
Denim	-	denim
PVC	-	PVC
Oxford	-	Oxford
Viskose	-	viscose
Kunstleder	-	leatherette
Jute	-	jute
		
		
		
		
		
		
backpack	-	backpack
material_type1	-	material_type1
--------------	-	--------------
Sterlingsilber	-	Sterling silver
Harz	-	resin
Nylon	-	nylon
Kupfer	-	copper
Edelstahlüberzogen	-	Stainless steel coated
Leder - Strauß	-	Leather-ostrich
Vermeil	-	Vermeil
Stahl und 18 Karat Gold	-	Steel and 18 carat gold
Platin	-	platinum
Velourleder	-	Suede
Gelbes und Weißes Gold	-	Yellow and white gold
Weißgold	-	White gold
Schlangenhaut	-	Snakeskin
Leder - Alligator	-	Leather - alligator
Platinüberzogener Edelstahl	-	Platinum-plated stainless steel
Vergoldeter Edelstahl	-	Gold-plated stainless steel
Gold	-	gold
Saphir	-	sapphire
Kalbsleder	-	Calfskin
Wolfram	-	tungsten
Titanüberzogener Edelstahl	-	Titanium coated stainless steel
Feinsilber	-	Fine silver
Leder - Kalbsleder	-	Leather - calfskin
Rotgold	-	Red gold
Python Schlangenhaut	-	Python snake skin
Leder - Synthetik	-	Leather - synthetic
Stahl zweifarbig	-	Two-tone steel
Gold und Platin	-	Gold and platinum
Goldton	-	Gold tone
Polyurethane	-	Polyurethanes
Silberton	-	Silver tone
Messing-überzogener Edelstahl	-	Brass-plated stainless steel
Lackleder	-	Patent leather
Titan	-	titanium
Zweifarbiger Edelstahl	-	Two-tone stainless steel
Leder - Stingray	-	Leather - stingray
Silikon	-	silicone
Rhodinierter Edelstahl	-	Rhodium-plated stainless steel
Keramik	-	Ceramics
Leder - Eidechse	-	Leather-lizard
Goldton Edelstahl	-	Gold tone stainless steel
Verchromter Edelstahl	-	Chromed stainless steel
Metall	-	metal
Titan Zweifarbig	-	Titanium two-tone
Satin	-	satin
Stahl und 14 Karat Gold	-	Steel and 14 carat gold
Holz	-	Wood
Leinen	-	linen
Versilberter Edelstahl	-	Silver-plated stainless steel
Gewebe	-	tissue
Gummi	-	rubber
Messing	-	Brass
Leder - Krokodil	-	Leather - crocodile
Leder - Schwein - Haut	-	Leather - pig - skin
Rostfreier Stahl	-	Stainless steel
Kunststoff	-	plastic
Silber und Gold	-	Silver and Gold
Gelbgold	-	Yellow gold
Legierung	-	alloy
Haifischhaut	-	Shark skin


Do all three fields at the same time
------------------------------------
*/



UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, 
                                           case when tmp_category_name = "Rucksäcke" or tmp_category_name = "Rucksacke" or tmp_category_name = "Rucksack" or tmp_category_name = "Rucksacks" then 
                                                case when tmp_material = "leather" or tmp_material = "leder" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyurethane" or tmp_material = "polyurethan" then
                                                        CONCAT("Polyurethane", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic leather" or tmp_material = "kunstleder" then
                                                        CONCAT("Leder - Synthetik", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, fabric" or tmp_material = "synthetisches Material, textiles Material" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, leather" OR tmp_material = "synthetisches Material, Leder" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material" OR tmp_material = "synthetisches Material" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyester" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" then
                                                        CONCAT("Velourleder", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                        /*"Synthetik" */
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, leather, fabric" or tmp_material = "synthetisches Material, Leder, textiles Material" then
                                                        CONCAT(sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                        CONCAT("Velourleder", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic leather, fabric" OR tmp_material = "kunstleder, textiles Material" then
                                                        CONCAT("Lackleder", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    else
                                                        CONCAT("Error (material):", tmp_material, sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    end
                                               when tmp_category_name = "Handbags" OR tmp_category_name = "Handtaschen" 
                                                 OR tmp_category_name = "Clutch bags" OR tmp_category_name = "Clutches" 
                                                 OR tmp_category_name = "Shopping bags" OR tmp_category_name = "Shopper" 
                                                 OR tmp_category_name = "Crossbody Bags" OR tmp_category_name = "Umhängetaschen" 
                                                 OR tmp_category_name = "Shoulder bags" OR tmp_category_name = "Schultertaschen" 
                                               then  
                                                case when tmp_material = "leather" or tmp_material = "leder" then
                                                        CONCAT("leder", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyurethane" or tmp_material = "polyurethan" then
                                                        CONCAT("Polyurethan", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic leather" or tmp_material = "kunstleder" then
                                                        CONCAT("kunstleder", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, fabric" or tmp_material = "synthetisches Material, textiles Material" then
                                                        CONCAT("synthetic", sSeparatorCharacter, "fabric", sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, leather" OR tmp_material = "synthetisches Material, Leder" then
                                                        CONCAT("synthetic", sSeparatorCharacter, "Leder", sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material" OR tmp_material = "synthetisches Material" then
                                                        CONCAT("synthetic", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyester" then
                                                        CONCAT("polyester", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                        CONCAT("leder", sSeparatorCharacter, "fabric", sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" then
                                                        CONCAT("suede", sSeparatorCharacter, "leder", sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                        CONCAT("Polyurethan", sSeparatorCharacter, "patent-leather", sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic material, leather, fabric" or tmp_material = "synthetisches Material, Leder, textiles Material" then
                                                        CONCAT("synthetic", sSeparatorCharacter, "leder", sSeparatorCharacter, "fabric", sSeparatorCharacter) 
                                                    when tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                        CONCAT("suede", sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    when tmp_material = "synthetic leather, fabric" OR tmp_material = "kunstleder, textiles Material" then
                                                        CONCAT("kunstleder", sSeparatorCharacter, "fabric", sSeparatorCharacter, sSeparatorCharacter) 
                                                    else
                                                        CONCAT("Error (material):", tmp_material, sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                    end
                                               else
                                                   CONCAT("Error (category_name):", tmp_category_name, sSeparatorCharacter, sSeparatorCharacter, sSeparatorCharacter) 
                                                   end, 
                                           sSeparatorCharacter);




/*********************
*   material         *
*   material_type2   *
*********************/
/*
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);
*/

/*********************
*   material         *
*   material_type3   *
*********************/
/*
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);
*/
/*****************
*   theme        *
*   lifestyle1   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   theme        *
*   lifestyle2   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   theme        *
*   lifestyle3   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   theme        *
*   lifestyle4   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   theme        *
*   lifestyle5   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************
*   Description of the fur and fur parts   *
*   fur_description                        *
*******************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************
*   Fit        *
*   fit_type   *
***************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Water resistance limit   *
*   water_resistance_level   *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Description of the bag   *
*   pocket_description       *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************
*   theme   *
*   theme   *
************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Inner lining         *
*   lining_description   *
*************************/

UPDATE temp_result As R
INNER JOIN (SELECT
                tmp_product_id,
                tmp_text
            FROM temp_product_attribute
            WHERE tmp_attribute_id = iAttributeId_InternalLining
            AND tmp_language_id = p_language_id) As A
ON R.tmp_product_id = A.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, A.tmp_text);


UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************
*   league        *
*   league_name   *
******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);


/*************************
*   Custom size          *
*   special_size_type1   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Custom size          *
*   special_size_type2   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Custom size          *
*   special_size_type3   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Custom size          *
*   special_size_type4   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Custom size          *
*   special_size_type5   *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************
*   size        *
*   size_name   *
****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Number of wheels   *
*   number_of_wheels   *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Availability in the product life cycle   *
*   lifecycle_supply_type                    *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************
*   Date of the item posting   *
*   item_booking_date          *
*******************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   target_audience_keywords1   *
*   target_audience_keywords1   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   target_audience_keywords2   *
*   target_audience_keywords2   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   target_audience_keywords3   *
*   target_audience_keywords3   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   target_audience_keywords4   *
*   target_audience_keywords4   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   target_audience_keywords5   *
*   target_audience_keywords5   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);


/***********************
*   shaft_style_type   *
*   shaft_style_type   *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Components included   *
*   included_components   *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Textile labeling       *
*   material_composition   *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************
*   Leather type   *
*   leather_type   *
*******************/
/*
handbag
leather_type
------------
Glattleder
Lackleder
Nubukleder
Wildleder

smooth leather
Patent leather
Nubuck leather
Suede

UPDATE temp_result As R
INNER JOIN (SELECT
                tmp_product_id,
                tmp_text
            FROM temp_product_attribute
            WHERE tmp_attribute_id = iAttributeId_Material
            AND tmp_language_id = p_language_id) As A
ON R.tmp_product_id = A.tmp_product_id
SET tmp_material = tmp_text;


                                                case when tmp_material = "leather" or tmp_material = "leder" then
                                                        "Leder"
                                                    when tmp_material = "polyurethane" or tmp_material = "polyurethan" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic leather" or tmp_material = "kunstleder" then
                                                        "Synthetikleder"
                                                    when tmp_material = "synthetic material, fabric" or tmp_material = "synthetisches Material, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, leather" OR tmp_material = "synthetisches Material, Leder" then
                                                        "leather"
                                                    when tmp_material = "synthetic material" OR tmp_material = "synthetisches Material" then
                                                        "Synthetik"
                                                    when tmp_material = "polyester" then
                                                        "Synthetik"
                                                    when tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                        "Leder"
                                                    when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" then
                                                        "Leder"
                                                    when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                        "Synthetik"
                                                    when tmp_material = "synthetic material, leather, fabric" or tmp_material = "synthetisches Material, Leder, textiles Material" then
                                                        "Synthetik"
                                                    when tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                        "Leder" 
                                                    when tmp_material = "synthetic leather, fabric" OR tmp_material = "kunstleder, textiles Material" then
                                                        "Synthetikleder"
                                                    else
                                                        CONCAT("Error (material):", tmp_material) 
                                                    end

*/

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, case when tmp_material = "leather" or tmp_material = "leder" or tmp_material = "leather, fabric" or tmp_material = "leder, textiles material" then
                                                                                      "Glattleder"
                                                                                  when tmp_material = "polyurethane, patent leather" or tmp_material = "Polyurethan, Lack" then
                                                                                      "Lackleder"
                                                                                  when tmp_material = "suede, leather" or tmp_material = "Chamoisleder, Leder" or tmp_material = "suede" or tmp_material = "Chamoisleder" then
                                                                                      "Wildleder"
                                                                                  else
                                                                                      ""
                                                                                  end);



UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   StrapType    *
*   strap_type   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************************
*   Unit of measurement of the shipping weight indicated on the website   *
*   website_shipping_weight_unit_of_measure                               *
**************************************************************************/
/*only handbag

    tmp_weight decimal(15,8) NOT NULL DEFAULT '0.00000000',
    tmp_weight_class_id int NOT NULL DEFAULT '0',
*/

IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND LOWER(TRIM(tmp_category_name)) IN ("handbags", "handtaschen", "clutch bags", "clutches", "shopping bags", "shopper", "crossbody bags", "umhängetaschen", "shoulder bags", "schultertaschen")) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);

            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET iTemp = (SELECT MIN(tmp_weight_class_id) FROM temp_product WHERE tmp_product_id = iProduct_ID);

                IF iTemp > 0 THEN
                    IF EXISTS (SELECT * FROM db_shoes.shoes_weight_class_description As w WHERE w.language_id = p_language_id AND weight_class_id = iTemp) THEN
                        SET sTemp = (SELECT w.unit FROM db_shoes.shoes_weight_class_description As w WHERE w.language_id = p_language_id AND weight_class_id = iTemp);

                        UPDATE temp_result As R
                        SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
                        WHERE R.tmp_id = iCounter
                        AND R.tmp_product_id = iProduct_ID;
                    END IF;
                END IF;
            END IF;
        END IF;
      
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);


/******************************
*   Shipping weight           *
*   website_shipping_weight   *
******************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND LOWER(TRIM(tmp_category_name)) IN ("handbags", "handtaschen", "clutch bags", "clutches", "shopping bags", "shopper", "crossbody bags", "umhängetaschen", "shoulder bags", "schultertaschen")) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);

            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET dTemp = (SELECT MAX(tmp_weight) FROM temp_product WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, FORMAT(dTemp, 8))
                WHERE R.tmp_id = iCounter
                AND R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Product length   *
*   item_length      *
*********************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND LOWER(TRIM(tmp_category_name)) IN ("handbags", "handtaschen", "clutch bags", "clutches", "shopping bags", "shopper", "crossbody bags", "umhängetaschen", "shoulder bags", "schultertaschen")) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);

            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET dTemp = (SELECT MAX(tmp_length) FROM temp_product WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, FORMAT(dTemp, 8))
                WHERE R.tmp_id = iCounter
                AND R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Product height   *
*   item_height      *
*********************/

IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;

    WHILE iCounter <= iEnd DO
/*
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND LOWER(TRIM(tmp_category_name)) IN ("handbags", "handtaschen", "clutch bags", "clutches", "shopping bags", "shopper", "crossbody bags", "umhängetaschen", "shoulder bags", "schultertaschen")) THEN
*/

        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter) THEN

            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);
            SET sTemp = (SELECT tmp_category_name FROM temp_result WHERE tmp_id = iCounter);
/*
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, "tmp_category_name:", sTemp)
            WHERE tmp_id = iCounter;
*/
            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET dTemp = (SELECT MAX(tmp_height) FROM temp_product WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, FORMAT(dTemp, 8))
                WHERE tmp_id = iCounter;
            END IF;
        END IF;
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   Product width   *
*   item_width      *
********************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND LOWER(TRIM(tmp_category_name)) IN ("handbags", "handtaschen", "clutch bags", "clutches", "shopping bags", "shopper", "crossbody bags", "umhängetaschen", "shoulder bags", "schultertaschen")) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);

            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET dTemp = (SELECT MAX(tmp_width) FROM temp_product WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, FORMAT(dTemp, 8))
                WHERE tmp_id = iCounter
                AND R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Shoe shaft width   *
*   shoe_width         *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************
*   Size assignment   *
*   size_map          *
**********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************
*   Display size   *
*   display_size   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************************
*   Unit of measurement for the display size   *
*   display_size_unit_of_measure               *
***********************************************/
/*tmp_length_class_id*/

IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * 
                   FROM temp_result 
                   WHERE tmp_id = iCounter
                   AND tmp_category_name IN ("Handbags", "Handtaschen", "Clutch bags", "Clutches", "Shopping bags", "Shopper", "Crossbody Bags", "Umhängetaschen", "Shoulder bags", "Schultertaschen")) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product WHERE tmp_id = iCounter);
/*
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, "iProduct_ID:", CONVERT(iProduct_ID, CHAR));
*/
            IF EXISTS (SELECT * 
                       FROM temp_product 
                       WHERE tmp_product_id = iProduct_ID) then
                SET iTemp = (SELECT MIN(tmp_length_class_id) FROM temp_product WHERE tmp_product_id = iProduct_ID);
/*
                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, "iTemp:", CONVERT(iTemp, CHAR));
*/
                IF iTemp > 0 THEN
                    IF EXISTS (SELECT * FROM db_shoes.shoes_length_class_description As w WHERE w.language_id = p_language_id AND length_class_id = iTemp) THEN
                        SET sTemp = (SELECT w.unit FROM db_shoes.shoes_length_class_description As w WHERE w.language_id = p_language_id AND length_class_id = iTemp);


                        UPDATE temp_result As R
                        SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
                        WHERE tmp_id = iCounter;
                    END IF;
                END IF;
            END IF;
        END IF;

        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************************
*   Unit of measure of storage volume   *
*   storage_volume_unit_of_measure      *
****************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Total usable content   *
*   storage_volume         *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************************
*   Unit of measurement for the article width   *
*   item_width_unit_of_measure                  *
************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************************
*   Unit of measure of capacity / power   *
*   capacity_unit_of_measure              *
******************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   item_shape   *
*   item_shape   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************************
*   Unit of measurement for the item height   *
*   item_height_unit_of_measure               *
**********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************
*   Capacity   *
*   capacity   *
***************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************
*   shoe_width_unit_of_measure   *
*   shoe_width_unit_of_measure   *
*********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Unit of measurement of the item length   *
*   item_length_unit_of_measure              *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   Shipping Center ID      *
*   fulfillment_center_id   *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Package length   *
*   package_length   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************
*   Package width   *
*   package_width   *
********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Package height   *
*   package_height   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************
*   Unit of measurement for the packaging length   *
*   package_length_unit_of_measure                 *
***************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Package weight   *
*   package_weight   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************
*   Unit of measurement of the packaging weight   *
*   package_weight_unit_of_measure                *
**************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Unit of measure for the package weight   *
*   package_height_unit_of_measure           *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************
*   Unit of measurement for the packaging width   *
*   package_width_unit_of_measure                 *
**************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   Country of origin   *
*   country_of_origin   *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************
*   Non-age-specific EU safety warning for toys   *
*   eu_toys_safety_directive_warning              *
**************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************************************
*   Is this product a battery or does it use batteries   *
*   batteries_required                                    *
**********************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Batteries are included   *
*   are_batteries_included   *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************
*   Composition of the battery   *
*   battery_cell_composition     *
*********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Battery type / size   *
*   battery_type1         *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Battery type / size   *
*   battery_type2         *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Battery type / size   *
*   battery_type3         *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Number of batteries    *
*   number_of_batteries1   *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Number of batteries    *
*   number_of_batteries2   *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Number of batteries    *
*   number_of_batteries3   *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Battery weight (in grams)   *
*   battery_weight              *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************************
*   battery_weight_unit_of_measure   *
*   battery_weight_unit_of_measure   *
*************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************
*   Number of lithium metal cells   *
*   number_of_lithium_metal_cells   *
************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   Number of lithium-ion cells   *
*   number_of_lithium_ion_cells   *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Lithium battery packaging   *
*   lithium_battery_packaging   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************************
*   Watt hours per battery           *
*   lithium_battery_energy_content   *
*************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************
*   lithium_battery_energy_content_unit_of_measure   *
*   lithium_battery_energy_content_unit_of_measure   *
*****************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Lithium content (g)      *
*   lithium_battery_weight   *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   lithium_battery_weight_unit_of_measure   *
*   lithium_battery_weight_unit_of_measure   *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Applicable dangerous goods regulations   *
*   supplier_declared_dg_hz_regulation1      *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Applicable dangerous goods regulations   *
*   supplier_declared_dg_hz_regulation2      *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Applicable dangerous goods regulations   *
*   supplier_declared_dg_hz_regulation3      *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Applicable dangerous goods regulations   *
*   supplier_declared_dg_hz_regulation4      *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************
*   Applicable dangerous goods regulations   *
*   supplier_declared_dg_hz_regulation5      *
*********************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************************
*   UN number                             *
*   hazmat_united_nations_regulatory_id   *
******************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   Safety data sheet (SDS) URL   *
*   safety_data_sheet_url         *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************
*   Item weight   *
*   item_weight   *
******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   item_weight_unit_of_measure   *
*   item_weight_unit_of_measure   *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   Product volume   *
*   item_volume   *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   item_volume_unit_of_measure   *
*   item_volume_unit_of_measure   *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************
*   Tissue type    *
*   fabric_type1   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************
*   Tissue type    *
*   fabric_type2   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************
*   Tissue type    *
*   fabric_type3   *
*******************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************
*   Flash point (° C)   *
*   flash_point          *
*************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************************************
*   Ordinance on the materials declared by the supplier   *
*   supplier_declared_material_regulation1                *
**********************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************************************
*   Ordinance on the materials declared by the supplier   *
*   supplier_declared_material_regulation2                *
**********************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************************************
*   Ordinance on the materials declared by the supplier   *
*   supplier_declared_material_regulation3                *
**********************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   Is product for adults   *
*   is_adult_product        *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Guarantee for the product   *
*   warranty_description        *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************
*   Categorization / GHS pictograms (select all that apply)   *
*   ghs_classification_class1                                 *
**************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************
*   Categorization / GHS pictograms (select all that apply)   *
*   ghs_classification_class2                                 *
**************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************
*   Categorization / GHS pictograms (select all that apply)   *
*   ghs_classification_class3                                 *
**************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************
*   State type of the offer   *
*   condition_type            *
******************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   State description   *
*   condition_note      *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************
*   Processing time       *
*   fulfillment_latency   *
**************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************
*   price        *
*   list_price   *
*****************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************
*   Number of items   *
*   number_of_items   *
**********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************
*   Gift message available         *
*   offering_can_be_gift_messaged   *
************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   Gift wrapping available       *
*   offering_can_be_giftwrapped   *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************
*   Availability date   *
*   restock_date        *
************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   Purchase unit           *
*   item_package_quantity   *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************
*   Production of the article stopped   *
*   is_discontinued_by_manufacturer      *
*****************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************
*   Tax code of the product   *
*   product_tax_code          *
******************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**********************************
*   Price with taxes to display   *
*   list_price_with_tax           *
**********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   Release date            *
*   merchant_release_date   *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************
*   Maximum amount that can be ordered   *
*   max_order_quantity                   *
*****************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************
*   Seller Shipping Group          *
*   merchant_shipping_group_name   *
***********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************
*   Sell ​​remaining stock   *
*   liquidate_remainder    *
***************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Retail price     *
*   uvp_list_price   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*************************************
*   Minimum Order Quantity           *
*   minimum_order_quantity_minimum   *
*************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, "1", sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (DE)                                                                  *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
/*
Das Letzte Datum, an dem der Verkaufspreis den standardpreis des artikels uberschreibt; der standardpries des produkts wird nach 0:00 Uhr des Verkaufsendtages andezeigt

The last date on which the selling price overrides the standard price of the item; The standard price of the product is displayed after midnight on the end of the sale day
*/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (DE)                                                                  *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
/*
Das Datum, an dem der Verkaufspreis beginnt, den standardpreis des Produkts zu uberschreien; der verkaufspreis wird nach 0:00 Uhr des Verkaufsdatums angezeigt

The date on which the selling price begins to exceed the standard price of the product; the sale price is displayed after midnight on the sale date
*/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_start, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price EUR (DE)                                                                                       *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
/*
Der Preis, zu dem Sie das Produkt zum Verkauf anbieten.

The price at which you are offering the product for sale.
*/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID) * dVATTax;

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(dTemp, CHAR))
                WHERE R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (DE)                                                  *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.end_at.value     *
***************************************************************************/
/*
Enddatum für Ihren Preis

End date for your price
*/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price EUR (DE)                                                                                 *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
/*
Geben Sie den Grundpreis eines Artikels an

Enter the basic price of an article
*/
UPDATE temp_result As R 
INNER JOIN temp_product As P ON R.tmp_product_id = P.tmp_product_id
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(tmp_price * dVATTax, CHAR));

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (DE)                                       *
*   purchasable_offer marketplace_id = A1PA6795UKMFR9 # 1.start_at.value     *
*****************************************************************************/
/*
Beginndatum für Ihren Preis

Start date for your price
*/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_start, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (FR)                                                                  *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (FR)                                                                  *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price EUR (FR)                                                                                       *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(dTemp, CHAR))
                WHERE R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (FR)                                                  *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.end_at.value     *
***************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price EUR (FR)                                                                                 *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (FR)                                       *
*   purchasable_offer marketplace_id = A13V1IB3VIYZZH # 1.start_at.value     *
*****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/******************************************************************************************************
*   End date for the offer price (IT)                                                                 *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.discounted_price # 1.schedule # 1.end_at     *
******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Start date for the offer price (IT)                                                                 *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.discounted_price # 1.schedule # 1.start_at     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************************************************************
*   Offer price EUR (IT)                                                                                      *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.discounted_price # 1.schedule # 1.value_with_tax     *
**************************************************************************************************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(dTemp, CHAR))
                WHERE R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/**************************************************************************
*   End of sale date (IT)                                                 *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.end_at.value     *
**************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   Your price EUR (IT)                                                                                *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.our_price # 1.schedule # 1.value_with_tax     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************************************************************
*   Publication date of the offer (IT)                                      *
*   purchasable_offer marketplace_id = APJ6JRA9NG5V4 # 1.start_at.value     *
****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (ES)                                                                  *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (ES)                                                                  *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price EUR (ES)                                                                                       *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(dTemp, CHAR))
                WHERE R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (ES)                                                  *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.end_at.value     *
***************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price EUR (ES)                                                                                 *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (ES)                                       *
*   purchasable_offer marketplace_id = A1RKKUPIHCS9HS # 1.start_at.value     *
*****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (NL)                                                                  *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (NL)                                                                  *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price EUR (NL)                                                                                       *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
IF EXISTS (SELECT * FROM temp_result) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_result);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_result);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_result WHERE tmp_ID = iCounter) THEN
            SET iProduct_ID = (SELECT MAX(tmp_product_id) FROM temp_result WHERE tmp_ID = iCounter);
            
            IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_product_id = iProduct_ID) THEN
                SET dTemp = (SELECT MAX(tmp_price) FROM temp_product_special WHERE tmp_product_id = iProduct_ID);

                UPDATE temp_result As R
                SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, CONVERT(dTemp, CHAR))
                WHERE R.tmp_product_id = iProduct_ID;
            END IF;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (NL)                                                  *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.end_at.value     *
***************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price EUR (NL)                                                                                 *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (NL)                                       *
*   purchasable_offer marketplace_id = A1805IZSGTT6HS # 1.start_at.value     *
*****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (SE)                                                                  *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (SE)                                                                  *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price SEK (SE)                                                                                       *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (SE)                                                  *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.end_at.value     *
***************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price SEK (SE)                                                                                 *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (SE)                                       *
*   purchasable_offer marketplace_id = A2NODRKZP88ZB9 # 1.start_at.value     *
*****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*******************************************************************************************************
*   End date for the offer price (PL)                                                                  *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.discounted_price # 1.schedule # 1.end_at     *
*******************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************************************************************
*   Start date for the offer price (PL)                                                                  *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.discounted_price # 1.schedule # 1.start_at     *
*********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************************************************
*   Offer price PLN (PL)                                                                                       *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.discounted_price # 1.schedule # 1.value_with_tax     *
***************************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***************************************************************************
*   End of sale date (PL)                                                  *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.end_at.value     *
***************************************************************************/
IF EXISTS (SELECT * FROM temp_product_special) THEN
    SET iStart = (SELECT MIN(tmp_id) FROM temp_product_special);
    SET iEnd = (SELECT MAX(tmp_id) FROM temp_product_special);
    SET iCounter = iStart;
    
    WHILE iCounter <= iEnd DO
        IF EXISTS (SELECT * FROM temp_product_special WHERE tmp_id = iCounter) THEN
            SET iProduct_ID = (SELECT MIN(tmp_product_id) FROM temp_product_special WHERE tmp_id = iCounter);
            SET sTemp = (SELECT DATE_FORMAT(tmp_date_end, "%d.%m.%Y") FROM temp_product_special WHERE tmp_id = iCounter);
        
            UPDATE temp_result As R
            SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sTemp)
            WHERE R.tmp_product_id = iProduct_ID;
        END IF;
        
        SET iCounter = iCounter + 1;
    END WHILE;
END IF;

UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************************************************************************************
*   Your price PLN (PL)                                                                                 *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.our_price # 1.schedule # 1.value_with_tax     *
********************************************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************************************************************
*   Publication date of the offer (PL)                                       *
*   purchasable_offer marketplace_id = A1C3SOZRARQ6R3 # 1.start_at.value     *
*****************************************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************
*   Business price   *
*   business_price   *
*********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Quantity pricing types   *
*   quantity_price_type      *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Lower limit of quantity 1   *
*   quantity_lower_bound1       *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Quantity price 1   *
*   quantity_price1    *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Lower quantity limit 2   *
*   quantity_lower_bound2    *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Quantity price 2   *
*   quantity_price2    *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Lower quantity limit 3   *
*   quantity_lower_bound3    *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Quantity price 3   *
*   quantity_price3    *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Lower quantity limit 4   *
*   quantity_lower_bound4    *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Quantity price 4   *
*   quantity_price4    *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*****************************
*   Lower quantity limit 5   *
*   quantity_lower_bound5    *
*****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Quantity price 5   *
*   quantity_price5    *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/********************************
*   Progressive discount type   *
*   progressive_discount_type   *
********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************************
*   Lower limit 1 of the progressive discount   *
*   progressive_discount_lower_bound1           *
************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************
*   Progressive discount value 1   *
*   progressive_discount_value1    *
***********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************************
*   Lower limit 2 of the progressive discount   *
*   progressive_discount_lower_bound2           *
************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************
*   Progressive discount value 2   *
*   progressive_discount_value2    *
***********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/************************************************
*   Lower limit 3 of the progressive discount   *
*   progressive_discount_lower_bound3           *
************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************************
*   Progressive discount value 3   *
*   progressive_discount_value3    *
***********************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/****************************
*   National Stock Number   *
*   national_stock_number   *
****************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/*********************************************************
*   United Nations Standard Products and Services Code   *
*   unspsc_code                                          *
*********************************************************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);

/***********************
*   Price adjustment   *
*   pricing_action     *
***********************/
UPDATE temp_result As R
SET R.tmp_tab_delimited_full_result = CONCAT(R.tmp_tab_delimited_full_result, sSeparatorCharacter);






/*********************************************************
*   TO DO                                                *
*   -----                                                *
*   Remove records where the discount end date is soon   *
*********************************************************/




/*********************************
*   remove records with errors   *
*********************************/

update temp_result
set tmp_load = false
where LOWER(tmp_tab_delimited_full_result) LIKE "%error%";



/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SELECT  
        tmp_tab_delimited_full_result
    FROM temp_result
    WHERE tmp_load = true;
/*
    SELECT
        tmp_id,
        tmp_product_id,
        tmp_name,
        tmp_description,
        tmp_sku,
        tmp_manufacturer_id,
        tmp_manufacturer_name,
        tmp_category_id,
        tmp_category_name, 
        tmp_parent_category_id,
        tmp_parent_category_name, 
        tmp_original_price_exclude_VAT,
        tmp_price_exclude_VAT,
        tmp_quantity,
        tmp_gender,
        tmp_material,
        tmp_colour,
        tmp_tab_delimited_full_result
    FROM temp_result
    WHERE tmp_load = true;
*/
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;



SET @p1='2'; SET @p2='10'; SET @p3='7'; CALL `amazon_products_to_upload`(@p0, @p1, @p2, @p3); SELECT @p0 AS `p_bIsOk`; 

