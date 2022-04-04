use db_settings;

DROP PROCEDURE if exists insertOptionPlusExtraFields;

DELIMITER //

CREATE PROCEDURE insertOptionPlusExtraFields(OUT p_bIsOk boolean, 
IN p_product_option_value_id int(11),
IN p_product_option_id int(11),
IN p_product_id int(11),
IN p_option_id int(11),
IN p_option_value_id int(11),
IN p_quantity int(3),
IN p_subtract tinyint(1),
IN p_price decimal(15,4),
IN p_price_prefix varchar(1),
IN p_points int(8),
IN p_points_prefix varchar(1),
IN p_weight decimal(15,8),
IN p_weight_prefix varchar(1),
IN p_model varchar(64),
IN p_Model_id int,
IN p_Barcode varchar(1000),
IN p_Product_code varchar(1000), 
IN p_sku varchar(64),
IN p_upc varchar(12),
IN p_ean varchar(14),
IN p_jan varchar(13),
IN p_isbn varchar(17),
IN p_mpn varchar(64),
IN p_location varchar(128))
BEGIN 
/*
DROP TABLE IF EXISTS db_settings.product_option_value_extra_details;
CREATE TABLE db_settings.product_option_value_extra_details (
  povxd_product_id int(11) NOT NULL,
  povxd_option_value_id int not null,
  povxd_model varchar(64) NOT NULL,
  povxd_Model_id int,
  povxd_Barcode varchar(1000) not null,
  povxd_Product_code varchar(1000) not null, 
  povxd_sku varchar(64) NOT NULL,
  povxd_upc varchar(12) NOT NULL,
  povxd_ean varchar(14) NOT NULL,
  povxd_jan varchar(13) NOT NULL,
  povxd_isbn varchar(17) NOT NULL,
  povxd_mpn varchar(64) NOT NULL,
  povxd_location varchar(128) NOT NULL
);

SELECT `povxd_product_id`, `povxd_option_value_id`, `povxd_model`, `povxd_Model_id`, `povxd_Barcode`, `povxd_Product_code`, `povxd_sku`, `povxd_upc`, `povxd_ean`, `povxd_jan`, `povxd_isbn`, `povxd_mpn`, `povxd_location` FROM `product_option_value_extra_details` WHERE 1




DROP TABLE IF EXISTS `shoes_product_option_value`;
CREATE TABLE `shoes_product_option_value` (
  `product_option_value_id` int(11) NOT NULL,
  `product_option_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `option_value_id` int(11) NOT NULL,
  `quantity` int(3) NOT NULL,
  `subtract` tinyint(1) NOT NULL,
  `price` decimal(15,4) NOT NULL,
  `price_prefix` varchar(1) NOT NULL,
  `points` int(8) NOT NULL,
  `points_prefix` varchar(1) NOT NULL,
  `weight` decimal(15,8) NOT NULL,
  `weight_prefix` varchar(1) NOT NULL
);
SELECT `product_option_value_id`, `product_option_id`, `product_id`, `option_id`, `option_value_id`, `quantity`, `subtract`, `price`, `price_prefix`, `points`, `points_prefix`, `weight`, `weight_prefix` FROM `shoes_product_option_value` WHERE 1

product_option_value_id	product_option_id	product_id	option_id	option_value_id	quantity	subtract	price	price_prefix	points	points_prefix	weight	weight_prefix
17 	227 	111869 	13 	49 	123 	1 	0.0000 	+ 	0 	+ 	0.00000000 	+
18 	227 	111869 	13 	50 	23 	1 	0.0000 	+ 	0 	+ 	0.00000000 	+
19 	227 	111869 	13 	51 	54 	1 	0.0000 	+ 	0 	+ 	0.00000000 	+
20 	227 	111869 	13 	52 	21 	1 	0.0000 	+ 	0 	+ 	0.00000000 	+

*/

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_product_option_value;
DROP TABLE IF EXISTS temp_product_option_value_extra_details;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');

