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

public class ClsProcessBDroppy {
  private enum enumProductType {
    eProd_Accessories,
    eProd_Bags,
    eProd_Clothing,
    eProd_Shoes,
    eProd_Underwear,
    eProd_unknown
  }

  ArrayList<ClsDataRawBDroppyVer1> lstDataRaw;
  ArrayList<ClsDataStep1BDroppyVer1> lstDataStep1;
//  ArrayList<ClsProductCrossRef> lstProductCrossRef;

  ClsSettings cSettings; 

  public ClsProcessBDroppy(ClsSettings pcSettings){
    try {
      this.cSettings = pcSettings;
      
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.ClsProcessBDroppy Exception e");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResult ReadFile(ClsProgressReport cProgressReport, String sSourceFile) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();
    
    try {
      this.lstDataRaw = new ArrayList<ClsDataRawBDroppyVer1>();
      this.lstDataStep1 = new ArrayList<ClsDataStep1BDroppyVer1>(); 

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
        
        System.out.println("lstLine.size(): " + Integer.toString(lstLine.size()));

        boolean bLineIsOk = true;
        
        switch(iLineNo) {
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

            ClsDataRawBDroppyVer1 cRawData = new ClsDataRawBDroppyVer1();
            
            //cRawData.iSourceProductId = lstLine.get(this.cSettings.getHeaderFieldPos("Product_id"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Product_id")), "", true, true, true)) {
              cRawData.iSourceProductId = 0;
            } else {
              if (ClsMisc.isInt (lstLine.get(this.cSettings.getHeaderFieldPos("Product_id")))) {
                cRawData.iSourceProductId = Integer.parseInt((lstLine.get(this.cSettings.getHeaderFieldPos("Product_id"))));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Product_id")), iLineNo, "Product_id not an integer");
                cRawData.iSourceProductId = 0;
                bLineIsOk = false;
              }
            }

            //cRawData.iModelId = lstLine.get(this.cSettings.getHeaderFieldPos("Model_id"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Model_id")), "", true, true, true)) {
              cRawData.iModelId = 0;
            } else {
              if (ClsMisc.isInt (lstLine.get(this.cSettings.getHeaderFieldPos("Model_id")))) {
                cRawData.iModelId = Integer.parseInt((lstLine.get(this.cSettings.getHeaderFieldPos("Model_id"))));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Model_id")), iLineNo, "Model_id not an integer");
                cRawData.iModelId = 0;
                bLineIsOk = false;
              }
            }

            cRawData.sBarcode = lstLine.get(this.cSettings.getHeaderFieldPos("Barcode"));
            cRawData.sBrand = lstLine.get(this.cSettings.getHeaderFieldPos("Brand"));
            cRawData.sName = lstLine.get(this.cSettings.getHeaderFieldPos("Name"));
            cRawData.sProductCode = lstLine.get(this.cSettings.getHeaderFieldPos("Product_code"));
            cRawData.sSku = lstLine.get(this.cSettings.getHeaderFieldPos("Sku"));

            //cRawData.fCostNoVat = lstLine.get(this.cSettings.getHeaderFieldPos("Cost_no_vat"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Cost_no_vat")), "", true, true, true)) {
              cRawData.fCostNoVat = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Cost_no_vat")))) {
                cRawData.fCostNoVat = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Cost_no_vat")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Cost_no_vat")), iLineNo, "Cost_no_vat not a Float");
                cRawData.fCostNoVat = 0.0f;
              }
            }

            //cRawData.fSellingPrice = lstLine.get(this.cSettings.getHeaderFieldPos("Selling_price"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Selling_price")), "", true, true, true)) {
              cRawData.fSellingPrice = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Selling_price")))) {
                cRawData.fSellingPrice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Selling_price")));
                cRawData.fSellingPrice = cRawData.fSellingPrice / 1.19f;  /*   remove tax here because it is added later and this makes it less confusing   */
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Selling_price")), iLineNo, "Selling_price not a Float");
                cRawData.fSellingPrice = 0.0f;
              }
            }

            //cRawData.fStreetPrice = lstLine.get(this.cSettings.getHeaderFieldPos("Street_price"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Street_price")), "", true, true, true)) {
              cRawData.fStreetPrice = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Street_price")))) {
                cRawData.fStreetPrice = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Street_price")));
                cRawData.fStreetPrice = cRawData.fStreetPrice / 1.19f;  /*   remove tax here because it is added later and this makes it less confusing   */
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Street_price")), iLineNo, "Street_price not a Float");
                cRawData.fStreetPrice = 0.0f;
              }
            }

            cRawData.sDescription = lstLine.get(this.cSettings.getHeaderFieldPos("Description"));

            //cRawData.fWeight = lstLine.get(this.cSettings.getHeaderFieldPos("Weight"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Weight")), "", true, true, true)) {
              cRawData.fWeight = 0.0f;
            } else {
              if (ClsMisc.isFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Weight")))) {
                cRawData.fWeight = Float.parseFloat(lstLine.get(this.cSettings.getHeaderFieldPos("Weight")));
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Weight")), iLineNo, "Weight not a Float");
                cRawData.fWeight = 0.0f;
              }
            }

            cRawData.sPicture1 = lstLine.get(this.cSettings.getHeaderFieldPos("Picture_1"));
            cRawData.sPicture2 = lstLine.get(this.cSettings.getHeaderFieldPos("Picture_2"));
            cRawData.sPicture3 = lstLine.get(this.cSettings.getHeaderFieldPos("Picture_3"));
            cRawData.sPicture4 = lstLine.get(this.cSettings.getHeaderFieldPos("Picture_4"));
            cRawData.sPicture5 = lstLine.get(this.cSettings.getHeaderFieldPos("Picture_5"));
            cRawData.sMadeIn = lstLine.get(this.cSettings.getHeaderFieldPos("Made_in"));
            cRawData.sShoesHeel = lstLine.get(this.cSettings.getHeaderFieldPos("Shoes_heel"));
            cRawData.sCategory = lstLine.get(this.cSettings.getHeaderFieldPos("Category"));
            cRawData.sSubCategory = lstLine.get(this.cSettings.getHeaderFieldPos("Sub category"));
            cRawData.sSeason = lstLine.get(this.cSettings.getHeaderFieldPos("Season"));
            cRawData.sColor = lstLine.get(this.cSettings.getHeaderFieldPos("Color"));
            cRawData.sBiColors = lstLine.get(this.cSettings.getHeaderFieldPos("Bi colors"));
            cRawData.sGender = lstLine.get(this.cSettings.getHeaderFieldPos("Gender"));
            cRawData.sPrint = lstLine.get(this.cSettings.getHeaderFieldPos("Print"));
            cRawData.sSize = lstLine.get(this.cSettings.getHeaderFieldPos("Size"));

            //cRawData.iQuantity = lstLine.get(this.cSettings.getHeaderFieldPos("Quantity"));
            if (ClsMisc.stringsEqual(lstLine.get(this.cSettings.getHeaderFieldPos("Quantity")), "", true, true, true)) {
              cRawData.iQuantity = 0;
            } else {
              if (ClsMisc.isInt (lstLine.get(this.cSettings.getHeaderFieldPos("Quantity")))) {
                cRawData.iQuantity = Integer.parseInt((lstLine.get(this.cSettings.getHeaderFieldPos("Quantity"))));
                
                if (cRawData.iQuantity > 0)
                { cRawData.iQuantity = cRawData.iQuantity - 1; }
              } else {
                cProgressReport.somethingToNote("ReadFile", lstLine.get(this.cSettings.getHeaderFieldPos("Quantity")), iLineNo, "Quantity not an integer");
                cRawData.iQuantity = 0;
                bLineIsOk = false;
              }
            }

            cRawData.sMaterial = lstLine.get(this.cSettings.getHeaderFieldPos("Material"));

            System.out.println("Made_in: " + lstLine.get(this.cSettings.getHeaderFieldPos("Made_in")));
            System.out.println("Shoes_heel: " + lstLine.get(this.cSettings.getHeaderFieldPos("Shoes_heel")));
            System.out.println("Category: " + lstLine.get(this.cSettings.getHeaderFieldPos("Category")));
            System.out.println("Subcategory: " + lstLine.get(this.cSettings.getHeaderFieldPos("Subcategory")));
            System.out.println("Season: " + lstLine.get(this.cSettings.getHeaderFieldPos("Season")));
            System.out.println("Color: " + lstLine.get(this.cSettings.getHeaderFieldPos("Color")));
            System.out.println("Bicolors: " + lstLine.get(this.cSettings.getHeaderFieldPos("Bicolors")));

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
      System.out.println("Error: ClsProcessBDroppy.ReadFile Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult processLstDataRaw(ClsProgressReport cProgressReport, int iLanguageId, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;

      ClsDataCorrection cDataCorrection = new ClsDataCorrection("shoe sizes", conn);
      ClsDataCorrection cDataCorr_SubCategory = new ClsDataCorrection("sub category", conn);

      int iOptionId = ClsMisc.iError;
      
      ClsOptionId cOptionId = new ClsOptionId();
      ClsFunctionResultInt cFnRslt_OptionId = cOptionId.getOptionID("Size", conn);

      if (cFnRslt_OptionId.bIsOk) 
      { iOptionId = cFnRslt_OptionId.iResult; }
      else
      { cProgressReport.somethingToNote("uploadToMySqlServer", "cOptionId.getOptionID ( ... ) returns an error" , -1, "tracking"); }
      
      ClsOptionValue cOptionValue = new ClsOptionValue();
      
      System.out.println("");
      System.out.println("");
      System.out.println("--------------");
      System.out.print("Option ID: ");
      System.out.println(iOptionId);
      System.out.println("--------------");
      System.out.println("");
      System.out.println("");
      
      for (int iRawPos = 0; iRawPos < this.lstDataRaw.size(); iRawPos++) {
        ClsDataRawBDroppyVer1 cRawData = this.lstDataRaw.get(iRawPos);
        ClsDataStep1BDroppyVer1_Option cOption = new ClsDataStep1BDroppyVer1_Option();

        cOption.iProductOptionValueId = 0;
        cOption.iProductOptionId = 0;
        cOption.iOptionValueId = 0;
        cOption.iModelId = cRawData.iModelId;
        cOption.sBarcode = cRawData.sBarcode.trim();
        cOption.sSku = cRawData.sSku.trim();
        cOption.sUpc = "";
        cOption.sEan = "";
        cOption.sJan = "";
        cOption.sIsbn = "";
        cOption.sMpn = "";
        cOption.sLocation = cRawData.sBarcode.trim();
        
        ClsFunctionResultString cFnRslt = cDataCorrection.getValue(cRawData.sSize.trim());
        
        if (cFnRslt.bIsOk) {
          cOption.sSize = cFnRslt.sResult;
        } else {
          cOption.sSize = cRawData.sSize.trim();
          
          cProgressReport.somethingToNote("uploadToMySqlServer", "cDataCorrection.getValue('" + cRawData.sSize.trim() + "', conn) returns an error" , -1, "Error");
        }
        
        cOption.iQuantity = cRawData.iQuantity;
        cOption.fDeltaCostNoVat = 0.0f;
        cOption.fDeltaSellingPrice = 0.0f;
        cOption.fDeltaStreetPrice = 0.0f;
        cOption.iSubtract = 1;
        cOption.fPrice = 0.0f;
        cOption.sPricePrefix = "+";
        cOption.iPoints = 0;
        cOption.sPointsPrefix = "+";
        cOption.fWeight = cRawData.fWeight;
        cOption.sWeightPrefix = "+";
        cOption.sModel = "";

        boolean bIsFound = false;
        int iPos = findProductPosition(cRawData);

        String sTempImage = "";
        ClsFunctionResultInt cFnRslt_OptionValue = cOptionValue.getOptionValueID(cProgressReport, iOptionId, sTempImage, iLanguageId, cOption.sSize, conn);
          
        cOption.iOptionValueId = ClsMisc.iError;

        if (cFnRslt_OptionValue.bIsOk) {
          cOption.iOptionValueId = cFnRslt_OptionValue.iResult;
        } else {
          cProgressReport.somethingToNote("processLstDataRaw", "cOptionValue.getOptionValueID returned error - cRawData.iSourceProductId: " + Integer.toString(cRawData.iSourceProductId), iRawPos, "Error");
        }

        if (iPos == ClsMisc.iError) {
          /****************************************************************************************
          *   We don't have the item in lstDataStep1                                              *
          *   so we have to create an instance of ClsDataStep1BDroppyVer1 as add it to the list   *
          ****************************************************************************************/
          ClsDataStep1BDroppyVer1 cDataStep1 = new ClsDataStep1BDroppyVer1(); 

          cDataStep1.iSourceProductId = cRawData.iSourceProductId;

          /*cDataStep1.iModelId = cRawData.iModelId;*/
          /*cDataStep1.sBarcode = cRawData.sBarcode.trim();*/
          cDataStep1.sBrand = cRawData.sBrand.trim();

/*
          cDataStep1.sName = cRawData.sName.trim();
*/          
          cDataStep1.sSubCategory = "";

          ClsFunctionResultString cFnRslt_SubCategory = cDataCorr_SubCategory.getValue(cRawData.sSubCategory.trim());
        
          if (cFnRslt_SubCategory.bIsOk) {
            cDataStep1.sSubCategory = cFnRslt_SubCategory.sResult;
          } else {
            cDataStep1.sSubCategory = cRawData.sSubCategory.trim();
          
            cProgressReport.somethingToNote("uploadToMySqlServer", "cDataCorr_SubCategory.getValue('" + cDataStep1.sSubCategory + "', conn) returns an error" , -1, "Error");
          }
          
          cDataStep1.sJustModelName = cRawData.sName.trim();
          
          cDataStep1.sName = cRawData.sName.trim();
          cDataStep1.sName = cDataStep1.sName + "<br><small>";

          if (ClsMisc.stringsEqual(cRawData.sBrand.trim(), "", true, true, true))
          { cDataStep1.sName = cDataStep1.sName + "Brand unknown"; }
          else
          { cDataStep1.sName = cDataStep1.sName + "" + cRawData.sBrand.trim(); }

          cDataStep1.sName = cDataStep1.sName + " <i>";

          if (ClsMisc.stringsEqual(cRawData.sCategory.trim(), "", true, true, true))
          { cDataStep1.sName = cDataStep1.sName.trim() + "Unknown Category"; }
          else
          { cDataStep1.sName = cDataStep1.sName.trim() + ClsMisc.removeCategoryPlural(cRawData.sCategory.trim()); }

          if (!ClsMisc.stringsEqual(cDataStep1.sSubCategory, "", true, true, true))
          { cDataStep1.sName = cDataStep1.sName + " (" + ClsMisc.removeSubCategoryPlural(cDataStep1.sSubCategory) + ")"; }
          
          if (!ClsMisc.stringsEqual(cRawData.sColor.trim(), "", true, true, true))
          { cDataStep1.sName = cDataStep1.sName + "<br>" + cRawData.sColor.trim(); }

          cDataStep1.sName = cDataStep1.sName + "</small></i>";

//        sDesc_description = sDesc_description + cDataStep1.sDescription;
          
          cDataStep1.sProductCode = cRawData.sProductCode.trim();
          cDataStep1.sSku = cRawData.sSku.trim();
          cDataStep1.fCostNoVat = cRawData.fCostNoVat;
          cDataStep1.fSellingPrice = cRawData.fSellingPrice;
          cDataStep1.fStreetPrice = cRawData.fStreetPrice;

          ClsFunctionResultString cFnRsltStr_Description = ClsMisc.fixDescription(cRawData.sDescription.trim());
          
          if (cFnRsltStr_Description.bIsOk) { 
            cDataStep1.sDescription = cFnRsltStr_Description.sResult;
          } else { 
            cDataStep1.sDescription = "";
            
            System.out.println("Error: ClsMisc.fixDescription");
            System.out.println("cRawData.sDescription.trim(): " + cRawData.sDescription.trim());
          }

          cDataStep1.fWeight = 0.0f; //just encase different shoes sizes weigh different amounts
          cDataStep1.sMadeIn = cRawData.sMadeIn.trim();
          cDataStep1.sShoesHeel = cRawData.sShoesHeel.trim();
          cDataStep1.sCategory = cRawData.sCategory.trim();
          cDataStep1.sSeason = cRawData.sSeason.trim();
          cDataStep1.sColor = cRawData.sColor.trim();
          cDataStep1.sBiColors = cRawData.sBiColors.trim();
          cDataStep1.sGender = cRawData.sGender.trim();
          cDataStep1.sPrint = cRawData.sPrint;
          /*cDataStep1.sSize = cRawData.sSize.trim();*/
          /*cDataStep1.iQuantity = cRawData.iQuantity;*/
          cDataStep1.sMaterial = cRawData.sMaterial.trim();

          if (cDataStep1.lstImages == null)
          { cDataStep1.lstImages = new ArrayList<String>(); }

          if (!ClsMisc.stringsEqual(cRawData.sPicture1, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sPicture1.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sPicture2, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sPicture2.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sPicture3, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sPicture3.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sPicture4, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sPicture4.trim()); }

          if (!ClsMisc.stringsEqual(cRawData.sPicture5, "", true, true, true))
          { cDataStep1.lstImages.add(cRawData.sPicture5.trim()); }

          cProgressReport.somethingToNote("processLstDataRaw", "Source Product Id: " + Integer.toString(cDataStep1.iSourceProductId), iRawPos, "tracking");

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

          cDataStep1.iOptionId = iOptionId;

          cDataStep1.lstSizes = new ArrayList<ClsDataStep1BDroppyVer1_Option>();
          cDataStep1.lstSizes.add(cOption);
          
          cDataStep1.iProductId = ClsMisc.iError;
          
          this.lstDataStep1.add(cDataStep1);
        } else {
          /*******************************************************************************
          *   When we already have the item in lstDataStep1,                             *
          *   then we have to check that we have the option in lstDataStep1.lstOptions   *
          *******************************************************************************/

/*calculate what the detail is in all the pricing*/
          
          ClsDataStep1BDroppyVer1 cDataStep1 = new ClsDataStep1BDroppyVer1(); 

          cDataStep1 = this.lstDataStep1.get(iPos);

          cOption.iProductOptionValueId = 0;
          cOption.iProductOptionId = 0;
          
          cOption.iModelId = cRawData.iModelId;
          cOption.sBarcode = cRawData.sBarcode.trim();
          cOption.sSku = cRawData.sSku.trim();
          cOption.sUpc = "";
          cOption.sEan = "";
          cOption.sJan = "";
          cOption.sIsbn = "";
          cOption.sMpn = "";
          cOption.sLocation = cRawData.sBarcode.trim();
          cOption.sSize = cRawData.sSize.trim();

          cOption.iQuantity = cRawData.iQuantity;
          cOption.iSubtract = 1;
          cOption.fPrice = 0.0f;
          cOption.sPricePrefix = "+";
          cOption.iPoints = 0;
          cOption.sPointsPrefix = "+";
          cOption.fWeight = cRawData.fWeight;
          cOption.sWeightPrefix = "+";
          cOption.sModel = "";
          
          cOption.fDeltaCostNoVat = cRawData.fCostNoVat - cDataStep1.fCostNoVat;
          cOption.fDeltaSellingPrice = cRawData.fSellingPrice - cDataStep1.fSellingPrice;
          cOption.fDeltaStreetPrice = cRawData.fStreetPrice - cDataStep1.fStreetPrice;
          
          cDataStep1.lstSizes.add(cOption);
          
          this.lstDataStep1.set(iPos, cDataStep1);

          boolean bOptionIsFound = false;
          int iOptionPos = ClsMisc.iError;

          for (int iTemp = 0; iTemp < this.lstDataStep1.get(iPos).lstSizes.size(); iTemp++) {
            if (this.lstDataStep1.get(iPos).lstSizes.get(iTemp).iModelId == cOption.iModelId) {
              if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).lstSizes.get(iTemp).sBarcode, cOption.sBarcode, true, true, true)) {
                if (ClsMisc.stringsEqual(this.lstDataStep1.get(iPos).lstSizes.get(iTemp).sSku, cOption.sSku, true, true, true)) {
                  iOptionPos = iTemp;
                }
              }
            }
          }
          
          if (iOptionPos == ClsMisc.iError) {
            this.lstDataStep1.get(iPos).lstSizes.add(cOption);
          } else {
            cProgressReport.somethingToNote("processLstDataRaw", "Source Product Id: " + Integer.toString(cDataStep1.iSourceProductId) + " - Model Id: " + Integer.toString(cOption.iModelId) + " - Barcode: " + cOption.sBarcode + " - Sku: " + cOption.sSku + " - Size: " + cOption.sSize, iRawPos, "duplicates in the data");
          }
          
          cDataStep1.iProductId = ClsMisc.iError;
        }

        /***************************************************************************************************
        *   Create my own cross reference table to keep track of reference codes across multiple options   *
        ***************************************************************************************************/
          
