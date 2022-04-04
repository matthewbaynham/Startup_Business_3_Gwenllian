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

class ClsWebLinks {
  int iId;
  int iLanguageId;
  int iEntityId;
  String sEntityType;
  String sType;
  String sTextPrefix;
  String sText;
  String sTextSuffix;
  String sUrl;
  int iSortOrder;
}

class ClsExtraPhrases {
  int iId;
  int iLanguageId;
  String sType;
  String sKey;
  String sText;
}




class ClsModuleDetails {
  int iId;
  String sName;
  String sCode;
  String sSetting;
}

class ClsImages {
  int iId;
  String sUrl;
  String sPath;
}

class ClsFilterDescription {
  int iFilterId;
  int iLanguageId;
  int iFilterGroupId;
  String sName;
}

class ClsFilterGroupDescription {
  int iFilterGroupId;
  int iLanguageId;
  String sName;
}

class ClsProductFilter {
  int iProductId;
  int iFilterId;
  String sFilterName;
  boolean bIsUsed;
}

class ClsCategoryId {
  int iId;
  int iParentId;
  String sText;
}

class ClsCategoryAllDetails {
  int iCategoryId;
  String sCatImage;
  int iParentId;
  int iTop;
  int iColumn;
  int iSortOrder;
  int iStatus;
  int iLanguageId;
  String sName;
  String sDescription;
  String sMeta_title;
  String sMeta_description;
  String sMeta_keyword;
}

class ClsFunctionResult {
  boolean bIsOk = true;
  String sError = "";
}

class ClsFunctionResultInt {
  boolean bIsOk = true;
  String sError = "";
  int iResult = 0;
}

class ClsFunctionResultCategory {
  boolean bIsOk = true;
  String sError = "";
  int iId = 0;
  int iParentId = 0;
}

class ClsFunctionResultFloat {
  boolean bIsOk = true;
  String sError = "";
  float fResult = 0.0f;
}

class ClsFunctionResultString {
  boolean bIsOk = true;
  String sError = "";
  String sResult = "";
}

class ClsFunctionResultLstAttribute {
  boolean bIsOk = true;
  String sError = "";
  ArrayList<ClsAttribute> lstResult;
}



class clsProductOption {
  int iId;
  String sName;
  String sQuantity;
  String sEan;
}

class clsProductImages {
  int iId;
  String sImage;
}

class clsProduct {
  int iCategoryId;
  String sPartscode;
  String sBrand_name;
  String sSku;
  int iQuantity;
  java.util.Date dteEstimated_arrival_date;
  ArrayList<clsProductOption> lstOptions;
  ArrayList<clsProductImages> lstImage;
}

class ClsWeightId {
  int iId;
  String sText;
}

class ClsWeightClass {
  int iId;
  String sTitle;
  String sUnit;
  float fValue;
}

class ClsLengthClass {
  int iId;
  String sTitle;
  String sUnit;
  float fValue;
}

class ClsStockStatusId {
  int iId;
  String sText;
}

class ClsField {
  public int iId;
  public int iSupplierId;
  public String sName;
  public String sHeaderText;
  public String sMySqlName;
  public String sFieldType;
}

class ClsFieldHeader {
  public int iPosition;
  public String sText;
}

class ClsAttribute {
  int iGroupId;
  int iId;
  String sGroupName;
  String sName;
  String sValue;
  int iSortOrder;
}

class ClsDataRawTuscanyVer1 {
  String sParentCategory;
  String sCategory;
  String sPartscode;
  String sBrandName;
  String sEan;
  String sSku;
  int iQuantity;
  java.util.Date dteEstimatedArrivalDate;
  String sPhaseOut;
  String sModelname;
  String sOption;
  String sCustomization;
  String sCustomizationCharLimit;
  String sDescription;
  String sUnitMeasure;
  String sUnitWeight;
  float fItemLength;
  float fItemHeight;
  float fItemWidth;
  float fItemWeight;
  float fShippingLength;
  float fShippingHeight;
  float fShippingWidth;
  float fShippingWeight;
  String sCurrency;
  float fRetailprice;
  float fRetailspecialprice;
  java.util.Date dteRetailexpiredate;
  float fResellerprice;
  float fResellerspecialprice;
  java.util.Date dteResellerexpiredate;
  java.util.Date dtePublishDate;
  String sImage1;
  String sImage2;
  String sImage3;
  String sImage4;
  String sImage5;
  String sImage6;
  String sImage7;
  String sImage8;
  String sImage9;
  String sImage10;
}

