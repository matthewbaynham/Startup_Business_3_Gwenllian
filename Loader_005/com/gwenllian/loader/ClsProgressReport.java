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

public class ClsProgressReport {
  FileWriter filProgressReport;
  String sFullPath;
  int iCounterSuccessful = 0;
  int iCounterFailure = 0;
  int iLineCounter = 0;
  ArrayList<ClsProgressOverview> lstOverview;

  
  public ClsProgressReport(String sFolderPath) {
    try {
      this.lstOverview = new ArrayList<ClsProgressOverview>();

      this.sFullPath = sFolderPath.trim();

      char cLastChar = sFullPath.substring(sFullPath.length()-1, sFullPath.length()).charAt(0);
      char cDash = "/".charAt(0);

      String strDate = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());

      if (cLastChar == cDash) {
        this.sFullPath = this.sFullPath + "progress_log_" + strDate + ".txt";
      } else {
        this.sFullPath = this.sFullPath + "/";
        this.sFullPath = this.sFullPath + "progress_log_" + strDate + ".txt";
      }
      
      this.filProgressReport = new FileWriter(this.sFullPath);
      String sTitleLine = "Progress Report Line Number\tNote\tDetails\tSource Line Number\tLevel of Serious\n";
      this.filProgressReport.write(sTitleLine);
    } catch(Exception e) {
      System.out.println("Error: ClsProgressReport.");
      System.out.println(e);
    }
  }
  
  public void close() {
    try {
      this.filProgressReport.close();  
    } catch(Exception e) {
      System.out.println("Error: ClsProgressReport.ClsProgressReport Exception e");
      System.out.println(e);
    }
  }

  public void summary() {
    try {
      int iCol_Note = 30;
      int iCol_LevelOfSerious = 50;
      int iCol_Counter = 7;
      String sLine_Note = "";
      String sLine_LevelOfSerious = "";
      String sLine_Counter = "";
       
      System.out.println("Full Path: " + this.sFullPath);
      System.out.println("Row Count: " + Integer.toString(this.iLineCounter));

      sortLstOverview();

      /************************
      *   header top border   *
      ************************/
      System.out.print("|");

      sLine_Note = "-----------------------------------------------------------------------------";
      sLine_Note = sLine_Note.substring(0, iCol_Note);
      System.out.print(sLine_Note + "|");
        
      sLine_LevelOfSerious = "-------------------------------------------------------------------";
      sLine_LevelOfSerious = sLine_LevelOfSerious.substring(0, iCol_LevelOfSerious);
      System.out.print(sLine_LevelOfSerious + "|");
        
      sLine_Counter = "------------------------------------------";
      sLine_Counter = sLine_Counter.substring(sLine_Counter.length() - iCol_Counter);
      System.out.println(sLine_Counter + "|");

      /***********************
      *   header text line   *
      ***********************/
      System.out.print("|");

      sLine_Note = "Note                                             ";
      sLine_Note = sLine_Note.substring(0, iCol_Note);
      System.out.print(sLine_Note + "|");
        
      sLine_LevelOfSerious = "Level of Serious                                          ";
      sLine_LevelOfSerious = sLine_LevelOfSerious.substring(0, iCol_LevelOfSerious);
      System.out.print(sLine_LevelOfSerious + "|");
        
      sLine_Counter = "Counter                                  ";
      sLine_Counter = sLine_Counter.substring(0, iCol_Counter);
      System.out.println(sLine_Counter + "|");

      /***************************
      *   header bottom border   *
      ***************************/
      System.out.print("|");

      sLine_Note = "-----------------------------------------------------------------------------";
      sLine_Note = sLine_Note.substring(0, iCol_Note);
      System.out.print(sLine_Note + "|");
        
      sLine_LevelOfSerious = "----------------------------------------------------------------";
      sLine_LevelOfSerious = sLine_LevelOfSerious.substring(0, iCol_LevelOfSerious);
      System.out.print(sLine_LevelOfSerious + "|");
        
      sLine_Counter = "------------------------------------------";
      sLine_Counter = sLine_Counter.substring(sLine_Counter.length() - iCol_Counter);
      System.out.println(sLine_Counter + "|");

      for (int iPos = 0; iPos < this.lstOverview.size(); iPos++) {
        ClsProgressOverview cOverview = this.lstOverview.get(iPos);

        System.out.print("|");
        
        sLine_Note = cOverview.sNote + "                                                              ";
        sLine_Note = sLine_Note.substring(0, iCol_Note);
        System.out.print(sLine_Note + "|");
        
        sLine_LevelOfSerious = cOverview.sLevelOfSerious + "                                                          ";
        sLine_LevelOfSerious = sLine_LevelOfSerious.substring(0, iCol_LevelOfSerious);
        System.out.print(sLine_LevelOfSerious + "|");
        
        sLine_Counter = "                                           " + Integer.toString(cOverview.iCounter);
        sLine_Counter = sLine_Counter.substring(sLine_Counter.length() - iCol_Counter);
        System.out.println(sLine_Counter + "|");
      }

      /******************************
      *   end table bottom border   *
      ******************************/
      System.out.print("|");

      sLine_Note = "-----------------------------------------------------------------------------";
      sLine_Note = sLine_Note.substring(0, iCol_Note);
      System.out.print(sLine_Note + "|");
        
      sLine_LevelOfSerious =  "----------------------------------------------------------------------------------";
      sLine_LevelOfSerious = sLine_LevelOfSerious.substring(0, iCol_LevelOfSerious);
      System.out.print(sLine_LevelOfSerious + "|");
        
      sLine_Counter = "------------------------------------------";
      sLine_Counter = sLine_Counter.substring(sLine_Counter.length() - iCol_Counter);
      System.out.println(sLine_Counter + "|");

      System.out.println("");
      
    } catch(Exception e) {
      System.out.println("Error: ClsProgressReport.summary Exception e");
      System.out.println(e);
    }
  }

  public void somethingToNote(String sNote, String sDetails, int iLineNo, String sLevelOfSerious) {
    try {
      this.iLineCounter++;
      
      String sLine = Integer.toString(this.iLineCounter) + "\t" + ClsMisc.stripReturnChar(sNote) + "\t" + ClsMisc.stripReturnChar(sDetails) + "\t" + Integer.toString(iLineNo) + "\t" + sLevelOfSerious + "\n";
    
      this.filProgressReport.write(sLine);

      boolean bIsFound = false;
      String sLevelOfSeriousPrefix = ClsMisc.cutString(sLevelOfSerious, "http");
      
      for (int iPos = 0; iPos < this.lstOverview.size(); iPos++) {
        ClsProgressOverview cOverview = this.lstOverview.get(iPos);
        
        if (ClsMisc.stringsEqual(cOverview.sLevelOfSerious, sLevelOfSeriousPrefix, true, true, false)) {
          if (ClsMisc.stringsEqual(cOverview.sNote, sNote, true, true, false)) {
            bIsFound = true;
            
            cOverview.iCounter++;
            
            this.lstOverview.set(iPos, cOverview);
          }
        }
      }
      
      if (!bIsFound) {
        ClsProgressOverview cOverview = new ClsProgressOverview();
      
        cOverview.sNote = sNote; 
        cOverview.sLevelOfSerious = sLevelOfSeriousPrefix;
        cOverview.iCounter = 1;
      
        this.lstOverview.add(cOverview);
      }
      
    } catch(Exception e) {
      System.out.println("Error: ClsProgressReport.somethingToNote Exception e");
      System.out.println(e);
    }
  }
  
  private void sortLstOverview() {
    try {
      boolean bIsFound = false;
      
      for (int iPosOne = 0; iPosOne < this.lstOverview.size() - 1; iPosOne++) {
        for (int iPosTwo = iPosOne + 1; iPosTwo < this.lstOverview.size(); iPosTwo++) {
          ClsProgressOverview cOverviewOne = this.lstOverview.get(iPosOne);
          ClsProgressOverview cOverviewTwo = this.lstOverview.get(iPosTwo);
          boolean bSwap = false;

          if (ClsMisc.stringsEqual(cOverviewOne.sNote, cOverviewTwo.sNote, true, true, false)) {
            if (cOverviewOne.sLevelOfSerious.compareToIgnoreCase(cOverviewTwo.sLevelOfSerious) == -1) {
              bSwap = true;
            }
          } else {
            if (cOverviewOne.sNote.compareToIgnoreCase(cOverviewTwo.sNote) == -1) {
              bSwap = true;
            }
          }

          if (bSwap) {
            this.lstOverview.set(iPosOne, cOverviewTwo);
            this.lstOverview.set(iPosTwo, cOverviewOne);
          }
        }
      }
    } catch(Exception e) {
      System.out.println("Error: ClsProgressReport.somethingToNote Exception e");
      System.out.println(e);
    }
  }
}
