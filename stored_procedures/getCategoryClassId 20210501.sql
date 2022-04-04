use db_settings;

DROP PROCEDURE if exists getCategoryClassId;

DELIMITER //

/*
	2 	model 	varchar(64) 	utf8_general_ci 		No 	None 			
	3 	sku 	varchar(64) 	utf8_general_ci 		No 	None 			
	4 	upc 	varchar(12) 	utf8_general_ci 		No 	None 			
	5 	ean 	varchar(14) 	utf8_general_ci 		No 	None 			

SET @p_category_text = "Shoes";
SET @p_language_id  = 1;
SET @p_parent_ID = -1;
SET @p_category_class_ID = 0;
SET @p_bIsOk = true;
SET @p_model = "";
SET @p_sku = "";
SET @p_upc = "";
SET @p_ean = "";
SET @p_generation = 1;

call  getCategoryClassId( @p_category_text , @p_language_id , @p_parent_ID , @p_category_class_ID, @p_bIsOk , @p_model , @p_sku , @p_upc , @p_ean , @p_generation );

SELECT @p_category_text ,  @p_language_id , @p_parent_ID , @p_category_class_ID , @p_bIsOk , @p_model , @p_sku , @p_upc , @p_ean , @p_generation = 1;


*/

CREATE PROCEDURE getCategoryClassId(IN p_category_text VARCHAR(255), IN p_language_id int, IN p_parent_ID int, OUT p_category_class_ID int, OUT p_bIsOk boolean, IN p_model VARCHAR(64), IN p_sku VARCHAR(64), IN p_upc VARCHAR(12), IN p_ean VARCHAR(14), IN p_generation INT)
BEGIN
DECLARE iSortOrder int;
DECLARE iOtherParentId int;
DECLARE iParentLevel int;

/*
p_generation = 1 if this is a parent category
p_generation = 0 if this is not a parent category
*/

SET p_bIsOk = true;

/************************************
*   Drop and recreate temp tables   *
************************************/
DROP TABLE IF EXISTS temp_errors;
DROP TABLE IF EXISTS temp_category;
DROP TABLE IF EXISTS temp_category_description;
DROP TABLE IF EXISTS temp_category_path;
DROP TABLE IF EXISTS temp_category_to_layout;
DROP TABLE IF EXISTS temp_product;
DROP TABLE IF EXISTS temp_product_to_category;

SET p_category_class_ID = -1;

CREATE TEMPORARY TABLE temp_errors(
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default ''
);

CREATE TEMPORARY TABLE temp_category (
    tmp_category_id int(11) NOT NULL,
    tmp_image varchar(255) DEFAULT NULL,
    tmp_parent_id int(11) NOT NULL DEFAULT '0',
    tmp_top tinyint(1) NOT NULL,
    tmp_column int(3) NOT NULL,
    tmp_sort_order int(3) NOT NULL DEFAULT '0',
    tmp_status tinyint(1) NOT NULL,
    tmp_date_added datetime NOT NULL,
    tmp_date_modified datetime NOT NULL
);

CREATE TEMPORARY TABLE temp_category_description (
    tmp_category_id int(11) NOT NULL,
    tmp_language_id int(11) NOT NULL,
    tmp_name varchar(255) NOT NULL,
    tmp_description text NOT NULL,
    tmp_meta_title varchar(255) NOT NULL,
    tmp_meta_description varchar(255) NOT NULL,
    tmp_meta_keyword varchar(255) NOT NULL
);

CREATE TEMPORARY TABLE temp_category_path (
    tmp_category_id int(11) NOT NULL,
    tmp_path_id int(11) NOT NULL,
    tmp_level int(11) NOT NULL
);

CREATE TEMPORARY TABLE temp_category_to_layout (
    tmp_category_id int(11) NOT NULL,
    tmp_store_id int(11) NOT NULL,
    tmp_layout_id int(11) NOT NULL
);

CREATE TEMPORARY TABLE temp_product (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int(11) NOT NULL,
    tmp_model varchar(64) NOT NULL,
    tmp_sku varchar(64),
    tmp_upc varchar(12),
    tmp_ean varchar(14)
);

CREATE TEMPORARY TABLE temp_product_to_category (
    tmp_ID INT AUTO_INCREMENT PRIMARY KEY,
    tmp_product_id int(11) NOT NULL,
    tmp_category_id int(11) NOT NULL
);

/************************
*   Get existing data   *
************************/
INSERT INTO temp_category_description (
    tmp_category_id,
    tmp_language_id,
    tmp_name,
    tmp_description,
    tmp_meta_title,
    tmp_meta_description,
    tmp_meta_keyword)
SELECT
    category_id,
    language_id,
    name,
    description,
    meta_title,
    meta_description,
    meta_keyword
FROM db_shoes.shoes_category_description
WHERE upper(trim(name)) = upper(trim(p_category_text))
AND language_id = p_language_id;

INSERT INTO temp_category (
    tmp_category_id,
    tmp_image,
    tmp_parent_id,
    tmp_top,
    tmp_column,
    tmp_sort_order,
    tmp_status,
    tmp_date_added,
    tmp_date_modified)
