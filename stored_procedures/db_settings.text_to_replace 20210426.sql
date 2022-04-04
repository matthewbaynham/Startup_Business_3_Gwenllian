
DROP TABLE IF EXISTS db_settings.text_to_replace;

CREATE TABLE db_settings.text_to_replace (
    id INT AUTO_INCREMENT PRIMARY KEY,
    language_id INT,
    orig varchar(255) default "",
    new varchar(255) default "");

