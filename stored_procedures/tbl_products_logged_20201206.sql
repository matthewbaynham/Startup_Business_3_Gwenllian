use db_settings;

DROP TABLE IF EXISTS tbl_products_logged;

CREATE TABLE tbl_products_logged (
    pl_id INT AUTO_INCREMENT PRIMARY KEY,
    pl_upload_type_id INT NOT NULL,
    pl_product_id INT NOT NULL);

