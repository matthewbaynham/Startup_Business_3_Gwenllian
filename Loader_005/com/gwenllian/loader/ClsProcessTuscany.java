package com.gwenllian.loader;

import java.util.List;
import java.util.Iterator;
import java.util.Date;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.regex.Pattern;
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

public class ClsProcessTuscany {
  ArrayList<ClsDataRawTuscanyVer1> lstDataRaw;
  ArrayList<ClsDataStep1TuscanyVer1> lstDataStep1;
  ArrayList<ClsProductCrossRef> lstProductCrossRef;
//`  ArrayList<ClsErrorProduct> lstErrorProduct;

  ClsSettings cSettings; 
//  ClsProgressReport cProgressReport;

//  public ClsProcessTuscany(ClsSettings pcSettings, ClsProgressReport pcProgressReport){
  public ClsProcessTuscany(ClsSettings pcSettings){
    try {
      this.cSettings = pcSettings;
      
//      this.lstErrorProduct = new ArrayList<ClsErrorProduct>();
//      this.cProgressReport = pcProgressReport;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.ClsProcessTuscany Exception e");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResult ReadFile(ClsProgressReport cProgressReport, String sSourceFile) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();
    
    try {
      this.lstDataRaw = new ArrayList<ClsDataRawTuscanyVer1>();
      this.lstDataStep1 = new ArrayList<ClsDataStep1TuscanyVer1>(); 

      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      
      /*********************
      *   Open text file   *
      *********************/
       
      File file=new File(sSourceFile);    //creates a new file instance  
      FileReader fr=new FileReader(file);   //reads the file  
      BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
      String sLine;  
      int iLineNo = 0;
      boolean bIsOk = true;
      String sDateFormat = "yyyy-mm-dd hh:mm:ss";
      
      while((sLine=br.readLine())!=null && bIsOk) {  
        System.out.println("");
        System.out.println("-------------------------------------------------------------");
        System.out.println("");

        System.out.println("Line Number: " + Integer.toString(iLineNo));
        System.out.println(sLine);
        
        ArrayList<String> lstLine = ClsMisc.delimitedStringToArrayList(sLine, this.cSettings.getUpload_Delimiter(), "\"");

        boolean bLineIsOk = true;
        
        switch(iLineNo) {
/*
          case 0:
            // Dont do anything because for some reason sLine = com.gwenllian.loader.ClsFieldHeader@76505305
            break;
*/
          case 0:
            /*****************************************
            *   analyse the header row of the file   *
            *****************************************/
            this.cSettings.analyseHeaderRow(sLine);
            bIsOk = this.cSettings.checkIsHeaderRowOK();

            break;
          default:
            /***************************************************************
            *   For each row create an instance of ClsDataRawTuscanyVer1   *
            ***************************************************************/

            ClsDataRawTuscanyVer1 cRawData = new ClsDataRawTuscanyVer1();

            cRawData.sParentCategory = lstLine.get(this.cSettings.getHeaderFieldPos("parent_category"));
            cRawData.sCategory = lstLine.get(this.cSettings.getHeaderFieldPos("category"));
            cRawData.sPartscode = lstLine.get(this.cSettings.getHeaderFieldPos("partscode"));
            cRawData.sBrandName = lstLine.get(this.cSettings.getHeaderFieldPos("brand_name"));
            cRawData.sEan = lstLine.get(this.cSettings.getHeaderFieldPos("ean"));
            cRawData.sSku = lstLine.get(this.cSettings.getHeaderFieldPos("sku"));

            cProgressReport.somethingToNote("ReadFile", "Partscode: " + cRawData.sPartscode + " - Ean: " + cRawData.sEan + " - Sku: " + cRawData.sSku, iLineNo, "tracking");
              
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("quantity")), "", true, true, true)) {
              cRawData.iQuantity = 0;
            } else {
              if (ClsMisc.isInt (lstLine.get(this.cSettings.getHeaderFieldPos("quantity")))) {
                cRawData.iQuantity = Integer.parseInt((lstLine.get(this.cSettings.getHeaderFieldPos("quantity"))));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("quantity")), iLineNo, "Quantity not an integer");
                cRawData.iQuantity = 0;
                bLineIsOk = false;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("estimated_arrival_date")), "", true, true, true)) {
              cRawData.dteEstimatedArrivalDate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
            } else {
              try {
                String sTempDate = lstLine.get(this.cSettings.getHeaderFieldPos("estimated_arrival_date"));
                if (Pattern.matches("20[0-4][0-9]-[0-1][0-9]-[0-3][0-9]", sTempDate)) {
                  sTempDate = sTempDate + " 00:00:00";
                }
                
                cRawData.dteEstimatedArrivalDate = new SimpleDateFormat(sDateFormat).parse(sTempDate);
              } catch(Exception e) {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("estimated_arrival_date")), iLineNo, "estimated_arrival_date failed to parse into a date");
                cRawData.dteEstimatedArrivalDate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
              }
            }

            cRawData.sPhaseOut = lstLine.get(this.cSettings.getHeaderFieldPos("phase_out"));
            cRawData.sModelname = lstLine.get(this.cSettings.getHeaderFieldPos("modelname"));
            cRawData.sOption = lstLine.get(this.cSettings.getHeaderFieldPos("option"));
            cRawData.sCustomization = lstLine.get(this.cSettings.getHeaderFieldPos("customization"));
            cRawData.sCustomizationCharLimit = lstLine.get(this.cSettings.getHeaderFieldPos("customization_char_limit"));
            cRawData.sDescription = lstLine.get(this.cSettings.getHeaderFieldPos("description"));
            cRawData.sUnitMeasure = lstLine.get(this.cSettings.getHeaderFieldPos("unit_measure"));
            cRawData.sUnitWeight = lstLine.get(this.cSettings.getHeaderFieldPos("unit_weight"));
              
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("item_length")), "", true, true, true)) {
              cRawData.fItemLength = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_length")))) {
                cRawData.fItemLength = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_length")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("item_length")), iLineNo, "item_length not a Float");
                cRawData.fItemLength = 0.0f;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("item_height")), "", true, true, true)) {
              cRawData.fItemHeight = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_height")))) {
                cRawData.fItemHeight = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_height")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("item_height")), iLineNo, "item_height not a Float");
                cRawData.fItemHeight = 0.0f;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("item_width")), "", true, true, true)) {
              cRawData.fItemWidth = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_width")))) {
                cRawData.fItemWidth = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_width")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("item_width")), iLineNo, "item_width not a Float");
                cRawData.fItemWidth = 0.0f;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("item_weight")), "", true, true, true)) {
              cRawData.fItemWeight = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_weight")))) {
                cRawData.fItemWeight = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("item_weight")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("item_weight")), iLineNo, "item_weight not a Float");
                cRawData.fItemWeight = 0.0f;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_length")), "", true, true, true)) {
              cRawData.fShippingLength = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_length")))) {
                cRawData.fShippingLength = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_length")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("shipping_length")), iLineNo, "shipping_length not a Float");
                cRawData.fShippingLength = 0.0f;
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_height")), "", true, true, true))
            { cRawData.fShippingHeight = 0.0f; }
            else
            { cRawData.fShippingHeight = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_height"))); }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_width")), "", true, true, true))
            { cRawData.fShippingWidth = 0.0f; }
            else
            { cRawData.fShippingWidth = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_width"))); }


            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_weight")), "", true, true, true))
            { cRawData.fShippingWeight = 0.0f; }
            else
            { cRawData.fShippingWeight = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("shipping_weight"))); }

            cRawData.sCurrency = lstLine.get(this.cSettings.getHeaderFieldPos("currency"));

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("retailprice")), "", true, true, true))
            { cRawData.fRetailprice = 0.0f; }
            else
            { cRawData.fRetailprice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("retailprice"))); }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("retailspecialprice")), "", true, true, true))
            { cRawData.fRetailspecialprice = 0.0f; }
            else
            { cRawData.fRetailspecialprice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("retailspecialprice"))); }

            if (lstLine.get(this.cSettings.getHeaderFieldPos("retailexpiredate")) == "") {
              cRawData.dteRetailexpiredate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
            } else {
              try {  
                cRawData.dteRetailexpiredate = new SimpleDateFormat(sDateFormat).parse(lstLine.get(this.cSettings.getHeaderFieldPos("retailexpiredate")));
              } catch(Exception e) {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("retailexpiredate")), iLineNo, "retailexpiredate failed to parse into a date");
                cRawData.dteRetailexpiredate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("resellerprice")), "", true, true, true))
            { cRawData.fResellerprice = 0.0f; }
            else
            { cRawData.fResellerprice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("resellerprice"))); }



            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("resellerspecialprice")), "", true, true, false))
            { cRawData.fResellerspecialprice = 0.0f; }
            else
            { cRawData.fResellerspecialprice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("resellerspecialprice"))); }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("resellerexpiredate")), "", true, true, true)) {
              cRawData.dteResellerexpiredate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
            } else {
              try {  
                cRawData.dteResellerexpiredate = new SimpleDateFormat(sDateFormat).parse(lstLine.get(this.cSettings.getHeaderFieldPos("resellerexpiredate")));
              } catch(Exception e) {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("resellerexpiredate")), iLineNo, "resellerexpiredate failed to parse into a date");
                cRawData.dteResellerexpiredate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
              }
            }

            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("publish_date")), "", true, true, false)) {
              cRawData.dtePublishDate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
            } else {
              try {  
                cRawData.dtePublishDate = new SimpleDateFormat(sDateFormat).parse(lstLine.get(this.cSettings.getHeaderFieldPos("publish_date")));
              } catch(Exception e) {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("publish_date")), iLineNo, "publish_date failed to parse into a date");
                cRawData.dtePublishDate = new SimpleDateFormat(ClsMisc.sDateNullFormat).parse(ClsMisc.sDateNullValue);
              }
            }

            cRawData.sImage1 = lstLine.get(this.cSettings.getHeaderFieldPos("image_1"));
            cRawData.sImage2 = lstLine.get(this.cSettings.getHeaderFieldPos("image_2"));
            cRawData.sImage3 = lstLine.get(this.cSettings.getHeaderFieldPos("image_3"));
            cRawData.sImage4 = lstLine.get(this.cSettings.getHeaderFieldPos("image_4"));
            cRawData.sImage5 = lstLine.get(this.cSettings.getHeaderFieldPos("image_5"));
            cRawData.sImage6 = lstLine.get(this.cSettings.getHeaderFieldPos("image_6"));
            cRawData.sImage7 = lstLine.get(this.cSettings.getHeaderFieldPos("image_7"));
            cRawData.sImage8 = lstLine.get(this.cSettings.getHeaderFieldPos("image_8"));
            cRawData.sImage9 = lstLine.get(this.cSettings.getHeaderFieldPos("image_9"));
            cRawData.sImage10 = lstLine.get(this.cSettings.getHeaderFieldPos("image_10"));

            if (cRawData.sParentCategory.length() > 255) {
              cProgressReport.somethingToNote("ReadFile", cRawData.sParentCategory, iLineNo, "Parent Category too long");
              cRawData.sParentCategory = cRawData.sParentCategory.substring(0, 255);
            }
             
            if (cRawData.sCategory.length() > 255) {
              cProgressReport.somethingToNote("ReadFile", cRawData.sCategory, iLineNo, "Category too long");
              cRawData.sCategory = cRawData.sCategory.substring(0, 255);
            }

            if (cRawData.sOption.length() > 128) {
              cProgressReport.somethingToNote("ReadFile", cRawData.sOption, iLineNo, "Option too long");
              cRawData.sOption = cRawData.sOption.substring(0, 128);
            }

            if (cRawData.sImage1.length() > 255) 
            { cRawData.sImage1 = cRawData.sImage1.substring(0, 255); }

            if (cRawData.sImage2.length() > 255) 
            { cRawData.sImage2 = cRawData.sImage2.substring(0, 255); }

            if (cRawData.sImage3.length() > 255) 
            { cRawData.sImage3 = cRawData.sImage3.substring(0, 255); }

            if (cRawData.sImage4.length() > 255) 
            { cRawData.sImage4 = cRawData.sImage4.substring(0, 255); }

            if (cRawData.sImage5.length() > 255) 
            { cRawData.sImage5 = cRawData.sImage5.substring(0, 255); }

            if (cRawData.sImage6.length() > 255) 
            { cRawData.sImage6 = cRawData.sImage6.substring(0, 255); }

            if (cRawData.sImage7.length() > 255) 
            { cRawData.sImage7 = cRawData.sImage7.substring(0, 255); }

            if (cRawData.sImage8.length() > 255) 
            { cRawData.sImage8 = cRawData.sImage8.substring(0, 255); }

            if (cRawData.sImage9.length() > 255) 
            { cRawData.sImage9 = cRawData.sImage9.substring(0, 255); }

            if (cRawData.sImage10.length() > 255) 
            { cRawData.sImage10 = cRawData.sImage10.substring(0, 255); }

            /*************************************************************
            *   Add all instances of ClsDataRawTuscanyVer1 to the list   *
            *************************************************************/
            this.lstDataRaw.add(cRawData);

        }  //switch
        iLineNo++;
      }  //while
      
      fr.close();    //closes the stream and release the resources  

      System.out.println("file closed");

      return cFunctionResult;
    } catch(IOException e) {  
      e.printStackTrace();  
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.ReadFile Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult processLstDataRaw(ClsProgressReport cProgressReport) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      this.lstProductCrossRef = new ArrayList<ClsProductCrossRef>();
      
      for (int iRawPos = 0; iRawPos < this.lstDataRaw.size(); iRawPos++) {
        ClsDataRawTuscanyVer1 cRawData = this.lstDataRaw.get(iRawPos);
        
        boolean bIsFound = false;
        int iPos = findProductPosition(cRawData);

        if (iPos == ClsMisc.iError) {
          /****************************************************************************************
          *   We don't have the item in lstDataStep1                                              *
          *   so we have to create an instance of ClsDataStep1TuscanyVer1 as add it to the list   *
          ****************************************************************************************/
          ClsDataStep1TuscanyVer1 cDataStep1 = new ClsDataStep1TuscanyVer1(); 

          cDataStep1.sParentCategory = cRawData.sParentCategory.trim();
          cDataStep1.sCategory = cRawData.sCategory.trim();
          cDataStep1.sPartscode = cRawData.sPartscode.trim();
          cDataStep1.sBrandName = cRawData.sBrandName.trim();
          cDataStep1.sEan = cRawData.sEan.trim();
          cDataStep1.sSku = cRawData.sSku.trim();

          cProgressReport.somethingToNote("processLstDataRaw", "Partscode: " + cDataStep1.sPartscode + " - Ean: " + cDataStep1.sEan + " - Sku: " + cDataStep1.sSku, iRawPos, "tracking");

          cDataStep1.iQuantity = cRawData.iQuantity;
          cDataStep1.dteEstimatedArrivalDate = cRawData.dteEstimatedArrivalDate;
          cDataStep1.sPhaseOut = cRawData.sPhaseOut.trim();
          cDataStep1.sModelname = cRawData.sModelname.trim() + " (" + cRawData.sOption.trim() + ")";
          if (cDataStep1.lstOptions == null) 
          { cDataStep1.lstOptions = new ArrayList<String>(); }
          cDataStep1.lstOptions.add(cRawData.sOption.trim());
          cDataStep1.sCustomization = cRawData.sCustomization.trim();
          cDataStep1.sCustomizationCharLimit = cRawData.sCustomizationCharLimit.trim();
          cDataStep1.sDescription = cRawData.sDescription.trim();
          cDataStep1.sUnitMeasure = cRawData.sUnitMeasure.trim();
          cDataStep1.sUnitWeight = cRawData.sUnitWeight.trim();
          cDataStep1.fItemLength = cRawData.fItemLength;
          cDataStep1.fItemHeight = cRawData.fItemHeight;
          cDataStep1.fItemWidth = cRawData.fItemWidth;
          cDataStep1.fItemWeight = cRawData.fItemWeight;
          cDataStep1.fShippingLength = cRawData.fShippingLength;
          cDataStep1.fShippingHeight = cRawData.fShippingHeight;
          cDataStep1.fShippingWidth = cRawData.fShippingWidth;
          cDataStep1.fShippingWeight = cRawData.fShippingWeight;
          cDataStep1.sCurrency = cRawData.sCurrency.trim();
          cDataStep1.fRetailprice = cRawData.fRetailprice;
          cDataStep1.fRetailspecialprice = cRawData.fRetailspecialprice;
          cDataStep1.dteRetailexpiredate = cRawData.dteRetailexpiredate;
          cDataStep1.fResellerprice = cRawData.fResellerprice;
          cDataStep1.fResellerspecialprice = cRawData.fResellerspecialprice;
          cDataStep1.dteResellerexpiredate = cRawData.dteResellerexpiredate;
          cDataStep1.dtePublishDate = cRawData.dtePublishDate;

          if (cDataStep1.lstImages == null)
          { cDataStep1.lstImages = new ArrayList<String>(); }

          if (!ClsMisc.stringsEqual(cRawData.sImage1, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage1.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage2, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage2.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage3, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage3.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage4, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage4.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage5, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage5.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage6, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage6.trim()); }
             
          if (!ClsMisc.stringsEqual(cRawData.sImage7, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage7.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage8, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage8.trim()); }
              
          if (!ClsMisc.stringsEqual(cRawData.sImage9, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage9.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sImage10, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sImage10.trim()); }

          if (cDataStep1.lstImages.size() > 1) {
            /* make images unique */
            for (int iPosOne = cDataStep1.lstImages.size() - 2; iPosOne > -1; iPosOne--) {
              String sImageOne = cDataStep1.lstImages.get(iPosOne);
              
              for (int iPosTwo = cDataStep1.lstImages.size() - 1; iPosTwo > iPosOne; iPosTwo--) {
                String sImageTwo = cDataStep1.lstImages.get(iPosTwo);
                
                if (ClsMisc.stringsEqual(sImageOne, sImageTwo, true, true, true) && iPosOne != iPosTwo)
                { cDataStep1.lstImages.remove(iPosTwo); }
              }
            }
          }
          
          cDataStep1.iProductId = ClsMisc.iError;
          
          this.lstDataStep1.add(cDataStep1);
        } else {
          /*******************************************************************************
          *   When we already have the item in lstDataStep1,                             *
          *   then we have to check that we have the option in lstDataStep1.lstOptions   *
          *******************************************************************************/

          boolean bOptionIsFound = false;
          int iOptionPos = ClsMisc.iError;

          for (int iTemp = 0; iTemp < this.lstDataStep1.get(iPos).lstOptions.size(); iTemp++) {
            if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).lstOptions.get(iTemp), cRawData.sOption, true, true, true)) {
              iOptionPos = iTemp;
            }
          }
              
          if (iOptionPos == ClsMisc.iError) {
            this.lstDataStep1.get(iPos).lstOptions.add(cRawData.sOption.trim());
          }
        }

        /***************************************************************************************************
        *   Create my own cross reference table to keep track of reference codes across multiple options   *
        ***************************************************************************************************/
          
        ClsProductCrossRef cProductCrossRef = new ClsProductCrossRef();

        cProductCrossRef.sPartscode = cRawData.sPartscode;
        cProductCrossRef.sEan = cRawData.sEan;
        cProductCrossRef.sSku = cRawData.sSku;
        cProductCrossRef.sOption = cRawData.sOption;
        
        if (this.lstProductCrossRef == null)
        { this.lstProductCrossRef = new ArrayList<ClsProductCrossRef>();}
        
        this.lstProductCrossRef.add(cProductCrossRef);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.processLstDataRaw Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public int findProductPosition(ClsDataRawTuscanyVer1 cRawData) {
    try {
      int iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < this.lstDataStep1.size();iPos++) {
        if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).sPartscode, cRawData.sPartscode, true, true, false)) { 
          if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).sModelname, cRawData.sModelname, true, true, false)) { 
            if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).sSku, cRawData.sSku, true, true, false)) {
              if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).sEan, cRawData.sEan, true, true, false)) {
                iResult = iPos;
              }
            }
          }
        }
      }

      return iResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.findProductPosition Exception e");
      System.out.println(e);
      
      return ClsMisc.iError;
    }
  }

  public ClsFunctionResult uploadToMySqlServer(int iUploadTypeId, ClsProgressReport cProgressReport, int iLanguageId, Connection conn, String sTaxClassName, String sImagesDir, String sImageRootDirectory) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      
      ClsStockStatus cStockStatus = new ClsStockStatus(conn, iLanguageId);
      ClsManufacturerId cManufacturerId = new ClsManufacturerId();
      ClsTaxClass cTaxClass = new ClsTaxClass(cProgressReport, conn);
      ClsWeightClassId cWeightClassId = new ClsWeightClassId(conn, iLanguageId);
      ClsLengthClassId cLengthClassId = new ClsLengthClassId(conn, iLanguageId);
      ClsAttributeId cAttributeIds = new ClsAttributeId();
      ClsImageManagement cImageManagement = new ClsImageManagement(conn);
      ClsCategoryClassId cCategoryId = new ClsCategoryClassId(iLanguageId, conn);
      
      /*************************************************************
      *   Look through each of the elements in this.lstDataStep1   *
      *************************************************************/
      
      for (int iDataPos = 0; iDataPos < this.lstDataStep1.size(); iDataPos++) {
        ClsDataStep1TuscanyVer1 cDataStep1 = this.lstDataStep1.get(iDataPos);
        boolean bLineFailedChecks = false;

        /************************************************************************
        *   Create seperate variable for each parameter the stored proc needs   *
        ************************************************************************/
        final int iFlag_add = 1;
        final int iFlag_edit = 2;
        final int iFlag_ignore = 3;
        
        boolean bIsOk = true;
        int iprd_product_id = -1;
        int ilanguage_id = iLanguageId;
        String sPrd_model = cDataStep1.sPartscode;
        String sPrd_sku = cDataStep1.sSku;
        String sPrd_upc = cDataStep1.sPartscode;
        String sPrd_ean = cDataStep1.sEan;
        String sPrd_jan = "";
        String sPrd_isbn = ""; //NA
        String sPrd_mpn = ""; 
        String sPrd_location = ""; //NA

        cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " - Ean: " + cDataStep1.sEan + " - Sku: " + sPrd_sku, iDataPos, "tracking");

        int iPrd_quantity = cDataStep1.iQuantity;
        int iPrd_stock_status_id = ClsMisc.iError;



