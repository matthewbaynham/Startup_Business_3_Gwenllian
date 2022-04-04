use db_settings;

DROP PROCEDURE IF EXISTS insertProduct;

DELIMITER //

CREATE PROCEDURE insertProduct(OUT p_bIsOk boolean,
OUT p_prd_product_id int,
IN p_upload_type_id INT, 
IN p_language_id int,
IN p_prd_model varchar(64),
IN p_prd_sku varchar(64),
IN p_prd_upc varchar(12),
IN p_prd_ean varchar(14),
IN p_prd_jan varchar(13),
IN p_prd_isbn varchar(17),
IN p_prd_mpn varchar(64),
IN p_prd_location varchar(128),
IN p_prd_quantity int,
IN p_prd_stock_status_id int,
IN p_prd_image varchar(255),
IN p_prd_manufacturer_id int,
IN p_prd_shipping tinyint,
IN p_prd_price decimal(15,4),
IN p_prd_points int,
IN p_prd_tax_class_id int,
IN p_prd_date_available date,
IN p_prd_weight decimal(15,8),
IN p_prd_weight_class_id int,
IN p_prd_length decimal(15,8),
IN p_prd_width decimal(15,8),
IN p_prd_height decimal(15,8),
IN p_prd_length_class_id int,
IN p_prd_subtract tinyint,
IN p_prd_minimum int,
IN p_prd_sort_order int,
IN p_prd_status tinyint,
IN p_desc_name varchar(255),
IN p_desc_description text,
IN p_desc_tag text,
IN p_desc_meta_title varchar(255) ,
IN p_desc_meta_description varchar(255),
IN p_desc_meta_keyword varchar(255), 
IN p_Concat_image varchar(4000),
IN p_Concat_image_sort_order varchar(4000),
IN p_prd_price_i_pay decimal(15,4),
IN iMode_product int,
IN iMode_description int,
IN iMode_images int,
IN p_seo_url_product_name varchar(255),
OUT p_status_text text)
BEGIN 
declare sDelimiterTab varchar(10) default "\t";
declare iCounter int;
declare iPosA int;
declare iPosB int;
declare iPosStart int default 0;
declare iPosEnd int default 0;
declare iTemp int default 0;
declare sTemp varchar(4000) default "";
declare bIsFinished boolean default false;
declare dMarkupMinimum decimal(15,4) default 0;
declare dSpecialPrice decimal(15,4) default 0;
declare dPriceRange_cheap decimal(15,4) default 0;
declare dPriceRange_expensive decimal(15,4) default 0;
declare dteDiscountEndDateMax date;
declare bIsSpecialOk boolean default true;
declare bIsSpecialOverlap boolean default true;
declare dteSpecialNewStartDate date;
declare dteSpecialNewEndDate date;
declare iSpecialLength int default 0;
declare iFlag_add int default 1;
declare iFlag_edit int default 2;
declare iFlag_ignore int default 3;
declare sManufacturerName varchar(255) default "";
declare iTempCategoryId int default 0;
declare sCategoryName varchar(255) default "";

DECLARE exit handler for SQLEXCEPTION
 BEGIN
  GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
   @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
  SET p_bIsOk = false;
  SET p_status_text = "SP Crashed";
  SELECT 0 as err_ID, 
         CONCAT('MYSQL_ERRNO: ', @errno) As err_Category, 
         CONCAT('MYSQL_ERRNO: ', @sqlstate) as err_Name, 
         CONCAT('MESSAGE_TEXT: ', @text) As err_Long_Description, 
         '' As err_Values;
 END;

SET p_bIsOk = true;
SET p_status_text = "";
SET p_prd_product_id = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_status;
DROP TABLE IF EXISTS temp_product;
DROP TABLE IF EXISTS temp_product_image;
DROP TABLE IF EXISTS temp_images;
DROP TABLE IF EXISTS temp_images_sort_order;
DROP TABLE IF EXISTS temp_images_duplicate;
DROP TABLE IF EXISTS temp_products_logged;
DROP TABLE IF EXISTS temp_product_discount;
DROP TABLE IF EXISTS temp_product_special;
DROP TABLE IF EXISTS temp_customer_group;
DROP TABLE IF EXISTS temp_customer_group_description;
DROP TABLE IF EXISTS temp_seo_url;
DROP TABLE IF EXISTS temp_product_to_category;
DROP TABLE IF EXISTS temp_category_description;

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) NOT NULL default '',
    err_Name varchar(1024) NOT NULL default '',
    err_Long_Description varchar(1024) NOT NULL default '',
    err_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_status (
    tmpSt_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmpSt_Category varchar(1024) NOT NULL default '',
    tmpSt_Name varchar(1024) NOT NULL default '',
    tmpSt_Long_Description varchar(1024) NOT NULL default '',
    tmpSt_Values varchar(1024) NOT NULL default '');

CREATE TEMPORARY TABLE temp_product (
  tmpP_id INT AUTO_INCREMENT PRIMARY KEY,
  tmpP_product_id int NOT NULL,
  tmpP_model varchar(64) NOT NULL,
  tmpP_sku varchar(64) NOT NULL,
  tmpP_upc varchar(12) NOT NULL,
  tmpP_ean varchar(14) NOT NULL,
  tmpP_jan varchar(13) NOT NULL,
  tmpP_isbn varchar(17) NOT NULL,
  tmpP_mpn varchar(64) NOT NULL,
  tmpP_location varchar(128) NOT NULL,
  tmpP_quantity int NOT NULL DEFAULT '0',
  tmpP_stock_status_id int NOT NULL,
  tmpP_image varchar(255) DEFAULT NULL,
  tmpP_manufacturer_id int NOT NULL,
  tmpP_shipping tinyint NOT NULL DEFAULT '1',
  tmpP_price decimal(15,4) NOT NULL DEFAULT '0.0000',
  tmpP_points int NOT NULL DEFAULT '0',
  tmpP_tax_class_id int NOT NULL,
  tmpP_date_available date NOT NULL DEFAULT '2020-01-01',
  tmpP_weight decimal(15,8) NOT NULL DEFAULT '0.00000000',
  tmpP_weight_class_id int NOT NULL DEFAULT '0',
  tmpP_length decimal(15,8) NOT NULL DEFAULT '0.00000000',
  tmpP_width decimal(15,8) NOT NULL DEFAULT '0.00000000',
  tmpP_height decimal(15,8) NOT NULL DEFAULT '0.00000000',
  tmpP_length_class_id int NOT NULL DEFAULT '0',
  tmpP_subtract tinyint NOT NULL DEFAULT '1',
  tmpP_minimum int NOT NULL DEFAULT '1',
  tmpP_sort_order int NOT NULL DEFAULT '0',
  tmpP_status tinyint NOT NULL DEFAULT '0',
  tmpP_viewed int NOT NULL DEFAULT '0',
  tmpP_date_added datetime NOT NULL,
  tmpP_date_modified datetime NOT NULL);

