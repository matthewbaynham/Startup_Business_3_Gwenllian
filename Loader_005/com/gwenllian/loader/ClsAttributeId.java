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
SELECT `attribute_id`, `attribute_group_id`, `sort_order` FROM `shoes_attribute` 
SELECT `attribute_id`, `language_id`, `name` FROM `shoes_attribute_description` 
Eg. Length, Hieght, length, Weight

SELECT `attribute_group_id`, `sort_order` FROM `shoes_attribute_group` 
SELECT `attribute_group_id`, `language_id`, `name` FROM `shoes_attribute_group_description` 
Eg. Shipping dimensions, items dimensions

SELECT `product_id`, `attribute_id`, `language_id`, `text` FROM `shoes_product_attribute` 

*/

public class ClsAttributeId {
  ArrayList<ClsAttribute> lstAttributes; 
  int iCurrentGroupId;
  String sCurrentGroupName;
  int iCurrentAttributeId;
  String sCurrentAttributeName;
  
  public ClsAttributeId() {
    try {
      this.lstAttributes = new ArrayList<ClsAttribute>();
      this.iCurrentGroupId = ClsMisc.iError;
      this.sCurrentGroupName = "";
      this.iCurrentAttributeId = ClsMisc.iError;
      this.sCurrentAttributeName = "";
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResult prepList(String sGroupName, String sAttributeName, int iLanguageId, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();
    
    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      
      /************************************************************************
      *   Look in the list to see if I already have the attribute and group   *
      ************************************************************************/
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < this.lstAttributes.size(); iPos++) {
        ClsAttribute cAttribute = this.lstAttributes.get(iPos);
        
        if (ClsMisc.stringsEqual(cAttribute.sName, sAttributeName, true, true, true) && ClsMisc.stringsEqual(cAttribute.sGroupName, sGroupName, true, true, true)) {
          bIsFound = true;

          this.iCurrentGroupId = cAttribute.iGroupId;
          this.sCurrentGroupName = cAttribute.sGroupName;
          this.iCurrentAttributeId = cAttribute.iId;
          this.sCurrentAttributeName = cAttribute.sName;
        }
      }
      
      if (!bIsFound) {
        /*******************************************************************************************************
        *   If I don't already have the values in this class then run the stored procedure to get the values   *
        *******************************************************************************************************/
        ResultSet rs;
        String sSql = "{Call getAttributeIds ( ? , ? , ? , ? , ? , ? )};";

        try (CallableStatement stmt=conn.prepareCall(sSql);) {
          stmt.setString(1, sAttributeName);
          stmt.setString(2, sGroupName);
          stmt.setInt(3, iLanguageId);
          stmt.registerOutParameter(4, Types.INTEGER);
          stmt.registerOutParameter(5, Types.INTEGER);
          stmt.registerOutParameter(6, Types.BOOLEAN);

          //stmt.execute();
          rs = stmt.executeQuery();

          ClsAttribute cAttribute = new ClsAttribute();
          cAttribute.iGroupId = stmt.getInt(5);
          cAttribute.iId = stmt.getInt(4);
          cAttribute.sGroupName = sGroupName;
          cAttribute.sName = sAttributeName;
          cAttribute.sValue = "";
          cAttribute.iSortOrder = 0;

          this.iCurrentAttributeId = cAttribute.iId;
          this.iCurrentGroupId = cAttribute.iGroupId;
          cFunctionResult.bIsOk = stmt.getBoolean(6);

          if (!cFunctionResult.bIsOk)
          { ClsMisc.printResultset(rs); }

          this.lstAttributes.add(cAttribute);
        } catch (SQLException e) {
          e.printStackTrace();
          cFunctionResult.bIsOk = false;
          cFunctionResult.sError = e.toString();
        }
      }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();

      return cFunctionResult;
    }
  }
  
  public int getGroupId() {
    try {
      return this.iCurrentGroupId;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return ClsMisc.iError;
    }
  }

  public int getId() {
    try {
      return this.iCurrentAttributeId;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return ClsMisc.iError;
    }
  }


  public ClsFunctionResult insertProductAttribute(ClsProgressReport cProgressReport, int iProductId, int iLanguageId, int iAttributeId, String sAttributeText, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();
    
    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      
      /*******************************************************************************************************
      *   If I don't already have the values in this class then run the stored procedure to get the values   *
      *******************************************************************************************************/
      ResultSet rs;
        
      String sSql = "{Call insertProductAttribute( ?, ? , ? , ? , ? ) };";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iProductId);
        stmt.setInt(2, iLanguageId);
        stmt.setInt(3, iAttributeId);
        stmt.setString(4, sAttributeText);
        stmt.registerOutParameter(5, Types.BOOLEAN);

        //stmt.execute();
        rs = stmt.executeQuery();

        cFunctionResult.bIsOk = stmt.getBoolean(5);

        if (!cFunctionResult.bIsOk)
        { ClsMisc.printResultset(rs); }
      } catch (SQLException e) {
        e.printStackTrace();
        cFunctionResult.bIsOk = false;
        cFunctionResult.sError = e.toString();
          
        cProgressReport.somethingToNote("ClsAttributeId.insertProductAttribute", "Product Id: " + Integer.toString(iProductId) + " Language Id: " + Integer.toString(iLanguageId) + " Attribute Id: " + Integer.toString(iAttributeId) + " Attribute Text: " + sAttributeText +" Error: " + cFunctionResult.sError, 0, "Error");
      }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();

      cProgressReport.somethingToNote("ClsAttributeId.insertProductAttribute", "Product Id: " + Integer.toString(iProductId) + " Language Id: " + Integer.toString(iLanguageId) + " Attribute Id: " + Integer.toString(iAttributeId) + " Attribute Text: " + sAttributeText +" Error: " + cFunctionResult.sError, 0, "Error");

      return cFunctionResult;
    }
  }





}
