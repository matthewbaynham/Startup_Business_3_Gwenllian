USE db_analysis_20201203;

DROP VIEW IF EXISTS db_analysis_20201203.v_product_both_sorted;

CREATE VIEW db_analysis_20201203.v_product_both_sorted AS 
SELECT
    b.source,
    b.product_id,
    b.model,
    b.sku,
    b.upc,
    b.ean,
    b.jan,
    b.isbn,
    b.mpn,
    b.location,
    b.quantity,
    b.stock_status_id,
    b.image,
    b.manufacturer_id,
    b.shipping,
    b.price,
    b.points,
    b.tax_class_id,
    b.date_available,
    b.weight,
    b.weight_class_id,
    b.length,
    b.width,
    b.height,
    b.length_class_id,
    b.subtract,
    b.minimum,
    b.sort_order,
    b.status,
    b.viewed,
    b.date_added,
    b.date_modified 
FROM db_analysis_20201203.shoes_product_both As b 
ORDER BY    b.ean,
    b.source;

DROP VIEW IF EXISTS db_analysis_20201203.v_product_added_equals_update;

CREATE VIEW db_analysis_20201203.v_product_added_equals_update AS 
SELECT
    b.product_id,
    b.model,
    b.sku,
    b.upc,
    b.ean,
    b.jan,
    b.isbn,
    b.mpn,
    b.location,
    b.quantity,
    b.stock_status_id,
    b.image,
    b.manufacturer_id,
    b.shipping,
    b.price,
    b.points,
    b.tax_class_id,
    b.date_available,
    b.weight,
    b.weight_class_id,
    b.length,
    b.width,
    b.height,
    b.length_class_id,
    b.subtract,
    b.minimum,
    b.sort_order,
    b.status,
    b.viewed,
    b.date_added,
    b.date_modified 
FROM db_analysis_20201203.shoes_product_two As b 
WHERE b.date_added = b.date_modified 
ORDER BY 
    b.ean;









DROP VIEW IF EXISTS db_analysis_20201203.v_product_only_one;

CREATE VIEW db_analysis_20201203.v_product_only_one AS 
SELECT
    b.product_id,
    b.model,
    b.sku,
    b.upc,
    b.ean,
    b.jan,
    b.isbn,
    b.mpn,
    b.location,
    b.quantity,
    b.stock_status_id,
    b.image,
    b.manufacturer_id,
    b.shipping,
    b.price,
    b.points,
    b.tax_class_id,
    b.date_available,
    b.weight,
    b.weight_class_id,
    b.length,
    b.width,
    b.height,
    b.length_class_id,
    b.subtract,
    b.minimum,
    b.sort_order,
    b.status,
    b.viewed,
    b.date_added,
    b.date_modified 
FROM db_analysis_20201203.shoes_product_one As b 
LEFT JOIN db_analysis_20201203.shoes_product_two As t
ON b.product_id = t.product_id
WHERE t.product_id = NULL
ORDER BY    b.product_id;



DROP VIEW IF EXISTS db_analysis_20201203.v_product_only_two;

CREATE VIEW db_analysis_20201203.v_product_only_two AS 
SELECT
    b.product_id,
    b.model,
    b.sku,
    b.upc,
    b.ean,
    b.jan,
    b.isbn,
    b.mpn,
    b.location,
    b.quantity,
    b.stock_status_id,
    b.image,
    b.manufacturer_id,
    b.shipping,
    b.price,
    b.points,
    b.tax_class_id,
    b.date_available,
    b.weight,
    b.weight_class_id,
    b.length,
    b.width,
    b.height,
    b.length_class_id,
    b.subtract,
    b.minimum,
    b.sort_order,
    b.status,
    b.viewed,
    b.date_added,
    b.date_modified 
FROM db_analysis_20201203.shoes_product_two As b 
LEFT JOIN db_analysis_20201203.shoes_product_one As o
ON b.product_id = o.product_id
WHERE o.product_id = NULL
ORDER BY    b.product_id;


