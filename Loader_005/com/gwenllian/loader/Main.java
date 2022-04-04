package com.gwenllian.loader;


/**********************************************************************

(1) open text file
(2) check header, 
    i) check we have all the columns we need.
    ii) take note of the order of the columns so that ClsSettings manages column positions for the rest of the code
    
(3) Loop through each row
    i) inserting each row
    ii) reporting whether each row is successful or reporting the error, to a text file.
    
(4) close text file
    i) display the full path for the file listing the detailed report
    ii) display totals: failed, successful


Change the plan above we need to pre-process the data to group the lines of the source file so that multiple lines are one product with multiple options 

Column K "option" in source file is different for the same product name.


also...


category
--------
make sure the shoes_product_to_category table is filled out to connect things.

Loop through columns A and B in source file and make sure that parent_category and category are in the tables shoes_category and shoes_category_description 


options
-------

This video explains options well http://docs.opencart.com/en-gb/catalog/option/

Make sure that the tables... 

shoes_option
shoes_option_description
shoes_option_value
shoes_option_value_description

...are correctly populated.

Then make sure that the tables shoes_product_option and shoes_product_option_value connec the products with the options


Reference codes
---------------
Remember I'm required to use the same reference codes as my supplier.

Create my own table listing product id and option id and the reference code in column E "ean" of the source file.

So I can report the correct reference code for each product in the order.
    
    

**********************************************************************/

/****************************************************************

Don't forget to add these lines to the my.cnf file

# Synchronize the MySQL clock with the computer system clock.
default-time-zone='+00:00'

****************************************************************/

import java.util.List;
import java.util.Iterator;
import java.util.Date;
import java.util.Arrays;
import java.util.ArrayList;
import java.text.SimpleDateFormat;  
import java.sql.Types;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;
import java.sql.ResultSet;
import java.sql.DriverManager;
//import java.sql.Date;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.io.*;
import java.lang.*;
import java.net.*;

