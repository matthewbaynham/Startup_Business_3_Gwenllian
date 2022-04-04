DROP TABLE IF EXISTS db_settings.Extra_Phases;

CREATE TABLE db_settings.Extra_Phases (
    ep_id INT AUTO_INCREMENT PRIMARY KEY,
    ep_language_id int, 
    ep_type varchar(1024),
    ep_key varchar(1024),
    ep_text varchar(1024));

INSERT INTO db_settings.Extra_Phases (
    ep_language_id, ep_type, ep_key, ep_text)
VALUES 
(   1, "links title", "size chart", "Size Chart"),
(   2, "links title", "size chart", "Größentabelle"),
(   1, "links title", "manufacturer info", "Manufacturer"),
(   2, "links title", "manufacturer info", "Der Hersteller");





