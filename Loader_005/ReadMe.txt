/**************************************************************************************
*                                                                                     *
*   *******************************************************************************   *
*   *   Read the README.md for a useful readme.                                   *   *
*   *                                                                             *   *
*   *   This readme was just a few motes for me personally as I developed this.   *   *
*   *                                                                             *   *
*   *   This file is mostly lines of code that I might just have to type in       *   * 
*   *   multiple times.                                                           *   *
*   *******************************************************************************   *
*                                                                                     *
**************************************************************************************/


cd /home/bob/java
cd /home/matthew/java/Loader_005








javac com/gwenllian/loader/DataStructures.java
javac com/gwenllian/loader/ClsMisc.java
javac com/gwenllian/loader/ClsRobotsTxt.java
javac com/gwenllian/loader/ClsSitemapXml.java
javac com/gwenllian/loader/ClsManageHomePage.java
javac com/gwenllian/loader/ClsDataCorrection.java
javac com/gwenllian/loader/ClsGetId.java
javac com/gwenllian/loader/ClsFilterClass.java
javac com/gwenllian/loader/ClsWeightClassId.java
javac com/gwenllian/loader/ClsLengthClassId.java
javac com/gwenllian/loader/ClsOptionId.java
javac com/gwenllian/loader/ClsOptionValue.java
javac com/gwenllian/loader/ClsStockStatus.java
javac com/gwenllian/loader/ClsManufacturerId.java
javac com/gwenllian/loader/ClsCategoryClassId.java
javac com/gwenllian/loader/ClsTaxClass.java
javac com/gwenllian/loader/ClsAttributeId.java
javac com/gwenllian/loader/ClsSettings.java
javac com/gwenllian/loader/ClsTestInsertProduct.java
javac com/gwenllian/loader/ClsImageManagement.java
javac com/gwenllian/loader/ClsExtraWebLinks.java
javac com/gwenllian/loader/ClsMaintainRelatedProductPartscode.java
javac com/gwenllian/loader/ClsProgressReport.java
javac com/gwenllian/loader/ClsProcessTuscany.java
javac com/gwenllian/loader/ClsProcessBDroppy.java
javac com/gwenllian/loader/Main.java





/* Test stuff */


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "data correction - short" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210501 en.csv" "/home/matthew/Test_Logs/" ""




/**********************
*                     *
*   ***************   *
*   *   BDroppy   *   *
*   ***************   *
*                     *
**********************/

/*   sitemap.xml   */

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "sitemap" "English" "" "" "catalog" "/home/matthew/sitemap.xml" "/home/matthew/Test_Logs/" "/home/matthew/Robots.txt"

/*   Robots.txt   */

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "robots" "English" "" "" "catalog" "" "/home/matthew/Test_Logs/" ""





/* Big test file */

/*   20210609   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210609 en.csv" "/home/matthew/Test_Logs/" ""


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210609 de.csv" "/home/matthew/Test_Logs/" ""


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "sitemap" "English" "" "" "catalog" "/home/matthew/sitemap.xml" "/home/matthew/Test_Logs/" "/home/matthew/Robots.txt"











/*   20210604   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210604 en.csv" "/home/matthew/Test_Logs/" ""


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210604 de.csv" "/home/matthew/Test_Logs/" ""


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "sitemap" "English" "" "" "catalog" "/home/matthew/sitemap.xml" "/home/matthew/Test_Logs/" "/home/matthew/Robots.txt"










/*   20210507   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210507 en.csv" "/home/matthew/Test_Logs/" ""


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210507 de.csv" "/home/matthew/Test_Logs/" ""


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "sitemap" "English" "" "" "catalog" "/home/matthew/sitemap.xml" "/home/matthew/Test_Logs/" "/home/matthew/Robots.txt"









/*   20210504   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210504 en.csv" "/home/matthew/Test_Logs/" ""


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210504 de.csv" "/home/matthew/Test_Logs/" ""








/*   20210501   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210501 en.csv" "/home/matthew/Test_Logs/" ""


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210501 de.csv" "/home/matthew/Test_Logs/" ""








/*   20210430   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210430 en.csv" "/home/matthew/Test_Logs/"


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210430 de.csv" "/home/matthew/Test_Logs/"








/*   20210425   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210425 en.csv" "/home/matthew/Test_Logs/"


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210425 de.csv" "/home/matthew/Test_Logs/"








/*   20210423   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210423 en.csv" "/home/matthew/Test_Logs/"


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210423 de.csv" "/home/matthew/Test_Logs/"








/*   20210421   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210421 en.csv" "/home/matthew/Test_Logs/"


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210421 de.csv" "/home/matthew/Test_Logs/"







/*   20210413   */

cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210413 en.csv" "/home/matthew/Test_Logs/"


cd /home/matthew/java/Loader_005

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210413 de.csv" "/home/matthew/Test_Logs/"






/*   20210401   */


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210401 en.csv" "/home/matthew/Test_Logs/"



java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210401 de.csv" "/home/matthew/Test_Logs/"






/*   20210219   */


java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210219 de Taschen.csv" "/home/matthew/Test_Logs/"



java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/Downloads/bdroppy 20210219 de Taschen.csv" "/home/matthew/Test_Logs/"






java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/bdroppy/file(1).csv" "/home/matthew/Test_Logs/"



/* Adidas data */

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/bdroppy/file_(28).csv" "/home/matthew/Test_Logs/"


/* bags data */

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "bdroppy csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/bdroppy/file_(29).csv" "/home/matthew/Test_Logs/"











/******************************
*                             *
*   ***********************   *
*   *   tuscany leather   *   *
*   ***********************   *
*                             *
******************************/




/****************
*   September   *
****************/

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-09-09_germany_en_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"





java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-09-09_germany_en_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"








/***************
*   November   *
***************/

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-11-30_germany_en_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"




java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-11-30_germany_de_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"


/******************
*   22 December   *
******************/

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-12-22_germany_en_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"




java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.cj.jdbc.Driver" "tuscany leather csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-12-22_germany_de_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/"










/***********************
*   Different driver   *
***********************/

java -cp .:/usr/share/java/mysql-connector-java-8.0.22.jar com.gwenllian.loader.Main fred [my password] db_settings "com.mysql.jdbc.Driver" "tuscany leather csv ver 1.0" "German" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/matthew/data/2020-11-30_germany_de_eur_decimal_512_pricelists.csv" "/home/matthew/Test_Logs/" 




java -cp .:/usr/share/java/mysql-connector-java.jar com.gwenllian.loader.Main bob [my password] db_settings "com.mysql.jdbc.Driver" "tuscany leather csv ver 1.0" "English" "Taxed goods with German VAT" "/var/www/html/shop/image/catalog/" "catalog" "/home/bob/source_files/2020-09-09_germany_en_eur_decimal_512_pricelists.csv" "/home/bob/Uploader_Logs/"










Test machine
"com.mysql.cj.jdbc.Driver"


Server
"com.mysql.jdbc.Driver"





/* sudo find / -name "*mysql*.jar" */

/usr/share/netbeans/ide14/modules/org-netbeans-modules-db-mysql.jar
/usr/share/java/mysql-connector-java-8.0.22.jar
/snap/netbeans/35/netbeans/ide/modules/org-netbeans-modules-db-mysql.jar
find: ‘/run/user/1000/gvfs’: Permission denied
/home/matthew/Downloads/mysql-connector-java-8.0.21/mysql-connector-java-8.0.21.jar

test image folder
/home/matthew/data/

image location

cd /var/www/html/shop/image/catalog/
ls -l
rm -r cdn*
ls -l









grep -rnw '/home/bob/java' -e 'disableProductsNotUpdated'
grep -rnw '/home/matthew/java/Loader_003' -e 'maintainRelatedProductPartscode'
grep -rnw '/home/matthew/java/Loader_003' -e 'getOptionValueId'
grep -rnw '/home/matthew/java/Loader_003' -e 'getOptionValueID'
grep -rnw '/home/matthew/java/Loader_003' -e 'tbl_products_logged'



grep -rnw '/home/matthew/stored_procedures' -e 'disableProductsNotUpdated'
grep -rnw '/home/matthew/stored_procedures' -e 'WHILE '
grep -rnw '/home/matthew/stored_procedures' -e 'product_option_value_extra_details'


grep -rnw '/home/matthew/stored_procedures' -e 'shoes_product_to_layout'
grep -rnw '/home/matthew/stored_procedures' -e 'shoes_product_related'

grep -rnw '/home/matthew/stored_procedures' -e 'shoes_option_value_description'
grep -rnw '/home/matthew/stored_procedures' -e 'tbl_products_logged'
grep -rnw '/home/matthew/stored_procedures' -e 'shoes_manufacturer'

grep -rnw '/home/matthew/stored_procedures' -e 'shoes_product_filter'
grep -rnw '/home/matthew/stored_procedures' -e 'shoes_product_to_category'






