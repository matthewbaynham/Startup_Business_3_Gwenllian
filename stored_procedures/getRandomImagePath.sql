delimiter //

CREATE PROCEDURE getRandomImagePath ()
BEGIN
    SELECT I.image as Image_Path  
    FROM db_shoes.shoes_product_image As I
    INNER JOIN db_shoes.shoes_product As P
    ON I.product_id = P.product_id
    ORDER BY RAND()
    LIMIT 1;

END//

delimiter ;
