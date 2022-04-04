SELECT P.product_id, P.model, P.sku, P.upc, P.ean, P.jan, P.isbn, P.mpn, P.location, P.quantity, P.stock_status_id, P.image, P.manufacturer_id, P.shipping, P.price, P.points, P.tax_class_id, P.date_available, P.weight, P.weight_class_id, P.length, P.width, P.height, P.length_class_id, P.subtract, P.minimum, P.sort_order, P.status, P.viewed, P.date_added, P.date_modified 
FROM db_shoes.shoes_product As P





SELECT S.product_special_id, S.product_id, S.customer_group_id, S.priority, S.price, S.date_start, S.date_end 
FROM db_shoes.shoes_product_special As S





SELECT P.product_id, P.model, P.sku, P.upc, P.ean, P.jan, P.isbn, P.mpn, P.location, P.quantity, P.stock_status_id, P.image, P.manufacturer_id, P.shipping, P.price, Sub.count_product_special_id, Sub.sum_special_price, P.points, P.tax_class_id, P.date_available, P.weight, P.weight_class_id, P.length, P.width, P.height, P.length_class_id, P.subtract, P.minimum, P.sort_order, P.status, P.viewed, P.date_added, P.date_modified 
FROM db_shoes.shoes_product As P
INNER JOIN (SELECT Count(S.product_special_id) As count_product_special_id, S.product_id, sum(S.price) As sum_special_price
            FROM db_shoes.shoes_product_special As S
            WHERE curdate() between date_start and date_end
            GROUP BY S.product_id) As Sub
ON P.product_id = Sub.product_id
WHERE P.status = 1;