CREATE TEMPORARY TABLE temp_product_image (
  tmpI_id INT AUTO_INCREMENT PRIMARY KEY,
  tmpI_product_image_id int NOT NULL,
  tmpI_product_id int NOT NULL,
  tmpI_image varchar(255) DEFAULT NULL,
  tmpI_sort_order int NOT NULL DEFAULT '0');

CREATE TEMPORARY TABLE temp_images (
  tmpM_id int AUTO_INCREMENT PRIMARY KEY,
  tmpM_image varchar(255) DEFAULT NULL);

CREATE TEMPORARY TABLE temp_images_sort_order (
  tmpS_id int AUTO_INCREMENT PRIMARY KEY,
  tmpS_sort_order varchar(255) DEFAULT NULL );

CREATE TEMPORARY TABLE temp_images_duplicate (
  tmpD_id int AUTO_INCREMENT PRIMARY KEY,
  tmpD_image varchar(255) DEFAULT NULL,
  tmpD_count int NOT NULL DEFAULT '0', 
  tmpD_min_id int NOT NULL DEFAULT '0');

CREATE TEMPORARY TABLE temp_products_logged (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_upload_type_id INT NOT NULL,
  tmp_product_id INT NOT NULL);
    
CREATE TEMPORARY TABLE temp_seo_url (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_seo_url_id int NOT NULL,
  tmp_store_id int NOT NULL,
  tmp_language_id int NOT NULL,
  tmp_query varchar(255) NOT NULL,
  tmp_keyword varchar(255) NOT NULL);

CREATE TEMPORARY TABLE temp_product_to_category (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  tmp_product_id int NOT NULL,
  tmp_category_id int NOT NULL);

/*
CREATE TEMPORARY TABLE temp_product_discount (
  tmp_id int AUTO_INCREMENT PRIMARY KEY,
  tmp_product_discount_id int NOT NULL,
  tmp_product_id int NOT NULL,
  tmp_customer_group_id int NOT NULL,
  tmp_quantity int NOT NULL DEFAULT '0',
  tmp_priority int NOT NULL DEFAULT '1',
  tmp_price decimal(15,4) NOT NULL DEFAULT '0.0000',
  tmp_date_start date,
  tmp_date_end date
);
*/

CREATE TEMPORARY TABLE temp_product_special (
  tmp_id int AUTO_INCREMENT PRIMARY KEY,
  tmp_product_special_id int NOT NULL,
  tmp_product_id int NOT NULL,
  tmp_customer_group_id int NOT NULL,
  tmp_priority int NOT NULL DEFAULT '1',
  tmp_price decimal(15,4) NOT NULL DEFAULT '0.0000',
  tmp_date_start date,
  tmp_date_end date);



CREATE TEMPORARY TABLE temp_customer_group (
  tmp_id int AUTO_INCREMENT PRIMARY KEY,
  tmp_customer_group_id int NOT NULL,
  tmp_approval int NOT NULL,
  tmp_sort_order int NOT NULL);

CREATE TEMPORARY TABLE temp_category_description (
  tmp_id int AUTO_INCREMENT PRIMARY KEY,
  tmp_category_id int NOT NULL,
  tmp_language_id int NOT NULL,
  tmp_name varchar(255) NOT NULL,
  tmp_description text NOT NULL,
  tmp_meta_title varchar(255) NOT NULL,
  tmp_meta_description varchar(255) NOT NULL,
  tmp_meta_keyword varchar(255) NOT NULL);




/*
CREATE TEMPORARY TABLE temp_customer_group_description (
  tmp_id int AUTO_INCREMENT PRIMARY KEY,
  tmp_customer_group_id int(11) NOT NULL,
  tmp_language_id int(11) NOT NULL,
  tmp_name varchar(32) NOT NULL,
  tmp_description text NOT NULL
);
*/


