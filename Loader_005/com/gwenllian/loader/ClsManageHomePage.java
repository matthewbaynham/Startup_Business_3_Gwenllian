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
import java.lang.*;
import java.net.*;

/*
SELECT `module_id`, `name`, `code`, `setting` FROM `shoes_module`

module_id	name	code	setting
30	Category	banner	{"name":"Category","banner_id":"6","width":"182","height":"182","status":"1"}
29	Home Page	carousel	{"name":"Home Page","banner_id":"8","width":"130","height":"100","status":"1"}
28	Home Page	featured	{"name":"Home Page","product":["43","40","42","30"],"limit":"4","width":"200","height":"200","status":"1"}
27	Home Page	slideshow	{"name":"Home Page","banner_id":"7","width":"1140","height":"380","status":"1"}
31	Banner 1	banner	{"name":"Banner 1","banner_id":"6","width":"182","height":"182","status":"1"}

(1) get data from db_shoes.shoes_module 

(2a) filter for [Name] = "Home Page" and [code] = "carousel" 
(2b) find the banner id somewhere within [setting] (in this example it's 8)
(2c) run stored procedure Call createBanner(OUT p_bIsOk boolean, IN p_language_id INT, IN p_banner_id INT);

(3a) filter for [Name] = "Home Page" and [code] = "slideshow" 
(3b) find the banner id somewhere within [setting] (in this example it's 7)
(3c) run stored procedure Call createBanner(OUT p_bIsOk boolean, IN p_language_id INT, IN p_banner_id INT);

(4a) filter for [Name] = "Home Page" and [code] = "featured" 
(4b) somewhere within [setting] look for square backets and you'll find the product id's we need to replace
(4c) pick some product ID's that cover a range of different types of products

class ClsModuleDetails {
  int iId;
  String sName;
  String sCode;
  String sSetting;
}


*/

public class ClsManageHomePage {
  private static final String scName_HomePage = "Home Page";
  private static final String scCode_Carousel = "carousel";
  private static final String scCode_Featured = "featured";
  private static final String scCode_Slideshow = "slideshow";
  private static final String scText_BannerId = "\"banner_id\"";
  private static final String scText_Product = "\"product\"";
  
  private static ArrayList<ClsModuleDetails> lstModuleDetails;

  /*public ClsManageHomePage(Connection conn){*/
  public static ClsFunctionResult ManageHomePage(ClsProgressReport cProgressReport, Connection conn, int iLanguageId) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();
    
