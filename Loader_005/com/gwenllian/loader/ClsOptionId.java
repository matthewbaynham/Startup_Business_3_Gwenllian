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
SELECT * FROM `shoes_option` 

option_id	type	sort_order
13 	select 	11

SELECT * FROM `shoes_option_description` 

option_id	language_id	name
13 	1 	Shoe Size
13 	2 	Schuhgröße

class ClsOptionClassId {
  int iId;
  String sName;
}

*/

public class ClsOptionId {
  ArrayList<ClsOptionClassId> lstOptions; 

  public ClsOptionId() {
    try {
      this.lstOptions = new ArrayList<ClsOptionClassId>();
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResultInt getOptionID(String sName, Connection conn) {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();
    
    try {
      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = ClsMisc.iError;
      
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < this.lstOptions.size(); iPos++) {
        ClsOptionClassId cOption = this.lstOptions.get(iPos);

        if (ClsMisc.stringsEqual(cOption.sName, sName, true, true, true)) {
          bIsFound = true;
          cFnRsltInt.iResult = cOption.iId;
        }
      }
      
      if (!bIsFound) {
        ClsFunctionResultInt cFnRsltInt_checkDb = checkDatabase(sName, conn);

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
  
  private ClsFunctionResultInt checkDatabase(String sName, Connection conn) {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();
    
    try {
      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = ClsMisc.iError;

  //CREATE PROCEDURE getOptionId(OUT p_bIsOk boolean, OUT p_id int, in p_name varchar(128))
      ResultSet rs;
      String sSql = "{Call getOptionId ( ? , ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.registerOutParameter(2, Types.INTEGER);
        stmt.setString(3, sName);

        rs = stmt.executeQuery();

        cFnRsltInt.bIsOk = stmt.getBoolean(1);
        int iId = stmt.getInt(2);

        System.out.print("iOptionId: ");
        System.out.println(iId);
        
        if (cFnRsltInt.bIsOk) {
          ClsOptionClassId cOption = new ClsOptionClassId();
            
          cOption.iId = iId;
          cOption.sName = sName;
          
          this.lstOptions.add(cOption);

          cFnRsltInt.iResult = iId;
        } else {
          ClsMisc.printResultset(rs);
        
          cFnRsltInt.bIsOk = false;
          cFnRsltInt.sError = "ClsOptionId.checkDatabase: Couldt get a values from " + sSql + " - sName: " + sName;
        }
      } catch (SQLException e) {
        e.printStackTrace();
        System.out.print("ClsOptionId.checkDatabase Error");
        System.out.print(e);
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