IF NOT REPLACE(p_Concat_image, sDelimiterTab, "") = "" AND NOT REPLACE(p_Concat_image_sort_order, sDelimiterTab, "") = "" THEN
    /****************************************************
    *   put all images in parameter into a temp table   *
    ****************************************************/
    SET iCounter = 0;
    SET iPosStart = 0;
    SET iPosEnd = 0;
    SET bIsFinished = false;

    WHILE iCounter < LENGTH(p_Concat_image) AND NOT bIsFinished DO
        SET sTemp = "";

        IF iCounter = 0 THEN
            /*****************
            *   First item   *
            *****************/
            SET iPosEnd = LOCATE(sDelimiterTab, p_Concat_image);
            
            IF iPosEnd > 0 THEN
                SET sTemp = LEFT(p_Concat_image, iPosEnd - 1);
        
                INSERT INTO temp_images (tmpM_image) 
                values (LOWER(TRIM(IFNULL(sTemp, ""))));
            END IF;
        ELSE
            /**************************************
            *   Not the first and not last item   *
            **************************************/
            SET iPosEnd = LOCATE(sDelimiterTab, p_Concat_image, iPosEnd + 1);

            IF iPosEnd = 0 THEN
                SET sTemp = RIGHT(p_Concat_image, LENGTH(p_Concat_image) - iPosStart + 1);
                INSERT INTO temp_images (tmpM_image) 
                values (LOWER(TRIM(IFNULL(sTemp, ""))));
            ELSE
                SET sTemp = MID(p_Concat_image, iPosStart, iPosEnd - iPosStart);
                INSERT INTO temp_images (tmpM_image) 
                values (LOWER(TRIM(IFNULL(sTemp, ""))));
            END IF;
        END IF;
  
        IF iPosEnd = 0 THEN
            SET bIsFinished = true;
        END IF;
  
        SET iPosStart = iPosEnd + 1;
  
        SET iCounter = iCounter + 1;
    END WHILE;

    /***************************************************************
    *   put all images sort order in parameter into a temp table   *
    ***************************************************************/
    SET iCounter = 0;
    SET iPosStart = 0;
    SET iPosEnd = 0;
    SET bIsFinished = false;

    WHILE iCounter < LENGTH(p_Concat_image_sort_order) AND NOT bIsFinished DO
        SET sTemp = "";

        IF iCounter = 0 THEN
            /*****************
            *   First item   *
            *****************/
            SET iPosEnd = LOCATE(sDelimiterTab, p_Concat_image_sort_order);
      
            IF iPosEnd > 0 THEN
                SET sTemp = LEFT(p_Concat_image_sort_order, iPosEnd - 1);
        
                INSERT INTO temp_images_sort_order (tmpS_sort_order) 
                values (LOWER(TRIM(IFNULL(sTemp, ""))));
           END IF;
       ELSE
           /**************************************
           *   Not the first and not last item   *
           **************************************/
           SET iPosEnd = LOCATE(sDelimiterTab, p_Concat_image_sort_order, iPosEnd + 1);

           IF iPosEnd = 0 THEN
               SET sTemp = RIGHT(p_Concat_image_sort_order, LENGTH(p_Concat_image_sort_order) - iPosStart + 1);
               INSERT INTO temp_images_sort_order (tmpS_sort_order) 
               values (LOWER(TRIM(IFNULL(sTemp, ""))));
           ELSE
               SET sTemp = MID(p_Concat_image_sort_order, iPosStart, iPosEnd - iPosStart);
               INSERT INTO temp_images_sort_order (tmpS_sort_order) 
               values (LOWER(TRIM(IFNULL(sTemp, ""))));
           END IF;
      END IF;
  
      IF iPosEnd = 0 THEN
        SET bIsFinished = true;
      END IF;
  
      SET iPosStart = iPosEnd + 1;
  
      SET iCounter = iCounter + 1;
    END WHILE;

    /****************************************
    *   check all sort orders are integer   *
    ****************************************/
    IF EXISTS (SELECT * 
               FROM temp_images_sort_order 
               WHERE NOT tmpS_sort_order REGEXP '[0-9]') THEN
        SET p_status_text = CONCAT(p_status_text, "|sort order for images is not a integer (8 digits or less)");

        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        SELECT 'image', 'sort order for images is not a integer (8 digits or less) ', concat('Sort order ', tmpS_sort_order), tmpS_sort_order
        FROM temp_images_sort_order
        WHERE NOT tmpS_sort_order REGEXP '[0-9]';
    
        SET p_bIsOk = false;
    END IF;

    /***********************************
    *   check sort orders are unique   *
    ***********************************/
    INSERT INTO temp_images_duplicate (
        tmpD_image, 
        tmpD_count, 
        tmpD_min_id)
    SELECT 
        tmpM_image, 
        COUNT(*) As Count_of_numbers,
        MIN(tmpM_id) As min_id
    FROM temp_images
    GROUP BY tmpM_image 
    HAVING count(*) > 1;

    IF EXISTS (SELECT * FROM temp_images_duplicate) THEN
        SET p_status_text = CONCAT(p_status_text, "|images_duplicates");
        SET iPosStart = (SELECT MIN(tmpD_id) FROM temp_images_duplicate);
        SET iPosEnd = (SELECT MAX(tmpD_id) FROM temp_images_duplicate);
        SET iCounter = iPosStart; 
    
        WHILE iCounter <= iPosEnd DO
            IF EXISTS (SELECT * FROM temp_images_duplicate WHERE tmpD_id = iCounter) THEN
                SET sTemp = (SELECT tmpM_image FROM temp_images_duplicate WHERE tmpD_id = iCounter);
                SET iTemp = (SELECT tmpD_min_id FROM temp_images_duplicate WHERE tmpD_id = iCounter);
            
                DELETE FROM temp_images_sort_order 
                WHERE tmpS_id in (SELECT tmpM_id
                                  FROM temp_images
                                  WHERE tmpM_image = sTemp
                                  AND NOT tmpM_id = iTemp);
            
                DELETE FROM temp_images
                WHERE tmpM_image = sTemp
                AND NOT tmpM_id = iTemp;
            END IF;
        
            SET iCounter = iCounter + 1;
        END WHILE;
    END IF;
    
    /********************************
    *   checking images are unique  *
    ********************************/
    IF EXISTS (SELECT tmpM_image, count(*) As Count_of_numbers 
          FROM temp_images
          GROUP BY tmpM_image 
          HAVING count(*) > 1) THEN
        SET p_status_text = CONCAT(p_status_text, "|images are not unique");
        SET p_bIsOk = false;
        
        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        SELECT 'image', 'images are not unique ', concat('Sort order ', T.tmpM_image, " repeats ", CONVERT(T.Count_of_numbers, CHAR(10)), " times."), T.tmpM_image
        FROM (SELECT tmpM_image, count(*) As Count_of_numbers 
              FROM temp_images
              GROUP BY tmpM_image 
              HAVING count(*) > 1) As T; 
    END IF;

    /*****************************
    *   Double checking images   *
    *****************************/
    IF EXISTS (SELECT * FROM temp_images) AND EXISTS (SELECT * FROM temp_images_sort_order) THEN
        IF (SELECT max(tmpM_id) FROM temp_images) != (SELECT MAX(tmpS_id) FROM temp_images_sort_order) THEN
            SET p_status_text = CONCAT(p_status_text, "|number of images does not equal number of sort order for those images");

            INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
            values ('image', 'number of images does not equal number of sort order for those images', '', '');

            INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
            SELECT 'image', 'number of images does not equal number of sort order for those images (temp_images values)', CONVERT(tmpM_id, CHAR), tmpM_image
            FROM temp_images;

            INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
            SELECT 'image', 'number of images does not equal number of sort order for those images (temp_images_sort_order values)', CONVERT(tmpS_id, CHAR), tmpS_sort_order
            FROM temp_images_sort_order;

            SET p_bIsOk = false;
        END IF;
    END IF;

    /*********************************************************
    *   check if item is in db_shoes_product from image      *
    *   also check image isn't in shoes_product_image        *
    *   also check name isn't in shoes_product_description   *
    *********************************************************/
