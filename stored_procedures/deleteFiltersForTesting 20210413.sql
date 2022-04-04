DELETE FROM db_shoes.shoes_category_filter WHERE filter_id > 3;

DELETE FROM db_shoes.shoes_filter WHERE filter_id > 3;

DELETE FROM db_shoes.shoes_filter_description WHERE filter_id > 3;

DELETE FROM db_shoes.shoes_product_filter WHERE filter_id > 3;




REPAIR TABLE db_shoes.shoes_category_filter;

REPAIR TABLE db_shoes.shoes_filter;

REPAIR TABLE db_shoes.shoes_filter_description;

REPAIR TABLE db_shoes.shoes_product_filter;





