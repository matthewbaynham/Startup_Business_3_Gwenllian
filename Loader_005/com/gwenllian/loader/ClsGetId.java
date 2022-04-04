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

public class ClsGetId {
  public static Integer getLanguageId(boolean bIsOk, Connection conn, String sLanguage) throws Exception {
    try {
      Integer iLanguageId = -1;
      ResultSet rs;

      String sSql = "{Call getLanguageID ( ? , ? , ? )};";
      
      System.out.println("Get Language ID");
      System.out.println("Language: " + sLanguage);
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setString(1, sLanguage);  
        stmt.registerOutParameter(2, Types.VARCHAR);
        stmt.registerOutParameter(3, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
               
        iLanguageId = stmt.getInt(2);
        bIsOk = stmt.getBoolean(3);
               
        if (bIsOk != true) {
          System.out.println("");
          System.out.println("Error...");

          ClsMisc.printResultset(rs);
          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      
      return iLanguageId;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return -1;
    }
  }

  public static Integer getUploadTypeID(boolean bIsOk, Connection conn, String sFileType) throws Exception {
    try {
      String sSql = "{Call getSettingsUploadStock_uploadTypeID ( ? , ? , ? )};";
      ResultSet rs;
      int iFileTypeId = -1;
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setString(1, sFileType);  
        stmt.registerOutParameter(2, Types.VARCHAR);
        stmt.registerOutParameter(3, Types.BOOLEAN);
              
        rs = stmt.executeQuery();
               
        iFileTypeId = stmt.getInt(2);
        bIsOk = stmt.getBoolean(3);
               
        if (bIsOk == true) {
          while (rs.next()) {
            Integer iId = rs.getInt("tmp_id");
            String sName = rs.getString("tmp_name");
            String sVersion = rs.getString("tmp_version");
            System.out.println("Id: " + Integer.toString(iId) + " Name: " + sName + " Version: " + sVersion);
          }
        } else {
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
       
      return iFileTypeId;
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
        return null;
    }
  }
}

