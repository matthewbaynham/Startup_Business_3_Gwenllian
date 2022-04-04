package com.gwenllian.loader;

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
import java.net.*;

/*
SELECT product_id, category_id FROM shoes_product_to_category 

product_id	category_id
28 	20
28 	24
29 	20
29 	24
30 	20
30 	33
31 	33
32 	34
33 	20
33 	28
34 	34
35 	20
36 	34
40 	20


SELECT category_id, image, parent_id, top, column, sort_order, status, date_added, date_modified FROM shoes_category 

category_id	image	parent_id	top	column	sort_order	status	date_added	date_modified
25 		0 	1 	1 	3 	1 	2009-01-31 01:04:25 	2011-05-30 12:14:55
27 		20 	0 	0 	2 	1 	2009-01-31 01:55:34 	2010-08-22 06:32:15
20 	catalog/demo/compaq_presario.jpg 	0 	1 	1 	1 	1 	2009-01-05 21:49:43 	2011-07-16 02:14:42
24 		0 	1 	1 	5 	1 	2009-01-20 02:36:26 	2011-05-30 12:15:18
18 	catalog/demo/hp_2.jpg 	0 	1 	0 	2 	1 	2009-01-05 21:49:15 	2011-05-30 12:13:55
17 		0 	1 	1 	4 	1 	2009-01-03 21:08:57 	2011-05-30 12:15:11
28 		25 	0 	0 	1 	1 	2009-02-02 13:11:12 	2010-08-22 06:32:46
26 		20 	0 	0 	1 	1 	2009-01-31 01:55:14 	2010-08-22 06:31:45


SELECT category_id, language_id, name, description, meta_title, meta_description, meta_keyword FROM shoes_category_description 

category_id	language_id	name	description	meta_title	meta_description	meta_keyword
28 	1 	Monitors 		Monitors 		
33 	1 	Cameras 		Cameras 		
32 	1 	Web Cameras 		Web Cameras 		
31 	1 	Scanners 		Scanners 		
30 	1 	Printers 		Printers 		
29 	1 	Mice and Trackballs 		Mice and Trackballs 		
27 	1 	Mac 		Mac 		
26 	1 	PC 		PC 		
17 	1 	Software 		Software 		
25 	1 	Components 		Components 		
24 	1 	Phones &amp; PDAs 		Phones &amp; PDAs 		

SELECT category_id, store_id FROM shoes_category_to_store 

category_id	store_id
17 	0
18 	0
20 	0
24 	0
25 	0
26 	0
27 	0
28 	0
29 	0
30 	0
31 	0
32 	0
33 	0
34 	0
35 	0
36 	0
37 	0


SELECT product_id, category_id FROM shoes_product_to_category WHERE 1

product_id	category_id
28 	20
28 	24
29 	20
29 	24
30 	20
30 	33
31 	33
32 	34
33 	20
33 	28
34 	34
35 	20
36 	34
40 	20
40 	24
Check parent category is in shoes_category and shoes_category_description

Check category is in shoes_category and shoes_category_description

add id's into shoes_category_to_store and shoes_product_to_category







CREATE PROCEDURE getCategoryClassId(IN p_category_text VARCHAR(255), 
                                    IN p_parent_category_text VARCHAR(255), 
                                    IN p_language_ID int, 
                                    IN p_insert_not_found boolean, 
                                    OUT p_category_class_ID int, 
                                    OUT p_parent_category_class_ID int, 
                                    OUT p_bIsOk boolean)

class ClsCategoryId {
  int iId;
  int iParentId;
  String sText;
}

class ClsFunctionResultCategory {
  boolean bIsOk = true;
  String sError = "";
  int iId = 0;
  int iParent = 0;
}

*/

public class ClsCategoryClassId {
  ArrayList<ClsCategoryAllDetails> lstCategoryAllDetails;
  
