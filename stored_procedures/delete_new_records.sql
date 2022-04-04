/*
reset the backend by deleting all 
*/




DELETE FROM db_settings.tbl_image_management;

DELETE FROM db_settings.tbl_products_logged;

DELETE FROM db_shoes.shoes_attribute WHERE attribute_id > 11 OR  attribute_group_id > 6;

DELETE FROM db_shoes.shoes_attribute_description WHERE attribute_id > 11;

DELETE FROM db_shoes.shoes_attribute_group WHERE attribute_group_id > 6;

DELETE FROM db_shoes.shoes_attribute_group_description WHERE attribute_group_id > 6;

DELETE FROM db_shoes.shoes_category_description WHERE category_id > 58;

DELETE FROM db_shoes.shoes_category WHERE category_id > 58 OR parent_id > 52;

DELETE FROM db_shoes.shoes_category_to_store WHERE category_id > 58;

DELETE FROM db_shoes.shoes_category_path WHERE category_id > 58;

DELETE FROM db_shoes.shoes_category_to_layout WHERE category_id > 58;

DELETE FROM db_shoes.shoes_option_value_description WHERE option_value_id > 48 OR option_id > 11;

DELETE FROM db_shoes.shoes_option_description where option_id > 12;

DELETE FROM db_shoes.shoes_option_value WHERE option_value_id > 48 OR option_id > 11;

DELETE FROM db_shoes.shoes_option WHERE option_id > 12;

DELETE FROM db_shoes.shoes_product_attribute WHERE product_id > 47 OR attribute_id > 4;

DELETE FROM db_shoes.shoes_product_description WHERE product_id > 49;

DELETE FROM db_shoes.shoes_product_image WHERE product_image_id > 2351 OR product_id > 49;

DELETE FROM db_shoes.shoes_product_option WHERE product_option_id > 226 OR product_id > 47 OR option_id > 12;

DELETE FROM db_shoes.shoes_product_option_value WHERE product_option_value_id > 16 OR product_option_id > 226 OR product_id > 42 OR option_id > 11 OR option_value_id > 48;

DELETE FROM db_shoes.shoes_product_to_category WHERE product_id > 49 OR category_id > 57;

DELETE FROM db_shoes.shoes_product WHERE product_id > 49;




REPAIR TABLE db_settings.tbl_image_management;

REPAIR TABLE db_settings.tbl_products_logged;

REPAIR TABLE db_shoes.shoes_attribute;

REPAIR TABLE db_shoes.shoes_attribute_description;

REPAIR TABLE db_shoes.shoes_attribute_group;

REPAIR TABLE db_shoes.shoes_attribute_group_description;

REPAIR TABLE db_shoes.shoes_category_description;

REPAIR TABLE db_shoes.shoes_category;

REPAIR TABLE db_shoes.shoes_category_to_store;

REPAIR TABLE db_shoes.shoes_category_path;

REPAIR TABLE db_shoes.shoes_category_to_layout;

REPAIR TABLE db_shoes.shoes_option_value_description;

REPAIR TABLE db_shoes.shoes_option_description;

REPAIR TABLE db_shoes.shoes_option_value;

REPAIR TABLE db_shoes.shoes_option;

REPAIR TABLE db_shoes.shoes_product_attribute;

REPAIR TABLE db_shoes.shoes_product_description;

REPAIR TABLE db_shoes.shoes_product_image;

REPAIR TABLE db_shoes.shoes_product_option;

REPAIR TABLE db_shoes.shoes_product_option_value;

REPAIR TABLE db_shoes.shoes_product_to_category;

REPAIR TABLE db_shoes.shoes_product;