class ClsDataRawBDroppyVer1 {
  int iSourceProductId;
  int iModelId;
  String sBarcode;
  String sBrand;
  String sName;
  String sProductCode;
  String sSku;
  float fCostNoVat;
  float fSellingPrice;
  float fStreetPrice;
  String sDescription;
  float fWeight;
  String sPicture1;
  String sPicture2;
  String sPicture3;
  String sPicture4;
  String sPicture5;
  String sMadeIn;
  String sShoesHeel;
  String sCategory;
  String sSubCategory;
  String sSeason;
  String sColor;
  String sBiColors;
  String sGender;
  String sPrint;
  String sSize;
  int iQuantity;
  String sMaterial;
}


class ClsDataStep1TuscanyVer1 {
  String sParentCategory;
  String sCategory;
  String sPartscode;
  String sBrandName;
  String sEan;
  String sSku;
  int iQuantity;
  java.util.Date dteEstimatedArrivalDate;
  String sPhaseOut;
  String sModelname;
  ArrayList<String> lstOptions;
  String sCustomization;
  String sCustomizationCharLimit;
  String sDescription;
  String sUnitMeasure;
  String sUnitWeight;
  float fItemLength;
  float fItemHeight;
  float fItemWidth;
  float fItemWeight;
  float fShippingLength;
  float fShippingHeight;
  float fShippingWidth;
  float fShippingWeight;
  String sCurrency;
  float fRetailprice;
  float fRetailspecialprice;
  java.util.Date dteRetailexpiredate;
  float fResellerprice;
  float fResellerspecialprice;
  java.util.Date dteResellerexpiredate;
  java.util.Date dtePublishDate;
  ArrayList<String> lstImages;
  ArrayList<ClsAttribute> lstAttribute;
  int iProductId;
}

/*
Size
Quantity
Model_id
Barcode
Sku
*/

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

class ClsDataStep1BDroppyVer1 {
  int iProductId;
  int iSourceProductId;
  /*int iModelId;*/
  /*String sBarcode;*/
  String sBrand;
  String sName;
  String sJustModelName;
  String sProductCode;
  String sSku;
  float fCostNoVat;
  float fSellingPrice;
  float fStreetPrice;
  String sDescription;
  float fWeight;
  String sMadeIn;
  String sShoesHeel;
  String sCategory;
  String sSubCategory;
  String sSeason;
  String sColor;
  String sBiColors;
  String sGender;
  String sPrint;
  /*String sSize;*/
  /*int iQuantity;*/
  String sMaterial;
  int iOptionId;
  ArrayList<String> lstImages;
  ArrayList<ClsDataStep1BDroppyVer1_Option> lstSizes;
}

class ClsDataCorrectionId {
  int iId;
  String sType;
  String sOrig;
  String sNew;
}

class ClsProductCrossRef {
  String sPartscode;
  String sEan;
  String sSku;
  String sOption;
}

class ClsTaxClassId {
  int iId;
  String sText;
}

class ClsOptionClassId {
  int iId;
  String sName;
}

class ClsOptionValueClassId {
  int iOptionValueId;
  int iOptionId;
  String sImage;
  int iSortOrder;
  int iLanguageId;
  String sName;
}


class ClsTaxClassDetails {
  int iId;
  String sTitle;
  String sDescription;
  java.util.Date dteDateAdded;
  java.util.Date dteDateModified;
}

class ClsManufacturerDetails {
  int iId;
  String sName;
  String sImage;
  int iSortOrder;
}

class ClsProgressOverview {
  String sNote; 
  String sLevelOfSerious;
  int iCounter;
}
/*
class ClsErrorProduct {
  int iDataPos;
  int iPoductId;
  String sSku;
  String sEan;
  String sModel;
  int iErr_Id;
  String sErr_Category;
  String sErr_Name;
  String sErr_Long_Description;
  String sErr_Values;
}
*/
/*
sPrd_model     OK
cDataStep1.sEan   OK
sPrd_sku      OK
iDataPos     OK
iprd_product_id    OK

CREATE TEMPORARY TABLE temp_errors (
    err_ID INT AUTO_INCREMENT PRIMARY KEY,
    err_Category varchar(1024) not null default '',
    err_Name varchar(1024) not null default '',
    err_Long_Description varchar(1024) not null default '',
    err_Values varchar(1024) not null default '');


    select err_ID, err_Category, err_Name, err_Long_Description, err_Values 
    from temp_errors;
*/