CREATE TEMPORARY TABLE temp_product_option_value (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_option_value_id int(11) NOT NULL,
    tmp_product_option_id int(11) NOT NULL,
    tmp_product_id int(11) NOT NULL,
    tmp_option_id int(11) NOT NULL,
    tmp_option_value_id int(11) NOT NULL,
    tmp_quantity int(3) NOT NULL,
    tmp_subtract tinyint(1) NOT NULL,
    tmp_price decimal(15,4) NOT NULL,
    tmp_price_prefix varchar(1) NOT NULL,
    tmp_points int(8) NOT NULL,
    tmp_points_prefix varchar(1) NOT NULL,
    tmp_weight decimal(15,8) NOT NULL,
    tmp_weight_prefix varchar(1) NOT NULL);

CREATE TEMPORARY TABLE temp_product_option_value_extra_details (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_option_value_id int(11) NOT NULL,
    tmp_product_option_id int(11) NOT NULL,
    tmp_product_id int(11) NOT NULL,
    tmp_option_id int(11) NOT NULL,
    tmp_option_value_id int not null,
    tmp_model varchar(64) NOT NULL,
    tmp_Model_id int,
    tmp_Barcode varchar(1000) not null,
    tmp_Product_code varchar(1000) not null, 
    tmp_sku varchar(64) NOT NULL,
    tmp_upc varchar(12) NOT NULL,
    tmp_ean varchar(14) NOT NULL,
    tmp_jan varchar(13) NOT NULL,
    tmp_isbn varchar(17) NOT NULL,
    tmp_mpn varchar(64) NOT NULL,
    tmp_location varchar(128) NOT NULL);

/*****************************************
*                                        *
*   **********************************   *
*   *   shoes_product_option_value   *   *
*   *   ===== ======= ====== =====   *   *
*   *   Add an entry in this table   *   *
*   **********************************   *
*                                        *
*****************************************/
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
    pov.product_option_value_id, 
    pov.product_option_id, 
    pov.product_id, 
    pov.option_id, 
    pov.option_value_id, 
    pov.quantity, 
    pov.subtract, 
    pov.price, 
    pov.price_prefix, 
    pov.points, 
    pov.points_prefix, 
    pov.weight, 
    pov.weight_prefix 
FROM db_shoes.shoes_product_option_value As pov
WHERE 
    pov.product_option_id = p_product_option_id 
AND pov.product_id = p_product_id 
AND pov.option_id = p_option_id 
AND pov.option_value_id = p_option_value_id;

IF EXISTS (SELECT * FROM temp_product_option_value) THEN
    UPDATE db_shoes.shoes_product_option_value 
    SET 
        quantity = p_quantity, 
        subtract = p_subtract, 
        price = p_price, 
        price_prefix = p_price_prefix, 
        points = p_points, 
        points_prefix = p_points_prefix, 
        weight = p_weight, 
        weight_prefix = p_weight_prefix
    WHERE
        product_option_id = p_product_option_id 
    AND product_id = p_product_id 
    AND option_id = p_option_id 
    AND option_value_id = p_option_value_id;
ELSE
    INSERT INTO db_shoes.shoes_product_option_value (
        product_option_value_id, 
        product_option_id, 
        product_id, 
        option_id, 
        option_value_id, 
        quantity, 
        subtract, 
        price, 
        price_prefix, 
        points, 
        points_prefix, 
        weight, 
        weight_prefix)
    VALUES (
        p_product_option_value_id, 
        p_product_option_id, 
        p_product_id, 
        p_option_id, 
        p_option_value_id, 
        p_quantity, 
        p_subtract, 
        p_price, 
        p_price_prefix, 
        p_points, 
        p_points_prefix, 
        p_weight, 
        p_weight_prefix);
