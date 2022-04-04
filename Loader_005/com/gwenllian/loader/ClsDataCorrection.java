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
import java.net.*;

/*
class ClsDataCorrectionId {
  int iId;
  String sType;
  String sOrig;
  String sNew;
}
*/

public class ClsDataCorrection {
  ArrayList<ClsDataCorrectionId> lstDataCorrection;
  
  public ClsDataCorrection(String sType, Connection conn) {
    try {
      this.lstDataCorrection = new ArrayList<ClsDataCorrectionId>();
      
      ClsFunctionResult cFnRslt = getAllData(sType, conn);
      
      if (!cFnRslt.bIsOk) {
        System.out.println("Errorin ClsDataCorrection.getAllData('" + sType + "', conn): ");
        System.out.println(cFnRslt.sError);
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResultString getValue(String sValue) {
    ClsFunctionResultString cFnRslt = new ClsFunctionResultString();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      cFnRslt.sResult = "";
      
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < this.lstDataCorrection.size(); iPos++) {
        ClsDataCorrectionId cDataCorrectionId = this.lstDataCorrection.get(iPos);

        if (ClsMisc.stringsEqual(sValue, cDataCorrectionId.sOrig, true, true, true)) {
          cFnRslt.sResult = cDataCorrectionId.sNew;
          bIsFound = true;
        }
      }
      
      if (!bIsFound)
      { cFnRslt.sResult = sValue; }

      return cFnRslt;
    } catch(Exception e) {
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      System.out.println("Error:");
      System.out.println(cFnRslt.sError);
      
      return cFnRslt;
    }
  }

  private ClsFunctionResult getAllData(String sType, Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      
      String sSql = "{Call getDataCorrectionSizes( ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        ResultSet rs;

        stmt.registerOutParameter(1, Types.INTEGER);
        stmt.setString(2, sType);

        rs = stmt.executeQuery();
      
        cFnRslt.bIsOk = stmt.getBoolean(1);

        if (cFnRslt.bIsOk == true) {
          while (rs.next()) {
            ClsDataCorrectionId cDataCorrectionId = new ClsDataCorrectionId();

            cDataCorrectionId.iId =  rs.getInt("id");
            cDataCorrectionId.sType =  rs.getString("type");
            cDataCorrectionId.sOrig =  rs.getString("orig");
            cDataCorrectionId.sNew =  rs.getString("new");

            this.lstDataCorrection.add(cDataCorrectionId);
          }
        } else {
          System.out.println("Error:");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      
      return cFnRslt;
    } catch(Exception e) {
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      System.out.println("Error:");
      System.out.println(cFnRslt.sError);
      
      return cFnRslt;
    }
  }
}
