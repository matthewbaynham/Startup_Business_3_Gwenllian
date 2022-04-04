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

public class ClsStockStatus {
  ArrayList<ClsStockStatusId> lstStockStatus;

  public ClsStockStatus(Connection conn, int iLanguageId){
    try {
      this.lstStockStatus = new ArrayList<ClsStockStatusId>();

      ClsFunctionResult cFunctionResult = getStockStatusList(conn, iLanguageId);
      
      if (!cFunctionResult.bIsOk) { 
        System.out.println("Error Couldnt initialise class ClsStockStatus");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResultInt getId(String sStockStatusText) {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();

    try {
      cFunctionResultInt.bIsOk = true;
      cFunctionResultInt.iResult = ClsMisc.iError;
      int iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < this.lstStockStatus.size(); iPos++) {
        ClsStockStatusId cStockStatusId = this.lstStockStatus.get(iPos);
        
        if (ClsMisc.stringsEqual(cStockStatusId.sText, sStockStatusText, true, true, false))
        { cFunctionResultInt.iResult = cStockStatusId.iId; }
      }

      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResultInt.bIsOk = false;
      cFunctionResultInt.sError = e.toString();
      cFunctionResultInt.iResult = ClsMisc.iError;
      return cFunctionResultInt ;
    }
  }
  
  public ClsFunctionResult getStockStatusList(Connection conn, int iLanguageId) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call  getAllStockStatusDetails ( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iLanguageId);  
        stmt.registerOutParameter(2, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(2);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsStockStatusId cStockStatusId = new ClsStockStatusId();
            
            cStockStatusId.iId = rs.getInt("stock_status_id");
            cStockStatusId.sText = rs.getString("name");

            this.lstStockStatus.add(cStockStatusId);
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