/*
    INSERT INTO temp_product_image (
      tmpI_product_image_id,
      tmpI_product_id,
      tmpI_image,
      tmpI_sort_order)
    SELECT product_image_id, product_id, image, sort_order
    FROM db_shoes.shoes_product_image
    WHERE trim(lower(image)) in (SELECT trim(lower(tmpM_image)) FROM temp_images);
*/
    /*********************************************************
    *   Check we have a matching image for each sort order   *
    *********************************************************/
    IF EXISTS (SELECT * 
               FROM temp_images LEFT JOIN temp_images_sort_order 
               ON tmpM_id = tmpS_id
               WHERE tmpM_id = NULL) THEN
        SET p_status_text = CONCAT(p_status_text, "|image sort order does not have matching image");
        SET p_bIsOk = false;
    
        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        SELECT "image", "image sort order does not have matching image", CONCAT("ID:", CONVERT(tmpS_id, CHAR)), CONCAT("Sort Order: ", tmpS_sort_order)
        FROM temp_images LEFT JOIN temp_images_sort_order 
        ON tmpM_id = tmpS_id
        WHERE tmpM_id = NULL;
    END IF;
    
    IF EXISTS (SELECT *
               FROM temp_images RIGHT JOIN temp_images_sort_order 
               ON tmpM_id = tmpS_id
               WHERE tmpS_id = NULL) THEN
        SET p_status_text = CONCAT(p_status_text, "|image does not have matching image sort order");
        SET p_bIsOk = false;

        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        SELECT "image", "image does not have matching image sort order", CONCAT("ID:", CONVERT(tmpM_id, CHAR)), CONCAT("image: ", tmpM_image)
        FROM temp_images RIGHT JOIN temp_images_sort_order 
        ON tmpM_id = tmpS_id
        WHERE tmpS_id = NULL;
    END IF;
    
    /***********************************************************
    *   If an error has been flagged return error temp table   *
    *   or else return details of language                     *
    ***********************************************************/
/*    IF EXISTS (SELECT * FROM temp_errors WHERE NOT err_Category = 'not an error') THEN*/

/*        SET p_status_text = CONCAT(p_status_text, "|model too long had to trim");*/

/*        SET p_bIsOk = false;*/
/*    END IF;*/
END IF;

/***********************
*   Check data types   *
***********************/
/*product_id int(11) NOT NULL*/
/*model varchar(64) NOT NULL*/
IF LENGTH(IFNULL(p_prd_model, '')) > 64 THEN
    SET p_status_text = CONCAT(p_status_text, "|model too long had to trim");
    SET p_prd_model = left(trim(p_prd_model), 64);
END IF;

/*sku varchar(64) NOT NULL*/
IF LENGTH(IFNULL(p_prd_sku, '')) > 64 THEN
    SET p_status_text = CONCAT(p_status_text, "|sku too long had to trim");
    SET p_prd_sku = left(trim(p_prd_sku), 64);
END IF;

/*upc varchar(12) NOT NULL*/
IF LENGTH(IFNULL(p_prd_upc, '')) > 12 THEN
    SET p_status_text = CONCAT(p_status_text, "|upc too long had to trim");
    SET p_prd_upc = left(trim(p_prd_upc), 12);
END IF;

/*ean varchar(14) NOT NULL*/
IF LENGTH(IFNULL(p_prd_ean, '')) > 14 THEN
    SET p_status_text = CONCAT(p_status_text, "|ean too long had to trim");
    SET p_prd_ean = left(trim(p_prd_ean), 14);
END IF;

/*jan varchar(13) NOT NULL*/
IF LENGTH(IFNULL(p_prd_jan, '')) > 13 THEN
    SET p_status_text = CONCAT(p_status_text, "|jan too long had to trim");
    SET p_prd_jan = left(trim(p_prd_jan), 13);
END IF;

/*isbn varchar(17) NOT NULL*/
IF LENGTH(IFNULL(p_prd_isbn, '')) > 17 THEN
    SET p_status_text = CONCAT(p_status_text, "|isbn too long had to trim");
    SET p_prd_isbn = left(trim(p_prd_isbn), 17);
END IF;

/*mpn varchar(64) NOT NULL*/
IF LENGTH(IFNULL(p_prd_mpn, '')) > 64 THEN
    SET p_status_text = CONCAT(p_status_text, "|mpn too long had to trim");
    SET p_prd_mpn = left(trim(p_prd_mpn), 64);
END IF;

/*location varchar(128) NOT NULL*/
IF LENGTH(IFNULL(p_prd_location, '')) > 128 THEN
    SET p_status_text = CONCAT(p_status_text, "|location too long had to trim");
    SET p_prd_location = left(trim(p_prd_location), 128);
END IF;

/*quantity int(4) NOT NULL DEFAULT '0'*/
/*stock_status_id int(11) NOT NULL*/
/*image varchar(255) DEFAULT NULL*/
IF LENGTH(IFNULL(p_prd_image, '')) > 255 THEN
    SET p_status_text = CONCAT(p_status_text, "|image too long had to trim");
    SET p_prd_image = left(trim(p_prd_image), 255);
END IF;

/*manufacturer_id int(11) NOT NULL*/
IF NOT exists (SELECT * FROM db_shoes.shoes_manufacturer WHERE manufacturer_id = p_prd_manufacturer_id ) THEN
    SET p_status_text = CONCAT(p_status_text, "|Unknown manufacturer id");
    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('manufacturer_id', 'Unknown manufacturer id', CONCAT('p_prd_manufacturer_id = ', CONVERT(p_prd_manufacturer_id, CHAR(10))), CONVERT(p_prd_manufacturer_id, CHAR(10)));
    SET p_bIsOk = false;
END IF;

/*shipping tinyint(1) NOT NULL DEFAULT '1'*/
/*price decimal(15, 4) NOT NULL DEFAULT '0.0000'*/
/*points int(8) NOT NULL DEFAULT '0'*/
/*tax_class_id int(11) NOT NULL*/
IF NOT exists (SELECT * FROM db_shoes.shoes_tax_class WHERE tax_class_id = p_prd_tax_class_id ) THEN
    SET p_status_text = CONCAT(p_status_text, "|Unknown tax class id");
    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('shoes_tax_class', 'Unknown tax class id', CONCAT('p_prd_tax_class_id = ', CONVERT(p_prd_tax_class_id, CHAR(10))), CONVERT(p_prd_tax_class_id, CHAR(10)));
    SET p_bIsOk = false;
END IF;

/*date_available date NOT NULL DEFAULT '0000-00-00'*/
/*weight decimal(15, 8) NOT NULL DEFAULT '0.00000000'*/
/*weight_class_id int(11) NOT NULL DEFAULT '0'*/
IF NOT exists (SELECT * FROM db_shoes.shoes_weight_class WHERE weight_class_id = p_prd_weight_class_id ) THEN
    SET p_status_text = CONCAT(p_status_text, "|Unknown weight class id");
    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('weight_class_id', 'Unknown weight class id', CONCAT('p_prd_weight_class_id = ', CONVERT(p_prd_weight_class_id, CHAR(10))), CONVERT(p_prd_weight_class_id, CHAR(10)));
    SET p_bIsOk = false;
END IF;