SELECT 
    C.category_id,
    C.image,
    C.parent_id,
    C.top,
    C.column,
    C.sort_order,
    C.status,
    C.date_added,
    C.date_modified
FROM db_shoes.shoes_category As C
WHERE C.category_id IN (SELECT tmp_category_id 
                        FROM temp_category_description);

INSERT INTO temp_category_path (
    tmp_category_id,
    tmp_path_id,
    tmp_level)
SELECT 
    P.category_id, 
    P.path_id, 
    P.level 
FROM db_shoes.shoes_category_path As P
WHERE P.category_id IN (SELECT tmp_category_id 
                        FROM temp_category_description);

/******************
*   Check stuff   * 
******************/

IF p_parent_ID = -1 THEN
    IF EXISTS (SELECT * FROM temp_category) THEN
        SET p_parent_ID = (SELECT MAX(tmp_parent_id) FROM temp_category);
    ELSE
        SET p_parent_ID = 0;
    END IF;
END IF;

SET p_category_class_ID = -1;

/*******************************
*   Category ID easy to find   *
*******************************/
IF EXISTS (SELECT * FROM temp_category) THEN
    SET p_category_class_ID = (SELECT MAX(tmp_category_id) FROM temp_category);
END IF;

/******************************************************************************************************************************
*  If we dont have existing category id then look for an existing product (in a different language) to find the category id   *
******************************************************************************************************************************/
IF p_category_class_ID = -1 THEN
    INSERT INTO temp_product (
        tmp_product_id,
        tmp_model,
        tmp_sku,
        tmp_upc,
        tmp_ean)
    SELECT 
        product_id,
        model,
        sku,
        upc,
        ean
    FROM db_shoes.shoes_product
    WHERE model = p_model
    AND sku = p_sku
    AND upc = p_upc
    and ean = p_ean;
    
    IF EXISTS (SELECT * FROM temp_product) THEN
        INSERT INTO temp_product_to_category (
            tmp_product_id,
            tmp_category_id)
        SELECT 
            product_id,
            category_id
        FROM db_shoes.shoes_product_to_category As pc
        INNER JOIN temp_product As p
        ON pc.product_id = p.tmp_product_id;

        IF EXISTS (SELECT * FROM temp_product_to_category) THEN
            SET p_category_class_ID = (SELECT MAX(tmp_category_id) FROM temp_product_to_category);
            
            IF p_generation > 0 THEN
                IF EXISTS (SELECT * FROM db_shoes.shoes_category WHERE category_id = p_category_class_ID) THEN
                    SET p_category_class_ID = (SELECT MAX(parent_id) FROM db_shoes.shoes_category WHERE category_id = p_category_class_ID);
                END IF;
            END IF;
        END IF;
    END IF;
END IF;

/**************************************************
*  really cant find a category id so create one   *
**************************************************/
IF p_category_class_ID = -1 THEN
    DELETE FROM temp_category;
    
    INSERT INTO temp_category (
        tmp_category_id,
        tmp_image,
        tmp_parent_id,
        tmp_top,
        tmp_column,
        tmp_sort_order,
        tmp_status,
        tmp_date_added,
        tmp_date_modified)
    SELECT 
        C.category_id,
        C.image,
        C.parent_id,
        C.top,
        C.column,
        C.sort_order,
        C.status,
        C.date_added,
        C.date_modified
    FROM db_shoes.shoes_category As C
    WHERE C.parent_id = p_parent_ID;

    SET iSortOrder = 0;
    
    IF EXISTS (SELECT * FROM temp_category) THEN
        SET iSortOrder = (SELECT MAX(tmp_sort_order) FROM temp_category);
    END IF;
    
    INSERT INTO db_shoes.shoes_category (
        `image`,
        `parent_id`,
        `top`,
        `column`,
        `sort_order`,
        `status`,
        `date_added`,
        `date_modified`)
    VALUES (
        "", /*image*/
        p_parent_ID, /*parent_id*/
        CASE WHEN p_parent_ID = 0 OR p_parent_ID = -1 THEN 1 ELSE 0 END, /*top*/
        0, /*column*/
        iSortOrder + 1, /*sort_order*/
        1, /*status*/
        CURRENT_TIMESTAMP(), /*date_added*/
        CURRENT_TIMESTAMP() /*date_modified*/
    );

    set p_category_class_ID = LAST_INSERT_ID();
END IF;
/*
We know the category id and the parent id

we don't know the level
we don't know if temp_category_path has a record for this category id
we don't know if temp_category_path has a record for this parent id

DON'T: add a grand parent id as a parameter, if grandparent id is -1 then it doesn't exist: this SP gets called twice by the java once first for the parent and second for the category.  So the first time this is called the parent id is the grand parent id
*/

/********************
*   Get the level   *
********************/
DELETE FROM temp_category_path;

INSERT INTO temp_category_path (
    tmp_category_id,
    tmp_path_id,
    tmp_level)
