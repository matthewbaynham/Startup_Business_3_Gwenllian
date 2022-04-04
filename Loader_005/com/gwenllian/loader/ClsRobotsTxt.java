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
import java.time.*;
import java.io.*;
import java.lang.*;
import java.net.*;

public class ClsRobotsTxt {
  FileWriter filRobotsTxt;
  String sFullPath;

  public ClsRobotsTxt() {
  
    try {
      this.sFullPath = "/var/www/html/shop/robots.txt";
      
      this.filRobotsTxt = new FileWriter(this.sFullPath, false);
      
      addUrl("https://www.gwenllian-retail.com");
      addUrl("https://www.gwenllian-retail.com/shop");

    } catch(Exception e) {
      System.out.println("Error: ClsRobotsTxt.");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResult getAllPaths(Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {

      ResultSet rs;
      String sSql = "{Call robot_txt( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        boolean bIsOk = stmt.getBoolean(1);
               
        if (bIsOk == true) {
          while (rs.next()) {
            String sUrl = "";
      
            sUrl = rs.getString("url");
      
            addUrl(sUrl);
          }

          ClsMisc.printResultset(rs);
        } else {
          cFnRslt.bIsOk = false;
          cFnRslt.sError = "Stored Proc returns error";
          
          System.out.println("");
          System.out.println("Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        cFnRslt.bIsOk = false;
        cFnRslt.sError = e.toString();
      }
      return cFnRslt;  
    } catch(Exception e) {
      System.out.println("Error: ClsManufacturerId.getManufacturerIdFromMySQL Exception e");
      System.out.println(e);
      cFnRslt.sError = e.toString();
      cFnRslt.bIsOk = false;
     return cFnRslt;
    }
  }
  
  public void close() {
    try {
      this.filRobotsTxt.close();  
    } catch(Exception e) {
      System.out.println("Error: ClsRobotsTxt.ClsRobotsTxt Exception e");
      System.out.println(e);
    }
  }

  public void addUrl(String sLine) {
    try {
      this.filRobotsTxt.write(sLine + "\n");
    } catch(Exception e) {
      System.out.println("Error: ClsRobotsTxt.somethingToNote Exception e");
      System.out.println(e);
    }
  }
}