/***********************************************************
*                                                          *
*   ****************************************************   *
*   *   Change this so that it's not always in stock   *   *
*   ****************************************************   *
*                                                          *
***********************************************************/


/*
        ClsFunctionResultInt cStockStatusResultInt = cStockStatus.getId("In Stock");
        if (cStockStatusResultInt.bIsOk) { 
          iPrd_stock_status_id = cStockStatusResultInt.iResult;
        } else { 
          System.out.println("Error calling ClsFunctionResultInt cStockStatusResultInt = cStockStatus.getId(...);"); 
          System.out.println(cStockStatusResultInt.sError); 
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cStockStatus.getId (In Stock) (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cStockStatusResultInt.sError, iDataPos, cStockStatusResultInt.sError);
        }
*/







        String sPrd_image = "";
        if (cDataStep1.lstImages.size() != 0) { 
          ClsFunctionResultString cFnRsltStr_ImagePath = cImageManagement.getImagePath(iUploadTypeId, sImagesDir, cDataStep1.lstImages.get(0), conn);
          
          if (cFnRsltStr_ImagePath.bIsOk) {
            sPrd_image = cFnRsltStr_ImagePath.sResult; 
            
            ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sPrd_image, sImageRootDirectory);
            
            if (cFnRsltStr_CutPath.bIsOk)
            { sPrd_image = cFnRsltStr_CutPath.sResult; }
          } else {
            System.out.println("Error cImageManagement.getImagePath:"); 
            System.out.println(cFnRsltStr_ImagePath.sError); 
            cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cImageManagement.getImagePath (Images Dir: " + sImagesDir + ") (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFnRsltStr_ImagePath.sError, iDataPos, cFnRsltStr_ImagePath.sError);
          }
        }
        
        int iPrd_manufacturer_id = cManufacturerId.getId(cDataStep1.sBrandName, conn, cProgressReport);
        int iPrd_shipping = 1; //"Requires Shipping" 1=yes, 0=no (then shipping is based on what is in the extensions)
        double dPrd_price = cDataStep1.fRetailprice;
        int iPrd_points = 0;

        ClsFunctionResultInt cFunctionResultTaxClass = cTaxClass.getId(sTaxClassName);
        int iPrd_tax_class_id = cFunctionResultTaxClass.iResult;
        
        if (cFunctionResultTaxClass.bIsOk) {
          iPrd_tax_class_id = cFunctionResultTaxClass.iResult;
        } else {
          System.out.println("Error in cTaxClass");
          System.out.println(cFunctionResultTaxClass.sError);
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cTaxClass (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFunctionResultTaxClass.sError, iDataPos, cFunctionResultTaxClass.sError);
        }

        java.sql.Date dtePrd_date_available = new java.sql.Date(cDataStep1.dtePublishDate.getTime());// new Date(1000000000);
        double dPrd_weight = cDataStep1.fShippingWeight;

        ClsFunctionResultInt cFunctionResultWeightClassId = cWeightClassId.getId(cDataStep1.sUnitWeight);
        int iPrd_weight_class_id = cFunctionResultWeightClassId.iResult;

        if (!cFunctionResultWeightClassId.bIsOk) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in ClsWeightClassId (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFunctionResultWeightClassId.sError, iDataPos, cFunctionResultWeightClassId.sError);
          System.out.println("Error in ClsWeightClassId");
          System.out.println(cFunctionResultWeightClassId.sError);
        }

        double dPrd_length = cDataStep1.fShippingLength;
        double dPrd_width = cDataStep1.fShippingWidth;
        double dPrd_height = cDataStep1.fShippingHeight;

        ClsFunctionResultInt cFunctionResultIntLengthClass = cLengthClassId.getId(cDataStep1.sUnitMeasure);
        int iPrd_length_class_id = cFunctionResultIntLengthClass.iResult;

        if (!cFunctionResultIntLengthClass.bIsOk) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in ClsLengthClassId (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFunctionResultIntLengthClass.sError, iDataPos, cFunctionResultIntLengthClass.sError);
          System.out.println("Error in ClsLengthClassId");
          System.out.println(cFunctionResultIntLengthClass.sError);
        }

        int iPrd_subtract = 0;
        int iPrd_minimum = 0;
        int iPrd_sort_order = 0;
        int iPrd_status = 1;
        String sDesc_name = cDataStep1.sModelname;
        String sDesc_description = cDataStep1.sDescription;
        String sDesc_tag = "";
        String sDesc_meta_title = cDataStep1.sModelname;
        String sDesc_meta_description = cDataStep1.sModelname;
        String sDesc_meta_keyword = "";
        String sConcat_image = "";
        String sConcat_image_sort_order = "";
        String sStatusText = "";

        for (int iImageCount = 0; iImageCount < cDataStep1.lstImages.size(); iImageCount++) {
          String sImageUrl = cDataStep1.lstImages.get(iImageCount);
          String sImagePath = "";
          
          ClsFunctionResultString cFnRsltStr_ImagePath = cImageManagement.getImagePath(iUploadTypeId, sImagesDir, cDataStep1.lstImages.get(iImageCount), conn);

          if (cFnRsltStr_ImagePath.bIsOk) {
            sImagePath = cFnRsltStr_ImagePath.sResult; 
            
            ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sImagePath, sImageRootDirectory);
            
            if (cFnRsltStr_CutPath.bIsOk)
            { sImagePath = cFnRsltStr_CutPath.sResult; }
            
            if (ClsMisc.stringsEqual(sConcat_image, "", true, true, true)) {
              sConcat_image = sImagePath;
              sConcat_image_sort_order = Integer.toString(iImageCount);
            } else {
              sConcat_image = sConcat_image + "\t" + sImagePath;
              sConcat_image_sort_order = sConcat_image_sort_order + "\t" + Integer.toString(iImageCount);
            }
          } else {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Error - Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + " cImageManagement.getImagePath(" + Integer.toString(iUploadTypeId) + ", " + sImagesDir + ", " + cDataStep1.lstImages.get(iImageCount) + ": " + cFnRsltStr_ImagePath.sError, iDataPos, cFnRsltStr_ImagePath.sError);
            System.out.print("iImageCount: ");
            System.out.println(iImageCount);
            System.out.println("Error cImageManagement.getImagePath(" + Integer.toString(iUploadTypeId) + ", " + sImagesDir + ", " + cDataStep1.lstImages.get(iImageCount) + ":"); 
            System.out.println(cFnRsltStr_ImagePath.sError); 
          }
        }

        int iFlag_product = iFlag_add;
        int iFlag_description = iFlag_add;
        int iFlag_images = iFlag_add;
        ArrayList<ClsAttribute> lstAttribute = new ArrayList<ClsAttribute>();
        ClsFunctionResult cAttributeResult;

        /**** "Item", "Height" ****/
        
        ClsAttribute cAttribute_ItemHeight = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Item", "Height", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ItemHeight.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ItemHeight.iId = cAttributeIds.getId();
        cAttribute_ItemHeight.sGroupName = "Item";
        cAttribute_ItemHeight.sName = "Height";
        cAttribute_ItemHeight.sValue = Float.toString(cDataStep1.fShippingHeight) + cDataStep1.sUnitMeasure;
        cAttribute_ItemHeight.iSortOrder = 1;
        lstAttribute.add(cAttribute_ItemHeight);

        /**** "Item", "Width" ****/
        
        ClsAttribute cAttribute_ItemWidth = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Item", "Width", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Width, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Item, Width, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ItemWidth.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ItemWidth.iId = cAttributeIds.getId();
        cAttribute_ItemWidth.sGroupName = "Item";
        cAttribute_ItemWidth.sName = "Width";
        cAttribute_ItemWidth.sValue = Float.toString(cDataStep1.fShippingWidth) + cDataStep1.sUnitMeasure;
        cAttribute_ItemWidth.iSortOrder = 2;
        lstAttribute.add(cAttribute_ItemWidth);

        /**** "Item", "Length" ****/
        
        ClsAttribute cAttribute_ItemLength = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Item", "Length", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Length, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Item, Length, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ItemLength.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ItemLength.iId = cAttributeIds.getId();
        cAttribute_ItemLength.sGroupName = "Item";
        cAttribute_ItemLength.sName = "Length";
        cAttribute_ItemLength.sValue = Float.toString(cDataStep1.fShippingLength) + cDataStep1.sUnitMeasure;
        cAttribute_ItemLength.iSortOrder = 3;
        lstAttribute.add(cAttribute_ItemLength);

        /**** "Item", "Weight" ****/

        ClsAttribute cAttribute_ItemWeight = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Item", "Weight", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Weight, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Item, Weight, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ItemWeight.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ItemWeight.iId = cAttributeIds.getId();
        cAttribute_ItemWeight.sGroupName = "Item";
        cAttribute_ItemWeight.sName = "Weight";
        cAttribute_ItemWeight.sValue = Float.toString(cDataStep1.fItemWeight) + cDataStep1.sUnitWeight;
        cAttribute_ItemWeight.iSortOrder = 4;
        lstAttribute.add(cAttribute_ItemWeight);

        /**** "Shipping", "Height" ****/

        ClsAttribute cAttribute_ShippingHeight = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Shipping", "Height", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Shipping, Height, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Shipping, Height, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ShippingHeight.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ShippingHeight.iId = cAttributeIds.getId();
        cAttribute_ShippingHeight.sGroupName = "Shipping";
        cAttribute_ShippingHeight.sName = "Height";
        cAttribute_ShippingHeight.sValue = Float.toString(cDataStep1.fShippingHeight) + cDataStep1.sUnitMeasure;
        cAttribute_ShippingHeight.iSortOrder = 5;
        lstAttribute.add(cAttribute_ShippingHeight);

        /**** "Shipping", "Width" ****/
        
        ClsAttribute cAttribute_ShippingWidth = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Shipping", "Width", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Shipping, Width, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Shipping, Width, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ShippingWidth.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ShippingWidth.iId = cAttributeIds.getId();
        cAttribute_ShippingWidth.sGroupName = "Shipping";
        cAttribute_ShippingWidth.sName = "Width";
        cAttribute_ShippingWidth.sValue = Float.toString(cDataStep1.fShippingWidth) + cDataStep1.sUnitMeasure;
        cAttribute_ShippingWidth.iSortOrder = 6;
        lstAttribute.add(cAttribute_ShippingWidth);

        /**** "Shipping", "Length" ****/
        
        ClsAttribute cAttribute_ShippingLength = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Shipping", "Length", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Shipping, Length, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Shipping, Length, iLanguageId, conn); Error");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ShippingLength.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ShippingLength.iId = cAttributeIds.getId();
        cAttribute_ShippingLength.sGroupName = "Shipping";
        cAttribute_ShippingLength.sName = "Length";
        cAttribute_ShippingLength.sValue = Float.toString(cDataStep1.fShippingLength) + cDataStep1.sUnitMeasure;
        cAttribute_ShippingLength.iSortOrder = 7;
        lstAttribute.add(cAttribute_ShippingLength);
        
        /**** "Shipping", "Weight" ****/
        
        ClsAttribute cAttribute_ShippingWeigth = new ClsAttribute();
        cAttributeResult = cAttributeIds.prepList("Shipping", "Weight", iLanguageId, conn);
        if (!cAttributeResult.bIsOk) {
          bIsOk = false;
          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Shipping, Weight, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
          System.out.println("cAttributeIds.prepList(Shipping, Weight, iLanguageId, conn); Error:");
          System.out.println(cAttributeResult.sError);
        }
        cAttribute_ShippingWeigth.iGroupId = cAttributeIds.getGroupId();
        cAttribute_ShippingWeigth.iId = cAttributeIds.getId();
        cAttribute_ShippingWeigth.sGroupName = "Shipping";
        cAttribute_ShippingWeigth.sName = "Weight";
        cAttribute_ShippingWeigth.sValue = Float.toString(cDataStep1.fItemWeight) + cDataStep1.sUnitWeight;
        cAttribute_ShippingWeigth.iSortOrder = 8;
        lstAttribute.add(cAttribute_ShippingWeigth);

        ResultSet rs;

        /********************************************************************************************
        *   Santy checks each variable that is going to be sent as a parameter to the stored proc   *
        ********************************************************************************************/
        if (sPrd_model.length() > 64) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Model: " + sPrd_model + " model length: "+ Integer.toString(sPrd_model.length()), iDataPos, "model too long max aloud 64");
          sPrd_model = sPrd_model.substring(0, 64).trim();
        }

        if (sPrd_sku.length() > 64) {
          System.out.println("five point one");
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " sku: " + sPrd_sku + " sku length: " + Integer.toString(sPrd_sku.length()), iDataPos, "sku too long max aloud 64");
          sPrd_sku = sPrd_sku.substring(0, 63).trim();
        }

        if (sPrd_upc.length() > 12) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " upc: " + sPrd_upc + " upc length: " + Integer.toString(sPrd_upc.length()), iDataPos, "upc too long max aloud 12");
          sPrd_upc = sPrd_upc.substring(0, 12).trim();
        }
        
        if (sPrd_ean.length() > 14) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " ean: " + sPrd_ean + " ean length: " + Integer.toString(sPrd_ean.length()), iDataPos, "ean too long max aloud 14");
          sPrd_ean = sPrd_ean.substring(0, 14).trim();
        }

        if (sPrd_jan.length() > 13) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " jan: " + sPrd_jan + " jan length: " +  Integer.toString(sPrd_jan.length()), iDataPos, "jan too long max aloud 13");
          sPrd_jan = sPrd_jan.substring(0, 13).trim();
        }

        if (sPrd_isbn.length() > 17) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " isbn: " + sPrd_isbn + " isbn length: " + Integer.toString(sPrd_isbn.length()), iDataPos, "isbn too long max aloud 17");
          sPrd_isbn = sPrd_isbn.substring(0, 17).trim();
        }

        if (sPrd_mpn.length() > 64) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " mpn: " + sPrd_mpn + " isbn length: " + Integer.toString(sPrd_mpn.length()), iDataPos, "mpn too long max aloud 64");
          sPrd_mpn = sPrd_mpn.substring(0, 64).trim();
        }
        
        if (sPrd_location.length() > 128) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: "+ sPrd_model + " location: " + sPrd_location + " location length: " + Integer.toString(sPrd_location.length()), iDataPos, "location too long max aloud 128");
          sPrd_location = sPrd_location.substring(0, 128).trim();
        }
        
        if (iPrd_quantity < 0) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " quantity: " + Integer.toString(iPrd_quantity), iDataPos, "Negative quantity");
          bLineFailedChecks = true;
        }
        
        
        