SELECT 
    P.category_id, 
    P.path_id, 
    P.`level` 
FROM db_shoes.shoes_category_path As P
WHERE P.category_id = p_parent_ID;

SET iParentLevel = -1;

IF EXISTS (SELECT * FROM temp_category_path) THEN
    SET iParentLevel = (SELECT MAX(tmp_level) FROM temp_category_path);
END IF;

/*************************************************************
*  Set parent ID and level in db_shoes.shoes_category_path   *
*************************************************************/
DELETE FROM db_shoes.shoes_category_path
WHERE category_id = p_category_class_ID
AND path_id IN (CASE WHEN p_parent_ID > 0 THEN p_parent_ID ELSE p_category_class_ID END, p_category_class_ID);

INSERT INTO db_shoes.shoes_category_path (category_id, path_id, `level`)
VALUES (p_category_class_ID, CASE WHEN p_parent_ID > 0 THEN p_parent_ID ELSE p_category_class_ID END, 0);

if p_parent_ID > 0 THEN
    INSERT INTO db_shoes.shoes_category_path (category_id, path_id, `level`)
    VALUES (p_category_class_ID, p_category_class_ID, 1);
END IF;

/**************************************************************************************************
*   Populate db_shoes.shoes_category_to_layout so that menus on website are populated correctly   *
**************************************************************************************************/
IF EXISTS (SELECT * FROM db_shoes.shoes_store) THEN
    INSERT INTO temp_category_to_layout (
        tmp_category_id,
        tmp_store_id,
        tmp_layout_id)
    SELECT   
        L.category_id,
        L.store_id,
        L.layout_id
    FROM db_shoes.shoes_category_to_layout As L
    WHERE L.category_id = p_category_class_ID;
    
    INSERT INTO db_shoes.shoes_category_to_layout (
        category_id,
        store_id,
        layout_id)
    SELECT 
        p_category_class_ID, 
        store_id, 
        0
    FROM db_shoes.shoes_store
    WHERE NOT store_id in (SELECT store_id FROM temp_category_to_layout);
ELSE
    INSERT INTO temp_category_to_layout (
        tmp_category_id,
        tmp_store_id,
        tmp_layout_id)
    SELECT   
        L.category_id,
        L.store_id,
        L.layout_id
    FROM db_shoes.shoes_category_to_layout As L
    WHERE L.category_id = p_category_class_ID;
    
    IF NOT EXISTS (SELECT * FROM temp_category_to_layout) THEN
        INSERT INTO db_shoes.shoes_category_to_layout (
            category_id,
            store_id,
            layout_id)
    VALUES (
        p_category_class_ID, 
        0, 
        0);
    END IF;
END IF;

/************************************************************************
*   Make sure the parent is correct whether the record is new or old.   *
************************************************************************/
UPDATE db_shoes.shoes_category
SET parent_id = p_parent_ID
WHERE category_id = p_category_class_ID;

/* Try this... Start */
DELETE FROM temp_category_description;

INSERT INTO temp_category_description (
    tmp_category_id, tmp_language_id, tmp_name, tmp_description, tmp_meta_title, tmp_meta_description, tmp_meta_keyword)
SELECT 
    category_id, language_id, "", "", "", "", ""
FROM db_shoes.shoes_category_description
WHERE
    category_id = p_category_class_ID
AND language_id = p_language_id;

/* Try this... End */

IF NOT EXISTS (SELECT * FROM temp_category_description) THEN
    INSERT INTO db_shoes.shoes_category_description (
        category_id,
        language_id,
        name,
        description,
        meta_title,
        meta_description,
        meta_keyword)
    VALUES (
        p_category_class_ID, /*category_id*/
        p_language_id, /*language_id*/
        trim(p_category_text), /*name*/
        trim(p_category_text), /*description*/
        trim(p_category_text), /*meta_title*/
        trim(p_category_text), /*meta_description*/
        trim(p_category_text)/*meta_keyword*/
    );
END IF;

/***********************************************************
*   If an error has been flagged return error temp table   *
*   or else return details of weight class                 *
***********************************************************/
if p_bIsOk then
    SELECT
        C.category_id As 'cat_category_id',
        C.image As 'cat_image',
        C.parent_id As 'cat_parent_id',
        C.top As 'cat_top',
        C.column As 'cat_column',
        C.sort_order As 'cat_sort_order',
        C.status As 'cat_status',
        C.date_added As 'cat_date_added',
        C.date_modified As 'cat_date_modified',
        D.category_id As 'disc_category_id',
        D.language_id As 'disc_language_id',
        D.name As 'disc_name',
        D.description As 'disc_description',
        D.meta_title As 'disc_meta_title',
        D.meta_description As 'disc_meta_description',
        D.meta_keyword As 'disc_meta_keyword'
    FROM db_shoes.shoes_category As C
    INNER JOIN db_shoes.shoes_category_description As D
    ON C.category_id = D.category_id 
    WHERE C.category_id = p_category_class_ID
    AND D.language_id = p_language_id;
else
    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
end if;

END// 

DELIMITER ;


