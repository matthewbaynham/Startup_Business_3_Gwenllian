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

public class ClsMaintainRelatedProductPartscode {
  ArrayList<Integer> lstProjectIds; 
  ArrayList<String> lstPartscode; 
  String sDelimiter;
  
  public ClsMaintainRelatedProductPartscode(String sDelimiterChar) {
    try {
      ClsFunctionResult cFunctionResult = new ClsFunctionResult();
      
      this.sDelimiter = sDelimiterChar;
      
      this.lstProjectIds = new ArrayList<Integer>();
      this.lstPartscode = new ArrayList<String>(); 
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("Error ClsMaintainRelatedProductPartscode.ClsMaintainRelatedProductPartscode(" + sDelimiterChar + ") failed...");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.ClsMaintainRelatedProductPartscode Exception e");
      System.out.println(e);
    }
  }

  public ClsFunctionResult clearAllProjectIds() {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      
      this.lstProjectIds = new ArrayList<Integer>();
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.clearAllProjectIds Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult clearAllPartscode() {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      
      this.lstPartscode = new ArrayList<String>();
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.clearAllPartscode Exception e");
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
      cFunctionResult.bIsOk = true;
      
      for (int iPos = 0; iPos < this.lstProjectIds.size(); iPos++) {
        if (this.lstProjectIds.get(iPos) == iProjectId)
        { bIsFound = true; }
      }
      
      if (!bIsFound)
      { this.lstProjectIds.add(iProjectId); }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.addProjectId Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }

  public ClsFunctionResult addPartscode(String sPartscode) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      boolean bIsFound = false;
      cFunctionResult.sError = "";
      cFunctionResult.bIsOk = true;
      
      for (int iPos = 0; iPos < this.lstPartscode.size(); iPos++) {
        if (ClsMisc.stringsEqual(this.lstPartscode.get(iPos), sPartscode, true, true, false))
        { bIsFound = true; }
      }
      
      if (!bIsFound)
      { this.lstPartscode.add(sPartscode); }
      
      return cFunctionResult;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.addPartscode Exception e");
      System.out.println(e);
      cFunctionResult.sError = e.toString();
      cFunctionResult.bIsOk = false;
      return cFunctionResult;
    }
  }
  
  public ClsFunctionResultInt partscodeCount() {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();

    try {
      cFunctionResultInt.bIsOk = true;
      cFunctionResultInt.sError = "";
      cFunctionResultInt.iResult = this.lstPartscode.size();
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.PartscodeCount Exception e");
      System.out.println(e);
      cFunctionResultInt.sError = e.toString();
      cFunctionResultInt.bIsOk = false;
      return cFunctionResultInt;
    }
  }
  
  public ClsFunctionResultInt productIdCount() {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();

    try {
      cFunctionResultInt.bIsOk = true;
      cFunctionResultInt.sError = "";
      cFunctionResultInt.iResult = this.lstProjectIds.size();
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.productIdCount");
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

        cFunctionResultString.sResult = cFunctionResultString.sResult + Integer.toString(this.lstProjectIds.get(iPos));
      }
      
      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.addProjectId Exception e");
      System.out.println(e);
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.bIsOk = false;
      return cFunctionResultString;
    }
  }

  private ClsFunctionResultString getPartscodeString() {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();

    try {
      cFunctionResultString.sResult = "";
      cFunctionResultString.sError = "";
      cFunctionResultString.bIsOk = true;
      
      for (int iPos = 0; iPos < this.lstPartscode.size(); iPos++) {
        if (iPos != 0)
        { cFunctionResultString.sResult = cFunctionResultString.sResult + this.sDelimiter; }

        cFunctionResultString.sResult = cFunctionResultString.sResult + this.lstPartscode.get(iPos);
      }
      
      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsMaintainRelatedProductPartscode.addProjectId Exception e");
      System.out.println(e);
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.bIsOk = false;
      return cFunctionResultString;
    }
  }

  public ClsFunctionResult runProc(int iUploadTypeID, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      
      ResultSet rs;
      String sSql = "{ Call maintainRelatedProductPartscode ( ? , ? ) };";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iUploadTypeID);
        stmt.registerOutParameter(2, Types.BOOLEAN);
          
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(2);
               
        System.out.print("cFunctionResult.bIsOk: ");
        System.out.println(cFunctionResult.bIsOk);
          
        if (cFunctionResult.bIsOk == true) {
            //while (rs.next()) {
            //  int iDump_id = rs.getInt("id");
            //  String sDump_Title = rs.getString("Partscode");
            //}

            //ClsMisc.printResultset(rs);
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
