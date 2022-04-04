/* create tables */

create database db_settings;

use db_settings;


DROP TABLE IF EXISTS set_supplier;

CREATE TABLE set_supplier (
sup_id INT AUTO_INCREMENT PRIMARY KEY,
sup_name VARCHAR(255) NOT NULL,
sup_version VARCHAR(255) not null default '1.0',
sup_filetype VARCHAR(255) NOT NULL default 'csv',
sup_has_header boolean not null  default true,
sup_prefix VARCHAR(255) NOT NULL
); 

insert into set_supplier (sup_name, sup_version, sup_filetype, sup_has_header, sup_prefix)
values("tuscany leather", '1.0', 'csv', true, 'tule'); 

SET @iSupplierID := last_insert_id();

DROP TABLE IF EXISTS  set_supplier_field;

CREATE TABLE set_supplier_field (
fld_id INT AUTO_INCREMENT PRIMARY KEY,
fld_supplier_id int, 
fld_name VARCHAR(255) NOT NULL,
fld_header_text VARCHAR(255) NOT NULL,
fld_mysql_name VARCHAR(255) NOT NULL,
fld_field_type VARCHAR(255) NOT NULL
); 

insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'parent_category', 'parent_category', 'parent_category', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'category', 'category', 'category', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'partscode', 'partscode', 'partscode', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'brand_name', 'brand_name', 'brand_name', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'ean', 'ean', 'ean', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'sku', 'sku', 'sku', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'quantity', 'quantity', 'quantity', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'estimated_arrival_date', 'estimated_arrival_date', 'estimated_arrival_date', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'phase_out', 'phase_out', 'phase_out', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'modelname', 'modelname', 'modelname', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'option', 'option', 'option', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'customization', 'customization', 'customization', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'customization_char_limit', 'customization_char_limit', 'customization_char_limit', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'description', 'description', 'description', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'unit_measure', 'unit_measure', 'unit_measure', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'unit_weight', 'unit_weight', 'unit_weight', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'item_length', 'item_length', 'item_length', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'item_height', 'item_height', 'item_height', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'item_width', 'item_width', 'item_width', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'item_weight', 'item_weight', 'item_weight', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'shipping_length', 'shipping_length', 'shipping_length', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'shipping_height', 'shipping_height', 'shipping_height', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'shipping_width', 'shipping_width', 'shipping_width', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'shipping_weight', 'shipping_weight', 'shipping_weight', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'currency', 'currency', 'currency', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'retailprice', 'retailprice', 'retailprice', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'retailspecialprice', 'retailspecialprice', 'retailspecialprice', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'retailexpiredate', 'retailexpiredate', 'retailexpiredate', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'resellerprice', 'resellerprice', 'resellerprice', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'resellerspecialprice', 'resellerspecialprice', 'resellerspecialprice', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'resellerexpiredate', 'resellerexpiredate', 'resellerexpiredate', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'publish_date', 'publish_date', 'publish_date', ''); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_1', 'image_1', 'image_1', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_2', 'image_2', 'image_2', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_3', 'image_3', 'image_3', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_4', 'image_4', 'image_4', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_5', 'image_5', 'image_5', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_6', 'image_6', 'image_6', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_7', 'image_7', 'image_7', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_8', 'image_8', 'image_8', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_9', 'image_9', 'image_9', 'image'); 
insert into set_supplier_field (fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iSupplierID, 'image_10', 'image_10', 'image_10', 'image'); 

























/*
get settings
*/








/*
call getSettingsUploadStock('fred'); 
call getSettingsUploadStock('tuscany leather');
*/

DROP PROCEDURE if exists getSettingsUploadStock;

DELIMITER //

