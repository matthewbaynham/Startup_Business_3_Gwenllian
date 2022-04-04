package com.gwenllian.loader;

import java.util.List;
import java.util.Iterator;
//import java.util.Date;
import java.util.Arrays;
import java.util.ArrayList;
import java.text.SimpleDateFormat;  
import java.sql.Types;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;
import java.sql.ResultSet;
import java.sql.DriverManager;
import java.sql.Date;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.io.*;
import java.lang.*;
import java.net.*;

public class ClsTestInsertProduct {
  public ClsTestInsertProduct (){
    try {

    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public Integer getProductId(Connection conn, String sWeightText) throws Exception {
    try {
        final int iFlag_add = 1;
        final int iFlag_edit = 2;
        final int iFlag_ignore = 3;
        
	boolean bIsOk = true;
	int iprd_product_id = -1;
	int ilanguage_id = 1;
	String sPrd_model = "";
	String sPrd_sku = "";
	String sPrd_upc = "";
	String sPrd_ean = "";
	String sPrd_jan = "";
	String sPrd_isbn = "";
	String sPrd_mpn = "";
	String sPrd_location = "";
	int iPrd_quantity = 0;
	int iPrd_stock_status_id = 0;
	String sPrd_image = "";
	int iPrd_manufacturer_id = 0;
	int iPrd_shipping = 0;
	double dPrd_price = 0.0f;
	int iPrd_points = 0;
	int iPrd_tax_class_id = 0;
	Date dtePrd_date_available = new Date(1000000000);
	double dPrd_weight = 0.0f;
	int iPrd_weight_class_id = 0;
	double dPrd_length = 0.0f;
	double dPrd_width = 0.0f;
	double dPrd_height = 0.0f;
	int iPrd_length_class_id = 0;
	int iPrd_subtract = 0;
	int iPrd_minimum = 0;
	int iPrd_sort_order = 0;
	int iPrd_status = 0;
	String sDesc_name = "";
	String sDesc_description = "";
	String sDesc_tag = "";
	String sDesc_meta_title = "";
	String sDesc_meta_description = "";
	String sDesc_meta_keyword = "";
	String sConcat_image = "catalog/demo/ipod_nano_5.jpg1\tcatalog/demo/ipod_nano_4.jpg\tcatalog/demo/ipod_nano_123.jpg";
	String sConcat_image_sort_order = "1\t2\t3";
	int iFlag_product = iFlag_add;
	int iFlag_description = iFlag_add;
	int iFlag_images = iFlag_add;
	
      	ResultSet rs;
	
      	String sSql = "{CALL insertProduct( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )};";
      
      System.out.println("CALL insertProduct");
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
               
        //Set OUT parameter
        stmt.registerOutParameter(1, Types.INTEGER); /* bIsOk */   /*OUT p_bIsOk boolean,1*/
        stmt.registerOutParameter(2, Types.INTEGER); /* iprd_product_id */   /*OUT p_prd_product_id int,2*/

        //Set IN parameter
        stmt.setInt(3, ilanguage_id); /*IN p_language_id int,3*/
        stmt.setString(4, sPrd_model); /*IN p_prd_model varchar(64),4*/
        stmt.setString(5, sPrd_sku); /*IN p_prd_sku varchar(64),5*/
        stmt.setString(6, sPrd_upc); /*IN p_prd_upc varchar(12),6*/
        stmt.setString(7, sPrd_ean); /*IN p_prd_ean varchar(14),7*/
        stmt.setString(8, sPrd_jan); /*IN p_prd_jan varchar(13),8*/
        stmt.setString(9, sPrd_isbn); /*IN p_prd_isbn varchar(17),9*/
        stmt.setString(10, sPrd_mpn); /*IN p_prd_mpn varchar(64),10*/
        stmt.setString(11, sPrd_location); /*IN p_prd_location varchar(128),11*/
        stmt.setInt(12, iPrd_quantity); /*IN p_prd_quantity int,12*/
        stmt.setInt(13, iPrd_stock_status_id); /*IN p_prd_stock_status_id int,13*/
        stmt.setString(14, sPrd_image); /*IN p_prd_image varchar(255),14*/
        stmt.setInt(15, iPrd_manufacturer_id); /*IN p_prd_manufacturer_id int,15*/
        stmt.setInt(16, iPrd_shipping); /*IN p_prd_shipping tinyint,16*/
        stmt.setDouble(17, dPrd_price); /*IN p_prd_price decimal(15,4),17*/
        stmt.setInt(18, iPrd_points); /*IN p_prd_points int,18*/
        stmt.setInt(19, iPrd_tax_class_id); /*IN p_prd_tax_class_id int,19*/
        stmt.setDate(20, dtePrd_date_available); /*IN p_prd_date_available date,20*/
        stmt.setDouble(21, dPrd_weight); /*IN p_prd_weight decimal(15,8),21*/
        stmt.setInt(22, iPrd_weight_class_id); /*IN p_prd_weight_class_id int,22*/
        stmt.setDouble(23, dPrd_length); /*IN p_prd_length decimal(15,8),23*/
        stmt.setDouble(24, dPrd_width); /*IN p_prd_width decimal(15,8),24*/
        stmt.setDouble(25, dPrd_height); /*IN p_prd_height decimal(15,8),25*/
        stmt.setInt(26, iPrd_length_class_id); /*IN p_prd_length_class_id int,26*/
        stmt.setInt(27, iPrd_subtract); /*IN p_prd_subtract tinyint,27*/
        stmt.setInt(28, iPrd_minimum); /*IN p_prd_minimum int,28*/
        stmt.setInt(29, iPrd_sort_order); /*IN p_prd_sort_order int,29*/
        stmt.setInt(30, iPrd_status); /*IN p_prd_status tinyint,30*/
        stmt.setString(31, sDesc_name); /*IN p_desc_name varchar(255),31*/
        stmt.setString(32, sDesc_description); /*IN p_desc_description text,32*/
        stmt.setString(33, sDesc_tag); /*IN p_desc_tag text,33*/
        stmt.setString(34, sDesc_meta_title); /*IN p_desc_meta_title varchar(255) ,34*/
        stmt.setString(35, sDesc_meta_description); /*IN p_desc_meta_description varchar(255),35*/
        stmt.setString(36, sDesc_meta_keyword); /*IN p_desc_meta_keyword varchar(255), 36*/
        stmt.setString(37, sConcat_image); /*IN p_Concat_image varchar(4000),37*/
        stmt.setString(38, sConcat_image_sort_order); /*IN p_Concat_image_sort_order varchar(4000),38*/
        stmt.setInt(39, iFlag_product); /*IN p_flag_product int,40*/
        stmt.setInt(40, iFlag_description); /*IN p_flag_description int,41*/
        stmt.setInt(41, iFlag_images); /*IN p_flag_images int42*/
               
        //Execute stored procedure
        //stmt.execute();
        rs = stmt.executeQuery();
               
        // Get Out and InOut parameters
        bIsOk = stmt.getBoolean(1);
        iprd_product_id = stmt.getInt(2);

        if (bIsOk == true) {
          System.out.println("Is OK");
          System.out.println("product id " + Integer.toString(iprd_product_id));

          ClsMisc.printResultset(rs);
        } else {
          System.out.println("Is NOT OK - ERROR!!!");
          System.out.println("Is NOT OK - ERROR!!!");
          System.out.println("Is NOT OK - ERROR!!!");
          
          ClsMisc.printResultset(rs);
        };
      } catch (SQLException e) {
        e.printStackTrace();
      }
      
      return iprd_product_id;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return -1;
    }
  }
  
}