public class Main {
  public static void main(String[] args) {
    // TODO Auto-generated method stub
    final int ciFlag_add = 1;
    final int ciFlag_edit = 2;
    final int ciFlag_ignore = 3;

    try {
      boolean bIsOk = false;
      String sUsername = args[0];
      String sPassword = args[1];
      String sDatabase = args[2]; /* "db_settings" */
      String sDriverTxt = args[3];
      String sFileType = args[4]; /* "tuscany leather csv ver 1.0" */
      String sLanguage = args[5]; /* "English" */
      String sTaxClassName = args[6];
      String sImagesDir = args[7];
      String sImageRootDirectory = args[8];
      String sUploadFile = args[9];
      String sFolderPathProgressReport = args[10];
      String sUploadFile2 = args[11];

      boolean bTesting_NoFile = false;

      /**********************
      *   Open connection   *
      **********************/
      Class.forName(sDriverTxt);
      
/*      String sUrl = "jdbc:mysql://localhost:3306/" + sDatabase;*/
      String sUrl = "jdbc:mysql://localhost:3306/" + sDatabase + "?serverTimezone=UTC&useSSL=false";
/*jdbc:mysql://localhost/db?useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC*/
      Connection conn = DriverManager.getConnection(sUrl, sUsername, sPassword);
      ClsSettings cSettings = new ClsSettings(conn, sLanguage, sFileType);

      /**********************************
      *   Get all the ID values ready   *
      **********************************/
      int iUploadTypeID = cSettings.uploadTypeID();
      int iLanguageID = cSettings.languageId();
      
      /*************************************************************************************
      *   Move this ClsTestInsertProduct down to where I'm looping through the text file   *
      *************************************************************************************/
/*      String sFolderPathProgressReport = "/home/matthew/Test_Logs/";*/
      ClsProgressReport cProgressReport = new ClsProgressReport(sFolderPathProgressReport);
      
      String strDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
      cProgressReport.somethingToNote("upload details", "Timestamp: " + strDate, 0, "Start");
      
      String strLinuxUser = System.getProperty("user.name");
      cProgressReport.somethingToNote("upload details", "User: " + strLinuxUser, 0, "Start");

      cProgressReport.somethingToNote("upload details", "File Type: " + sFileType, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Language: " + sLanguage, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Tax Class Name: " + sTaxClassName, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Images Dir: " + sImagesDir, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Image Root Directory: " + sImageRootDirectory, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Upload File: " + sUploadFile, 0, "Start");
      cProgressReport.somethingToNote("upload details", "Folder Path Progress Report: " + sFolderPathProgressReport, 0, "Start");
      
      ClsFunctionResult cFunctionResult = new ClsFunctionResult();
      
      
      switch(sFileType) {
        case "tuscany leather csv ver 1.0":
          /******************************
          *                             *
          *   ***********************   *
          *   *   tuscany leather   *   *
          *   ***********************   *
          *                             *
          ******************************/
          ClsProcessTuscany cProcessTuscany = new ClsProcessTuscany(cSettings);
      
          /*******************************
          *   Setup a few things first   *
          *******************************/ 
          System.out.println("ClsProcessTuscany initialised");
      
          // ClsFunctionResult cFunctionResult = new ClsFunctionResult();
        
          if (!bTesting_NoFile) {
            cFunctionResult = cProcessTuscany.ReadFile(cProgressReport, sUploadFile);
        
            /****************************************
            *   Open text file and loop though it   *
            ****************************************/ 
            if (cFunctionResult.bIsOk == true) {  
              System.out.println("File read");
            } else {
              System.out.println("----------------");
              System.out.println("Read File failed");
              System.out.println("----------------");
              System.out.println(cFunctionResult.sError);
            }
          }

          /************************************************************
          *   Process the data from "Raw format" to "Step 1" format   *
          ************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessTuscany.processLstDataRaw(cProgressReport); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("Raw data processed");
              } else {
                System.out.println("--------------------------");
                System.out.println("Processing raw data failed");
                System.out.println("--------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }

          /******************************************************************
          *   Loop through "Step 1" data and call MySQL stored Procedures   *
          ******************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessTuscany.uploadToMySqlServer(iUploadTypeID, cProgressReport, iLanguageID, conn, sTaxClassName, sImagesDir, sImageRootDirectory); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("Data uploaded to MySQL Server");
              } else {
                System.out.println("-------------------------------------");
                System.out.println("Uploading data to MySQL Server failed");
                System.out.println("-------------------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }
      
          /*************************************************************
          *   Loop through "Step 1" data and call fixRelatedProducts   *
          *************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessTuscany.fixRelatedProducts(iUploadTypeID, conn); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("Fixing Related Products");
              } else {
                System.out.println("------------------------------");
                System.out.println("Fixing Related Products failed");
                System.out.println("------------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }

          /***************************************************************
          *   If a product hasn't been updated it needs to be disabled   *
          ***************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessTuscany.disableProductsNotUpdated(cProgressReport, iUploadTypeID, conn); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("disable Products not updated today");
              } else {
                System.out.println("-----------------------------------------");
                System.out.println("disable Products not updated today failed");
                System.out.println("-----------------------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }

          break;
        case "bdroppy csv ver 1.0":
          /**********************
          *                     *
          *   ***************   *
          *   *   BDroppy   *   *
          *   ***************   *
          *                     *
          **********************/
          ClsProcessBDroppy cProcessBDroppy = new ClsProcessBDroppy(cSettings);
      
          /*******************************
          *   Setup a few things first   *
          *******************************/ 
          System.out.println("ClsProcessBDroppy initialised");
      
          // ClsFunctionResult cFunctionResult = new ClsFunctionResult();
        
          if (!bTesting_NoFile) {
            cFunctionResult = cProcessBDroppy.ReadFile(cProgressReport, sUploadFile);
        
            /****************************************
            *   Open text file and loop though it   *
            ****************************************/ 
            if (cFunctionResult.bIsOk == true) {  
              System.out.println("File read");
            } else {
              System.out.println("----------------");
              System.out.println("Read File failed");
              System.out.println("----------------");
              System.out.println(cFunctionResult.sError);
            }
          }

          /************************************************************
          *   Process the data from "Raw format" to "Step 1" format   *
          ************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessBDroppy.processLstDataRaw(cProgressReport, iLanguageID, conn); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("Raw data processed");
              } else {
                System.out.println("--------------------------");
                System.out.println("Processing raw data failed");
                System.out.println("--------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }

          /******************************************************************
          *   Loop through "Step 1" data and call MySQL stored Procedures   *
          ******************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessBDroppy.uploadToMySqlServer(iUploadTypeID, cProgressReport, iLanguageID, conn, sTaxClassName, sImagesDir, sImageRootDirectory); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("Data uploaded to MySQL Server");
              } else {
                System.out.println("-------------------------------------");
                System.out.println("Uploading data to MySQL Server failed");
                System.out.println("-------------------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }
      
          /***************************************************************
          *   If a product hasn't been updated it needs to be disabled   *
          ***************************************************************/
          if (!bTesting_NoFile) {
            if (cFunctionResult.bIsOk == true) { 
              cFunctionResult = cProcessBDroppy.disableProductsNotUpdated(cProgressReport, iUploadTypeID, conn); 

              if (cFunctionResult.bIsOk == true) {  
                System.out.println("disable Products not updated today");
              } else {
                System.out.println("-----------------------------------------");
                System.out.println("disable Products not updated today failed");
                System.out.println("-----------------------------------------");
                System.out.println(cFunctionResult.sError);
              }
            }
          }
          break;
        case "robots":
          System.out.println("Writing Robots.txt");
      
          ClsRobotsTxt cRobotsTxt = new ClsRobotsTxt();
      
          ClsFunctionResult cFnRslt_Robots = cRobotsTxt.getAllPaths(conn);
      
          if (!cFnRslt_Robots.bIsOk) { 
            System.out.println("Failed to write Robots.txt correctly");
            System.out.println(cFnRslt_Robots.sError);
          }
      
          cRobotsTxt.close();
      
          System.out.println("Done writing Robots.txt");
          break;
        case "sitemap":
          System.out.println("Writing sitemap.xml");
      
          ClsSitemapXml cSitemapXml = new ClsSitemapXml(sUploadFile, sUploadFile2);
      
          ClsFunctionResult cFnRslt_Sitemap = cSitemapXml.getLinesSitemap(conn);

      
          if (!cFnRslt_Sitemap.bIsOk) {
            System.out.println("Failed to write sitemap.xml correctly");
            System.out.println(cFnRslt_Sitemap.sError);
          }

          System.out.println("Done writing sitemap.xml");

          ClsFunctionResult cFnRslt_RobotsTxt = cSitemapXml.getLinesRobots(conn);

          if (!cFnRslt_RobotsTxt.bIsOk) {
            System.out.println("Failed to write Robots.txt correctly");
            System.out.println(cFnRslt_RobotsTxt.sError);
          }
      
          cSitemapXml.close();
      
          System.out.println("Done writing Robots.txt");
          break;
        case "data correction - short":
          ClsDataCorrection cDataCorrection = new ClsDataCorrection("shoe sizes", conn);
          ClsDataCorrection cDataCorr_SubCategory = new ClsDataCorrection("sub category", conn);

          ClsFunctionResultString cFnRslt_SubCategory = cDataCorr_SubCategory.getValue("Short");

          System.out.println("cFnRslt_SubCategory.bIsOk:" + Boolean.toString(cFnRslt_SubCategory.bIsOk));
          System.out.println("cFnRslt_SubCategory.sResult:" + cFnRslt_SubCategory.sResult);


          
/*

          ClsFunctionResultString cFnRslt_SubCategory = cDataCorr_SubCategory.getValue(cRawData.sSubCategory.trim());
        
          if (cFnRslt_SubCategory.bIsOk) {
            cDataStep1.sSubCategory = cFnRslt_SubCategory.sResult;
          } else {
            cDataStep1.sSubCategory = cRawData.sSubCategory.trim();
          
            cProgressReport.somethingToNote("uploadToMySqlServer", "cDataCorr_SubCategory.getValue('" + cDataStep1.sSubCategory + "', conn) returns an error" , -1, "Error");
          }
          
          System.out.println("cRawData.sSubCategory.trim(): " + cRawData.sSubCategory.trim());
          System.out.println("cDataStep1.sSubCategory:      " + cDataStep1.sSubCategory);
          


*/          
          
          
          
        default:
          // code block
      }

      /********************************************************************************************************************
      *   Update db_shoes.shoes_banner_image and db_shoes.shoes_module so that the the home page of the shop is updated   *
      ********************************************************************************************************************/
      ClsFunctionResult cFnRslt_ManageHomePage = ClsManageHomePage.ManageHomePage(cProgressReport,  conn, iLanguageID);
      
      if (!cFnRslt_ManageHomePage.bIsOk) {
        System.out.println("");
        System.out.println("Error ClsManageHomePage.ManageHomePage:");
        System.out.println(cFnRslt_ManageHomePage.sError);
        System.out.println("");
      }

      cProgressReport.close();
      cProgressReport.summary();

      //String sImagesDir = "/var/www/html/shop/image/";
      //String sImagesDir = "/home/matthew/data/";
      //String sPictureUrl = "https://cdn4.tuscanyleather.it/storage/products/13617/conversions/thumb_512.jpg";
      
      if (bTesting_NoFile) {
        System.out.println("=====================================");
        System.out.println("");
        System.out.println("");
        System.out.println("REMEMBER");
        System.out.println("FLAG: bTesting_NoFile was set in main");
        System.out.println("");
        System.out.println("");
      }

      System.out.println("====================================================");
      System.out.println("Summary...");

      System.out.println("");
      System.out.println("UploadFile:");
      System.out.println(sUploadFile);
      System.out.println("iUploadTypeID: " + Integer.toString(iUploadTypeID));

      System.out.println("");
      System.out.println("FileType: " + sFileType); /* "tuscany leather csv ver 1.0" */
      System.out.println("Database: " + sDatabase); /* "db_settings" */
      System.out.println("Language: " + sLanguage); /* "English" */
      System.out.println("Tax Class Name: " + sTaxClassName);
      System.out.println("Images Dir: " + sImagesDir);
      System.out.println("Image Root Directory: " + sImageRootDirectory);
      
      

      System.out.println("");
      System.out.println("--------");
      System.out.println("Finished");
      System.out.println("--------");
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }

  public static Connection getConnection(boolean bIsOk, String sUrl, String sUsername, String sPassword) throws Exception {
    try {
      //String driver = "com.mysql.cj.jdbc.Driver";
      System.out.println("One");
      String driver = "com.mysql.cj.jdbc.Driver";
      System.out.println("Two");
      Class.forName(driver);
      System.out.println("Three");
      
      System.out.println("Connecting...");
      Connection conn = DriverManager.getConnection(sUrl, sUsername, sPassword);
      System.out.println("Connected");
      
      return conn;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return null;
    }
  }
}