    try {
      int iCarousel_pos = ClsMisc.iError;
      int iFeatured_pos = ClsMisc.iError;
      int iSlideshow_pos = ClsMisc.iError;
      int iCarousel_BannerId = ClsMisc.iError;
      int iSlideshow_BannerId = ClsMisc.iError;
      
      System.out.println("ClsManageHomePage.ManageHomePage(...) - Start");

      cFnRslt.sError = "";
      cFnRslt.bIsOk = true;

      /**********************************************
      *   (1) get data from db_shoes.shoes_module   *
      **********************************************/
      cProgressReport.somethingToNote("ClsManageHomePage.ManageHomePage", "Starting", 0, "tracking");

      lstModuleDetails = new ArrayList<ClsModuleDetails>();
      
      if (cFnRslt.bIsOk) { 
        cFnRslt = getAllModuleDetails(conn); 
       
        if (!cFnRslt.bIsOk) { 
          System.out.println("Error Couldnt run getAllModuleDetails");
          System.out.println(cFnRslt.sError);
        }
      }

      /******************************************************************************************************************
      *   (2a) filter for [Name] = "Home Page" and [code] = "carousel"                                                  *
      *   (2b) find the banner id somewhere within [setting] (in this example it's 8)                                   *
      *   (2c) run stored procedure Call createBanner(OUT p_bIsOk boolean, IN p_language_id INT, IN p_banner_id INT);   *
      ******************************************************************************************************************/
      if (cFnRslt.bIsOk) { 
        ClsFunctionResultInt cFnRsltInt = findCode(conn, scName_HomePage, scCode_Carousel);
        
        cFnRslt.bIsOk = cFnRsltInt.bIsOk;
        cFnRslt.sError = cFnRsltInt.sError;
        
        if (cFnRslt.bIsOk) { 
          iCarousel_pos = cFnRsltInt.iResult;
        } else {
          System.out.println("Error Couldnt run findCode(conn, " + scName_HomePage + ", " + scCode_Carousel + ")");
          System.out.println(cFnRsltInt.sError);
          cFnRslt.bIsOk = cFnRsltInt.bIsOk;
          cFnRslt.sError = cFnRsltInt.sError;
        }
      }
      
      if (cFnRslt.bIsOk) {
        ClsModuleDetails cModuleDetails = lstModuleDetails.get(iCarousel_pos);
        
        ClsFunctionResultInt cFnRsluInt_Carousel = getBannerIdFromSettingTxt(cModuleDetails.sSetting);

        if (cFnRsluInt_Carousel.bIsOk) { 
          iCarousel_BannerId = cFnRsluInt_Carousel.iResult;

          ClsFunctionResult cFnRslt_Carousel_runCreateBanner = runCreateBanner(conn, iLanguageId, iCarousel_BannerId);
          
          if (!cFnRslt_Carousel_runCreateBanner.bIsOk) {
            System.out.println("Error Couldnt run runCreateBanner(conn, iLanguageId, " + Integer.toString(iCarousel_BannerId) + ");");
            cFnRslt.bIsOk = cFnRslt_Carousel_runCreateBanner.bIsOk;
            cFnRslt.sError = cFnRslt_Carousel_runCreateBanner.sError;
          }
          
          
        } else {
          System.out.println("Error Couldnt run getBannerIdFromSettingTxt(conn, " + cModuleDetails.sSetting + ") iCarousel_pos: " + Integer.toString(iCarousel_pos));
          System.out.println(cFnRsluInt_Carousel.sError);
          cFnRslt.bIsOk = cFnRsluInt_Carousel.bIsOk;
          cFnRslt.sError = cFnRsluInt_Carousel.sError;
        }
      }
      
      System.out.println("iCarousel_BannerId: " + Integer.toString(iCarousel_BannerId));
      
      /******************************************************************************************************************
      *   (3a) filter for [Name] = "Home Page" and [code] = "slideshow"                                                 *
      *   (3b) find the banner id somewhere within [setting] (in this example it's 7)                                   *
      *   (3c) run stored procedure Call createBanner(OUT p_bIsOk boolean, IN p_language_id INT, IN p_banner_id INT);   *
      ******************************************************************************************************************/
      if (cFnRslt.bIsOk) { 
        System.out.println("findCode(conn, scName_HomePage, \"" + scCode_Slideshow  + "\");");
        ClsFunctionResultInt cFnRsltInt = findCode(conn, scName_HomePage, scCode_Slideshow);
        
        if (cFnRsltInt.bIsOk) { 
          iSlideshow_pos = cFnRsltInt.iResult;
        } else {
          System.out.println("Error Couldnt run findCode(conn, " + scName_HomePage + ", " + scCode_Slideshow + ")");
          System.out.println(cFnRsltInt.sError);
          cFnRslt.bIsOk = cFnRsltInt.bIsOk;
          cFnRslt.sError = cFnRsltInt.sError;
        }
      }

      if (cFnRslt.bIsOk) {
        ClsModuleDetails cModuleDetails = lstModuleDetails.get(iSlideshow_pos);
        ClsFunctionResultInt cFnRsltInt_Slideshow = getBannerIdFromSettingTxt(cModuleDetails.sSetting);

        if (cFnRsltInt_Slideshow.bIsOk) { 
          iSlideshow_BannerId = cFnRsltInt_Slideshow.iResult;

          ClsFunctionResult cFnRslt_Slideshow_runCreateBanner = runCreateBanner(conn, iLanguageId, iSlideshow_BannerId);
          
          if (!cFnRslt_Slideshow_runCreateBanner.bIsOk) {
            System.out.println("Error Couldnt run runCreateBanner(conn, iLanguageId, " + Integer.toString(iSlideshow_BannerId) + ");");
            cFnRslt.bIsOk = cFnRslt_Slideshow_runCreateBanner.bIsOk;
            cFnRslt.sError = cFnRslt_Slideshow_runCreateBanner.sError;
          }
        } else {
          System.out.println("Error Couldnt run getBannerIdFromSettingTxt(conn, " + cModuleDetails.sSetting + ") iSlideshow_pos: " + Integer.toString(iSlideshow_pos));
          System.out.println(cFnRsltInt_Slideshow.sError);
          cFnRslt.bIsOk = cFnRsltInt_Slideshow.bIsOk;
          cFnRslt.sError = cFnRsltInt_Slideshow.sError;
        }
      }
      
      System.out.println("iSlideshow_BannerId: " + Integer.toString(iSlideshow_BannerId));

      /******************************************************************************************************************
      *   (4a) filter for [Name] = "Home Page" and [code] = "featured"                                                  *
      *   (4b) somewhere within [setting] look for square backets and you'll find the product id's we need to replace   *
      *   (4c) pick some product ID's that cover a range of different types of products                                 *
      ******************************************************************************************************************/ 
      if (cFnRslt.bIsOk) { 
        ClsFunctionResultInt cFnRsltInt = findCode(conn, scName_HomePage, scCode_Featured);
        
        if (cFnRsltInt.bIsOk) { 
          iFeatured_pos = cFnRsltInt.iResult;
        } else {
          System.out.println("Error Couldnt run findCode(conn, " + scName_HomePage + ", " + scCode_Featured + ")");
          System.out.println(cFnRsltInt.sError);
          cFnRslt.bIsOk = cFnRsltInt.bIsOk;
          cFnRslt.sError = cFnRsltInt.sError;
        }
      }

      if (cFnRslt.bIsOk) { 
        ClsModuleDetails cModuleDetails = lstModuleDetails.get(iFeatured_pos);
        ClsFunctionResultString cFnRsltStr_NewFeatureSetting = createNewSettingTxtFeatured(conn, cModuleDetails.sSetting);

        if (cFnRsltStr_NewFeatureSetting.bIsOk) {
          String sNewFeature_Setting = cFnRsltStr_NewFeatureSetting.sResult;
          System.out.println("sNewFeature_Setting: " + sNewFeature_Setting);
          ClsFunctionResult cFnRslt_updateModSetting = runUpdateModuleSetting(conn, cModuleDetails.sName, cModuleDetails.sCode, sNewFeature_Setting);
          
          if (!cFnRslt_updateModSetting.bIsOk) {
            System.out.println("Error Couldnt run runUpdateModuleSetting(conn, \"" + cModuleDetails.sName + "\", \"" + cModuleDetails.sCode + "\", \"" + sNewFeature_Setting + "\")");
            System.out.println(cFnRslt_updateModSetting.sError);
            cFnRslt.bIsOk = cFnRslt_updateModSetting.bIsOk;
            cFnRslt.sError = cFnRslt_updateModSetting.sError;
          }
        } else {
          System.out.println("Error Couldnt run createNewSettingTxtFeatured(conn, " + cModuleDetails.sSetting + ") iFeatured_pos: " + Integer.toString(iFeatured_pos));
          System.out.println(cFnRsltStr_NewFeatureSetting.sError);
          cFnRslt.bIsOk = cFnRsltStr_NewFeatureSetting.bIsOk;
          cFnRslt.sError = cFnRsltStr_NewFeatureSetting.sError;
        }
      }
      
      cProgressReport.somethingToNote("ClsManageHomePage.ManageHomePage", "iCarousel_pos: " + Integer.toString(iCarousel_pos), 0, "tracking");
      cProgressReport.somethingToNote("ClsManageHomePage.ManageHomePage", "iFeatured_pos: " + Integer.toString(iFeatured_pos), 0, "tracking");
      cProgressReport.somethingToNote("ClsManageHomePage.ManageHomePage", "iSlideshow_pos: " + Integer.toString(iSlideshow_pos), 0, "tracking");
      
      System.out.println("ClsManageHomePage.ManageHomePage: iCarousel_pos: " + Integer.toString(iCarousel_pos));
      System.out.println("ClsManageHomePage.ManageHomePage: iFeatured_pos: " + Integer.toString(iFeatured_pos));
      System.out.println("ClsManageHomePage.ManageHomePage: iSlideshow_pos: " + Integer.toString(iSlideshow_pos));
      
      System.out.println("ClsManageHomePage.ManageHomePage(...) - End");
      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }

  
  /*
***************
*   DO THIS   *
***************

For this record...
28	Home Page	featured	{"name":"Home Page","product":["43","40","42","30"],"limit":"4","width":"200","height":"200","status":"1"}

get the random product ID's from this SP
  CALL getRandomProducts(OUT p_bIsOk boolean, in iNumberResults INT)
  
i.e. CALL getRandomProducts(bIsOk, 12)
  
  
  */

