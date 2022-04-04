delimiter //

CREATE PROCEDURE getAllImagePaths ()
BEGIN
    SELECT I.image as Image_Path  
    FROM db_shoes.shoes_product_image As I
    INNER JOIN db_shoes.shoes_product As P
    ON I.product_id = P.product_id;

END//

delimiter ;
