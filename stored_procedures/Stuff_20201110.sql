DROP TABLE IF EXISTS temp_images;
DROP TABLE IF EXISTS temp_images_sort_order;

CREATE TEMPORARY TABLE temp_images (
  tmpM_id int AUTO_INCREMENT PRIMARY KEY,
  tmpM_image varchar(255) DEFAULT NULL);

CREATE TEMPORARY TABLE temp_images_sort_order (
  tmpS_id int AUTO_INCREMENT PRIMARY KEY,
  tmpS_sort_order varchar(255) DEFAULT NULL );

INSERT INTO temp_images (tmpM_image) VALUES ("FRED");
INSERT INTO temp_images_sort_order (tmpS_sort_order) VALUES ("0");

INSERT INTO temp_images (tmpM_image) VALUES ("Bob");
INSERT INTO temp_images_sort_order (tmpS_sort_order) VALUES ("1");

INSERT INTO temp_images (tmpM_image) VALUES ("Maria");
INSERT INTO temp_images_sort_order (tmpS_sort_order) VALUES ("2");

INSERT INTO temp_images (tmpM_image) VALUES ("Mark");
INSERT INTO temp_images_sort_order (tmpS_sort_order) VALUES ("3");

SELECT M.tmpM_image, S.tmpS_sort_order
FROM temp_images As M INNER JOIN temp_images_sort_order As S
ON S.tmpS_id = M.tmpM_id;

SELECT M.tmpM_image, S.tmpS_sort_order
FROM temp_images As M, temp_images_sort_order As S
WHERE S.tmpS_id = M.tmpM_id;



