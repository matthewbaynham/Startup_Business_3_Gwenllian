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
class ClsLengthClass {
  int iId;
  String sTitle;
  String sUnit;
  float fValue;
}
*/

public class ClsMaintainRelatedProductUpc {
  ArrayList<Integer> lstProjectIds; 
  ArrayList<String> lstUpc; 
  String sDelimiter;
  
  public ClsMaintainRelatedProductUpc(String sDelimiterChar) {
    try {
      ClsFunctionResult cFunctionResult = new ClsFunctionResult();
      
      this.sDelimiter = sDelimiterChar;
      
      this.lstProjectIds = new ArrayList<Integer>();
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("Error ClsMaintainRelatedProductUpc.ClsMaintainRelatedProductUpc(" + sDelimiterChar + ") failed...");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.ClsMaintainRelatedProductUpc Exception e");
      System.out.println(e);
    }
  }

  public ClsFunctionResult clearAllProjectIds() {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = false;
      
      this.lstProjectIds = new ArrayList<Integer>();
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.clearAllProjectIds Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult clearAllUpc() {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = false;
      
      this.lstUpc = new ArrayList<String>();
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.clearAllUpc Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult addProjectId(int iProjectId) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      boolean bIsFound = false;
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = false;
      
      for (int iPos = 0; iPos < this.lstProjectIds.size(); iPos++) {
        if (this.lstProjectIds.get(iPos) == iProjectId)
        { bIsFound = true; }
      }
      
      if (bIsFound)
      { this.lstProjectIds.add(iProjectId); }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.addProjectId Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult addUpc(String sUpc) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      boolean bIsFound = false;
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = false;
      
      for (int iPos = 0; iPos < this.lstUpc.size(); iPos++) {
        if (ClsMisc.stringsEqual(this.lstUpc.get(iPos), sUpc, true, true, false))
        { bIsFound = true; }
      }
      
      if (bIsFound)
      { this.lstUpc.add(sUpc); }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.addUpc Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }
  
  public ClsFunctionResultInt upcCount() {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();

    try {
      cFunctionResultInt.iResult = this.lstUpc.size();
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.upcCount Exception e");
      System.out.println(e);
      cFunctionResultInt.sError = e.toString();
      cFunctionResultInt.bIsOk = false;
      return cFunctionResultInt;
    }
  }
  

  private ClsFunctionResultString getProjectIdsString() {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();

    try {
      cFunctionResultString.sResult = "";
      cFunctionResultString.sError = "";
      cFunctionResultString.bIsOk = true;
      
      for (int iPos = 0; iPos < this.lstProjectIds.size(); iPos++) {
        if (iPos != 0)
        { cFunctionResultString.sResult = cFunctionResultString.sResult + this.sDelimiter; }

        cFunctionResultString.sResult = cFunctionResultString.sResult + this.lstProjectIds.get(iPos);
      }
      
      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductUpc.addProjectId Exception e");
      System.out.println(e);
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.bIsOk = false;
      return cFunctionResultString;
    }
  }

  public ClsFunctionResult runProc(Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      String sProductIdAllowed = "";
      String sUpcAllowed = "";

      ClsFunctionResultString cFnRsltStr_ProjectIds = getProjectIdsString();
      
      if (cFnRsltStr_ProjectIds.bIsOk) {
        sProductIdAllowed = cFnRsltStr_ProjectIds.sResult;
      } else {
        cFunctionResult.bIsOk = cFnRsltStr_ProjectIds.bIsOk;
        cFunctionResult.sError = cFnRsltStr_ProjectIds.sError;
      }
      
      if (cFunctionResult.bIsOk) {
        ResultSet rs;
      /*CREATE PROCEDURE maintainRelatedProductUpc(IN p_delimiter VARCHAR(10), IN p_products_allowed text, IN p_upc_allowed text, OUT p_bIsOk boolean)*/
        String sSql = "{Call maintainRelatedProductUpc ( ? , ? , ? , ? )};";

        try (CallableStatement stmt=conn.prepareCall(sSql);) {
          stmt.setString(1, this.sDelimiter);
          stmt.setString(2, sProductIdAllowed);
          stmt.setString(2, sUpcAllowed);
          stmt.registerOutParameter(3, Types.BOOLEAN);
          
          rs = stmt.executeQuery();
          cFunctionResult.bIsOk = stmt.getBoolean(2);
               
          if (cFunctionResult.bIsOk == true) {
            while (rs.next()) {
              int iDump_id = rs.getInt("id");
              String sDump_Title = rs.getString("upc");
            }

            ClsMisc.printResultset(rs);
          } else {
            System.out.println("");
            System.out.println("Error...");

            ClsMisc.printResultset(rs);

            System.out.println("");
          }
        } catch (SQLException e) {
          e.printStackTrace();

          cFunctionResult.bIsOk = false;
          cFunctionResult.sError = e.toString();
        }
      }

      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsLengthClassId.getLengthClassList Exception e");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }
}
