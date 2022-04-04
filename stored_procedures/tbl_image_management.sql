use db_settings;

DROP TABLE IF EXISTS tbl_image_management;

CREATE TABLE tbl_image_management (
    im_id INT AUTO_INCREMENT PRIMARY KEY,
    im_upload_type_id INT NOT NULL,
    im_url VARCHAR(4000) NOT NULL default '', 
    im_fullpath VARCHAR(4000) NOT NULL default '');

