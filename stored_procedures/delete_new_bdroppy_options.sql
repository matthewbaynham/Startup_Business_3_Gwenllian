
DELETE FROM db_shoes.shoes_product_option_value WHERE product_option_value_id > 20;

DELETE FROM db_shoes.shoes_product_option WHERE product_option_id > 227;

DELETE FROM db_shoes.shoes_option_value_description WHERE option_value_id > 68;

DELETE FROM db_shoes.shoes_option_value WHERE option_value_id > 68;


REPAIR TABLE db_shoes.shoes_product_option_value;

REPAIR TABLE db_shoes.shoes_product_option;

REPAIR TABLE db_shoes.shoes_option_value_description;

REPAIR TABLE db_shoes.shoes_option_value;




DELETE FROM db_shoes.shoes_product_description WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_image WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_option WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_option_value WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_related WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_to_category WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_to_layout WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_shoes.shoes_product_to_store WHERE product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

REPAIR TABLE db_shoes.shoes_product_description;

REPAIR TABLE db_shoes.shoes_product_image;

REPAIR TABLE db_shoes.shoes_product_option;

REPAIR TABLE db_shoes.shoes_product_option_value;

REPAIR TABLE db_shoes.shoes_product_related;

REPAIR TABLE db_shoes.shoes_product_to_category;

REPAIR TABLE db_shoes.shoes_product_to_layout;

REPAIR TABLE db_shoes.shoes_product_to_store;


DELETE FROM db_settings.product_option_value_extra_details WHERE povxd_product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

DELETE FROM db_settings.tbl_products_logged WHERE pl_product_id in (SELECT product_id FROM db_shoes.shoes_product WHERE manufacturer_id > 11);

REPAIR TABLE db_settings.product_option_value_extra_details;

REPAIR TABLE db_settings.tbl_products_logged;



DELETE FROM db_shoes.shoes_product WHERE manufacturer_id > 11;

REPAIR TABLE db_shoes.shoes_product;