/*LENGTH decimal(15, 8) NOT NULL DEFAULT '0.00000000'*/
/*width decimal(15, 8) NOT NULL DEFAULT '0.00000000'*/
/*height decimal(15, 8) NOT NULL DEFAULT '0.00000000'*/
/*length_class_id int(11) NOT NULL DEFAULT '0'*/

IF NOT exists (SELECT * FROM db_shoes.shoes_length_class WHERE length_class_id = p_prd_length_class_id ) THEN
    SET p_status_text = CONCAT(p_status_text, "|Unknown length class id");
    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('length_class_id', 'Unknown length class id', CONCAT('p_prd_length_class_id = ', CONVERT(p_prd_length_class_id, CHAR(10))), CONVERT(p_prd_length_class_id, CHAR(10)));
    SET p_bIsOk = false;
END IF;


/*subtract tinyint(1) NOT NULL DEFAULT '1'*/
/*minimum int(11) NOT NULL DEFAULT '1'*/
/*sort_order int(11) NOT NULL DEFAULT '0'*/
/*status tinyint(1) NOT NULL DEFAULT '0'*/
/*viewed int(5) NOT NULL DEFAULT '0'*/
/*date_added datetime NOT NULL*/
/*date_modified datetime NOT NULL*/

SET p_prd_product_id = -1;

/****************************************
*   insert or edit into shoes_product   *
****************************************/
IF p_bIsOk THEN
    IF EXISTS (SELECT *
               FROM db_shoes.shoes_product As P
               WHERE TRIM(UPPER(P.model)) = TRIM(UPPER(p_prd_model))
               AND TRIM(UPPER(P.sku)) = TRIM(UPPER(p_prd_sku))
               AND TRIM(UPPER(P.ean)) = TRIM(UPPER(p_prd_ean))
               AND TRIM(UPPER(P.jan)) = TRIM(UPPER(p_prd_jan))
               AND TRIM(UPPER(P.isbn)) = TRIM(UPPER(p_prd_isbn))
               AND TRIM(UPPER(P.mpn)) = TRIM(UPPER(p_prd_mpn))) THEN
        SET p_status_text = CONCAT(p_status_text, "|edit project record");
        SET iMode_product = iFlag_edit; 

        SET p_prd_product_id = (SELECT MAX(P.product_id)
                                FROM db_shoes.shoes_product P
                                WHERE 
                                    TRIM(UPPER(P.model)) = TRIM(UPPER(p_prd_model))
                                AND TRIM(UPPER(P.sku)) = TRIM(UPPER(p_prd_sku))
                                AND TRIM(UPPER(P.ean)) = TRIM(UPPER(p_prd_ean))
                                AND TRIM(UPPER(P.jan)) = TRIM(UPPER(p_prd_jan))
                                AND TRIM(UPPER(P.isbn)) = TRIM(UPPER(p_prd_isbn))
                                AND TRIM(UPPER(P.mpn)) = TRIM(UPPER(p_prd_mpn)));
    ELSE
        SET p_status_text = CONCAT(p_status_text, "|insert project record");
        SET iMode_product = iFlag_add; 
    END IF;
    
    IF iMode_product = iFlag_add THEN
        INSERT INTO db_shoes.shoes_product (
            model,
            sku,
            upc,
            ean,
            jan,
            isbn,
            mpn,
            location,
            quantity,
            stock_status_id,
            image,
            manufacturer_id,
            shipping,
            price,
            points,
            tax_class_id,
            date_available,
            weight,
            weight_class_id,
            length,
            width,
            height,
            length_class_id,
            subtract,
            minimum,
            sort_order,
            status,
            viewed,
            date_added,
            date_modified)
        VALUES (
            TRIM(p_prd_model),
            TRIM(p_prd_sku),
            TRIM(p_prd_upc),
            TRIM(p_prd_ean),
            TRIM(p_prd_jan),
            TRIM(p_prd_isbn),
            TRIM(p_prd_mpn),
            TRIM(p_prd_location),
            p_prd_quantity,
            p_prd_stock_status_id,
            TRIM(p_prd_image),
            p_prd_manufacturer_id,
            p_prd_shipping,
            p_prd_price,
            p_prd_points,
            p_prd_tax_class_id,
            p_prd_date_available,
            p_prd_weight,
            p_prd_weight_class_id,
            p_prd_length,
            p_prd_width,
            p_prd_height,
            p_prd_length_class_id,
            p_prd_subtract,
            p_prd_minimum,
            p_prd_sort_order,
            p_prd_status,
            0,
            CURRENT_TIMESTAMP(),
            CURRENT_TIMESTAMP());
        SET p_prd_product_id = LAST_INSERT_ID(); 

        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('not an error', 'checking the product id', '', CONVERT(p_prd_product_id, CHAR(10)));
    END IF;

    IF iMode_product = iFlag_edit THEN
        UPDATE db_shoes.shoes_product 
        SET
            model = TRIM(p_prd_model),
            sku = TRIM(p_prd_sku),
            upc = TRIM(p_prd_upc),
            ean = TRIM(p_prd_ean),
            jan = TRIM(p_prd_jan),
            isbn = TRIM(p_prd_isbn),
            mpn = TRIM(p_prd_mpn),
            location = TRIM(p_prd_location),
            quantity = p_prd_quantity,
            stock_status_id = p_prd_stock_status_id,
            image = TRIM(p_prd_image),
            manufacturer_id = p_prd_manufacturer_id,
            shipping = p_prd_shipping,
            price = p_prd_price,
            points = p_prd_points,
            tax_class_id = p_prd_tax_class_id,
            date_available = p_prd_date_available,
            weight = p_prd_weight,
            weight_class_id = p_prd_weight_class_id,
            length = p_prd_length,
            width = p_prd_width,
            height = p_prd_height,
            length_class_id = p_prd_length_class_id,
            subtract = p_prd_subtract,
            minimum = p_prd_minimum,
            sort_order = p_prd_sort_order,
            status = p_prd_status,
            date_modified = CURRENT_TIMESTAMP()
        WHERE product_id = p_prd_product_id;
    END IF;

    /***********************
    *   Check product id   *
    ***********************/
    IF p_prd_product_id = NULL THEN
        SET p_status_text = CONCAT(p_status_text, "|insert/update product id did not return a product id in expected range");

        INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('product id', 'insert/update product id did not return a product id in expected range', CONCAT('p_prd_model = ', p_prd_model), 'product id = null');
        SET p_bIsOk = false;
    ELSE
        IF p_prd_product_id < 1 THEN
            SET p_status_text = CONCAT(p_status_text, "|insert/update product id did not return a product id in expected range");

            INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
            values ('product id', 'insert/update product id did not return a product id in expected range', CONCAT('p_prd_product_id = ', CONVERT(p_prd_product_id, CHAR(10))), CONVERT(p_prd_product_id, CHAR(10)));
            SET p_bIsOk = false;
        END IF;
    END IF;
