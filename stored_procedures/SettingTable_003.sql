/*
call getSettingsUploadStock("tuscany leather csv ver 1.0")
*/

/********************
*   create tables   *
********************/

/*create database db_settings;*/

use db_settings;

DROP TABLE IF EXISTS set_upload_type;

CREATE TABLE set_upload_type (
    upl_id INT AUTO_INCREMENT PRIMARY KEY,
    upl_name VARCHAR(255) NOT NULL default '', 
    upl_shortName VARCHAR(255) NOT NULL default '', 
    upl_version VARCHAR(255) not null default '1.0',
    upl_filetype VARCHAR(255) NOT NULL default 'csv',
    upl_has_header boolean not null  default true,
    upl_prefix VARCHAR(255) NOT NULL default '',
    upl_delimit VARCHAR(255) NOT NULL default '');

insert into set_upload_type (upl_name, upl_shortName, upl_version, upl_filetype, upl_has_header, upl_prefix, upl_delimit)
values('tuscany leather csv ver 1.0', 'tuscany', '1.0', 'csv', true, 'tule', ';'); 

SET @iUploadTypeID := last_insert_id();

DROP TABLE IF EXISTS  set_upload_type_field;

CREATE TABLE set_upload_type_field (
    fld_id INT AUTO_INCREMENT PRIMARY KEY,
    fld_upload_type_id int, 
    fld_name VARCHAR(255) NOT NULL,
    fld_header_text VARCHAR(255) NOT NULL,
    fld_mysql_name VARCHAR(255) NOT NULL,
    fld_field_type VARCHAR(255) NOT NULL
); 
/*
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'parent_category', 'parent_category', 'parent_category', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'category', 'category', 'category', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'partscode', 'partscode', 'partscode', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'brand_name', 'brand_name', 'brand_name', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'ean', 'ean', 'ean', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'sku', 'sku', 'sku', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'quantity', 'quantity', 'quantity', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'estimated_arrival_date', 'estimated_arrival_date', 'estimated_arrival_date', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'phase_out', 'phase_out', 'phase_out', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'modelname', 'modelname', 'modelname', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'option', 'option', 'option', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'customization', 'customization', 'customization', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'customization_char_limit', 'customization_char_limit', 'customization_char_limit', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'description', 'description', 'description', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'unit_measure', 'unit_measure', 'unit_measure', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'unit_weight', 'unit_weight', 'unit_weight', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'item_length', 'item_length', 'item_length', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'item_height', 'item_height', 'item_height', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'item_width', 'item_width', 'item_width', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'item_weight', 'item_weight', 'item_weight', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'shipping_length', 'shipping_length', 'shipping_length', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'shipping_height', 'shipping_height', 'shipping_height', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'shipping_width', 'shipping_width', 'shipping_width', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'shipping_weight', 'shipping_weight', 'shipping_weight', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'currency', 'currency', 'currency', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'retailprice', 'retailprice', 'retailprice', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'retailspecialprice', 'retailspecialprice', 'retailspecialprice', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'retailexpiredate', 'retailexpiredate', 'retailexpiredate', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'resellerprice', 'resellerprice', 'resellerprice', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'resellerspecialprice', 'resellerspecialprice', 'resellerspecialprice', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'resellerexpiredate', 'resellerexpiredate', 'resellerexpiredate', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'publish_date', 'publish_date', 'publish_date', ''); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_1', 'image_1', 'image_1', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_2', 'image_2', 'image_2', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_3', 'image_3', 'image_3', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_4', 'image_4', 'image_4', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_5', 'image_5', 'image_5', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_6', 'image_6', 'image_6', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_7', 'image_7', 'image_7', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_8', 'image_8', 'image_8', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_9', 'image_9', 'image_9', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'image_10', 'image_10', 'image_10', 'image'); 
*/









insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_model', 'p_prd_model', 'p_prd_model', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_sku', 'p_prd_sku', 'p_prd_sku', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_upc', 'p_prd_upc', 'p_prd_upc', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_ean', 'p_prd_ean', 'p_prd_ean', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_jan', 'p_prd_jan', 'p_prd_jan', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_isbn', 'p_prd_isbn', 'p_prd_isbn', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_mpn', 'p_prd_mpn', 'p_prd_mpn', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_location', 'p_prd_location', 'p_prd_location', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_quantity', 'p_prd_quantity', 'p_prd_quantity', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_stock_status_id', 'p_prd_stock_status_id', 'p_prd_stock_status_id', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_image', 'p_prd_image', 'p_prd_image', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_manufacturer_id', 'p_prd_manufacturer_id', 'p_prd_manufacturer_id', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_shipping', 'p_prd_shipping', 'p_prd_shipping', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_price', 'p_prd_price', 'p_prd_price', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_points', 'p_prd_points', 'p_prd_points', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_tax_class_id', 'p_prd_tax_class_id', 'p_prd_tax_class_id', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_date_available', 'p_prd_date_available', 'p_prd_date_available', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_weight', 'p_prd_weight', 'p_prd_weight', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_weight_class_id', 'p_prd_weight_class_id', 'p_prd_weight_class_id', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_length', 'p_prd_length', 'p_prd_length', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_width', 'p_prd_width', 'p_prd_width', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_height', 'p_prd_height', 'p_prd_height', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_length_class_id', 'p_prd_length_class_id', 'p_prd_length_class_id', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_subtract', 'p_prd_subtract', 'p_prd_subtract', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_minimum', 'p_prd_minimum', 'p_prd_minimum', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_sort_order', 'p_prd_sort_order', 'p_prd_sort_order', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_prd_status', 'p_prd_status', 'p_prd_status', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_name', 'p_desc_name', 'p_desc_name', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_description', 'p_desc_description', 'p_desc_description', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_tag', 'p_desc_tag', 'p_desc_tag', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_meta_title', 'p_desc_meta_title', 'p_desc_meta_title', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_meta_description', 'p_desc_meta_description', 'p_desc_meta_description', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_desc_meta_keyword', 'p_desc_meta_keyword', 'p_desc_meta_keyword', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_Concat_image', 'p_Concat_image', 'p_Concat_image', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_Concat_image_sort_order', 'p_Concat_image_sort_order', 'p_Concat_image_sort_order', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_flag_product', 'p_flag_product', 'p_flag_product', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_flag_description', 'p_flag_description', 'p_flag_description', 'image'); 
insert into set_upload_type_field (fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type) values (@iUploadTypeID, 'p_flag_image', 'p_flag_image', 'p_flag_image', 'image'); 




/*

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
IN p_flag_product int,
IN p_flag_description int,
IN p_flag_images int


*/



















/*****************************************************
*   create stored procedure getSettingsUploadStock   *
*****************************************************/








/*
CREATE PROCEDURE getSettingsUploadStock(IN p_supplier_name VARCHAR(255)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN 

call getSettingsUploadStock('fred'); 
call getSettingsUploadStock('tuscany leather');
call getSettingsUploadStock('tuscany leather csv ver 1.0');
*/




/*
SET @pName='fred'; 

CALL getSettingsUploadStock_uploadTypeID(@pName, @pUploadTypeID, @pIsOK_Name); 

SELECT @pUploadTypeID AS `p_upload_type_ID`, @pIsOK_Name AS `p_bIsOk (Name)`; 

CALL getSettingsUploadStock_uploadField(@pUploadTypeID, @pIsOK_Fields); 

SELECT @pUploadTypeID AS `p_upload_type_ID`, @pIsOK_Name AS `p_bIsOk (Name)`, @pIsOK_Fields AS `p_bIsOk (Fields)`;
*/







DROP PROCEDURE if exists getSettingsUploadStock_uploadTypeID;

DELIMITER //

CREATE PROCEDURE getSettingsUploadStock_uploadTypeID(IN p_upload_type_name VARCHAR(255), OUT p_upload_type_ID int, OUT p_bIsOk boolean)
BEGIN 

set p_bIsOk = true;
set p_upload_type_ID = -1;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_upload_type;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_upload_type (
    tmp_id INT,
    tmp_name VARCHAR(255) NOT NULL default '',
    tmp_shortName VARCHAR(255) NOT NULL default '',
    tmp_version VARCHAR(255) not null default '1.0',
    tmp_filetype VARCHAR(255) NOT NULL default 'csv',
    tmp_has_header boolean not null  default true,
    tmp_prefix VARCHAR(255) NOT NULL default '', 
    tmp_delimit VARCHAR(255) NOT NULL default '');


/*************************************
*   Load file type into temp table   *
*************************************/
insert into temp_upload_type (tmp_id, tmp_name, tmp_shortName, tmp_version, tmp_filetype, tmp_has_header, tmp_prefix, tmp_delimit) 
select upl_id, upl_name, upl_shortName, upl_version, upl_filetype, upl_has_header, upl_prefix, upl_delimit 
from set_upload_type 
where TRIM(UPPER(upl_name)) = TRIM(UPPER(p_upload_type_name));

