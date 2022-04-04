DROP TABLE IF EXISTS db_settings.Extra_Weblinks;

CREATE TABLE db_settings.Extra_Weblinks (
    ew_id INT AUTO_INCREMENT PRIMARY KEY,
    ew_language_id int, 
    ew_entity_id int, 
    ew_entity_type varchar(1024),
    ew_type varchar(1024),
    ew_text_prefix varchar(1024),
    ew_text varchar(1024),
    ew_text_suffix varchar(1024),
    ew_url varchar(1024),
    ew_sort_order int);

/*34	Dr Martens*/

INSERT INTO db_settings.Extra_Weblinks (
    ew_language_id, 
    ew_entity_id, 
    ew_entity_type,
    ew_type,
    ew_text_prefix,
    ew_text,
    ew_text_suffix,
    ew_url, 
    ew_sort_order)
VALUES 
(   1, 
    34, 
    "Manufacturer", 
    "Size Chart",
    "For information about the size please consult ",
    "Dr Martens Size Chart", 
    ".",
    "https://www.drmartens.com/us/en/shoe-size-guide",
    0),
(
    2, 
    34, 
    "Manufacturer", 
    "Size Chart",
    "Informationen zur Größe finden Sie in ",
    "der Größentabelle von Dr. Martens", 
    ".",
    "https://www.drmartens.com/de/de/shoe-size-guide",
    0);


INSERT INTO db_settings.Extra_Weblinks (
    ew_language_id, 
    ew_entity_id, 
    ew_entity_type,
    ew_type,
    ew_text_prefix,
    ew_text,
    ew_text_suffix,
    ew_url, 
    ew_sort_order)
VALUES 
(   1, 
    104, 
    "Manufacturer", 
    "Size Chart",
    "For information about the size please consult ",
    "Adidas Size Chart", 
    ".",
    "https://www.adidas.com/us/help/size_charts",
    0),
(
    2, 
    140, 
    "Manufacturer", 
    "Size Chart",
    "Informationen zur Größe finden Sie in ",
    "der Größentabelle von Adidas", 
    ".",
    "https://www.adidas.de/size-chart-size-shoes.html",
    0);





INSERT INTO db_settings.Extra_Weblinks (
    ew_language_id, 
    ew_entity_id, 
    ew_entity_type,
    ew_type,
    ew_text_prefix,
    ew_text,
    ew_text_suffix,
    ew_url, 
    ew_sort_order)
VALUES 
(   1, 
    104, 
    "Manufacturer", 
    "manufacturer info",
    "",
    "Adidas", 
    " is one of the top sports shoes manufacturers in the world.",
    "https://www.adidas.com/us",
    1),
(
    2, 
    140, 
    "Manufacturer", 
    "manufacturer info",
    "",
    "Adidas", 
    "ist einer der weltweit führenden Hersteller von Sportschuhen.",
    "https://www.adidas.de",
    1);

INSERT INTO db_settings.Extra_Weblinks (
    ew_language_id, 
    ew_entity_id, 
    ew_entity_type,
    ew_type,
    ew_text_prefix,
    ew_text,
    ew_text_suffix,
    ew_url, 
    ew_sort_order)
VALUES 
(   1, 
    104, 
    "Manufacturer", 
    "manufacturer info",
    "And was founded in july 1924 by ",
    "Adolf Dassler", 
    " in July 1924.",
    "https://en.wikipedia.org/wiki/Adolf_Dassler",
    2),
(
    2, 
    140, 
    "Manufacturer", 
    "manufacturer info",
    "Und wurde im Juli 1924 von ",
    "Adolf Dassler", 
    " im Juli 1924 gegründet.",
    "https://de.wikipedia.org/wiki/Adolf_Dassler",
    2);




















