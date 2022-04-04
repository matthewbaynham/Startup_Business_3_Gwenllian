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

public class ClsLengthClassId {
  ArrayList<ClsLengthClass> lstLengths; 
  
  public ClsLengthClassId(Connection conn, int iLanguageId) {
    try {
      ClsFunctionResult cFunctionResult = new ClsFunctionResult();
      
      this.lstLengths = new ArrayList<ClsLengthClass>();
      
      cFunctionResult = getLengthClassList(conn, iLanguageId);
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("Error ClsLengthClassId(Connection conn, int iLanguageId) failed...");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error: ClsLengthClassId.ClsLengthClassId Exception e");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResultInt getId(String sText) {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();
    try {
      cFunctionResultInt.iResult = ClsMisc.iError;
      cFunctionResultInt.sError = "";
      cFunctionResultInt.bIsOk = false;
      
      for (int iPos = 0; iPos < this.lstLengths.size(); iPos++) {
        ClsLengthClass cLengthClass = this.lstLengths.get(iPos);

        if (ClsMisc.stringsEqual(cLengthClass.sTitle, sText, true, true, true) || ClsMisc.stringsEqual(cLengthClass.sUnit, sText, true, true, true)) {
          cFunctionResultInt.iResult = cLengthClass.iId;
          cFunctionResultInt.bIsOk = true;
        }
      }
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error: ClsLengthClassId.getId Exception e");
      System.out.println(e);
      cFunctionResultInt.iResult = ClsMisc.iError;
      cFunctionResultInt.sError = e.toString();
      cFunctionResultInt.bIsOk = false;
      return cFunctionResultInt;
    }
  }

  private ClsFunctionResult getLengthClassList(Connection conn, int iLanguageId) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call  getAllLengthClassDetails ( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iLanguageId);  
        stmt.registerOutParameter(2, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(2);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsLengthClass cLengthClass = new ClsLengthClass();
            
            cLengthClass.iId = rs.getInt("length_class_id");
            cLengthClass.sTitle = rs.getString("title");
            cLengthClass.sUnit = rs.getString("unit");
            cLengthClass.fValue = rs.getFloat("value");

            this.lstLengths.add(cLengthClass);
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
