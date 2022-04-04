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

public class ClsOptionValue {
  ArrayList<ClsOptionValueClassId> lstOptionValues; 

  public ClsOptionValue() {
    try {
      this.lstOptionValues = new ArrayList<ClsOptionValueClassId>();
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }

  public ClsFunctionResultInt getOptionValueID(ClsProgressReport cProgressReport, int iOptionId, String sImage, int iLanguageId, String sName, Connection conn) {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();
    
    try {
      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = ClsMisc.iError;
      
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < this.lstOptionValues.size(); iPos++) {
        ClsOptionValueClassId cOptionValue = this.lstOptionValues.get(iPos);

        if (cOptionValue.iOptionId == iOptionId) {
          if (cOptionValue.iLanguageId == iLanguageId) {
            if (ClsMisc.stringsEqual(cOptionValue.sName, sName, true, true, true)) {
              bIsFound = true;
              cFnRsltInt.iResult = cOptionValue.iOptionValueId;
            }
          }
        }
      }
      
      if (!bIsFound) {
        ClsFunctionResultInt cFnRsltInt_checkDb = checkDatabase(cProgressReport, iOptionId, sImage, iLanguageId, sName, conn);

        if (cFnRsltInt_checkDb.bIsOk) {
          cFnRsltInt.bIsOk = cFnRsltInt_checkDb.bIsOk;
          cFnRsltInt.sError = cFnRsltInt_checkDb.sError;
          cFnRsltInt.iResult = cFnRsltInt_checkDb.iResult;
        }
      }
      
      return cFnRsltInt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRsltInt.bIsOk = false;
      cFnRsltInt.sError = e.toString();

      return cFnRsltInt;
    }
  }
  
  private ClsFunctionResultInt checkDatabase(ClsProgressReport cProgressReport, int iOptionId, String sImage, int iLanguageId, String sName, Connection conn) {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();
    
    try {
      ResultSet rs;
      String sSql = "{Call getOptionValueId ( ? , ? , ? , ? , ? , ? , ? , ? )};";

      System.out.println("ClsOptionValue.checkDatabase - sName:" + sName);
      
//CREATE PROCEDURE getOptionValueId(OUT p_bIsOk boolean, OUT p_status VARCHAR(1000), OUT p_option_value_id int, OUT p_sort_order int, in p_option_id int, in p_image varchar(1000), in p_language_id int, in p_name varchar(1000))

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.registerOutParameter(2, Types.CHAR);
        stmt.registerOutParameter(3, Types.INTEGER);
        stmt.registerOutParameter(4, Types.INTEGER);
        stmt.setInt(5, iOptionId);
        stmt.setString(6, sImage);
        stmt.setInt(7, iLanguageId);
        stmt.setString(8, sName);

        rs = stmt.executeQuery();

        boolean bIsOk = stmt.getBoolean(1);
        String sStatus = stmt.getString(2);
        int iOptionValueId = stmt.getInt(3);
        int iSortOrder = stmt.getInt(4);
        
        cFnRsltInt.iResult = iOptionValueId;
        
        if (!ClsMisc.stringsEqual(sStatus, "", true, true, true)) {
            cProgressReport.somethingToNote("ClsOptionValue.checkDatabase", "{Call getOptionValueId ( ? , ? , ? , ? , ? , ? , ? , ? )}; returned unexpected status", 0, sStatus);
        }
        
        if (bIsOk) {
          ClsOptionValueClassId cOptionValue = new ClsOptionValueClassId();

          cOptionValue.iOptionValueId = iOptionValueId;
          cOptionValue.iOptionId = iOptionId;
          cOptionValue.sImage = sImage;
          cOptionValue.iSortOrder = iSortOrder;
          cOptionValue.iLanguageId = iLanguageId;
          cOptionValue.sName = sName;

          this.lstOptionValues.add(cOptionValue);
        } else {
          cFnRsltInt.bIsOk = false;
          cFnRsltInt.sError = "ClsOptionValue.checkDatabase: Couldnt get a values from " + sSql + " - sName: " + sName;
        }
      } catch (SQLException e) {
        e.printStackTrace();
        cFnRsltInt.bIsOk = false;
        cFnRsltInt.sError = e.toString();
      }

      return cFnRsltInt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRsltInt.bIsOk = false;
      cFnRsltInt.sError = e.toString();

      return cFnRsltInt;
    }
  }
}