/*****************************************************************
*   Check temp table is populated,                               *
*   if not write an error in error temp table and flag an error  *
*****************************************************************/
if not exists (select * from temp_upload_type) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'Cant find upload type ', concat('Cant find supplier ', p_upload_type_name , ' in table set_upload_type'), p_upload_type_name);
    set p_bIsOk = false;
end if;

/************************************************
*   Check we don't have more than one result    *
*   There should be only one upload file type   *
************************************************/
if p_bIsOk then
    if (select count(*) from temp_upload_type) > 1 then
        insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('settings', 'More than one upload type ', concat('Cant find supplier ', p_upload_type_name , ' in table set_upload_type matches criteria'), p_upload_type_name);
        set p_bIsOk = false;
    end if;
end if;

/********************************************
*   Set upload file type ID out parameter   *
********************************************/
if p_bIsOk then
    set p_upload_type_ID = (select max(tmp_id) from temp_upload_type);
end if;

/*
*   If an error has been flagged return error temp table   *
*   or else return details of upload file                  *
*/
if p_bIsOk then
    select tmp_id, tmp_name, tmp_shortName, tmp_version, tmp_filetype, tmp_has_header, tmp_prefix, tmp_delimit 
    from temp_upload_type;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;



DROP PROCEDURE if exists getSettingsUploadStock_uploadField;

DELIMITER //

CREATE PROCEDURE getSettingsUploadStock_uploadField(IN p_upload_type_ID int, OUT p_bIsOk boolean )
BEGIN 

set p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_upload_type_field;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_upload_type_field (
    tmp_id INT AUTO_INCREMENT PRIMARY KEY,
    tmp_supplier_id int, 
    tmp_name VARCHAR(255) NOT NULL,
    tmp_header_text VARCHAR(255) NOT NULL,
    tmp_mysql_name VARCHAR(255) NOT NULL,
    tmp_field_type VARCHAR(255) NOT NULL
);

/**********************
*   Check parameter   *
**********************/
if p_upload_type_ID IS Null then 
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'parameter Null', 'parameter p_upload_type_ID is null' , '');
    set p_bIsOk = false;
else
    if p_upload_type_ID < 0 then 
        insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
        values ('settings', 'parameter wrong', 'parameter p_upload_type_ID less than zero' , CAST(p_upload_type_ID AS CHAR));
        set p_bIsOk = false;
    end if;
end if;

/***************************************
*   Load fields data into temp table   *
***************************************/
if p_bIsOk then
    insert into temp_upload_type_field (tmp_supplier_id, tmp_name, tmp_header_text, tmp_mysql_name, tmp_field_type) 
    select fld_upload_type_id, fld_name, fld_header_text, fld_mysql_name, fld_field_type 
    from set_upload_type_field 
    where fld_upload_type_id = p_upload_type_ID;
end if;

/**************************
*   Check if temp table   *
**************************/
if not exists (select * from temp_upload_type_field) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    values ('settings', 'Can''t find data', concat('Cant find upload id ', CAST(p_upload_type_ID AS CHAR) , ' in table set_upload_type_field'), CAST(p_upload_type_ID AS CHAR));
    set p_bIsOk = false;
end if;

if exists (select tmp_name from temp_upload_type_field group by tmp_name having count(*) > 1) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    select 'settings', 'Duplicate values', concat('value in fld_name repeats ', tmp_name), tmp_name  
    from temp_upload_type_field 
    group by tmp_name 
    having count(*) > 1;
    set p_bIsOk = false;
end if;

if exists (select tmp_header_text from temp_upload_type_field group by tmp_header_text having count(*) > 1) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    select 'settings', 'Duplicate values', concat('value in fld_header_text repeats ', tmp_header_text), tmp_header_text  
    from temp_upload_type_field 
    group by tmp_header_text 
    having count(*) > 1;
    set p_bIsOk = false;
end if;


if exists (select tmp_mysql_name from temp_upload_type_field group by tmp_mysql_name having count(*) > 1) then
    insert into temp_errors (err_Category, err_Name, err_Long_Description, err_Values) 
    select 'settings', 'Duplicate values', concat('value in fld_mysql_name repeats ', tmp_mysql_name), tmp_mysql_name  
    from temp_upload_type_field 
    group by tmp_mysql_name 
    having count(*) > 1;
    set p_bIsOk = false;
end if;

/******************************************
*   if error flagged return error table   *
*   else return temp of all fields        *
******************************************/
if p_bIsOk then
    select tmp_id, tmp_supplier_id, tmp_name, tmp_header_text, tmp_mysql_name, tmp_field_type
    from temp_upload_type_field;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