  public static ClsFunctionResultString createNewSettingTxtFeatured(Connection conn, String sSettingTxt) {
    ClsFunctionResultString cFnRslt = new ClsFunctionResultString();

    try {
      /*
      (1) find "product"
      (2) find square bracket beginning and end
      (3) get the product ids from stored procedure 
      (4) replace text 
      */

      /***********************
      *   Split the string   *
      ***********************/

      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      cFnRslt.sResult = "";

      final int iMode_before = 1;
      final int iMode_number = 2;
      final int iMode_after = 3;
      int iMode = ClsMisc.iError;
      int iPosSquareBracketOpen = ClsMisc.iError;
      int iPosSquareBracketClose = ClsMisc.iError;
      String sNumber = "";

//      System.out.println("ClsManageHomePage.createNewSettingTxtFeatured(\"" + sSettingTxt + "\")");
      
      int iPos_Product = sSettingTxt.indexOf(scText_Product); 

      if (iPos_Product == -1) {
        cFnRslt.bIsOk = false;
        cFnRslt.sError = "ClsManageHomePage.createNewSettingTxtFeatured(\"" + sSettingTxt + "\"): Can't find \"" + scText_Product + "\"";
      } else {
        int iPos = iPos_Product + scText_Product.length();
        
        iMode = iMode_before;
        
        while (iPos < sSettingTxt.length()) {
          switch (iMode) {
            case iMode_before:
              if (ClsMisc.stringsEqual(sSettingTxt.substring(iPos, iPos+1), "[", true, true, false)) { 
                iMode = iMode_number; 
                iPosSquareBracketOpen = iPos;
              }

              break;
            case iMode_number:
              if (ClsMisc.stringsEqual(sSettingTxt.substring(iPos, iPos+1), "]", true, true, false)) { 
                iMode = iMode_after; 
                iPosSquareBracketClose = iPos;
              }

              break;
            case iMode_after:
              break;
          }
          
          iPos++;
        }
      }

/*
      System.out.println("sSettingTxt:");
      System.out.println(sSettingTxt);
      System.out.println("0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789");
      System.out.println("0         1         2         3         4         5         6         7         8         9         ");
      
      System.out.println("iPosSquareBracketOpen: " + Integer.toString(iPosSquareBracketOpen));
      System.out.println("iPosSquareBracketClose: " + Integer.toString(iPosSquareBracketClose));
      
      System.out.println("sSettingTxt.substring(0, iPosSquareBracketOpen + 1): " + sSettingTxt.substring(0, iPosSquareBracketOpen + 1));
      System.out.println("sSettingTxt.substring(iPosSquareBracketOpen + 1, iPosSquareBracketClose): " + sSettingTxt.substring(iPosSquareBracketOpen + 1, iPosSquareBracketClose));
      System.out.println("sSettingTxt.substring(iPosSquareBracketClose, sSettingTxt.length()): " + sSettingTxt.substring(iPosSquareBracketClose, sSettingTxt.length()));
*/      
      String sBefore = sSettingTxt.substring(0, iPosSquareBracketOpen + 1);
      String sOldProductIds = sSettingTxt.substring(iPosSquareBracketOpen + 1, iPosSquareBracketClose);
      String sAfter = sSettingTxt.substring(iPosSquareBracketClose, sSettingTxt.length());
      
      /****************************************************************
      *   run Store Procedure and build a new string of product ids   *
      ****************************************************************/
      
      
      /*CREATE PROCEDURE getRandomProducts(OUT p_bIsOk boolean, in iNumberResults INT)*/
      
      int iNumberResults = 12;
      ArrayList<Integer> lstProductIds = new ArrayList<Integer>();
      String sNewProductIds = "";
      
      if (cFnRslt.bIsOk) {
        ResultSet rs;
        String sSql = "{Call getRandomProducts( ? , ? )};";

        try (CallableStatement stmt=conn.prepareCall(sSql);) {
          stmt.registerOutParameter(1, Types.BOOLEAN);
          stmt.setInt(2, iNumberResults);
               
          rs = stmt.executeQuery();
          cFnRslt.bIsOk = stmt.getBoolean(1);
               
          if (cFnRslt.bIsOk == true) {
            while (rs.next()) {
              int iProductId = rs.getInt("product_id");

              lstProductIds.add(iProductId);
            }
          } else {
            System.out.println("");
            System.out.println("ClsManageHomePage.createNewSettingTxtFeatured: Error...");

            ClsMisc.printResultset(rs);

            System.out.println("");
          }
        } catch (SQLException e) {
          e.printStackTrace();

          cFnRslt.bIsOk = false;
          cFnRslt.sError = e.toString();
        }
      }
      
      if (cFnRslt.bIsOk) {
        for (int iPos = 0; iPos < lstProductIds.size(); iPos++) {
          if (iPos != 0) 
          { sNewProductIds = sNewProductIds + ","; }
          sNewProductIds = sNewProductIds + "\"" + lstProductIds.get(iPos) + "\"";
        }
      }
      
//      System.out.println("sNewProductIds: " + sNewProductIds);
      
      cFnRslt.sResult = sBefore + sNewProductIds + sAfter;
/*      
      System.out.println("");
      System.out.println("cFnRslt.sResult:");
      System.out.println(cFnRslt.sResult);
      System.out.println("");
*/      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("ClsManageHomePage.createNewSettingTxtFeatured - Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }

  
  private static ClsFunctionResult getAllModuleDetails(Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call getAllModuleDetails ( ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
               
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsModuleDetails cModuleDetails = new ClsModuleDetails();
            
            cModuleDetails.iId = rs.getInt("module_id");
            cModuleDetails.sName = rs.getString("name");
            cModuleDetails.sCode = rs.getString("code");
            cModuleDetails.sSetting = rs.getString("setting");

            lstModuleDetails.add(cModuleDetails);
          }

          ClsMisc.printResultset(rs);
        } else {
          System.out.println("");
          System.out.println("ClsManageHomePage.getAllModuleDetails: Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();

        cFunctionResult.bIsOk = false;
        cFunctionResult.sError = e.toString();
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("ClsManageHomePage.getAllModuleDetails: Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }
  
  private static ClsFunctionResult runCreateBanner(Connection conn, int iLanguageId, int iBannerId) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call createBanner( ? , ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, iLanguageId);  
        stmt.setInt(3, iBannerId);  
               
        System.out.println(sSql + " - iLanguageId: " + Integer.toString(iLanguageId) + " iBannerId: " + Integer.toString(iBannerId));

        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
        
        if (cFunctionResult.bIsOk == true) {
          //ClsMisc.printResultset(rs);
        } else {
          System.out.println("");
          System.out.println("ClsManageHomePage.runCreateBanner: Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();

        cFunctionResult.bIsOk = false;
        cFunctionResult.sError = e.toString();
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("ClsManageHomePage.runCreateBanner - Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }

  private static ClsFunctionResultInt findCode(Connection conn, String sName, String sCode) {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();
    
    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";

      cFnRslt.iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < lstModuleDetails.size(); iPos++) {
        ClsModuleDetails cModuleDetails = lstModuleDetails.get(iPos);
        
        if (ClsMisc.stringsEqual(sName, cModuleDetails.sName, true, true, false )) {
          if (ClsMisc.stringsEqual(sCode, cModuleDetails.sCode, true, true, false )) {
            cFnRslt.iResult = iPos;
          }
        }
      }

      if (cFnRslt.iResult == ClsMisc.iError) {
        cFnRslt.bIsOk = false;
        cFnRslt.sError = "ClsManageHomePage.findCode: Could not find data. Name:" + sName + " - Code: " + sCode;
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
  
  /*{"name":"Home Page","banner_id":"8","width":"130","height":"100","status":"1"}*/
  private static ClsFunctionResultInt getBannerIdFromSettingTxt(String sSettingTxt) {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();
    
    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      cFnRslt.iResult = ClsMisc.iError;

      final int iMode_before = 1;
      final int iMode_number = 2;
      final int iMode_after = 3;
      int iMode = ClsMisc.iError;
      String sNumber = "";
      
      cFnRslt.iResult = ClsMisc.iError;

      int iPos_BannerId = sSettingTxt.indexOf(scText_BannerId); 

      if (iPos_BannerId == -1) {
        cFnRslt.bIsOk = false;
        cFnRslt.sError = "ClsManageHomePage.getBannerIdFromSettingTxt(\"" + sSettingTxt + "\"): Can't find \"" + scText_BannerId + "\"";
      } else {
        int iPos = iPos_BannerId + scText_BannerId.length();
        
        iMode = iMode_before;
        
        while (iPos < sSettingTxt.length()) {
          switch (iMode) {
            case iMode_before:
              if (ClsMisc.stringsEqual(sSettingTxt.substring(iPos, iPos+1), "\"", true, true, false)) 
              { iMode = iMode_number; }
              break;
            case iMode_number:
              if (Character.isDigit(sSettingTxt.charAt(iPos))) 
              { sNumber = sNumber + sSettingTxt.substring(iPos, iPos+1); }

              if (ClsMisc.stringsEqual(sSettingTxt.substring(iPos, iPos+1), "\"", true, true, false)) 
              { iMode = iMode_after; }

              break;
            case iMode_after:
              break;
          }
          
          iPos++;
        }
      }
      
      if ( ClsMisc.stringsEqual(sNumber, "", true, true, false)) 
      { cFnRslt.iResult = 0; }
      else
      { cFnRslt.iResult = Integer.parseInt(sNumber); }
      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("ClsManageHomePage.getBannerIdFromSettingTxt: Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();

      return cFnRslt;
    }
  }
  
  
  /*CREATE PROCEDURE updateModuleSetting(OUT p_bIsOk boolean, IN p_name VARCHAR(64), IN p_code VARCHAR(32), IN p_setting TEXT)*/
  
  private static ClsFunctionResult runUpdateModuleSetting(Connection conn, String sName, String sCode, String sSetting) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call updateModuleSetting( ? , ? , ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setString(2, sName);
        stmt.setString(3, sCode);
        stmt.setString(4, sSetting);
               
        System.out.println(sSql + " - sName: " + sName + " sCode: " + sCode + " sSetting: " + sSetting);

        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
        
        if (cFunctionResult.bIsOk == true) {
          //ClsMisc.printResultset(rs);
        } else {
          System.out.println("");
          System.out.println("ClsManageHomePage.runUpdateModuleSetting: Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();

        cFunctionResult.bIsOk = false;
        cFunctionResult.sError = e.toString();
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("ClsManageHomePage.runUpdateModuleSetting - Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }
}