//        ClsProductCrossRef cProductCrossRef = new ClsProductCrossRef();

//        cProductCrossRef.sPartscode = cRawData.sPartscode;
//        cProductCrossRef.sEan = cRawData.sEan;
//        cProductCrossRef.sSku = cRawData.sSku;
//        cProductCrossRef.sOption = cRawData.sOption;
        
//        if (this.lstProductCrossRef == null)
//        { this.lstProductCrossRef = new ArrayList<ClsProductCrossRef>();}
        
//        this.lstProductCrossRef.add(cProductCrossRef);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.processLstDataRaw Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public int findProductPosition(ClsDataRawBDroppyVer1 cRawData) {
    try {
      int iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < this.lstDataStep1.size();iPos++) {
        if (this.lstDataStep1.get(iPos).iSourceProductId == cRawData.iSourceProductId) { 
          iResult = iPos;
        }
      }

      return iResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.findProductPosition Exception e");
      System.out.println(e);
      
      return ClsMisc.iError;
    }
  }

/**************************************************************************************************
*                                                                                                 *
*   *******************************************************************************************   *
*   *   To do                                                                                 *   *
*   *   ==-==                                                                                 *   *
*   *   (1) If the quantity of one size then dont add the product_option_value                *   *
*   *   (2) Make sure that if a product previously had many records in product_option_value   *   *
*   *       but this time has less records in product_option_value.                           *   *
*   *                                                                                         *   *
*   *******************************************************************************************   *
*                                                                                                 *
**************************************************************************************************/

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
      ClsFilterClass cFilterClass = new ClsFilterClass(cProgressReport, iLanguageId, iUploadTypeId, conn);
      ClsExtraWebLinks cExtraWebLinks = new ClsExtraWebLinks(iLanguageId, conn);

      String sValue = "";
      int iRequired = 1;

      ClsFunctionResultInt cFnRsltInt_FilterGrp_Colour = cFilterClass.getFilterGroupId(cProgressReport, "Colour", conn);
      ClsFunctionResultInt cFnRsltInt_FilterGrp_Gender = cFilterClass.getFilterGroupId(cProgressReport, "Gender", conn);
      ClsFunctionResultInt cFnRsltInt_FilterGrp_ShoeSize = cFilterClass.getFilterGroupId(cProgressReport, "Size", conn);
      ClsFunctionResultInt cFnRsltInt_FilterGrp_Manufacturer = cFilterClass.getFilterGroupId(cProgressReport, "Manufacturer", conn);
      
      if (!cFnRsltInt_FilterGrp_Colour.bIsOk)
      { System.out.println("ClsFilterClass.getFilterGroupId (looking for Colour) - " + cFnRsltInt_FilterGrp_Colour.sError); }

      if (!cFnRsltInt_FilterGrp_Gender.bIsOk)
      { System.out.println("ClsFilterClass.getFilterGroupId (looking for Gender) - " + cFnRsltInt_FilterGrp_Gender.sError); }

      if (!cFnRsltInt_FilterGrp_ShoeSize.bIsOk)
      { System.out.println("ClsFilterClass.getFilterGroupId (looking for Size) - " + cFnRsltInt_FilterGrp_ShoeSize.sError); }

      if (!cFnRsltInt_FilterGrp_Manufacturer.bIsOk)
      { System.out.println("ClsFilterClass.getFilterGroupId (looking for Manufacturer) - " + cFnRsltInt_FilterGrp_Manufacturer.sError); }

      /*************************************************************
      *   Look through each of the elements in this.lstDataStep1   *
      *************************************************************/
      for (int iDataPos = 0; iDataPos < this.lstDataStep1.size(); iDataPos++) {
        ClsDataStep1BDroppyVer1 cDataStep1 = this.lstDataStep1.get(iDataPos);
        boolean bLineFailedChecks = false;

        /************************************************************************
        *   Create seperate variable for each parameter the stored proc needs   *
        ************************************************************************/
        final int iFlag_add = 1;
        final int iFlag_edit = 2;
        final int iFlag_ignore = 3;
        boolean bIsOk = true;
        boolean bLoadRecord = true;

        /******************************************************
        *   If cDataStep1.lstSizes == 1 and Size = "NOSIZE"   *
        *   And Category != "Shoes"                           *
        *   Then bHasOption_ShoeSize = false                  *
        *   Else bHasOption_ShoeSize = true                   *
        ******************************************************/
        enumProductType eProductType = enumProductType.eProd_unknown;

        /*English*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Accessories", true, true, true)) {
          eProductType = enumProductType.eProd_Accessories;
        }
        
        /*German*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Accessoires", true, true, true)) {
          eProductType = enumProductType.eProd_Accessories;
        }
        
        /*English*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Bags", true, true, true)) {
          eProductType = enumProductType.eProd_Bags;
        }

        /*German*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Taschen", true, true, true)) {
          eProductType = enumProductType.eProd_Bags;
        }
        
        /*English*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Clothing", true, true, true)) {
          eProductType = enumProductType.eProd_Clothing;
        }
        
        /*German*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Bekleidung", true, true, true)) {
          eProductType = enumProductType.eProd_Clothing;
        }
        
        /*English*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Shoes", true, true, true)) {
          eProductType = enumProductType.eProd_Shoes;
        }
        
        /*German*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Schuhe", true, true, true)) {
          eProductType = enumProductType.eProd_Shoes;
        }
        
        /*English*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Underwear", true, true, true)) {
          eProductType = enumProductType.eProd_Underwear;
        }
        
        /*German*/
        if (ClsMisc.stringsEqual(cDataStep1.sCategory, "Unterwäsche", true, true, true)) {
          eProductType = enumProductType.eProd_Underwear;
        }
        
        ClsDataStep1BDroppyVer1_Option cOption_OnlyOne = new ClsDataStep1BDroppyVer1_Option();
        
        if (eProductType == enumProductType.eProd_Bags) {
          if (cDataStep1.lstSizes.size() == 1) {
            eProductType = enumProductType.eProd_Bags;
            cOption_OnlyOne = cDataStep1.lstSizes.get(0);
          } else {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Category is bag but the number of lstSizes is wrong it should be one - Source Product Id: " + Integer.toString(cDataStep1.iSourceProductId) + " - cDataStep1.lstSizes.size(): " + Integer.toString(cDataStep1.lstSizes.size()), iDataPos, "Error");
            eProductType = enumProductType.eProd_unknown;
          }
        }

        int iprd_product_id = -1;
//        int iprd_source_product_id = cDataStep1.iSourceProductId;
        int ilanguage_id = iLanguageId;

/*        String sPrd_model = "";*/
        String sPrd_sku = "";
        String sPrd_upc = "";
        String sPrd_ean = "";
        String sPrd_jan = "";
        String sPrd_isbn = "";
        String sPrd_mpn  = "";
        String sPrd_location = "";
/*
        sPrd_model = Integer.toString(cDataStep1.iSourceProductId); // cDataStep1.iSourceProductId;
*/
        
/*Note: the first line of the model will be entered onto the invoice and the tag <br> is used to mark where this line needs to be cut*/
        String sPrd_model = Integer.toString(cDataStep1.iSourceProductId);


/*****************************************************************************
*                                                                            *
*   **********************************************************************   *
*   *   Think about dual language                                        *   *
*   *   If the model is language dependent will all the data match up?   *   *
*   **********************************************************************   *
*                                                                            *
*****************************************************************************/        
        
        
        
        
        
        
        
        
        sPrd_mpn = cDataStep1.sProductCode; 
        double dPrd_price = 0.0f;
        double dPrd_price_i_pay = 0.0f;
        double dPrd_weight = 0.0f; // cDataStep1.fShippingWeight;

        sPrd_sku = ""; 

        if (cDataStep1.fStreetPrice < cDataStep1.fCostNoVat) {
          bLineFailedChecks = true;

          cProgressReport.somethingToNote("uploadToMySqlServer", "Price I am selling it is less than the cost to me - Source Product Id: " + sPrd_model + " cDataStep1.fStreetPrice: " + Float.toString(cDataStep1.fStreetPrice) + " cDataStep1.fCostNoVat: " + Float.toString(cDataStep1.fCostNoVat), iDataPos, "Cost more than sale");
        }

        switch (eProductType) {
          case eProd_Shoes:
            sPrd_sku = ""; 
            sPrd_location = ""; //NA
            dPrd_price = cDataStep1.fStreetPrice;
            dPrd_price_i_pay = cDataStep1.fCostNoVat; // Math.max(cDataStep1.fSellingPrice, cDataStep1.fCostNoVat);
            dPrd_weight = 0.0f; // have to consider different size shoes that weigh different amounts make sure weigh is in shoes_product_option_value and zero is in shoes_product
            sPrd_upc = "";
            break;
          case eProd_Bags:
            sPrd_sku = cOption_OnlyOne.sSku; 
            sPrd_location = cOption_OnlyOne.sBarcode; //NA
            dPrd_price = cDataStep1.fStreetPrice;
            dPrd_price_i_pay = cDataStep1.fCostNoVat; // Math.max(cDataStep1.fSellingPrice, cDataStep1.fCostNoVat);
            dPrd_weight = cOption_OnlyOne.fWeight; // have to consider different size shoes that weigh different amounts
            sPrd_upc = Integer.toString(cOption_OnlyOne.iModelId);
            break;
          case eProd_Accessories:
            bLoadRecord = false;
            cProgressReport.somethingToNote("uploadToMySqlServer", "Not loading the product type Accessories - Source Product Id: " + sPrd_mpn, iDataPos, "Not loading this data");
            break;
          case eProd_Clothing:
            sPrd_sku = ""; 
            sPrd_location = ""; //NA
            dPrd_price = cDataStep1.fStreetPrice;
            dPrd_price_i_pay = cDataStep1.fCostNoVat; // Math.max(cDataStep1.fSellingPrice, cDataStep1.fCostNoVat);
            dPrd_weight = 0.0f; // have to consider different size shoes that weigh different amounts make sure weigh is in shoes_product_option_value and zero is in shoes_product
            sPrd_upc = "";
            break;
          case eProd_Underwear:
            sPrd_sku = ""; 
            sPrd_location = ""; //NA
            dPrd_price = cDataStep1.fStreetPrice;
            dPrd_price_i_pay = cDataStep1.fCostNoVat; // Math.max(cDataStep1.fSellingPrice, cDataStep1.fCostNoVat);
            dPrd_weight = 0.0f; // have to consider different size shoes that weigh different amounts make sure weigh is in shoes_product_option_value and zero is in shoes_product
            sPrd_upc = "";
            break;
          default:
            bLoadRecord = false;
            sPrd_sku = "Error"; 
            sPrd_location = "Error"; //NA
            dPrd_price = 0.0f;
            dPrd_weight = 0.0f; // have to consider different size shoes that weigh different amounts
            sPrd_upc = "";
            cProgressReport.somethingToNote("uploadToMySqlServer", "Unknown product type - Source Product Id: " + sPrd_mpn, iDataPos, "Error");
        }

        cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn, iDataPos, "tracking");

        int iPrd_quantity = 0; //cDataStep1.iQuantity;

        ClsFunctionResultInt cFnRslt_TotalQuantity = getStep1ProductTotalStock(cProgressReport, cDataStep1);

        if (cFnRslt_TotalQuantity.bIsOk) 
        { iPrd_quantity = cFnRslt_TotalQuantity.iResult; } 
        else 
        { cProgressReport.somethingToNote("uploadToMySqlServer", "getStep1ProductTotalStock(...) failed - Source Product Id: " + sPrd_mpn + " - Error: " + cFnRslt_TotalQuantity.sError, iDataPos, "Error"); }

        int iPrd_stock_status_id = ClsMisc.iError;
        /*
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
        */
        int iPrd_manufacturer_id = cManufacturerId.getId(cDataStep1.sBrand, conn, cProgressReport);
        String sDescription_ExtraText = "";
        
        switch (eProductType) {
          case eProd_Shoes:
            ClsFunctionResultString cFnRsltStr_ManInfo_S = cExtraWebLinks.getHtml("Manufacturer", "manufacturer info", iPrd_manufacturer_id);
            
            if (!cFnRsltStr_ManInfo_S.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"manufacturer info\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_ManInfo_S.sError, iDataPos, cFnRsltStr_ManInfo_S.sError); }

            ClsFunctionResultString cFnRsltStr_Size_S = cExtraWebLinks.getHtml("Manufacturer", "Size Chart", iPrd_manufacturer_id);

            if (!cFnRsltStr_Size_S.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"Size Chart\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_Size_S.sError, iDataPos, cFnRsltStr_Size_S.sError); }

            sDescription_ExtraText = cFnRsltStr_ManInfo_S.sResult
                                   + cFnRsltStr_Size_S.sResult;
            break;
          case eProd_Bags:
            ClsFunctionResultString cFnRsltStr_ManInfo_B = cExtraWebLinks.getHtml("Manufacturer", "manufacturer info", iPrd_manufacturer_id);
            
            if (!cFnRsltStr_ManInfo_B.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"manufacturer info\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_ManInfo_B.sError, iDataPos, cFnRsltStr_ManInfo_B.sError); }

            sDescription_ExtraText = cFnRsltStr_ManInfo_B.sResult;

            break;
          case eProd_Clothing:  
            ClsFunctionResultString cFnRsltStr_ManInfo_C = cExtraWebLinks.getHtml("Manufacturer", "manufacturer info", iPrd_manufacturer_id);
            
            if (!cFnRsltStr_ManInfo_C.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"manufacturer info\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_ManInfo_C.sError, iDataPos, cFnRsltStr_ManInfo_C.sError); }

            ClsFunctionResultString cFnRsltStr_Size_C = cExtraWebLinks.getHtml("Manufacturer", "Clothes Size Chart", iPrd_manufacturer_id);

            if (!cFnRsltStr_Size_C.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"Clothes Size Chart\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_Size_C.sError, iDataPos, cFnRsltStr_Size_C.sError); }

            sDescription_ExtraText = cFnRsltStr_ManInfo_C.sResult;

          case eProd_Underwear:  
            ClsFunctionResultString cFnRsltStr_ManInfo_U = cExtraWebLinks.getHtml("Manufacturer", "manufacturer info", iPrd_manufacturer_id);
            
            if (!cFnRsltStr_ManInfo_U.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"manufacturer info\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_ManInfo_U.sError, iDataPos, cFnRsltStr_ManInfo_U.sError); }

            ClsFunctionResultString cFnRsltStr_Size_U = cExtraWebLinks.getHtml("Manufacturer", "Clothes Size Chart", iPrd_manufacturer_id);

            if (!cFnRsltStr_Size_U.bIsOk)
            { cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cExtraWebLinks.getHtml (\"Manufacturer\", \"Clothes Size Chart\", " + Integer.toString(iPrd_manufacturer_id) + "): " + cFnRsltStr_Size_U.sError, iDataPos, cFnRsltStr_Size_U.sError); }

            sDescription_ExtraText = cFnRsltStr_ManInfo_U.sResult
                                   + cFnRsltStr_Size_U.sResult;




            break;
          default:
            sDescription_ExtraText = "";
        }        
        
        
        
        int iPrd_shipping = 1; //"Requires Shipping" 1=yes, 0=no (then shipping is based on what is in the extensions)
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

        java.sql.Date dtePrd_date_available = new java.sql.Date(1000000000); //new java.sql.Date(cDataStep1.dtePublishDate.getTime());// new Date(1000000000);

        // ClsFunctionResultInt cFunctionResultWeightClassId = cWeightClassId.getId(cDataStep1.sWeight);
        ClsFunctionResultInt cFunctionResultWeightClassId = cWeightClassId.getId("kg");
        int iPrd_weight_class_id = cFunctionResultWeightClassId.iResult;

        if (!cFunctionResultWeightClassId.bIsOk) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in ClsWeightClassId (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFunctionResultWeightClassId.sError, iDataPos, cFunctionResultWeightClassId.sError);
          System.out.println("Error in ClsWeightClassId");
          System.out.println(cFunctionResultWeightClassId.sError);
        }

        double dPrd_length = 0.0f; // cDataStep1.fShippingLength;
        double dPrd_width = 0.0f; // cDataStep1.fShippingWidth;
        double dPrd_height = 0.0f; // cDataStep1.fShippingHeight;

        ClsFunctionResultInt cFunctionResultIntLengthClass = cLengthClassId.getId("cm");
        int iPrd_length_class_id = cFunctionResultIntLengthClass.iResult;

        if (!cFunctionResultIntLengthClass.bIsOk) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Error in ClsLengthClassId (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFunctionResultIntLengthClass.sError, iDataPos, cFunctionResultIntLengthClass.sError);
          System.out.println("Error in ClsLengthClassId");
          System.out.println(cFunctionResultIntLengthClass.sError);
        }

        int iPrd_subtract = 1;
        int iPrd_minimum = 0;
        int iPrd_sort_order = 0;
        int iPrd_status = 1;

        String sSeoUrl_JustModelName = cDataStep1.sJustModelName + "-" + cDataStep1.sColor + "-";
        sSeoUrl_JustModelName = ClsMisc.stripChars(sSeoUrl_JustModelName, true, true, true, false, true, false, false);
 
        sSeoUrl_JustModelName = sSeoUrl_JustModelName.replaceAll(" ", "-");
        sSeoUrl_JustModelName = sSeoUrl_JustModelName.replaceAll("----", "-");
        sSeoUrl_JustModelName = sSeoUrl_JustModelName.replaceAll("---", "-");
        sSeoUrl_JustModelName = sSeoUrl_JustModelName.replaceAll("--", "-");
        
        String sDesc_name = cDataStep1.sName;

        String sDesc_description = cDataStep1.sDescription;

        
        sDesc_description = sDesc_description + "<br>" + sDescription_ExtraText;

/*Note: the first line of the description will be entered onto the invoice and the tag <br> is used to mark where this line needs to be cut*/
/*
        String sDesc_description = "";
        if (ClsMisc.stringsEqual(cDataStep1.sBrand.trim(), "", true, true, true))
        { sDesc_description = "Brand unknown <i>"; }
        else
        { sDesc_description = cDataStep1.sBrand.trim() + " <i>"; }

        if (ClsMisc.stringsEqual(cDataStep1.sCategory.trim(), "", true, true, true))
        { sDesc_description = sDesc_description.trim() + "Unknown Category"; }
        else
        { sDesc_description = sDesc_description.trim() + cDataStep1.sCategory.trim(); }

        if (ClsMisc.stringsEqual(cDataStep1.sSubCategory.trim(), "", true, true, true))
        { sDesc_description = sDesc_description + " (Unknown Sub Category)</i><br>";  }
        else
        { sDesc_description = sDesc_description + " (" + cDataStep1.sSubCategory.trim() + ")</i><br>"; }

        sDesc_description = sDesc_description + cDataStep1.sDescription;
*/

        String sDesc_tag = cDataStep1.sName;
        sDesc_tag = sDesc_tag.replaceAll(" ", "¬");
        sDesc_tag = ClsMisc.removeTags(sDesc_tag);
        sDesc_tag = sDesc_tag.replace("(", "");
        sDesc_tag = sDesc_tag.replace("(", "");
        sDesc_tag = sDesc_tag.replace("(", "");
        sDesc_tag = sDesc_tag.replace(")", "");
        sDesc_tag = sDesc_tag.replace(")", "");
        sDesc_tag = sDesc_tag.replace(")", "");
        sDesc_tag = sDesc_tag.replaceAll(" ", ",");
        sDesc_tag = sDesc_tag.replaceAll("¬", " ");
        sDesc_tag = cDataStep1.sBrand + "," + sDesc_tag;

        String sDesc_meta_title = ClsMisc.removeTags(cDataStep1.sName);

        String sDesc_meta_description = ClsMisc.removeTags(cDataStep1.sDescription); // cDataStep1.sModelname;

        String sDesc_meta_keyword = ClsMisc.removeTags(cDataStep1.sName);

        sDesc_meta_keyword = sDesc_meta_keyword.replaceAll(" ", ",");
        sDesc_meta_keyword = sDesc_meta_keyword.replace("(", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replace("(", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replace("(", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replace(")", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replace(")", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replace(")", "");
/*
        sDesc_meta_keyword = sDesc_meta_keyword.replaceAll("\\(", "");
        sDesc_meta_keyword = sDesc_meta_keyword.replaceAll("\\)", "");
*/
        String sConcat_image = "";
        String sConcat_image_sort_order = "";
        String sStatusText = "";

/*        String sPrd_image = "";*/
/*
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
*/
        
        /***************************
        *   Prep the images data   *
        ***************************/
        ArrayList<String> lstTempPaths = new ArrayList<String>();

        for (int iImageCount = 0; iImageCount < cDataStep1.lstImages.size(); iImageCount++) {
          ClsFunctionResultString cFnRsltStr_ImagePath = cImageManagement.getImagePath(iUploadTypeId, sImagesDir, cDataStep1.lstImages.get(iImageCount), conn);
          String sImagePath = ""; 

          if (cFnRsltStr_ImagePath.bIsOk) {
            sImagePath = cFnRsltStr_ImagePath.sResult; 

            ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sImagePath, sImageRootDirectory);

            if (cFnRsltStr_CutPath.bIsOk) { 
              if (!ClsMisc.stringsEqual(cFnRsltStr_CutPath.sResult, "", true, true, true))
              { lstTempPaths.add(cFnRsltStr_CutPath.sResult); }
            } else {
              System.out.println("Error: ClsMisc.cutPath(" + sImagePath + ", " + sImageRootDirectory + ");");
            }
          } else {
            System.out.println("Error: cImageManagement.getImagePath(iUploadTypeId, " + sImagesDir + ", " + cDataStep1.lstImages.get(iImageCount) + ", conn);");
          }
        }
        
        String sPrd_image = "";
        sConcat_image = "";
        sConcat_image_sort_order = "";
        
        if (lstTempPaths.size() == 0) {
          System.out.println("No images");
        } else {
          for (int iImageCount = 0; iImageCount < lstTempPaths.size(); iImageCount++) {
            String sTempPath = lstTempPaths.get(iImageCount);
 
            if (iImageCount == 0) {
              sPrd_image = sTempPath; 
            } else {
              if (ClsMisc.stringsEqual(sConcat_image, "", true, true, true)) {
                sConcat_image = sTempPath;
                sConcat_image_sort_order = Integer.toString(iImageCount);
              } else {
                sConcat_image = sConcat_image + "\t" + sTempPath;
                sConcat_image_sort_order = sConcat_image_sort_order + "\t" + Integer.toString(iImageCount);
              }
            }
          }
        }



/*
        for (int iImageCount = 0; iImageCount < cDataStep1.lstImages.size(); iImageCount++) {
          
          ClsFunctionResultString cFnRsltStr_ImagePath = cImageManagement.getImagePath(iUploadTypeId, sImagesDir, cDataStep1.lstImages.get(iImageCount), conn);
          String sImagePath = cFnRsltStr_ImagePath.sResult; 
            
          ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sImagePath, sImageRootDirectory);

          if (cFnRsltStr_CutPath.bIsOk)
          { sImagePath = cFnRsltStr_CutPath.sResult; }
          
          if (iImageCount == 0) {
            if (cFnRsltStr_ImagePath.bIsOk) {
              sPrd_image = sImagePath; 
            
              ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sPrd_image, sImageRootDirectory);
            
              if (cFnRsltStr_CutPath.bIsOk)
              { sPrd_image = cFnRsltStr_CutPath.sResult; }
            } else {
              System.out.println("Error cImageManagement.getImagePath:"); 
              System.out.println(cFnRsltStr_ImagePath.sError); 
              cProgressReport.somethingToNote("uploadToMySqlServer", "Error in cImageManagement.getImagePath (Images Dir: " + sImagesDir + ") (Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + "): " + cFnRsltStr_ImagePath.sError, iDataPos, cFnRsltStr_ImagePath.sError);
            }
          } else {
            if (cFnRsltStr_ImagePath.bIsOk) {

              System.out.println("sImagePath     " + sImagePath);
            
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
          
          System.out.println("iImageCount: " + Integer.toString(iImageCount) + " " + sConcat_image);
        }
*/

/*
        for (int iImageCount = 0; iImageCount < cDataStep1.lstImages.size(); iImageCount++) {
          String sImagePath = "";
          
          ClsFunctionResultString cFnRsltStr_ImagePath = cImageManagement.getImagePath(iUploadTypeId, sImagesDir, cDataStep1.lstImages.get(iImageCount), conn);

          if (cFnRsltStr_ImagePath.bIsOk) {
            sImagePath = cFnRsltStr_ImagePath.sResult; 
            
            ClsFunctionResultString cFnRsltStr_CutPath = ClsMisc.cutPath(sImagePath, sImageRootDirectory);
            
            if (cFnRsltStr_CutPath.bIsOk)
            { sImagePath = cFnRsltStr_CutPath.sResult; }

            System.out.println("sImagePath     " + sImagePath);
            
            if (!ClsMisc.stringsEqual(sImagePath, sPrd_image, true, true, true)) {
              if (ClsMisc.stringsEqual(sConcat_image, "", true, true, true)) {
                sConcat_image = sImagePath;
                sConcat_image_sort_order = Integer.toString(iImageCount);
              } else {
                sConcat_image = sConcat_image + "\t" + sImagePath;
                sConcat_image_sort_order = sConcat_image_sort_order + "\t" + Integer.toString(iImageCount);
              }
            }
          } else {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Error - Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean + " cImageManagement.getImagePath(" + Integer.toString(iUploadTypeId) + ", " + sImagesDir + ", " + cDataStep1.lstImages.get(iImageCount) + ": " + cFnRsltStr_ImagePath.sError, iDataPos, cFnRsltStr_ImagePath.sError);
            System.out.print("iImageCount: ");
            System.out.println(iImageCount);
            System.out.println("Error cImageManagement.getImagePath(" + Integer.toString(iUploadTypeId) + ", " + sImagesDir + ", " + cDataStep1.lstImages.get(iImageCount) + ":"); 
            System.out.println(cFnRsltStr_ImagePath.sError); 
          }

          System.out.println("iImageCount: " + Integer.toString(iImageCount) + " " + sConcat_image);
        }
*/
        
        int iFlag_product = iFlag_add;
        int iFlag_description = iFlag_add;
        int iFlag_images = iFlag_add;
        ArrayList<ClsAttribute> lstAttribute = new ArrayList<ClsAttribute>();
        ClsFunctionResult cAttributeResult;

        ClsFunctionResultLstAttribute cFnRsltLstAttr = getLstAttributes(cProgressReport, cAttributeIds, cDataStep1.sDescription, iLanguageId, conn);
        
        if (cFnRsltLstAttr.bIsOk) {
          lstAttribute = cFnRsltLstAttr.lstResult;
        } else {
          System.out.println("getLstAttributes Error: " + cFnRsltLstAttr.sError);
        }
        
        
        
        

        /**** "Item", "Height" ****/
        
//        ClsAttribute cAttribute_ItemHeight = new ClsAttribute();
//        cAttributeResult = cAttributeIds.prepList("Item", "Height", iLanguageId, conn);
//        if (!cAttributeResult.bIsOk) {
//          bIsOk = false;
//          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
//          System.out.println("cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error");
//          System.out.println(cAttributeResult.sError);
//        }
//        cAttribute_ItemHeight.iGroupId = cAttributeIds.getGroupId();
//        cAttribute_ItemHeight.iId = cAttributeIds.getId();
//        cAttribute_ItemHeight.sGroupName = "Item";
//        cAttribute_ItemHeight.sName = "Height";
//        cAttribute_ItemHeight.sValue = Float.toString(cDataStep1.fShippingHeight) + cDataStep1.sUnitMeasure;
//        cAttribute_ItemHeight.iSortOrder = 1;
//        lstAttribute.add(cAttribute_ItemHeight);
























        ResultSet rs;

        /********************************************************************************************
        *   Santy checks each variable that is going to be sent as a parameter to the stored proc   *
        ********************************************************************************************/
        if (sPrd_model.length() > 64) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " Model: " + sPrd_model + " model length: "+ Integer.toString(sPrd_model.length()), iDataPos, "model too long max aloud 64");
          sPrd_model = sPrd_model.substring(0, 64).trim();
        }

        if (sPrd_sku.length() > 64) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " sku: " + sPrd_sku + " sku length: " + Integer.toString(sPrd_sku.length()), iDataPos, "sku too long max aloud 64");
          sPrd_sku = sPrd_sku.substring(0, 63).trim();
        }

        if (sPrd_upc.length() > 12) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " upc: " + sPrd_upc + " upc length: " + Integer.toString(sPrd_upc.length()), iDataPos, "upc too long max aloud 12");
          sPrd_upc = sPrd_upc.substring(0, 12).trim();
        }
        
        if (sPrd_ean.length() > 14) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " ean: " + sPrd_ean + " ean length: " + Integer.toString(sPrd_ean.length()), iDataPos, "ean too long max aloud 14");
          sPrd_ean = sPrd_ean.substring(0, 14).trim();
        }

        if (sPrd_jan.length() > 13) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " jan: " + sPrd_jan + " jan length: " +  Integer.toString(sPrd_jan.length()), iDataPos, "jan too long max aloud 13");
          sPrd_jan = sPrd_jan.substring(0, 13).trim();
        }

        if (sPrd_isbn.length() > 17) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " isbn: " + sPrd_isbn + " isbn length: " + Integer.toString(sPrd_isbn.length()), iDataPos, "isbn too long max aloud 17");
          sPrd_isbn = sPrd_isbn.substring(0, 17).trim();
        }

        if (sPrd_mpn.length() > 64) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " mpn: " + sPrd_mpn + " isbn length: " + Integer.toString(sPrd_mpn.length()), iDataPos, "mpn too long max aloud 64");
          sPrd_mpn = sPrd_mpn.substring(0, 64).trim();
        }

        if (sPrd_location.length() > 128) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " location: " + sPrd_location + " location length: " + Integer.toString(sPrd_location.length()), iDataPos, "location too long max aloud 128");
          sPrd_location = sPrd_location.substring(0, 128).trim();
        }

        if (iPrd_quantity < 0) {
          cProgressReport.somethingToNote("uploadToMySqlServer", "Source Product Id: " + sPrd_mpn + " quantity: " + Integer.toString(iPrd_quantity), iDataPos, "Negative quantity");
          bLineFailedChecks = true;
        }
        
        ClsFunctionResultInt cStockStatusResultInt = new ClsFunctionResultInt();
        if (iPrd_quantity > 0)
        { cStockStatusResultInt = cStockStatus.getId("In Stock"); }
        else { 
          bLoadRecord = false;
          cStockStatusResultInt = cStockStatus.getId("Out Of Stock");
        }

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
        
        if(sSeoUrl_JustModelName == null) {
          sSeoUrl_JustModelName = "";
        } else {
          if (sSeoUrl_JustModelName.length() > 255) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " just name: " + sSeoUrl_JustModelName + " name length: " + Integer.toString(sSeoUrl_JustModelName.length()), iDataPos, "just name too long max aloud 255");
          sSeoUrl_JustModelName = sSeoUrl_JustModelName.substring(0, 255).trim();
          }
        }
        
        if(sDesc_name == null) {
          sDesc_name = "";
        } else {
          if (sDesc_name.length() > 255) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " name: " + sDesc_name + " name length: " + Integer.toString(sDesc_name.length()), iDataPos, "name too long max aloud 255");
          sDesc_name = sDesc_name.substring(0, 255).trim();
          }
        }
        
        if(sDesc_description == null) {
          sDesc_description = "";
        } else {
          if (sDesc_description.length() > 65536) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " description: " + sDesc_description + " description length: " + Integer.toString(sDesc_description.length()), iDataPos, "description too long max aloud 65536");
            sDesc_description = sDesc_description.substring(0, 65536).trim();
          }
        }
        
        if(sDesc_tag == null) {
          sDesc_tag = "";
        } else {
          if (sDesc_tag.length() > 65536) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " tag: " + sDesc_tag + " tag length: " + Integer.toString(sDesc_tag.length()), iDataPos, "tag too long max aloud 65536");
            sDesc_tag = sDesc_tag.substring(0, 65536).trim();
          }
        }

        if(sDesc_meta_title == null) {
          sDesc_meta_title = "";
        } else {
          if (sDesc_meta_title.length() > 255) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta title: " + sDesc_meta_title + " meta title length: " + Integer.toString(sDesc_meta_title.length()), iDataPos, "meta title too long max aloud 255");
            sDesc_meta_title = sDesc_meta_title.substring(0, 255).trim();
          }
        }

        if(sDesc_meta_description == null) {
          sDesc_meta_description = "";
        } else {
          if (sDesc_meta_description.length() > 255) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta description: " + sDesc_meta_description + " meta description length: " + Integer.toString(sDesc_meta_description.length()), iDataPos, "meta description too long max aloud 255");
            sDesc_meta_description = sDesc_meta_description.substring(0, 255).trim();
          }
        }

        if(sDesc_meta_keyword == null) {
          sDesc_meta_keyword = "";
        } else {
          if (sDesc_meta_keyword.length() > 255) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " meta keyword: " + sDesc_meta_keyword + " meta keyword length: " + Integer.toString(sDesc_meta_keyword.length()), iDataPos, "meta keyword too long max aloud 255");
            sDesc_meta_keyword = sDesc_meta_keyword.substring(0, 255).trim();
          }
        }

        if(sConcat_image == null) {
          sConcat_image = "";
        } else {
          if (sConcat_image.length() > 4000) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Concat image: " + sConcat_image + " Concat image length: " + Integer.toString(sConcat_image.length()), iDataPos, "Concat image too long max aloud 4000");
            sConcat_image = sConcat_image.substring(0, 4000).trim();
          }
        }
        
        if(sConcat_image_sort_order == null) {
          sConcat_image_sort_order = "";
        } else {
          if (sConcat_image_sort_order.length() > 4000) {
            cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " Concat sort order: " + sConcat_image_sort_order + " Concat sort order length: " + Integer.toString(sConcat_image_sort_order.length()), iDataPos, "Concat sort order too long max aloud 4000");
            sConcat_image_sort_order = sConcat_image_sort_order.substring(0, 4000).trim();
          }
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
        if (bLoadRecord) {
          if (bLineFailedChecks == false) {
            String sSql = "{CALL insertProduct( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ?  , ? )};";
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
              stmt.setInt(13, iPrd_quantity); // p_prd_quantity int,12                       <-------------
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
              stmt.setDouble(40, dPrd_price_i_pay); // p_prd_price_i_pay decimal(15,4),39
              stmt.setInt(41, iFlag_product); // p_flag_product int,40
              stmt.setInt(42, iFlag_description); // p_flag_description int,41
              stmt.setInt(43, iFlag_images); // p_flag_images int42
              stmt.setString(44, sSeoUrl_JustModelName); // p_seo_url_product_name varchar(255),44
              stmt.registerOutParameter(45, java.sql.Types.VARCHAR);  // OUT p_status_text text)

              rs = stmt.executeQuery();

              // Get Out and InOut parameters
              bIsOk = stmt.getBoolean(1);
              iprd_product_id = stmt.getInt(2);
              sStatusText = stmt.getString(45);
            
              cDataStep1.iProductId = iprd_product_id;
            
              this.lstDataStep1.set(iDataPos, cDataStep1);

              cProgressReport.somethingToNote("uploadToMySqlServer", "Partscode: " + sPrd_model + " - Sku: " + sPrd_sku + " - iprd_product_id: " + Integer.toString(iprd_product_id) + " - Status Text: " + sStatusText, iDataPos, "uploaded");

              if (bIsOk == true) {
                System.out.println("product id " + Integer.toString(iprd_product_id) + " - item " + iDataPos + " of " + this.lstDataStep1.size());

                ClsMisc.printResultset(rs);
              
                int iCategory = ClsMisc.iError;
                int iGrandParentId = -1; /*this is related to the table db_shoes.shoes_category_path which defines where things go in the menu's */

                ClsFunctionResultCategory cFnRsltCategory = cCategoryId.getCategoryClassID(cDataStep1.sSubCategory, cDataStep1.sCategory, iLanguageId, iGrandParentId, sPrd_model, sPrd_sku, sPrd_upc, sPrd_ean, conn);
              
                if (cFnRsltCategory.bIsOk) {
                  addToCategory(cProgressReport, iprd_product_id, cFnRsltCategory.iId, cFnRsltCategory.iParentId, conn);
                } else {
                  System.out.println("Error");
                  System.out.print("ClsCategoryClassId.getCategoryClassID(" + cDataStep1.sSubCategory + ", " + cDataStep1.sCategory + ", ");
                  System.out.print(iLanguageId);
                  System.out.println(")");
                }

                switch (eProductType) {
                  case eProd_Shoes:
                    if (cDataStep1.lstSizes.size() > 0) {
                      ClsFunctionResultInt cFnRslt_OptionSize = insertOptionSize(cProgressReport, iprd_product_id, cDataStep1.iOptionId, sValue, iRequired, conn);
                      String sOptionValueIds = "|";

                      if (cFnRslt_OptionSize.bIsOk) {
                        for (int iPosSize = 0; iPosSize < cDataStep1.lstSizes.size(); iPosSize++) {
                          ClsDataStep1BDroppyVer1_Option cOptionSize = cDataStep1.lstSizes.get(iPosSize);
    
                          if (cOptionSize.iQuantity > 0) {
                            if (cFnRsltInt_FilterGrp_ShoeSize.bIsOk) {
                              ClsFunctionResultInt cFnRslt_FilterId = cFilterClass.getFilterId(cProgressReport, cOptionSize.sSize, cFnRsltInt_FilterGrp_ShoeSize.iResult, iLanguageId, iprd_product_id, conn);
                            }
                          }

                          cOptionSize.iProductOptionId = cFnRslt_OptionSize.iResult;

                          ClsFunctionResult cFnRslt_OptionSizePlusExtFlds = insertOptionSizePlusExtFlds(cProgressReport, cDataStep1, cOptionSize, conn);

                          if (!cFnRslt_OptionSizePlusExtFlds.bIsOk) {
                            cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id) + " - Model Id: " + Integer.toString(cOptionSize.iModelId) + " - Barcode: " + cOptionSize.sBarcode + " - Sku" + cOptionSize.sSku + " - sSize: " + cOptionSize.sSize, iDataPos, "insertOptionSizePlusExtFlds returned error: " + cFnRslt_OptionSizePlusExtFlds.sError);
                          }
                          sOptionValueIds = sOptionValueIds + Integer.toString(cOptionSize.iOptionValueId) + "|";
                        }
                        
                        removeOptionPlusExtraFields(cProgressReport, cDataStep1, sOptionValueIds, conn);
                        
  //                      System.out.println(""); 
                      } else {
                        cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id), iDataPos, "insertOptionSize returned error: " + cFnRslt_OptionSize.sError);
                      }
                    }
                    break;
                  case eProd_Bags:
                    break;
                  case eProd_Clothing:  
                    
                    






                    if (cDataStep1.lstSizes.size() > 0) {
                      ClsFunctionResultInt cFnRslt_OptionSize = insertOptionSize(cProgressReport, iprd_product_id, cDataStep1.iOptionId, sValue, iRequired, conn);
                      String sOptionValueIds = "|";

                      if (cFnRslt_OptionSize.bIsOk) {
                        for (int iPosSize = 0; iPosSize < cDataStep1.lstSizes.size(); iPosSize++) {
                          ClsDataStep1BDroppyVer1_Option cOptionSize = cDataStep1.lstSizes.get(iPosSize);
    
                          if (cOptionSize.iQuantity > 0) {
                            if (cFnRsltInt_FilterGrp_ShoeSize.bIsOk) {
                              ClsFunctionResultInt cFnRslt_FilterId = cFilterClass.getFilterId(cProgressReport, cOptionSize.sSize, cFnRsltInt_FilterGrp_ShoeSize.iResult, iLanguageId, iprd_product_id, conn);
                            }
                          }

                          cOptionSize.iProductOptionId = cFnRslt_OptionSize.iResult;
                          ClsFunctionResult cFnRslt_OptionSizePlusExtFlds = insertOptionSizePlusExtFlds(cProgressReport, cDataStep1, cOptionSize, conn);

                          if (!cFnRslt_OptionSizePlusExtFlds.bIsOk) {
                            cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id) + " - Model Id: " + Integer.toString(cOptionSize.iModelId) + " - Barcode: " + cOptionSize.sBarcode + " - Sku" + cOptionSize.sSku + " - sSize: " + cOptionSize.sSize, iDataPos, "insertOptionSizePlusExtFlds returned error: " + cFnRslt_OptionSizePlusExtFlds.sError);
                          }
                          sOptionValueIds = sOptionValueIds + Integer.toString(cOptionSize.iOptionValueId) + "|";
                        }
                        
                        removeOptionPlusExtraFields(cProgressReport, cDataStep1, sOptionValueIds, conn);
                      } else {
                        cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id), iDataPos, "insertOptionSize returned error: " + cFnRslt_OptionSize.sError);
                      }
                    }





                    break;
                  case eProd_Underwear:  
                    
                    






                    if (cDataStep1.lstSizes.size() > 0) {
                      ClsFunctionResultInt cFnRslt_OptionSize = insertOptionSize(cProgressReport, iprd_product_id, cDataStep1.iOptionId, sValue, iRequired, conn);
                      String sOptionValueIds = "|";

                      if (cFnRslt_OptionSize.bIsOk) {
                        for (int iPosSize = 0; iPosSize < cDataStep1.lstSizes.size(); iPosSize++) {
                          ClsDataStep1BDroppyVer1_Option cOptionSize = cDataStep1.lstSizes.get(iPosSize);
    
                          if (cOptionSize.iQuantity > 0) {
                            if (cFnRsltInt_FilterGrp_ShoeSize.bIsOk) {
                              ClsFunctionResultInt cFnRslt_FilterId = cFilterClass.getFilterId(cProgressReport, cOptionSize.sSize, cFnRsltInt_FilterGrp_ShoeSize.iResult, iLanguageId, iprd_product_id, conn);
                            }
                          }

                          cOptionSize.iProductOptionId = cFnRslt_OptionSize.iResult;
                          ClsFunctionResult cFnRslt_OptionSizePlusExtFlds = insertOptionSizePlusExtFlds(cProgressReport, cDataStep1, cOptionSize, conn);

                          if (!cFnRslt_OptionSizePlusExtFlds.bIsOk) {
                            cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id) + " - Model Id: " + Integer.toString(cOptionSize.iModelId) + " - Barcode: " + cOptionSize.sBarcode + " - Sku" + cOptionSize.sSku + " - sSize: " + cOptionSize.sSize, iDataPos, "insertOptionSizePlusExtFlds returned error: " + cFnRslt_OptionSizePlusExtFlds.sError);
                          }
                          sOptionValueIds = sOptionValueIds + Integer.toString(cOptionSize.iOptionValueId) + "|";
                        }
                        
                        removeOptionPlusExtraFields(cProgressReport, cDataStep1, sOptionValueIds, conn);
                      } else {
                        cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + Integer.toString(cDataStep1.iSourceProductId) + " - iprd_product_id: " + Integer.toString(iprd_product_id), iDataPos, "insertOptionSize returned error: " + cFnRslt_OptionSize.sError);
                      }
                    }
















                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    break;
                  default:
                    cProgressReport.somethingToNote("uploadToMySqlServer", "Unknown product type - Source Product Id: " + sPrd_mpn, iDataPos, "Error");
                }

                ClsFunctionResultInt cFnRslt_FilterId_Colour;
                ClsFunctionResultInt cFnRslt_FilterId_Manufacturer;
                switch (eProductType) {
                  case eProd_Shoes:
                    cFnRslt_FilterId_Colour = cFilterClass.getFilterId(cProgressReport, cDataStep1.sColor, cFnRsltInt_FilterGrp_Colour.iResult, iLanguageId, iprd_product_id, conn);
                    cFnRslt_FilterId_Manufacturer = cFilterClass.getFilterId(cProgressReport, cDataStep1.sBrand, cFnRsltInt_FilterGrp_Manufacturer.iResult, iLanguageId, iprd_product_id, conn);
                    break;
                  case eProd_Bags:
                    cFnRslt_FilterId_Colour = cFilterClass.getFilterId(cProgressReport, cDataStep1.sColor, cFnRsltInt_FilterGrp_Colour.iResult, iLanguageId, iprd_product_id, conn);
                    cFnRslt_FilterId_Manufacturer = cFilterClass.getFilterId(cProgressReport, cDataStep1.sBrand, cFnRsltInt_FilterGrp_Manufacturer.iResult, iLanguageId, iprd_product_id, conn);
                    break;
                  case eProd_Clothing:
                    cFnRslt_FilterId_Colour = cFilterClass.getFilterId(cProgressReport, cDataStep1.sColor, cFnRsltInt_FilterGrp_Colour.iResult, iLanguageId, iprd_product_id, conn);
                    cFnRslt_FilterId_Manufacturer = cFilterClass.getFilterId(cProgressReport, cDataStep1.sBrand, cFnRsltInt_FilterGrp_Manufacturer.iResult, iLanguageId, iprd_product_id, conn);
                    break;
                  case eProd_Underwear:
                    cFnRslt_FilterId_Colour = cFilterClass.getFilterId(cProgressReport, cDataStep1.sColor, cFnRsltInt_FilterGrp_Colour.iResult, iLanguageId, iprd_product_id, conn);
                    cFnRslt_FilterId_Manufacturer = cFilterClass.getFilterId(cProgressReport, cDataStep1.sBrand, cFnRsltInt_FilterGrp_Manufacturer.iResult, iLanguageId, iprd_product_id, conn);
                    break;
                  default:
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
                cProgressReport.somethingToNote("uploadToMySqlServer", "source product id: " + sPrd_mpn + " - iprd_product_id: " + Integer.toString(iprd_product_id), iDataPos, "SQL Failed " + sSql);

                ResultSetMetaData rsmd = rs.getMetaData();
              
                while (rs.next()) {
                  String sLine = "source product id: " + sPrd_mpn + " - iprd_product_id: " + Integer.toString(iprd_product_id);
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
          } //if (bLineFailedChecks == false) {
        } else {
          cProgressReport.somethingToNote("uploadToMySqlServer", "bLoadRecord set to false - cDataStep1.sCategory: " + cDataStep1.sCategory + " - Source Product ID: " + sPrd_model + " - Product Code: " + sPrd_mpn, 0, "tracking");
        } //if (bLoadRecord) {
      } //for
      
      ClsFunctionResult cFnRslt = cFilterClass.fixCategoryFilter(cProgressReport, conn);
      
      if (!cFnRslt.bIsOk) {
        System.out.println("ClsFilterClass.fixCategoryFilter: " + cFnRslt.sError);
        cProgressReport.somethingToNote("uploadToMySqlServer", "Error: ClsFilterClass.fixCategoryFilter: ", 0, cFnRslt.sError);
      }
      
      ClsFunctionResult cFnRslt_Filter_printNotFoundGroupNames = cFilterClass.printNotFoundGroupNames();
      
      if (!cFnRslt_Filter_printNotFoundGroupNames.bIsOk)
      { System.out.println(cFnRslt_Filter_printNotFoundGroupNames.sError); }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.uploadToMySqlServer Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;

      cProgressReport.somethingToNote("uploadToMySqlServer", "Error: ClsProcessBDroppy.uploadToMySqlServer Exception e", 0, cFunctionResult.sError);
      return cFunctionResult;
    }
  }

  private ClsFunctionResultInt insertOptionSize(ClsProgressReport cProgressReport, int iProductId, int iOptionId, String sValue, int iRequired, Connection conn) {
    ClsFunctionResultInt cFunctionResult = new ClsFunctionResultInt();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      cFunctionResult.iResult = ClsMisc.iError;
      int iProductOptionId = -1;

      ResultSet rs;

/*CREATE PROCEDURE insertProdOpt(OUT p_bIsOk boolean, OUT p_product_option_id int, IN p_product_id int, IN p_option_id int, IN p_value text, IN p_required tinyint)*/
      String sSql = "{Call insertProdOpt( ? , ? , ? , ? , ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.registerOutParameter(2, Types.INTEGER);
        stmt.setInt(3, iProductId);
        stmt.setInt(4, iOptionId);
        stmt.setString(5, sValue);
        stmt.setInt(6, iRequired);

        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(1);
        iProductOptionId = stmt.getInt(2);   //  <--------
        cFunctionResult.iResult = iProductOptionId; // <--------
        
        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempId = rs.getInt("id");
            int iTempProductOptionId = rs.getInt("product_option_id");
            int iTempProductId = rs.getInt("product_id");
            int iTempOptionId = rs.getInt("option_id");
            int iTempValue = rs.getInt("value");
            int iTempRequired = rs.getInt("required");

            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessBDroppy.insertOptionSize - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessBDroppy.insertOptionSize SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.addToCategory Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("addToCategory", cFunctionResult.sError, 0, cFunctionResult.sError);

      return cFunctionResult;
    }
  }

  private ClsFunctionResult insertOptionSizePlusExtFlds(ClsProgressReport cProgressReport, 
                                                        ClsDataStep1BDroppyVer1 cDataStep1, 
                                                        ClsDataStep1BDroppyVer1_Option cOptionSize, 
                                                        Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;

      String sSql = "{Call insertOptionPlusExtraFields( ? , ? , ? , ?  , ? , ? , ? , ? , ?  , ? , ? , ? , ? , ?  , ? , ? , ? , ? , ?  , ? , ? , ? , ? , ?  , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, cOptionSize.iProductOptionValueId);  
        stmt.setInt(3, cOptionSize.iProductOptionId);  
        stmt.setInt(4, cDataStep1.iProductId);  
        stmt.setInt(5, cDataStep1.iOptionId);  
        stmt.setInt(6, cOptionSize.iOptionValueId);//  <------
        stmt.setInt(7, cOptionSize.iQuantity);  
        stmt.setInt(8, cOptionSize.iSubtract);  
        stmt.setFloat(9, cOptionSize.fPrice);
        stmt.setString(10, cOptionSize.sPricePrefix); 
        stmt.setInt(11, cOptionSize.iPoints);  
        stmt.setString(12, cOptionSize.sPointsPrefix);  
        stmt.setFloat(13, cOptionSize.fWeight);  
        stmt.setString(14, cOptionSize.sWeightPrefix);  
        stmt.setString(15, cOptionSize.sModel);
        stmt.setInt(16, cOptionSize.iModelId);  
        stmt.setString(17, cOptionSize.sBarcode);  
        stmt.setString(18, cDataStep1.sProductCode);  
        stmt.setString(19, cOptionSize.sSku);  
        stmt.setString(20, cOptionSize.sUpc);
        stmt.setString(21, cOptionSize.sEan);
        stmt.setString(22, cOptionSize.sJan);
        stmt.setString(23, cOptionSize.sIsbn);
        stmt.setString(24, cOptionSize.sMpn);
        stmt.setString(25, cOptionSize.sLocation);

        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(1);

        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempValProductOptionValueId = rs.getInt("val_product_option_value_id");
            int iTempValProductOptionId = rs.getInt("val_product_option_id");
            int iTempValProductId = rs.getInt("val_product_id");
            int iTempValOptionId = rs.getInt("val_option_id");
            int iTempValOptionValueId = rs.getInt("val_option_value_id");
            int iTempValQuantity = rs.getInt("val_quantity");
            int iTempValSubtract = rs.getInt("val_subtract");
            float fTempValPrice = rs.getFloat("val_price");
            int iTempValPricePrefix = rs.getInt("val_price_prefix");
            int iTempValPoints = rs.getInt("val_points");
            String iTempValPointsPrefix = rs.getString("val_points_prefix");
            float fTempValWeight = rs.getFloat("val_weight");
            String iTempValWeightPrefix = rs.getString("val_weight_prefix");
            int iTempDescId = rs.getInt("desc_id");
            int iTempDescProductOptionValueId = rs.getInt("desc_product_option_value_id");
            int iTempDescProductOptionId = rs.getInt("desc_product_option_id");
            int iTempDescProductId = rs.getInt("desc_product_id");
            int iTempDescOptionId = rs.getInt("desc_option_id");
            int iTempDescOptionValueId = rs.getInt("desc_option_value_id");
            String iTempDescModel = rs.getString("desc_model");
            int iTempDescModel_id = rs.getInt("desc_Model_id");
            String sTempDescBarcode = rs.getString("desc_Barcode");
            String sTempDescProductCode = rs.getString("desc_Product_code");
            String STempDescSku = rs.getString("desc_sku");
            String sTempDescSku = rs.getString("desc_sku");
            String sTempDescUpc = rs.getString("desc_upc");
            String sTempDescEan = rs.getString("desc_ean");
            String sTempDescJan = rs.getString("desc_jan");
            String sTempDescIsbn = rs.getString("desc_isbn");
            String sTempDescMpn = rs.getString("desc_mpn");
            String sTempDescLocation = rs.getString("desc_location");

            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("insertOptionSizePlusExtFlds", "cDataStep1.iProductId: " + Integer.toString(cDataStep1.iProductId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessBDroppy.insertOptionSizePlusExtFlds - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessBDroppy.insertOptionSizePlusExtFlds SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("insertOptionSizePlusExtFlds", "cDataStep1.iProductId: " + Integer.toString(cDataStep1.iProductId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.insertOptionSizePlusExtFlds Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("insertOptionSizePlusExtFlds", cFunctionResult.sError, 0, cFunctionResult.sError);

      return cFunctionResult;
    }
  }
  
  private ClsFunctionResult removeOptionPlusExtraFields(ClsProgressReport cProgressReport, 
                                                        ClsDataStep1BDroppyVer1 cDataStep1, 
                                                        String sOptionValueIds, 
                                                        Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;

/*CREATE PROCEDURE removeOptionPlusExtraFields(OUT p_bIsOk boolean, IN p_product_id int(11), IN p_option_value_ids VARCHAR(4000))*/

      String sSql = "{Call removeOptionPlusExtraFields( ? , ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, cDataStep1.iProductId);  
        stmt.setString(3, sOptionValueIds); 

        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(1);

        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempOptionValueId = rs.getInt("option_value_id");

            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("removeOptionPlusExtraFields", "cDataStep1.iProductId: " + Integer.toString(cDataStep1.iProductId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessBDroppy.removeOptionPlusExtraFields - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessBDroppy.removeOptionPlusExtraFields SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("removeOptionPlusExtraFields", "cDataStep1.iProductId: " + Integer.toString(cDataStep1.iProductId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.removeOptionPlusExtraFields Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("removeOptionPlusExtraFields", cFunctionResult.sError, 0, cFunctionResult.sError);

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

        rs = stmt.executeQuery();
      
        cFunctionResult.bIsOk = stmt.getBoolean(4);

        if (cFunctionResult.bIsOk == true) {
          int iCount = 0;
          while (rs.next()) {
            int iTempProductId = rs.getInt("product_id");
            /*int iTempCategoryId = rs.getInt("category_id");*/
            
            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessBDroppy.addToCategory - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessBDroppy.addToCategory SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("addToCategory", "iProductId: " + Integer.toString(iProductId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.addToCategory Exception e");
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
            iCount++;
          }
        } else {
          cProgressReport.somethingToNote("disableProductsNotUpdated", "iUploadTypeId: " + Integer.toString(iUploadTypeId), 0, "SQL Failed " + sSql);
          System.out.println("Error: ClsProcessBDroppy.disableProductsNotUpdated - cFunctionResult.bIsOk == false");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        System.out.println("Error: ClsProcessBDroppy.disableProductsNotUpdated SQLException e");
        System.out.println(e);
      
        cFunctionResult.sError = e.toString();
        cFunctionResult.bIsOk = false;

        cProgressReport.somethingToNote("disableProductsNotUpdated", "iUploadTypeId: " + Integer.toString(iUploadTypeId), 0, cFunctionResult.sError);
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.disableProductsNotUpdated Exception e");
      System.out.println(e);
      
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      cProgressReport.somethingToNote("disableProductsNotUpdated", cFunctionResult.sError, 0, cFunctionResult.sError);

      return cFunctionResult;
    }
  }
  
/*
class ClsDataStep1BDroppyVer1_Option {
  int iProductOptionValueId;
  int iProductOptionId;
  int iOptionValueId;
  int iModelId;
  String sBarcode;
  String sSku;
  String sUpc;
  String sEan;
  String sJan;
  String sIsbn;
  String sMpn;
  String sLocation;
  String sSize;
  int iQuantity;
  float fDeltaCostNoVat;
  float fDeltaSellingPrice;
  float fDeltaStreetPrice;
  int iSubtract;
  float fPrice;
  String sPricePrefix;
  int iPoints;
  String sPointsPrefix;
  float fWeight;
  String sWeightPrefix;
  String sModel;
}
*/  
  private ClsFunctionResultInt getStep1ProductTotalStock(ClsProgressReport cProgressReport, ClsDataStep1BDroppyVer1 cDataStep1) {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      
      int iResult = 0;
      
      for (int iPos = 0; iPos < cDataStep1.lstSizes.size(); iPos++) {
        ClsDataStep1BDroppyVer1_Option cOption = cDataStep1.lstSizes.get(iPos);
        
        iResult = iResult + cOption.iQuantity;
      }
  
      cFnRslt.iResult = iResult; 

      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.getProductTotalStock Exception e");
      System.out.println(e);
      
      cFnRslt.sError = e.toString();
      cFnRslt.bIsOk = false;
      cProgressReport.somethingToNote("ClsProcessBDroppy.getProductTotalStock", cFnRslt.sError, 0, cFnRslt.sError);

      return cFnRslt;
    }
  }


/*
class ClsFunctionResultLstAttribute {
  boolean bIsOk = true;
  String sError = "";
  ArrayList<ClsAttribute> lstResult;
}

*/  
  private ClsFunctionResultLstAttribute getLstAttributes(ClsProgressReport cProgressReport, ClsAttributeId cAttributeIds, String sDescription, int iLanguageId, Connection conn) {
    ClsFunctionResultLstAttribute cFnRslt = new ClsFunctionResultLstAttribute();
    cFnRslt.lstResult = new ArrayList<ClsAttribute>();
    
    try {
      String sGroupName = "";
      
      switch(iLanguageId) {
          case 1:
              sGroupName = "Details";
              break;
          case 2:
              sGroupName = "Einzelheiten";
              break;
      }
      
      String sName = "";
      String sValue = "";
      int iPos_NameStart = 0;
      int iPos_NameEnd = 0;
      int iPos_ValueStart = 0;
      int iPos_ValueEnd = 0;
      int iSortOrder = 1;
      int iLookupFor = 0;
      int iLookupFor_NameStart = 1;
      int iLookupFor_NameEnd = 2;
      int iLookupFor_ValueStart = 3;
      int iLookupFor_ValueEnd1 = 4;
      int iLookupFor_ValueEnd2 = 5;
      
      
      
      iLookupFor = iLookupFor_NameStart;

      for (int iPos = 0; iPos < sDescription.length(); iPos++) {
        /*
        search for "<span class='pdbDescSectionTitle'>"
        from that till the next "</span>" is the sName
        */
        boolean bAttribute = false;
        String sNamePrefix = "<span class='pdbDescSectionTitle'>";
        String sNameSuffix = "</span>";
        
        if (iLookupFor == iLookupFor_NameStart) {
          if (iPos < sDescription.length() - sNamePrefix.length() - 1) {
            if (ClsMisc.stringsEqual(sNamePrefix, sDescription.substring(iPos, iPos + sNamePrefix.length()), true, true, false)) {
              iPos_NameStart = iPos + sNamePrefix.length() + 1;
              iLookupFor = iLookupFor_NameEnd;
            }
          }
        }
        
        if (iLookupFor == iLookupFor_NameEnd) {
          if (iPos < sDescription.length() - sNameSuffix.length() - 1) {
            if (ClsMisc.stringsEqual(sNameSuffix, sDescription.substring(iPos, iPos + sNameSuffix.length()), true, true, false)) {
              iPos_NameEnd = iPos + sNameSuffix.length() + 1;
              
              sName = sDescription.substring(iPos_NameStart - 1, iPos_NameEnd - sNameSuffix.length() - 1);
              
              iLookupFor = iLookupFor_ValueStart;
            }
          }
        }
        
        
        /*
        if not sName = "" then
        search for either "<span class='pdbDescSectionText'>" till "</span>" and that is the sValue
        
        
        Or "<span class='pdbDescSectionText'><span class='pdbDescSectionList'><span class='pdbDescSectionItem'>" till "</span></span></span>"
        and that is the sValue
        */

        String sValuePrefix1 = "<span class='pdbDescSectionText'>";
        String sValueSuffix1 = "</span>";
        String sValuePrefix2 = "<span class='pdbDescSectionText'><span class='pdbDescSectionList'><span class='pdbDescSectionItem'>";
        String sValueSuffix2 = "</span></span></span>";



        
        if (iLookupFor == iLookupFor_ValueStart) {
          if (iPos < sDescription.length() - sValuePrefix1.length() - 1) {
            if (ClsMisc.stringsEqual(sValuePrefix1, sDescription.substring(iPos, iPos + sValuePrefix1.length()), true, true, false)) {
              iPos_ValueStart = iPos + sValuePrefix1.length() + 1;
              iLookupFor = iLookupFor_ValueEnd1;
            }
          }
            
          if (iPos < sDescription.length() - sValuePrefix2.length() - 1) {
            if (ClsMisc.stringsEqual(sValuePrefix2, sDescription.substring(iPos, iPos + sValuePrefix2.length()), true, true, false)) {
              iPos_ValueStart = iPos + sValuePrefix2.length() + 1;
              iLookupFor = iLookupFor_ValueEnd2;
            }
          }
        }

        
        if (iLookupFor == iLookupFor_ValueEnd1) {
          if (iPos < sDescription.length() - sValueSuffix1.length() - 1) {
            if (ClsMisc.stringsEqual(sValueSuffix1, sDescription.substring(iPos, iPos + sValueSuffix1.length()), true, true, false)) {
              iPos_ValueEnd = iPos + sValueSuffix1.length() + 1;
              
              sValue = sDescription.substring(iPos_ValueStart - 1, iPos_ValueEnd - sValueSuffix1.length() - 1);
              bAttribute = true;
              iLookupFor = iLookupFor_NameStart;
            }
          }
        }

        if (iLookupFor == iLookupFor_ValueEnd2) {
          if (iPos < sDescription.length() - sValueSuffix2.length() - 1) {
            if (ClsMisc.stringsEqual(sValueSuffix2, sDescription.substring(iPos, iPos + sValueSuffix2.length()), true, true, false)) {
              iPos_ValueEnd = iPos + sValueSuffix2.length() + 1;
              sValue = sDescription.substring(iPos_ValueStart - 1, iPos_ValueEnd - sValueSuffix2.length() - 1);
              bAttribute = true;
              iLookupFor = iLookupFor_NameStart;
            }
          }
        }

        if (bAttribute == true) {
          sName = sName.replaceAll(":", "");
          sName = sName.trim();
          sName = ClsMisc.removeAttributeOddOnes(sName);
          
          sValue = sValue.replaceAll("</span><span class='pdbDescSectionItem'>", ", ");
          sValue = sValue.trim();
        
          /*System.out.println("Adding Attribute - Name: " + sName + " - Value: " + sValue);*/
          
          ClsAttribute cAttribute = new ClsAttribute();
          ClsFunctionResult cAttributeResult = cAttributeIds.prepList(sGroupName, sName, iLanguageId, conn);
          if (!cAttributeResult.bIsOk) {
            cFnRslt.bIsOk = false;
            cFnRslt.sError = cAttributeResult.sError;
            cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(" + sGroupName + ", " + sName + ", " + Integer.toString(iLanguageId) + ", conn);", iPos, cAttributeResult.sError);
            System.out.println("cAttributeIds.prepList(" + sGroupName + ", " + sName + ", " + Integer.toString(iLanguageId) + ", conn); Error");
            System.out.println(cAttributeResult.sError);
          }
          cAttribute.iGroupId = cAttributeIds.getGroupId();
          cAttribute.iId = cAttributeIds.getId();
          cAttribute.sGroupName = sGroupName;
          cAttribute.sName = sName;
          cAttribute.sValue = sValue;
          cAttribute.iSortOrder = iSortOrder;
          cFnRslt.lstResult.add(cAttribute);
          
          iSortOrder++;
          
          sName = "";
          sValue = "";
        }
      }
  
  
  
  
  





//        ClsAttribute cAttribute_ItemHeight = new ClsAttribute();
//        cAttributeResult = cAttributeIds.prepList("Item", "Height", iLanguageId, conn);
//        if (!cAttributeResult.bIsOk) {
//          bIsOk = false;
//          cProgressReport.somethingToNote("uploadToMySqlServer", "cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error: Model: " + sPrd_model + " sku: " + sPrd_sku + " ean: " + sPrd_ean, iDataPos, cAttributeResult.sError);
//          System.out.println("cAttributeIds.prepList(Item, Height, iLanguageId, conn); Error");
//          System.out.println(cAttributeResult.sError);
//        }
//        cAttribute_ItemHeight.iGroupId = cAttributeIds.getGroupId();
//        cAttribute_ItemHeight.iId = cAttributeIds.getId();
//        cAttribute_ItemHeight.sGroupName = "Item";
//        cAttribute_ItemHeight.sName = "Height";
//        cAttribute_ItemHeight.sValue = Float.toString(cDataStep1.fShippingHeight) + cDataStep1.sUnitMeasure;
//        cAttribute_ItemHeight.iSortOrder = 1;
//        lstAttribute.add(cAttribute_ItemHeight);
  
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error: ClsProcessBDroppy.getLstAttributes Exception e");
      System.out.println(e);
      
      cFnRslt.sError = e.toString();
      cFnRslt.bIsOk = false;
      cProgressReport.somethingToNote("ClsProcessBDroppy.getLstAttributes", cFnRslt.sError, 0, cFnRslt.sError);

      return cFnRslt;
    }
  }
}