END IF;

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
INSERT INTO temp_product_option_value_extra_details (
    tmp_id,
    tmp_product_option_value_id,product_option_value_extra_details
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
WHERE
    povxd_product_option_value_id = p_product_option_value_id
AND povxd_product_option_id = p_product_option_id 
AND povxd_product_id = p_product_id 
AND povxd_option_id = p_option_id 
AND povxd_option_value_id = p_option_value_id;

IF EXISTS (SELECT * FROM temp_product_option_value_extra_details) THEN
    UPDATE db_settings.product_option_value_extra_details
    SET
        povxd_model = p_model,
        povxd_Model_id = p_Model_id,
        povxd_Barcode = p_Barcode,
        povxd_Product_code = p_Product_code, 
        povxd_sku = p_sku,
        povxd_upc = p_upc,
        povxd_ean = p_ean,
        povxd_jan = p_jan,
        povxd_isbn = p_isbn,
        povxd_mpn = p_mpn,
        povxd_location = p_location
    WHERE 
        povxd_product_option_value_id = p_product_option_value_id
    AND povxd_product_option_id = p_product_option_id 
    AND povxd_product_id = p_product_id 
    AND povxd_option_id = p_option_id 
    AND povxd_option_value_id = p_option_value_id;
ELSE
    INSERT INTO db_settings.product_option_value_extra_details (
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
        povxd_location)
    VALUES (
        p_product_option_value_id,
        p_product_option_id,
        p_product_id,
        p_option_id,
        p_option_value_id,
        p_model,
        p_Model_id,
        p_Barcode,
        p_Product_code, 
        p_sku,
        p_upc,
        p_ean,
        p_jan,
        p_isbn,
        p_mpn,
        p_location);
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of length class                 *
***********************************************************/
IF p_bIsOk THEN
    SELECT
        V.tmp_product_option_value_id As 'val_product_option_value_id',
        V.tmp_product_option_id As 'val_product_option_id',
        V.tmp_product_id As 'val_product_id',
        V.tmp_option_id As 'val_option_id',
        V.tmp_option_value_id As 'val_option_value_id',
        V.tmp_quantity As 'val_quantity',
        V.tmp_subtract As 'val_subtract',
        V.tmp_price As 'val_price',
        V.tmp_price_prefix As 'val_price_prefix',
        V.tmp_points As 'val_points',
        V.tmp_points_prefix As 'val_points_prefix',
        V.tmp_weight As 'val_weight',
        V.tmp_weight_prefix As 'val_weight_prefix',
        D.tmp_id As 'desc_id',
        D.tmp_product_option_value_id As 'desc_product_option_value_id',
        D.tmp_product_option_id As 'desc_product_option_id',
        D.tmp_product_id As 'desc_product_id',
        D.tmp_option_id As 'desc_option_id',
        D.tmp_option_value_id As 'desc_option_value_id',
        D.tmp_model As 'desc_model',
        D.tmp_Model_id As 'desc_Model_id',
        D.tmp_Barcode As 'desc_Barcode',
        D.tmp_Product_code As 'desc_Product_code', 
        D.tmp_sku As 'desc_sku',
        D.tmp_upc As 'desc_upc',
        D.tmp_ean As 'desc_ean',
        D.tmp_jan As 'desc_jan',
        D.tmp_isbn As 'desc_isbn',
        D.tmp_mpn As 'desc_mpn',
        D.tmp_location As 'desc_location'
    FROM temp_product_option_value As V
    INNER JOIN temp_product_option_value_extra_details As D
    ON
        V.tmp_product_option_value_id = D.tmp_product_option_value_id
    AND V.tmp_product_option_id = D.tmp_product_option_id
    AND V.tmp_product_id = D.tmp_product_id
    AND V.tmp_option_id = D.tmp_option_id
    AND V.tmp_option_value_id = D.tmp_option_value_id;
ELSE
    SELECT err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    FROM temp_errors;
END IF;

END// 

DELIMITER ;