  public ClsCategoryClassId(int iLanguageId, Connection conn) {
    try {
      this.lstCategoryAllDetails = new ArrayList<ClsCategoryAllDetails>();
      
      ClsFunctionResult cFunctionResult = getAllCategory(iLanguageId, conn);
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("ClsCategoryClassId.getAllCategory Error...");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }

  public ClsFunctionResultCategory getCategoryClassID(String sCategoryText, String sParentText, int iLanguageId, int iGrandParentId, String sModel, String sSku, String sUpc, String sEan, Connection conn) {
    ClsFunctionResultCategory cFnRsltCat = new ClsFunctionResultCategory();

    try {
      cFnRsltCat.bIsOk = true;
      cFnRsltCat.sError = "";
      cFnRsltCat.iId = ClsMisc.iError;
      cFnRsltCat.iParentId = ClsMisc.iError;

      ClsFunctionResultInt cFnRsltInt_Parent = getCategoryId(sParentText, iLanguageId, iGrandParentId, sModel, sSku, sUpc, sEan, 1, conn);
      
      if (cFnRsltInt_Parent.bIsOk) {
        cFnRsltCat.iParentId = cFnRsltInt_Parent.iResult;
      } else {
        cFnRsltCat.bIsOk = cFnRsltInt_Parent.bIsOk;
        cFnRsltCat.sError = cFnRsltInt_Parent.sError;
        cFnRsltCat.iParentId = ClsMisc.iError;

        System.out.println("Error:");
        System.out.print("cFnRsltInt_Parent = getCategoryId(" + sParentText + ", ");
        System.out.print(iLanguageId);
        System.out.print(", ClsMisc.iError, conn);");
        
        System.out.println(cFnRsltInt_Parent.sError);
      }
      
      if (cFnRsltCat.bIsOk) {
        ClsFunctionResultInt cFnRsltInt_Category = getCategoryId(sCategoryText, iLanguageId, cFnRsltCat.iParentId, sModel, sSku, sUpc, sEan, 0, conn);

        if (cFnRsltInt_Category.bIsOk) {
          cFnRsltCat.iId = cFnRsltInt_Category.iResult;
        } else {
          cFnRsltCat.bIsOk = cFnRsltInt_Category.bIsOk;
          cFnRsltCat.sError = cFnRsltInt_Category.sError;
          cFnRsltCat.iParentId = ClsMisc.iError;

          System.out.println("Error:");
          System.out.print("cFnRsltInt_Category = getCategoryId(" + sCategoryText + ", ");
          System.out.print(iLanguageId);
          System.out.print(", ClsMisc.iError, conn);");
        
          System.out.println(cFnRsltInt_Category.sError);
        }
      }

      /***********************************************************************
      *   Check ArrayList to see if we already have this Category Class ID   *
      ***********************************************************************/
      
      /********************************************************************************************************
      *   If we don't already have the Category Class ID in our ArrayList then get it from the MySQL server   *
      ********************************************************************************************************/ 
      
     return cFnRsltCat;  
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRsltCat.bIsOk = false;
      cFnRsltCat.sError = e.toString();
     return cFnRsltCat;
    }
  }
  
  private ClsFunctionResultInt getCategoryId(String sCategoryName, int iLanguageId, int iParentId, String sModel, String sSku, String sUpc, String sEan, int iGeneration, Connection conn) {

    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();

    try {

      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = ClsMisc.iError;
      
      ClsFunctionResultInt cFnRslt_FoundCat = findCategoryPosInLst(sCategoryName);
      
      if (cFnRslt_FoundCat.bIsOk) {
        if (cFnRslt_FoundCat.iResult == ClsMisc.iError) {
          /**************************************************************************************************
          *   Category was not found above and we need to add it to the database as well as return the ID   *
          **************************************************************************************************/
/*
CREATE PROCEDURE getCategoryClassId(IN p_category_text VARCHAR(255),  1
                                    IN p_language_id int,             2 
                                    IN p_parent_ID int,               3 
                                    OUT p_category_class_ID int,      4
                                    OUT p_bIsOk boolean,              5    
                                    IN p_model VARCHAR(64),           6
                                    IN p_sku VARCHAR(64),             7
                                    IN p_upc VARCHAR(12),             8 
                                    IN p_ean VARCHAR(14),             9 
                                    IN p_generation INT)             10

p_generation = 1 if this is a parent category
p_generation = 0 if this is not a parent category
*/

//          String sSql = "{Call getCategoryClassId( ? , ? , ? , ? , ? )};";
          String sSql = "{Call getCategoryClassId( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )};";

          System.out.println("");
          System.out.println("ClsCategoryClassId.getCategoryId - Couldnt find category");
          System.out.println("sCategoryName: "+ sCategoryName);
          System.out.println("iLanguageId: " + Integer.toString(iLanguageId));
          System.out.println("iParentId: " + Integer.toString(iParentId));
          System.out.println("sModel: "+ sModel);
          System.out.println("sSku: "+ sSku);
          System.out.println("sUpc: "+ sUpc);
          System.out.println("sEan: "+ sEan);
          System.out.println("iGeneration: " + Integer.toString(iGeneration));
          System.out.println("");

          try (CallableStatement stmt=conn.prepareCall(sSql);) {
            ResultSet rs;

            stmt.setString(1, sCategoryName);  
            stmt.setInt(2, iLanguageId);  
            stmt.setInt(3, iParentId);  
            stmt.registerOutParameter(4, Types.INTEGER);
            stmt.registerOutParameter(5, Types.BOOLEAN);
            stmt.setString(6, sModel);  
            stmt.setString(7, sSku);  
            stmt.setString(8, sUpc);  
            stmt.setString(9, sEan);  
            stmt.setInt(10, iGeneration);  

            rs = stmt.executeQuery();
      
            int iCategoryId = stmt.getInt(4);
            System.out.print("iCategoryId from {Call getCategoryClassId( ? , ? , ? , ? , ? )}; : ");
            System.out.println(iCategoryId);
            
            cFnRsltInt.bIsOk = stmt.getBoolean(5);
            System.out.print("bIsOk from {Call getCategoryClassId( ? , ? , ? , ? , ? )}; : ");
            System.out.println(cFnRsltInt.bIsOk);


            if (cFnRsltInt.bIsOk == true) {
              cFnRsltInt.iResult = iCategoryId;
              
              while (rs.next()) {
                ClsCategoryAllDetails cCategoryAllDetails = new ClsCategoryAllDetails();
 
                cCategoryAllDetails.iCategoryId = rs.getInt("cat_category_id");
                cCategoryAllDetails.sCatImage = rs.getString("cat_image");
                cCategoryAllDetails.iParentId = rs.getInt("cat_parent_id");
                cCategoryAllDetails.iTop = rs.getInt("cat_top");
                cCategoryAllDetails.iColumn = rs.getInt("cat_column");
                cCategoryAllDetails.iSortOrder = rs.getInt("cat_sort_order");
                cCategoryAllDetails.iStatus = rs.getInt("cat_status");
                cCategoryAllDetails.iLanguageId = rs.getInt("disc_language_id");
                cCategoryAllDetails.sName = rs.getString("disc_name");
                cCategoryAllDetails.sDescription = rs.getString("disc_description");
                cCategoryAllDetails.sMeta_title = rs.getString("disc_meta_title");
                cCategoryAllDetails.sMeta_description = rs.getString("disc_meta_description");
                cCategoryAllDetails.sMeta_keyword = rs.getString("disc_meta_keyword");

                cFnRsltInt.iResult = cCategoryAllDetails.iCategoryId;
                
                System.out.print("Add category: ");
                System.out.println(cFnRsltInt.iResult);
            
                this.lstCategoryAllDetails.add(cCategoryAllDetails);
              }
            } else {
              System.out.println("Error:");
              ClsMisc.printResultset(rs);
            }
          } catch (SQLException e) {
            e.printStackTrace();
          }
        } else {
          /*******************************
          *   Category was found above   *
          *******************************/
          cFnRsltInt.iResult = this.lstCategoryAllDetails.get(cFnRslt_FoundCat.iResult).iCategoryId;
        }  
      } else {
        /***********************************************************************************************
        *   Looking for the position of the category in this.lstCategoryAllDetails returned an error   *
        *   different from just not being found                                                        *
        ***********************************************************************************************/
        System.out.println("ClsCategoryClassId.findCategoryPosInLst('" + sCategoryName + "') - Error");  
        System.out.println(cFnRsltInt.sError= cFnRslt_FoundCat.sError);  
        
        cFnRsltInt.bIsOk = false;
        cFnRsltInt.sError= cFnRslt_FoundCat.sError;
      }
      return cFnRsltInt;  
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRsltInt.bIsOk = false;
      cFnRsltInt.sError = e.toString();
     return cFnRsltInt;
    }
  }
  
  private ClsFunctionResult getAllCategory(int iLanguageId, Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      ResultSet rs;

      String sSql = "{Call getAllCategoryDetails( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iLanguageId);  
        stmt.registerOutParameter(2, Types.BOOLEAN);

        //stmt.execute();
        rs = stmt.executeQuery();
      
        cFnRslt.bIsOk = stmt.getBoolean(2);

        if (cFnRslt.bIsOk == true) {
          this.lstCategoryAllDetails = new ArrayList<ClsCategoryAllDetails>();

          while (rs.next()) {
            ClsCategoryAllDetails cCategoryAllDetails = new ClsCategoryAllDetails();

            cCategoryAllDetails.iCategoryId = rs.getInt("cat_category_id");
            cCategoryAllDetails.sCatImage = rs.getString("cat_image");
            cCategoryAllDetails.iParentId = rs.getInt("cat_parent_id");
            cCategoryAllDetails.iTop = rs.getInt("cat_top");
            cCategoryAllDetails.iColumn = rs.getInt("cat_column");
            cCategoryAllDetails.iSortOrder = rs.getInt("cat_sort_order");
            cCategoryAllDetails.iStatus = rs.getInt("cat_status");
            cCategoryAllDetails.iLanguageId = rs.getInt("disc_language_id");
            cCategoryAllDetails.sName = rs.getString("disc_name");
            cCategoryAllDetails.sDescription = rs.getString("disc_description");
            cCategoryAllDetails.sMeta_title = rs.getString("disc_meta_title");
            cCategoryAllDetails.sMeta_description = rs.getString("disc_meta_description");
            cCategoryAllDetails.sMeta_keyword = rs.getString("disc_meta_keyword");
            
            this.lstCategoryAllDetails.add(cCategoryAllDetails);
          }
        } else {
          System.out.println("Error:");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
  
     return cFnRslt;  
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
     return cFnRslt;
    }
  }
  
  private ClsFunctionResultInt findCategoryPosInLst(String sCategoryName) {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();

    try {
      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < this.lstCategoryAllDetails.size(); iPos++) {
        ClsCategoryAllDetails cCategoryAllDetails = this.lstCategoryAllDetails.get(iPos);

        if (ClsMisc.stringsEqual(cCategoryAllDetails.sName, sCategoryName, true, true, false)) {
          cFnRsltInt.iResult = iPos;
        }
      }
      
      return cFnRsltInt;  
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRsltInt.bIsOk = false;
      cFnRsltInt.sError = e.toString();
     return cFnRsltInt;
    }
  }
}