ELSE
    SET p_status_text = CONCAT(p_status_text, "|there were problems with the data, so no attempt was made to insert/update the product table");

    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('product not updated', 'there were problems with the data, so no attempt was made to insert/update the product table', CONCAT('model: ', p_prd_model, ' - sku: ', p_prd_sku, ' - ean: ', p_prd_ean, ' - jan: ', p_prd_jan, ' - isbn: ', p_prd_isbn, ' - mpn: ', p_prd_mpn), '');
END IF;

IF p_bIsOk THEN
    /**********************************************
    *   Look for records in tbl_products_logged   *
    **********************************************/
    INSERT INTO temp_products_logged (tmp_upload_type_id, tmp_product_id)
    SELECT pl_upload_type_id, pl_product_id 
    FROM tbl_products_logged
    WHERE pl_upload_type_id = p_upload_type_id
    AND pl_product_id = p_prd_product_id;

    /***************************************
    *   Check does not exist then add it   *
    ***************************************/
    IF NOT EXISTS (SELECT * FROM temp_products_logged) THEN
        INSERT INTO tbl_products_logged (pl_upload_type_id, pl_product_id)
        VALUES (p_upload_type_id, p_prd_product_id);
    END IF;
END IF;

IF p_bIsOk THEN
    /* IN p_desc_name varchar(255),*/
    IF LENGTH(IFNULL(p_desc_name, '')) > 255 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:name too long have to trim");
        SET p_desc_name = left(trim(p_desc_name), 255);
    END IF;
    
    /* IN p_desc_description text,*/
    IF LENGTH(IFNULL(p_desc_description, '')) > 65535 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:description too long have to trim");
        SET p_desc_description = left(trim(p_desc_description), 65535);
    END IF;
    
    /* IN p_desc_tag text,*/
    IF LENGTH(IFNULL(p_desc_tag, '')) > 65535 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:tag too long have to trim");
        SET p_desc_tag = left(trim(p_desc_tag), 65535);
    END IF;
    
    /* IN p_desc_meta_title varchar(255) ,*/
    IF LENGTH(IFNULL(p_desc_meta_title, '')) > 255 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:meta title too long have to trim");
        SET p_desc_meta_title = left(trim(p_desc_meta_title), 255);
    END IF;
    
    /* IN p_desc_meta_description varchar(255),*/
    IF LENGTH(IFNULL(p_desc_meta_description, '')) > 255 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:meta description too long have to trim");
        SET p_desc_meta_description = left(trim(p_desc_meta_description), 255);
    END IF;
    
    /* IN p_desc_meta_keyword varchar(255), */
    IF LENGTH(IFNULL(p_desc_meta_keyword, '')) > 255 THEN
        SET p_status_text = CONCAT(p_status_text, "|project description:meta keywords too long have to trim");
        SET p_desc_meta_keyword = left(trim(p_desc_meta_keyword), 255);
    END IF;
    
    IF EXISTS (SELECT *
               FROM db_shoes.shoes_product_description
               WHERE product_id = p_prd_product_id
               AND language_id = p_language_id) THEN
        SET p_status_text = CONCAT(p_status_text, "|update project description");
        SET iMode_description = iFlag_edit;
    ELSE
        SET p_status_text = CONCAT(p_status_text, "|insert project description");
        SET iMode_description = iFlag_add;
    END IF;
    
    IF iMode_description = iFlag_add THEN
        INSERT INTO db_shoes.shoes_product_description (
            product_id,
            language_id,
            name,
            description,
            tag,
            meta_title,
            meta_description,
            meta_keyword) 
        VALUES (
            p_prd_product_id, 
            p_language_id,
            TRIM(p_desc_name),
            TRIM(p_desc_description),
            TRIM(p_desc_tag),
            TRIM(p_desc_meta_title),
            TRIM(p_desc_meta_description),
            TRIM(p_desc_meta_keyword));
    END IF;
    
    IF iMode_description = iFlag_edit THEN
        UPDATE db_shoes.shoes_product_description 
        SET
            name = TRIM(p_desc_name),
            description = TRIM(p_desc_description),
            tag = TRIM(p_desc_tag),
            meta_title = TRIM(p_desc_meta_title),
            meta_description = TRIM(p_desc_meta_description),
            meta_keyword = TRIM(p_desc_meta_keyword)
        WHERE
            product_id = p_prd_product_id
        AND language_id = p_language_id;
    END IF;
    
    /******************************************************************************************
    *   NOTE: meta_description = TRIM(p_desc_meta_description) gets over written at the end   *
    *         in order to include the price                                                   *
    ******************************************************************************************/
END IF;

/*****************
*   add images   *
*****************/
IF p_bIsOk THEN
    IF iMode_images = iFlag_add OR iMode_images = iFlag_edit THEN
        IF EXISTS (SELECT * FROM temp_images) AND EXISTS (SELECT * FROM temp_images_sort_order) THEN
            SET p_status_text = CONCAT(p_status_text, "|update images");
            
            DELETE FROM temp_product_image;
        
            INSERT INTO temp_product_image (
                tmpI_product_image_id,
                tmpI_product_id,
                tmpI_image,
                tmpI_sort_order)
            SELECT -1, p_prd_product_id, tmpM_image, tmpS_sort_order
            FROM temp_images INNER JOIN temp_images_sort_order 
            ON tmpM_id = tmpS_id;
        
            SET sTemp = (SELECT tmpM_image As image
                         FROM temp_images 
                         WHERE tmpM_id in (SELECT MIN(tmpS_id) FROM temp_images_sort_order));