CREATE PROCEDURE getSettingsUploadStock(IN p_supplier_name VARCHAR(255)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN 
DECLARE bIsOk boolean DEFAULT true;  

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_supplier (
tmp_id INT AUTO_INCREMENT PRIMARY KEY,
tmp_name VARCHAR(255) NOT NULL,
tmp_version VARCHAR(255) not null default '1.0',
tmp_filetype VARCHAR(255) NOT NULL default 'csv',
tmp_has_header boolean not null  default true,
tmp_prefix VARCHAR(255) NOT NULL
); 

CREATE TEMPORARY TABLE temp_supplier_field (
tmp_id INT AUTO_INCREMENT PRIMARY KEY,
tmp_supplier_id int, 
tmp_name VARCHAR(255) NOT NULL,
tmp_header_text VARCHAR(255) NOT NULL,
tmp_mysql_name VARCHAR(255) NOT NULL,
tmp_field_type VARCHAR(255) NOT NULL
); 


insert into temp_supplier (tmp_name, tmp_version, tmp_filetype, tmp_has_header, tmp_prefix) 
select sup_name, sup_version, sup_filetype, sup_has_header, sup_prefix 
from set_supplier 
where sup_name = p_supplier_name;

if not exists (select * from temp_supplier) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'Cant find supplier', concat('Cant find supplier ', p_supplier_name , ' in table set_supplier'), p_supplier_name);
    set bIsOk = false;
end if;

if bIsOk then
    insert into temp_supplier_field (tmp_supplier_id, tmp_name, tmp_header_text, tmp_mysql_name, tmp_field_type) 
    select fld_supplier_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type 
    from set_supplier_field 
    where fld_supplier_id in (select tmp_id from temp_supplier);

    if not exists (select * from temp_supplier) then
        insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('settings', 'Cant find supplier fields', concat('Cant find supplier fields ', p_supplier_name , ' in table set_supplier_field'), p_supplier_name);
        set bIsOk = false;
    end if;
end if;


select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
from temp_errors;

END// 

DELIMITER ;












DECLARE iToday  INT(8) DEFAULT 0;  
DECLARE iYesterday  INT(8) DEFAULT 0;  
DECLARE sToday  char(8) DEFAULT "        ";  
DECLARE sYesterday  char(8) DEFAULT "        ";  


set sToday = DATE_FORMAT(CURRENT_DATE(), "%Y%m%d");
set iToday = CONVERT( sToday , UNSIGNED );

set sYesterday = DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY), "%Y%m%d");
set iYesterday = CONVERT( sYesterday , UNSIGNED );



DELETE FROM db_misc.tbl_root_page_previous_pictures 
WHERE NOT (last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday);


CREATE TEMPORARY TABLE temp_old_product_id 
SELECT product_id 
FROM db_misc.tbl_root_page_previous_pictures 
WHERE last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday
ORDER BY last_displayed_timestamp DESC
LIMIT 5;

CREATE TEMPORARY TABLE temp_old_product_image_id 
SELECT product_image_id, product_id 
FROM db_misc.tbl_root_page_previous_pictures 
WHERE last_displayed_date_as_int = iToday or last_displayed_date_as_int = iYesterday
ORDER BY last_displayed_timestamp DESC
LIMIT 10;

DELETE FROM db_misc.tbl_root_page_previous_pictures 
WHERE NOT (last_displayed_date_as_int in (SELECT product_id FROM temp_old_product_id)
           or last_displayed_date_as_int in (SELECT product_image_id FROM temp_old_product_image_id));


/*
SELECT id, session_id, product_id, product_image_id, last_displayed_timestamp, last_displayed_date_as_int FROM tbl_root_page_previous_pictures WHERE 1
*/


SELECT I.image as Image_Path, 
       CONCAT('https://www.gwenllian-retail.com/shop/index.php?route=product/product&product_id=', P.product_id) as URL, 
       P.product_id as Product_id 
FROM db_shoes.shoes_product_image As I 
       INNER JOIN db_shoes.shoes_product As P 
       ON I.product_id = P.product_id 
WHERE I.product_id not in (SELECT product_id FROM temp_old_product_id) 
       AND I.product_image_id not in (SELECT product_image_id FROM temp_old_product_image_id)
ORDER BY RAND() 
LIMIT 1; 


INSERT INTO db_misc.tbl_root_page_previous_pictures ( session_id, product_id, product_image_id, last_displayed_date_as_int ) 
SELECT p_session_ID,  product_id, product_image_id, iToday FROM temp_old_product_image_id;

END// 

DELIMITER ;




