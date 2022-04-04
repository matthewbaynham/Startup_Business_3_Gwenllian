USE db_settings;

DROP TABLE IF EXISTS db_settings.product_option_value_extra_details;
CREATE TABLE db_settings.product_option_value_extra_details (
    povxd_id INT AUTO_INCREMENT PRIMARY KEY,
    povxd_product_option_value_id int(11) NOT NULL,
    povxd_product_option_id int(11) NOT NULL,
    povxd_product_id int(11) NOT NULL,
    povxd_option_id int not null,
    povxd_option_value_id int not null,
    povxd_model varchar(64) NOT NULL,
    povxd_Model_id int,
    povxd_Barcode varchar(1000) not null,
    povxd_Product_code varchar(1000) not null, 
    povxd_sku varchar(64) NOT NULL,
    povxd_upc varchar(12) NOT NULL,
    povxd_ean varchar(14) NOT NULL,
    povxd_jan varchar(13) NOT NULL,
    povxd_isbn varchar(17) NOT NULL,
    povxd_mpn varchar(64) NOT NULL,
    povxd_location varchar(128) NOT NULL
);





/*
  product_id int(11) NOT NULL,
  model varchar(64) NOT NULL,
  sku varchar(64) NOT NULL,
  upc varchar(12) NOT NULL,
  ean varchar(14) NOT NULL,
  jan varchar(13) NOT NULL,
  isbn varchar(17) NOT NULL,
  mpn varchar(64) NOT NULL,
  location varchar(128) NOT NULL,
  quantity int(4) NOT NULL DEFAULT '0',
  stock_status_id int(11) NOT NULL,
  image varchar(255) DEFAULT NULL,
  manufacturer_id int(11) NOT NULL,
  shipping tinyint(1) NOT NULL DEFAULT '1',
  price decimal(15,4) NOT NULL DEFAULT '0.0000',
  points int(8) NOT NULL DEFAULT '0',
  tax_class_id int(11) NOT NULL,
  date_available date NOT NULL,
  weight decimal(15,8) NOT NULL DEFAULT '0.00000000',
  weight_class_id int(11) NOT NULL DEFAULT '0',
  length decimal(15,8) NOT NULL DEFAULT '0.00000000',
  width decimal(15,8) NOT NULL DEFAULT '0.00000000',
  height decimal(15,8) NOT NULL DEFAULT '0.00000000',
  length_class_id int(11) NOT NULL DEFAULT '0',
  subtract tinyint(1) NOT NULL DEFAULT '1',
  minimum int(11) NOT NULL DEFAULT '1',
  sort_order int(11) NOT NULL DEFAULT '0',
  status tinyint(1) NOT NULL DEFAULT '0',
  viewed int(5) NOT NULL DEFAULT '0',
  date_added datetime NOT NULL,
  date_modified datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
*/





/*
DROP TABLE IF EXISTS `shoes_product`;
CREATE TABLE `shoes_product` (
  `product_id` int(11) NOT NULL,
  `model` varchar(64) NOT NULL,
  `sku` varchar(64) NOT NULL,
  `upc` varchar(12) NOT NULL,
  `ean` varchar(14) NOT NULL,
  `jan` varchar(13) NOT NULL,
  `isbn` varchar(17) NOT NULL,
  `mpn` varchar(64) NOT NULL,
  `location` varchar(128) NOT NULL,
  `quantity` int(4) NOT NULL DEFAULT '0',
*/



/*
DROP TABLE IF EXISTS `shoes_option_value`;
CREATE TABLE `shoes_option_value` (
  `option_value_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(3) NOT NULL
);

INSERT INTO `shoes_option_value` (`option_value_id`, `option_id`, `image`, `sort_order`) VALUES
(43, 1, '', 3),
(32, 1, '', 1),
(45, 2, '', 4),
(44, 2, '', 3),
(42, 5, '', 4),
(41, 5, '', 3),
(39, 5, '', 1),
(40, 5, '', 2),
(31, 1, '', 2),
(23, 2, '', 1),
(24, 2, '', 2),
(46, 11, '', 1),
(47, 11, '', 2),
(48, 11, '', 3);
*/

/*
DROP TABLE IF EXISTS `shoes_option_value_description`;
CREATE TABLE `shoes_option_value_description` (
  `option_value_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL
);

INSERT INTO `shoes_option_value_description` (`option_value_id`, `language_id`, `option_id`, `name`) VALUES
(43, 1, 1, 'Large'),
(32, 1, 1, 'Small'),
(45, 1, 2, 'Checkbox 4'),
(44, 1, 2, 'Checkbox 3'),
(31, 1, 1, 'Medium'),
(42, 1, 5, 'Yellow'),
(41, 1, 5, 'Green'),
(39, 1, 5, 'Red'),
(40, 1, 5, 'Blue'),
(23, 1, 2, 'Checkbox 1'),
(24, 1, 2, 'Checkbox 2'),
(48, 1, 11, 'Large'),
(47, 1, 11, 'Medium'),
(46, 1, 11, 'Small');
*/

