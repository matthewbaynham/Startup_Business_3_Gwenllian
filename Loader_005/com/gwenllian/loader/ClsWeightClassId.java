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
class ClsWeightClass {
  int iId;
  String sTitle;
  String sUnit;
  float fValue;
}
*/

public class ClsWeightClassId {
  ArrayList<ClsWeightClass> lstWeights; 
  
  public ClsWeightClassId(Connection conn, int iLanguageId) {
    try {
      ClsFunctionResult cFunctionResult = new ClsFunctionResult();
      
      this.lstWeights = new ArrayList<ClsWeightClass>();
      
      cFunctionResult = getWeightClassList(conn, iLanguageId);
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("Error ClsWeightClassId(Connection conn, int iLanguageId) failed...");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResultInt getId(String sText) {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();
    try {
      cFunctionResultInt.iResult = ClsMisc.iError;
      cFunctionResultInt.sError = "";
      cFunctionResultInt.bIsOk = false;
      
      for (int iPos = 0; iPos < this.lstWeights.size(); iPos++) {
        ClsWeightClass cWeightClass = this.lstWeights.get(iPos);

        if (ClsMisc.stringsEqual(cWeightClass.sTitle, sText, true, true, true) || ClsMisc.stringsEqual(cWeightClass.sUnit, sText, true, true, true)) {
          cFunctionResultInt.iResult = cWeightClass.iId;
          cFunctionResultInt.bIsOk = true;
        }
      }
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResultInt.iResult = ClsMisc.iError;
      cFunctionResultInt.sError = e.toString();
      cFunctionResultInt.bIsOk = false;
      return cFunctionResultInt;
    }
  }

  private ClsFunctionResult getWeightClassList(Connection conn, int iLanguageId) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call  getAllWeightClassDetails ( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iLanguageId);  
        stmt.registerOutParameter(2, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(2);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsWeightClass cWeightClass = new ClsWeightClass();
            
            cWeightClass.iId = rs.getInt("weight_class_id");
            cWeightClass.sTitle = rs.getString("title");
            cWeightClass.sUnit = rs.getString("unit");
            cWeightClass.fValue = rs.getFloat("value");

            this.lstWeights.add(cWeightClass);
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
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }
}