/*        
            UPDATE db_shoes.shoes_product 
            SET image = TRIM(sTemp)
            WHERE product_id = p_prd_product_id;
*/
            
            DELETE FROM db_shoes.shoes_product_image
            WHERE product_id = p_prd_product_id
            AND NOT image IN (SELECT LOWER(TRIM(tmpI_image)) FROM temp_product_image);

            IF EXISTS (SELECT * FROM temp_product_image) THEN
                SET iPosStart = (SELECT MIN(tmpI_id) FROM temp_product_image);
                SET iPosEnd = (SELECT MAX(tmpI_id) FROM temp_product_image);
                SET iCounter = iPosStart;
                
                WHILE iCounter <= iPosEnd DO
                    IF EXISTS (SELECT * FROM temp_product_image WHERE tmpI_id = iCounter) THEN
                        SET sTemp = (SELECT LOWER(TRIM(tmpI_image)) FROM temp_product_image WHERE tmpI_id = iCounter);
                        
                        IF NOT EXISTS (SELECT * FROM db_shoes.shoes_product_image WHERE product_id = p_prd_product_id AND image = sTemp) THEN
                            INSERT INTO db_shoes.shoes_product_image (product_id, image, sort_order)
                            SELECT p_prd_product_id, LOWER(TRIM(tmpI_image)), tmpI_sort_order
                            FROM temp_product_image
                            WHERE tmpI_id = iCounter;
                        END IF;
                    END IF;
                    SET iCounter = iCounter + 1;
                END WHILE;
            END IF;
        ELSE
            SET p_status_text = CONCAT(p_status_text, "|no images to update");
        END IF;
    END IF;
END IF;

/***********************
*   Add to the store   *
***********************/
IF p_prd_product_id > -1 THEN
    SET p_status_text = CONCAT(p_status_text, "|add to the store");

    DELETE FROM db_shoes.shoes_product_to_store WHERE product_id = p_prd_product_id;
    
    IF EXISTS (SELECT * FROM db_shoes.shoes_store) THEN
        INSERT INTO db_shoes.shoes_product_to_store (product_id, store_id)
        SELECT p_prd_product_id, store_id FROM db_shoes.shoes_store;
    ELSE
        INSERT INTO db_shoes.shoes_product_to_store (product_id, store_id)
        VALUES (p_prd_product_id, 0);
    END IF;
ELSE
    INSERT INTO temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
            values ('product id', 'product id was zero or lower for an unknown reason', CONCAT('p_prd_product_id = ', CONVERT(p_prd_product_id, CHAR(10))), CONVERT(p_prd_product_id, CHAR(10)));
    SET p_bIsOk = false;
END IF;

/**********************
*   Add the special   *
**********************/
IF p_bIsOk THEN
    SET bIsSpecialOk = true;
/*
If no discount exists OR the end date on the discounts is more than 2 days old then
    create a new discount with the p_prd_discount_price

If there is already a discount ...
    ...AND nothing has been sold for 2 days then leave it alone
    ...AND 1 item has been sold in the last 2 days then raise the price a little
    ...AND 2 items have been sold in the last 2 days then raise the price a little more
    ...AND 3 items have been sold in the last 2 days then raise the price a lot

*/

    IF p_prd_price_i_pay < 5 THEN
        SET bIsSpecialOk = false;
    else
        /**********************************
        *   Calculate the special price   *
        **********************************/
        SET dPriceRange_cheap = 150;
        SET dPriceRange_expensive = 400;
        SET dMarkupMinimum = 0;
        SET p_prd_price_i_pay = p_prd_price_i_pay * 1.1;
        
        IF p_prd_price < dPriceRange_cheap THEN
            SET dMarkupMinimum = 5;
        ELSEIF p_prd_price < dPriceRange_expensive THEN 
            SET dMarkupMinimum = 10;
        ELSE
            SET dMarkupMinimum = 25;
        END IF;

        SET dSpecialPrice = p_prd_price_i_pay + dMarkupMinimum + (((4 * RAND(p_prd_product_id) * RAND()) + 1) / 120) * (p_prd_price - (p_prd_price_i_pay + dMarkupMinimum));
        
        IF dSpecialPrice < (p_prd_price * 0.40) THEN
            SET dSpecialPrice = (p_prd_price * 0.40);
        END IF;
        
        /**********************************************************
        *   Check the discount price is not too high or too low   *
        **********************************************************/
        IF dSpecialPrice < (p_prd_price_i_pay + dMarkupMinimum) THEN 
            SET bIsSpecialOk = false;
        END IF;

        IF dSpecialPrice > (p_prd_price * 0.95) THEN 
            SET bIsSpecialOk = false;
        END IF;

        IF dSpecialPrice > (p_prd_price - 5) THEN 
            SET bIsSpecialOk = false;
        END IF;
        
        SET iSpecialLength = 0;
 
        IF p_prd_quantity < 5 THEN 
            SET iSpecialLength = 5;
        ELSEIF p_prd_quantity < 8 THEN
            SET iSpecialLength = 7;
        ELSEIF p_prd_quantity < 12 THEN
            SET iSpecialLength = 10;
        ELSEIF p_prd_quantity < 20 THEN
            SET iSpecialLength = 14;
        ELSE
            SET iSpecialLength = 21;
        END IF;
    END IF;

    IF bIsSpecialOk THEN
        IF iSpecialLength = 0 THEN
            SET bIsSpecialOk = false;
        END IF;
    END IF;

    IF bIsSpecialOk THEN
        INSERT INTO temp_product_special (
            tmp_product_special_id,
            tmp_product_id,
            tmp_customer_group_id,
            tmp_priority,
            tmp_price,
            tmp_date_start,
            tmp_date_end)
        SELECT
            product_special_id,
            product_id,
            customer_group_id,
            priority,
            price,
            date_start,
            date_end
        FROM db_shoes.shoes_product_special 
        WHERE product_id = p_prd_product_id;
        
        SET bIsSpecialOverlap = false;
        SET dteSpecialNewStartDate = CURRENT_DATE();
        SET dteSpecialNewEndDate = DATE_ADD(CURRENT_DATE(), INTERVAL iSpecialLength DAY);
        
        IF EXISTS (SELECT * FROM temp_product_special) THEN
            SET iPosStart = (SELECT MIN(tmp_ID) FROM temp_product_special);
            SET iPosEnd = (SELECT MAX(tmp_ID) FROM temp_product_special);
            SET iCounter = iPosStart;
            
            WHILE iCounter <= iPosEnd DO
                IF EXISTS (SELECT * FROM temp_product_special 
                           WHERE tmp_id = iCounter
                           AND (
                                (dteSpecialNewStartDate BETWEEN tmp_date_start AND tmp_date_end)
                                OR (dteSpecialNewEndDate BETWEEN tmp_date_start AND tmp_date_end)
                                OR (dteSpecialNewStartDate <= tmp_date_start AND dteSpecialNewEndDate >= tmp_date_end)
                                OR (dteSpecialNewStartDate >= tmp_date_start AND dteSpecialNewEndDate <= tmp_date_end)
                                )
                          ) THEN
                    SET bIsSpecialOverlap = true;
                    
                    SET dSpecialPrice = (SELECT MAX(tmp_price) 
                                         FROM temp_product_special 
                                         WHERE tmp_id = iCounter
                                         AND (
                                               (dteSpecialNewStartDate BETWEEN tmp_date_start AND tmp_date_end)
                                            OR (dteSpecialNewEndDate BETWEEN tmp_date_start AND tmp_date_end)
                                            OR (dteSpecialNewStartDate <= tmp_date_start AND dteSpecialNewEndDate >= tmp_date_end)
                                            OR (dteSpecialNewStartDate >= tmp_date_start AND dteSpecialNewEndDate <= tmp_date_end)
                                              )
                                        );

                    UPDATE db_shoes.shoes_product_description 
                    SET
                        meta_description = LEFT(CONCAT("Netto €", FORMAT(dSpecialPrice, 2), " ", TRIM(p_desc_meta_description)), 255)
                    WHERE
                        product_id = p_prd_product_id
                    AND language_id = p_language_id;
                END IF;
                
                SET iCounter = iCounter + 1;
            END WHILE;
        END IF;
        
        IF bIsSpecialOverlap THEN
            SET bIsSpecialOk = false;
        END IF;
    END IF;

    IF bIsSpecialOk THEN
        INSERT INTO temp_customer_group (
            tmp_customer_group_id,
            tmp_approval,
            tmp_sort_order)
        SELECT
            customer_group_id,
            approval,
            sort_order
        FROM db_shoes.shoes_customer_group;
        
        INSERT INTO db_shoes.shoes_product_special (
            product_id,
            customer_group_id,
            priority,
            price,
            date_start,
            date_end)
        SELECT
            p_prd_product_id,
            tmp_customer_group_id,
            1,
            dSpecialPrice,
            dteSpecialNewStartDate, 
            dteSpecialNewEndDate
        FROM temp_customer_group;

        UPDATE db_shoes.shoes_product_description 
        SET
            meta_description = LEFT(CONCAT("Netto €", FORMAT(dSpecialPrice, 2), " ", TRIM(p_desc_meta_description)), 255)
        WHERE
            product_id = p_prd_product_id
        AND language_id = p_language_id;
    END IF;