/**************************
*                         *        
*   *******************   *
*   *   Change here   *   *
*   *******************   *
*                         *        
**************************/
        ClsFunctionResultInt cStockStatusResultInt = new ClsFunctionResultInt();
        if (iPrd_quantity > 0)
        { cStockStatusResultInt = cStockStatus.getId("In Stock"); }
        else
        { cStockStatusResultInt = cStockStatus.getId("Out Of Stock"); }

        if (cStockStatusResultInt.bIsOk) { 
          iPrd_stock_status_id = cStockStatusResultInt.iResult;
        } else { 
          System.out.println("Error calling ClsFunctionResultInt cStockStatusResultInt = cStockStatus.getId(...);"); 
          System.out.println(cStockStatusResultInt.sError); 
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cStockStatus.getId (...) (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + " quantity: " + Integer.toString(iPrd_quantity) + "): " + cStockStatusResultInt.sError, iDataPos, cStockStatusResultInt.sError);
        }
        
        
        
        
        
        
        
        if (iPrd_stock_status_id == ClsMisc.iError) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " stock status id: " + Integer.toString(iPrd_stock_status_id), iDataPos, "Unknown stock status ID");
          bLineFailedChecks = true;
        } 

        if (sPrd_image.length() > 255) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " image: " + sPrd_image + " image length: " + Integer.toString(sPrd_image.length()), iDataPos, "image too long max aloud 128");
          sPrd_image = sPrd_image.substring(0, 255).trim();
        }

        if (iPrd_manufacturer_id == ClsMisc.iError) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " manufacturer id: " + Integer.toString(iPrd_manufacturer_id), iDataPos, "unknown manufacturer id");
          bLineFailedChecks = true;
        }

        if (dPrd_weight < 0.0f) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " weight: " + Double.toString(dPrd_weight), iDataPos, "weight must not be negative");
          bLineFailedChecks = true;
        }

        if (iPrd_weight_class_id == ClsMisc.iError) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " weight class id: " + Integer.toString(iPrd_weight_class_id), iDataPos, "unknown weight class id");
          bLineFailedChecks = true;
        }
        
        if (dPrd_length < 0.0f) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " length: " + Double.toString(dPrd_length), iDataPos, "length must not be negative");
          bLineFailedChecks = true;
        }
        
        if (dPrd_width < 0.0f) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " width: " + Double.toString(dPrd_width), iDataPos, "width must not be negative");
          bLineFailedChecks = true;
        }
        
        if (dPrd_height < 0.0f) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " height: " + Double.toString(dPrd_height), iDataPos, "height must not be negative");
          bLineFailedChecks = true;
        }

        if (sDesc_name.length() > 255) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " name: " + sDesc_name + " name length: " + Integer.toString(sDesc_name.length()), iDataPos, "name too long max aloud 255");
          sDesc_name = sDesc_name.substring(0, 255).trim();
        }
        
        if (sDesc_description.length() > 65536) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " description: " + sDesc_description + " description length: " + Integer.toString(sDesc_description.length()), iDataPos, "description too long max aloud 65536");
          sDesc_description = sDesc_description.substring(0, 65536).trim();
        }
        
        if (sDesc_tag.length() > 65536) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " tag: " + sDesc_tag + " tag length: " + Integer.toString(sDesc_tag.length()), iDataPos, "tag too long max aloud 65536");
          sDesc_tag = sDesc_tag.substring(0, 65536).trim();
        }

        if (sDesc_meta_title.length() > 255) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta title: " + sDesc_meta_title + " meta title length: " + Integer.toString(sDesc_meta_title.length()), iDataPos, "meta title too long max aloud 255");
          sDesc_meta_title = sDesc_meta_title.substring(0, 255).trim();
        }

        if (sDesc_meta_description.length() > 255) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta description: " + sDesc_meta_description + " meta description length: " + Integer.toString(sDesc_meta_description.length()), iDataPos, "meta description too long max aloud 255");
          sDesc_meta_description = sDesc_meta_description.substring(0, 255).trim();
        }

        if (sDesc_meta_keyword.length() > 255) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta keyword: " + sDesc_meta_keyword + " meta keyword length: " + Integer.toString(sDesc_meta_keyword.length()), iDataPos, "meta keyword too long max aloud 255");
          sDesc_meta_keyword = sDesc_meta_keyword.substring(0, 255).trim();
        }

        if (sConcat_image.length() > 4000) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Concat image: " + sConcat_image + " Concat image length: " + Integer.toString(sConcat_image.length()), iDataPos, "Concat image too long max aloud 4000");
          sConcat_image = sConcat_image.substring(0, 4000).trim();
        }
        
        if (sConcat_image_sort_order.length() > 4000) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Concat sort order: " + sConcat_image_sort_order + " Concat sort order length: " + Integer.toString(sConcat_image_sort_order.length()), iDataPos, "Concat sort order too long max aloud 4000");
          sConcat_image_sort_order = sConcat_image_sort_order.substring(0, 4000).trim();
        }
        
        if (!(iFlag_product == iFlag_add || iFlag_product == iFlag_edit || iFlag_product == iFlag_ignore)) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Product Flag: " + Integer.toString(iFlag_product), iDataPos, "Product Flag is not an expected value");
          bLineFailedChecks = true;
        }
        
        if (!(iFlag_description == iFlag_add || iFlag_description == iFlag_edit || iFlag_description == iFlag_ignore)) { 
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Description Flag: " + Integer.toString(iFlag_description), iDataPos, "Description Flag is not an expected value");
          bLineFailedChecks = true;
        }
        
        if (!(iFlag_images == iFlag_add || iFlag_description == iFlag_edit || iFlag_description == iFlag_ignore)) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Image Flag: " + Integer.toString(iFlag_images), iDataPos, "Image Flag is not an expected value");
          bLineFailedChecks = true;
        }

        /*********************************************
        *   If checks are OK then call Stored Proc   *
        *********************************************/
        if (bLineFailedChecks == false) {
          String sSql = "{CALL insertProduct( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )};";
          sStatusText = "";
          
          try (CallableStatement stmt=conn.prepareCall(sSql);) {
            //Set OUT parameter
            stmt.registerOutParameter(1, Types.INTEGER); // bIsOk  OUT p_bIsOk boolean,1
            stmt.registerOutParameter(2, Types.INTEGER);  //iprd_product_id    OUT p_prd_product_id int,2

            //Set IN parameter
            stmt.setInt(3, iUploadTypeId); // p_language_id int,3
            stmt.setInt(4, ilanguage_id); // p_language_id int,3
            stmt.setString(5, sPrd_model); // p_prd_model varchar(64),4
            stmt.setString(6, sPrd_sku); // p_prd_sku varchar(64),5
            stmt.setString(7, sPrd_upc); // p_prd_upc varchar(12),6
            stmt.setString(8, sPrd_ean); // p_prd_ean varchar(14),7
            stmt.setString(9, sPrd_jan); // p_prd_jan varchar(13),8
            stmt.setString(10, sPrd_isbn); // p_prd_isbn varchar(17),9
            stmt.setString(11, sPrd_mpn); // p_prd_mpn varchar(64),10
            stmt.setString(12, sPrd_location); // p_prd_location varchar(128),11
            stmt.setInt(13, iPrd_quantity); // p_prd_quantity int,12
            stmt.setInt(14, iPrd_stock_status_id); // p_prd_stock_status_id int,13
            stmt.setString(15, sPrd_image); // p_prd_image varchar(255),14
            stmt.setInt(16, iPrd_manufacturer_id); // p_prd_manufacturer_id int,15
            stmt.setInt(17, iPrd_shipping); // p_prd_shipping tinyint,16
            stmt.setDouble(18, dPrd_price); // p_prd_price decimal(15,4),17
            stmt.setInt(19, iPrd_points); // p_prd_points int,18
            stmt.setInt(20, iPrd_tax_class_id); // p_prd_tax_class_id int,19
            stmt.setDate(21, dtePrd_date_available); // p_prd_date_available date,20
            stmt.setDouble(22, dPrd_weight); // p_prd_weight decimal(15,8),21
            stmt.setInt(23, iPrd_weight_class_id); // p_prd_weight_class_id int,22
            stmt.setDouble(24, dPrd_length); // p_prd_length decimal(15,8),23
            stmt.setDouble(25, dPrd_width); // p_prd_width decimal(15,8),24
            stmt.setDouble(26, dPrd_height); // p_prd_height decimal(15,8),25
            stmt.setInt(27, iPrd_length_class_id); // p_prd_length_class_id int,26
            stmt.setInt(28, iPrd_subtract); // p_prd_subtract tinyint,27
            stmt.setInt(29, iPrd_minimum); // p_prd_minimum int,28
            stmt.setInt(30, iPrd_sort_order); // p_prd_sort_order int,29
            stmt.setInt(31, iPrd_status); // p_prd_status tinyint,30
            stmt.setString(32, sDesc_name); // p_desc_name varchar(255),31
            stmt.setString(33, sDesc_description); // p_desc_description text,32
            stmt.setString(34, sDesc_tag); // p_desc_tag text,33
            stmt.setString(35, sDesc_meta_title); // p_desc_meta_title varchar(255) ,34
            stmt.setString(36, sDesc_meta_description); // p_desc_meta_description varchar(255),35
            stmt.setString(37, sDesc_meta_keyword); // p_desc_meta_keyword varchar(255), 36
            stmt.setString(38, sConcat_image); // p_Concat_image varchar(4000),37
            stmt.setString(39, sConcat_image_sort_order); // p_Concat_image_sort_order varchar(4000),38
            stmt.setInt(40, iFlag_product); // p_flag_product int,40
            stmt.setInt(41, iFlag_description); // p_flag_description int,41
            stmt.setInt(42, iFlag_images); // p_flag_images int42

            stmt.registerOutParameter(43, java.sql.Types.VARCHAR);  // OUT p_status_text text)

            //stmt.execute();
            rs = stmt.executeQuery();

            // Get Out and InOut parameters
            bIsOk = stmt.getBoolean(1);
            iprd_product_id = stmt.getInt(2);
            sStatusText = stmt.getString(43);
            
            cDataStep1.iProductId = iprd_product_id;
            
            this.lstDataStep1.set(iDataPos, cDataStep1);

            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " - Ean: " + cDataStep1.sEan + " - Sku: " + sPrd_sku + " - iprd_product_id: " + Integer.toString(iprd_product_id) + " - Status Text: " + sStatusText, iDataPos, "uploaded");

            if (bIsOk == true) {
              System.out.println("product id " + Integer.toString(iprd_product_id));

              ClsMisc.printResultset(rs);
              
              int iCategory = ClsMisc.iError;
              int iGrandParentId = -1; /*this is related to the table db_shoes.shoes_category_path which defines where things go in the menu's */

//              ClsFunctionResultCategory cFnRsltCategory = cCategoryId.getCategoryClassID(cDataStep1.sCategory, cDataStep1.sParentCategory, iLanguageId, iGrandParentId, conn);
              ClsFunctionResultCategory cFnRsltCategory = cCategoryId.getCategoryClassID(cDataStep1.sCategory, cDataStep1.sParentCategory, iLanguageId, iGrandParentId, sPrd_model, sPrd_sku, sPrd_upc, sPrd_ean, conn);
              
              
/*  
public ClsFunctionResultCategory getCategoryClassID(String sCategoryText, String sParentText, int iLanguageId, int iGrandParentId, String sModel, String sSku, String sUpc, String sEan, Connection conn) {
*/              
              
              if (cFnRsltCategory.bIsOk) {
                addToCategory(cProgressReport, iprd_product_id, cFnRsltCategory.iId, cFnRsltCategory.iParentId, conn);
              } else {
                System.out.println("Error");
                System.out.print("ClsCategoryClassId.getCategoryClassID(" + cDataStep1.sCategory + ", " + cDataStep1.sParentCategory + ", ");
                System.out.print(iLanguageId);
                System.out.println(")");
              }
              
              /**********************************
              *   populate tables for options   *
              **********************************/
              
              
              /*****************************************
              *   populate the tables for attributes   *
              *****************************************/
              for (int iAttributeCounter = 0; iAttributeCounter < lstAttribute.size(); iAttributeCounter++) {
                ClsAttribute cAttribute = lstAttribute.get(iAttributeCounter);
                cAttributeIds.insertProductAttribute(cProgressReport, iprd_product_id, iLanguageId, cAttribute.iId, cAttribute.sValue, conn);
              }
            } else {
              cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " - Ean: " + cDataStep1.sEan + " - Sku: " + sPrd_sku + " - iprd_product_id: " + Integer.toString(iprd_product_id), iDataPos, "SQL Failed " + sSql);

              ResultSetMetaData rsmd = rs.getMetaData();
              
              while (rs.next()) {
                String sLine = "Partscode: " + sPrd_model + " - Ean: " + cDataStep1.sEan + " - Sku: " + sPrd_sku + " - iprd_product_id: " + Integer.toString(iprd_product_id);
                String sErrName = "";
 
                for (int iCol = 1; iCol <= rsmd.getColumnCount(); iCol++) {
                  switch(rsmd.getColumnClassName(iCol)) {
                    case "java.lang.Integer":
                      sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Integer.toString(rs.getInt(rsmd.getColumnName(iCol)));
                      break;
                    case "java.lang.String":
                      sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + rs.getString(rsmd.getColumnName(iCol));
                      if (ClsMisc.stringsEqual( rsmd.getColumnName(iCol), "err_Name", true, true, false))
                      { sErrName = rs.getString(rsmd.getColumnName(iCol)); }
                      break;
                    case "java.lang.Long":
                      sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Long.toString(rs.getLong(rsmd.getColumnName(iCol)));
                      break;
                    case "java.lang.Double":
                      sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Double.toString(rs.getDouble(rsmd.getColumnName(iCol)));
                      break;
                    case "java.lang.Boolean":
                      sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Boolean.toString(rs.getBoolean(rsmd.getColumnName(iCol)));
                      break;
                    default:
                      sLine = sLine + "Ooooops have to finish writing ClsMisc.printResultset() add the data type " + rsmd.getColumnClassName(iCol);
                  }
                }
                sLine = sLine.trim();
                System.out.println(sLine);
                
                if (ClsMisc.stringsEqual(sErrName, "", true, true, false)) { 
                  cProgressReport.somethingToNote("uploadToMySqlServer", sLine, iDataPos, "SQL Failed Details " + sSql); 
                } else { 
                  cProgressReport.somethingToNote("uploadToMySqlServer", sLine, iDataPos, "SQL Failed Details " + sErrName);
                  System.out.println(sErrName);
                }
              }
            } //if (bIsOk == true) 
          } catch (SQLException e) {
            e.printStackTrace();
          } //try (CallableStatement stmt=conn.prepareCall(sSql);) 
        } //if
      } //for

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.uploadToMySqlServer Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;

      cProgressReport.somethingToNote("uploadToMySqlServer", "Error: ClsProcessTuscany.uploadToMySqlServer Exception e", 0, cFunctionResult.sError);
      return cFunctionResult;
    }
  }
  
  public ClsFunctionResult fixRelatedProducts(int iUploadTypeID, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      System.out.println("");
      System.out.println("public ClsFunctionResult fixRelatedProducts(Connection conn) {");
      
      ClsMaintainRelatedProductPartscode cRelated = new ClsMaintainRelatedProductPartscode("*");

      System.out.println("one");
      System.out.print("this.lstDataStep1.size(): ");
      System.out.println(this.lstDataStep1.size());
      
      for (int iDataPos = 0; iDataPos < this.lstDataStep1.size(); iDataPos++) {
        System.out.print("iDataPos: ");
        System.out.println(iDataPos);

        ClsDataStep1TuscanyVer1 cDataStep1 = this.lstDataStep1.get(iDataPos);

        if (cDataStep1.iProductId > 0)
        { 
          System.out.print("cRelated.addProjectId(" + Integer.toString(cDataStep1.iProductId) + ");");
          cRelated.addProjectId(cDataStep1.iProductId);
        }
      }
      
      ClsFunctionResultInt cFnRsltInt_productIdCount = cRelated.productIdCount();

      System.out.print("product id Is OK: " + Boolean.toString(cFnRsltInt_productIdCount.bIsOk));
      System.out.print("product id Count: " + Integer.toString(cFnRsltInt_productIdCount.iResult));

      System.out.println("two");
      System.out.print("this.lstDataStep1.size(): ");
      System.out.println(this.lstDataStep1.size());

      for (int iDataPos = 0; iDataPos < this.lstDataStep1.size(); iDataPos++) {
        System.out.print("iDataPos: ");
        System.out.println(iDataPos);

        ClsDataStep1TuscanyVer1 cDataStep1 = this.lstDataStep1.get(iDataPos);

        if (cDataStep1.iProductId > 0) {
          cRelated.addPartscode(cDataStep1.sPartscode);
          
          ClsFunctionResultInt cFnRsltInt_partscodeCount = cRelated.partscodeCount();
          
          if (cFnRsltInt_partscodeCount.bIsOk) {
            if (cFnRsltInt_partscodeCount.iResult > 10) {
              cRelated.runProc(iUploadTypeID, conn);
              cRelated.clearAllPartscode();
            }
          } else {
            cFunctionResult.bIsOk = cFnRsltInt_partscodeCount.bIsOk;
            cFunctionResult.sError = cFnRsltInt_partscodeCount.sError;
            System.out.println("cFnRsltInt_partscodeCount.sError: " + cFnRsltInt_partscodeCount.sError);
          }
        }
      }

      ClsFunctionResultInt cFnRsltInt_partscodeCount = cRelated.partscodeCount();
      
      if (cFnRsltInt_partscodeCount.bIsOk) {
        //System.out.print("cRelated.partscodeCount(): ");
        //System.out.println(cFnRsltInt_partscodeCount.iResult);
        if (cFnRsltInt_partscodeCount.iResult > 0) {
          cRelated.runProc(iUploadTypeID, conn);
          cRelated.clearAllPartscode();
        }
      } else {
        cFunctionResult.bIsOk = cFnRsltInt_partscodeCount.bIsOk;
        cFunctionResult.sError = cFnRsltInt_partscodeCount.sError;
      }

      System.out.println("End: public ClsFunctionResult fixRelatedProducts(Connection conn) {");

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.fixRelatedProducts Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  private ClsFunctionResult addToCategory(ClsProgressReport cProgressReport, int iProductId, int iCategoryId, int iParentId, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;

      String sSql = "{Call insertProductCategoryMapping( ? , ? , ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iProductId);  
        stmt.setInt(2, iCategoryId);  
        stmt.setInt(3, iParentId);  
        stmt.registerOutParameter(4, Types.BOOLEAN);

        //stmt.execute();
        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(4);

        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempProductId = rs.getInt("product_id");
            int iTempCategoryId = rs.getInt("category_id");
            
            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessTuscany.addToCategory - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessTuscany.addToCategory SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.addToCategory Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("addToCategory", cFunctionResult.sError, 0, cFunctionResult.sError);

      return cFunctionResult;
    }
  }

  public ClsFunctionResult disableProductsNotUpdated(ClsProgressReport cProgressReport, int iUploadTypeId, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
/* disableProductsNotUpdated(OUT p_bIsOk boolean, IN p_upload_type_id int)*/
      String sSql = "{Call disableProductsNotUpdated( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, iUploadTypeId);  

        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(1);

        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempId = rs.getInt("id");
//            int iTempCategoryId = rs.getInt("date_modified");  /* not sure of the datatype but I dont need this data anyway */
            
            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("disableProductsNotUpdated", "iUploadTypeId: " + Integer.toString(iUploadTypeId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessTuscany.disableProductsNotUpdated - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessTuscany.disableProductsNotUpdated SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("disableProductsNotUpdated", "iUploadTypeId: " + Integer.toString(iUploadTypeId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessTuscany.disableProductsNotUpdated Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("disableProductsNotUpdated", cFunctionResult.sError, 0, cFunctionResult.sError);

      return cFunctionResult;
    }
  }
}

