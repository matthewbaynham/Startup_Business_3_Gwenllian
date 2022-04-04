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

public class ClsSitemapXml {
  FileWriter filSitemapXml;
  FileWriter filRobotsTxt;
  String sFullPath_sitemap;
  String sFullPath_robots;

  public ClsSitemapXml(String sPath_sitemap, String sPath_robots) {
  
    try {
      this.sFullPath_sitemap = sPath_sitemap;
      this.sFullPath_robots = sPath_robots;
      
      this.filSitemapXml = new FileWriter(this.sFullPath_sitemap, false);
      this.filRobotsTxt = new FileWriter(this.sFullPath_robots, false);
      
    } catch(Exception e) {
      System.out.println("Error: ClsSitemapXml.");
      System.out.println(e);
    }
  }
  
  public ClsFunctionResult getLinesSitemap(Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {

      ResultSet rs;
      String sSql = "{Call sitemap_xml( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        boolean bIsOk = stmt.getBoolean(1);
               
        if (bIsOk == true) {
          while (rs.next()) {
            String sLine = "";
      
            sLine = rs.getString("line");
      
            addLineSitemap(sLine);
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
      System.out.println("Error: ClsSitemapXml.getLinesSitemap Exception e");
      System.out.println(e);
      cFnRslt.sError = e.toString();
      cFnRslt.bIsOk = false;
     return cFnRslt;
    }
  }
  
  public ClsFunctionResult getLinesRobots(Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {

      ResultSet rs;
      String sSql = "{Call robot_txt ( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        boolean bIsOk = stmt.getBoolean(1);
               
        if (bIsOk == true) {
          while (rs.next()) {
            String sLine = "";
      
            sLine = rs.getString("url");
      
            addLineRobots(sLine);
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
      System.out.println("Error: ClsSitemapXml.getLinesRobots Exception e");
      System.out.println(e);
      cFnRslt.sError = e.toString();
      cFnRslt.bIsOk = false;
     return cFnRslt;
    }
  }
  
  public void close() {
    try {
      this.filSitemapXml.close();  
      this.filRobotsTxt.close();  
    } catch(Exception e) {
      System.out.println("Error: ClsSitemapXml.ClsSitemapXml Exception e");
      System.out.println(e);
    }
  }

  public void addLineSitemap(String sLine) {
    try {
      this.filSitemapXml.write(sLine + "\n");
    } catch(Exception e) {
      System.out.println("Error: ClsSitemapXml.addUrl Exception e");
      System.out.println(e);
    }
  }

  public void addLineRobots(String sLine) {
    try {
      this.filRobotsTxt.write(sLine + "\n");
    } catch(Exception e) {
      System.out.println("Error: ClsSitemapXml.addUrl Exception e");
      System.out.println(e);
    }
  }
}
