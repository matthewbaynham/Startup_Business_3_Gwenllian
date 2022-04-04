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
class ClsManufacturerDetails {
  int iId;
  String sName;
  String sImage;
  int iSortOrder;
}
*/
public class ClsManufacturerId {
  ArrayList<ClsManufacturerDetails> lstManufacturers; 

  public ClsManufacturerId(){
    try {
      this.lstManufacturers = new ArrayList<ClsManufacturerDetails>();
      
    } catch(Exception e) {
      System.out.println("Error: ClsManufacturerId.ClsManufacturerId Exception e");
      System.out.println(e);
    }
  }
  
  public int getId(String sManufacturerName, Connection conn, ClsProgressReport cProgressReport) {
    try {
      boolean bIsFonud = false;
      int iResult = ClsMisc.iError;
      
      for (int iPos = 0; iPos < this.lstManufacturers.size(); iPos++) {
        if (ClsMisc.stringsEqual(this.lstManufacturers.get(iPos).sName, sManufacturerName, true, true, false)) {
          bIsFonud = true;
          iResult = this.lstManufacturers.get(iPos).iId;
        }
      }
      
      if (!bIsFonud) {
        ClsFunctionResultInt cFunctionResultInt = getManufacturerIdFromMySQL(sManufacturerName, conn);

        if (cFunctionResultInt.bIsOk) {
          iResult = cFunctionResultInt.iResult;
        } else {
          System.out.println(cFunctionResultInt.sError);
          cProgressReport.somethingToNote(cFunctionResultInt.sError, sManufacturerName, 0, "Failed");
        }
      }
      
      return iResult;
    } catch(Exception e) {
      System.out.println("Error: ClsManufacturerId.getId Exception e");
      System.out.println(e);
      return ClsMisc.iError;
    }
  }
  
  private ClsFunctionResultInt getManufacturerIdFromMySQL(String sManufacturerName, Connection conn) {
    ClsFunctionResultInt cFunctionResult = new ClsFunctionResultInt();

    try {

      ResultSet rs;
      String sSql = "{Call getManufacturerId( ? , ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setString(1, sManufacturerName);  
        stmt.registerOutParameter(2, Types.INTEGER);
        stmt.registerOutParameter(3, Types.BOOLEAN);
        
        //stmt.execute();
        rs = stmt.executeQuery();
        int iManufacturerId = stmt.getInt(2);
        boolean bIsOk = stmt.getBoolean(3);
               
        if (bIsOk == true) {
          while (rs.next()) {
            ClsManufacturerDetails cManufacturer = new ClsManufacturerDetails();
      
            cManufacturer.iId = rs.getInt("manufacturer_id");
            cManufacturer.sName = rs.getString("name");
            cManufacturer.sImage = rs.getString("image");
            cManufacturer.iSortOrder = rs.getInt("sort_order");
      
            this.lstManufacturers.add(cManufacturer);
          }

          ClsMisc.printResultset(rs);
          cFunctionResult.iResult = iManufacturerId;
        } else {
          cFunctionResult.bIsOk = false;
          cFunctionResult.sError = "Stored Proc returns error";
          cFunctionResult.iResult = ClsMisc.iError;
          
          System.out.println("");
          System.out.println("Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      return cFunctionResult;  
    } catch(Exception e) {
      System.out.println("Error: ClsManufacturerId.getManufacturerIdFromMySQL Exception e");
      System.out.println(e);
      cFunctionResult.bIsOk = false;
     return cFunctionResult;
    }
  }
}