END IF;

IF p_bIsOk THEN
/*

seo_url_id	store_id	language_id	query	keyword
824 	0 	1 	product_id=48 	ipod-classic
836 	0 	1 	category_id=20 	desktops
834 	0 	1 	category_id=26 	pc
835 	0 	1 	category_id=27 	mac
730 	0 	1 	manufacturer_id=8 	apple

query = "product_id=" + product_id
query = "category_id=" + category_id
query = "manufacturer_id=" + manufacturer_id

*/

/**********************
*   Product SEO URL   *
**********************/
    DELETE FROM temp_seo_url;

    INSERT INTO temp_seo_url (
        tmp_seo_url_id,
        tmp_store_id,
        tmp_language_id,
        tmp_query,
        tmp_keyword)
    SELECT
        s.seo_url_id,
        s.store_id,
        s.language_id,
        s.query,
        s.keyword
    FROM db_shoes.shoes_seo_url  As s
    WHERE s.query = CONCAT("product_id=", CONVERT(p_prd_product_id, CHAR))
    AND s.language_id = p_language_id;

    IF EXISTS (SELECT * FROM temp_seo_url) THEN
        UPDATE db_shoes.shoes_seo_url
        SET 
            keyword = CONCAT(p_seo_url_product_name, "-", CONVERT(p_language_id, CHAR), "-", CONVERT(p_prd_product_id, CHAR))
        WHERE
            query = CONCAT("product_id=", CONVERT(p_prd_product_id, CHAR))
        AND language_id = p_language_id;
        
    ELSE
        INSERT INTO db_shoes.shoes_seo_url (
            store_id,
            language_id,
            query,
            keyword)
        VALUES (
            0,
            p_language_id,
            CONCAT("product_id=", CONVERT(p_prd_product_id, CHAR)),
            CONCAT(p_seo_url_product_name, "-", CONVERT(p_language_id, CHAR), "-", CONVERT(p_prd_product_id, CHAR)));
    END IF;

/***************************
*   manufacturer SEO URL   *
***************************/
    IF EXISTS (SELECT * FROM db_shoes.shoes_manufacturer WHERE manufacturer_id = p_prd_manufacturer_id) THEN
        SET sManufacturerName = (SELECT M.name FROM db_shoes.shoes_manufacturer As M WHERE M.manufacturer_id = p_prd_manufacturer_id);
    
        DELETE FROM temp_seo_url;

        INSERT INTO temp_seo_url (
            tmp_seo_url_id,
            tmp_store_id,
            tmp_language_id,
            tmp_query,
            tmp_keyword)
        SELECT
            s.seo_url_id,
            s.store_id,
            s.language_id,
            s.query,
            s.keyword
        FROM db_shoes.shoes_seo_url  As s
        WHERE s.query = CONCAT("manufacturer_id=", CONVERT(p_prd_manufacturer_id, CHAR))
        AND s.language_id = p_language_id;

        IF EXISTS (SELECT * FROM temp_seo_url) THEN
            UPDATE db_shoes.shoes_seo_url
            SET 
                keyword = REPLACE(REPLACE(REPLACE(CONCAT(sManufacturerName, "-", CONVERT(p_language_id, CHAR)), " ", "-"), ".", "-"), "--", "-")
            WHERE
                query = CONCAT("manufacturer_id=", CONVERT(p_prd_manufacturer_id, CHAR))
            AND language_id = p_language_id;
        ELSE
            INSERT INTO db_shoes.shoes_seo_url (
                store_id,
                language_id,
                query,
                keyword)
            VALUES (
                0,
                p_language_id,
                CONCAT("manufacturer_id=", CONVERT(p_prd_manufacturer_id, CHAR)),
                REPLACE(REPLACE(REPLACE(CONCAT(sManufacturerName, "-", CONVERT(p_language_id, CHAR)), " ", "-"), ".", "-"), "--", "-"));
        END IF;    
    END IF;
END IF;

/****************************
*   return result to java   *
****************************/
IF p_bIsOk THEN
    SET p_status_text = CONCAT(p_status_text, "|return results");

    SELECT
        tmpSt_ID,
        tmpSt_Category,
        tmpSt_Name,
        tmpSt_Long_Description,
        tmpSt_Values
    FROM temp_status
    ORDER BY tmpSt_ID;
ELSE
    SET p_status_text = CONCAT(p_status_text, "|return error");

    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


