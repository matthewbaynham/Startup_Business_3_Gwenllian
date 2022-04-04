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
class ClsExtraWebLinks {
  int iId;
  int iLanguageId;
  int iEntityId;
  String sEntityType;
  String sType;
  String sText;
  String sUrl;
}
*/

public class ClsExtraWebLinks {
  ArrayList<ClsWebLinks> lstWebLinks; 
  ArrayList<ClsExtraPhrases> lstExtraPhrases; 
  ClsFunctionResult cInit_OK;
  
  public ClsExtraWebLinks(int iLanguageId, Connection conn) {
    try {
      this.lstWebLinks = new ArrayList<ClsWebLinks>(); 
      this.cInit_OK = new ClsFunctionResult();

      ClsFunctionResult cFnRslt_WebLinks = getAllExtraWebLinks(iLanguageId, conn);

      ClsFunctionResult cFnRslt_Phrases = getExtraPhrases(iLanguageId, conn);

      if (cFnRslt_WebLinks.bIsOk && cFnRslt_Phrases.bIsOk) 
      {
        this.cInit_OK.bIsOk = true;
        this.cInit_OK.sError = "";
      } else {
        this.cInit_OK.bIsOk = false;
        this.cInit_OK.sError = "";
        
        if (cFnRslt_WebLinks.bIsOk) {
          this.cInit_OK.sError = this.cInit_OK.sError + "ClsExtraWebLinks.getAllExtraWebLinks - Error: " + cFnRslt_WebLinks.sError + " ";
        }
      
        if (cFnRslt_Phrases.bIsOk) {
          this.cInit_OK.sError = this.cInit_OK.sError + "ClsExtraWebLinks.getExtraPhrases - Error: " + cFnRslt_Phrases.sError + " ";
        }
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      this.cInit_OK.bIsOk = false;
      this.cInit_OK.sError = e.toString();
    }
  }

  public ClsFunctionResult init_OK() {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = this.cInit_OK.bIsOk;
      cFnRslt.sError = this.cInit_OK.sError;
      
      return cFnRslt;  
    } catch(Exception e) {
      System.out.println("Error: ClsExtraWebLinks.getAllExtraWebLinks Exception e");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
     return cFnRslt;
    }
  }


  private ClsFunctionResult getAllExtraWebLinks(int iLanguageId, Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";

      this.lstWebLinks = new ArrayList<ClsWebLinks>(); 

      ResultSet rs;
      String sSql = "{Call getAllExtraWebLinks ( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        boolean bIsOk = stmt.getBoolean(1);
               
        if (bIsOk == true) {
          while (rs.next()) {
            if (iLanguageId == rs.getInt("language_id")) {
              ClsWebLinks cWebLinks = new ClsWebLinks();
            
              cWebLinks.iId = rs.getInt("id");
              cWebLinks.iLanguageId = rs.getInt("language_id");
              cWebLinks.iEntityId = rs.getInt("entity_id");
              cWebLinks.sEntityType = rs.getString("entity_type");
              cWebLinks.sType = rs.getString("type");
              cWebLinks.sTextPrefix = rs.getString("text_prefix");
              cWebLinks.sText = rs.getString("text");
              cWebLinks.sTextSuffix = rs.getString("text_suffix");
              cWebLinks.sUrl = rs.getString("url");
              cWebLinks.iSortOrder = rs.getInt("sort_order");
            
              this.lstWebLinks.add(cWebLinks);
            }
          }
        } else {
          cFnRslt.bIsOk = false;
          cFnRslt.sError = "Stored Proc returns error";
          
          System.out.println("");
          System.out.println("Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      return cFnRslt;  
    } catch(Exception e) {
      System.out.println("Error: ClsExtraWebLinks.getAllExtraWebLinks Exception e");
      System.out.println(e);
      cFnRslt.bIsOk = false;
     return cFnRslt;
    }
  }

  private ClsFunctionResult getExtraPhrases(int iLanguageId, Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";

      this.lstExtraPhrases = new ArrayList<ClsExtraPhrases>();
      
      ResultSet rs;
      String sSql = "{Call getExtraPhrases ( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        boolean bIsOk = stmt.getBoolean(1);
               
        if (bIsOk == true) {
          while (rs.next()) {
            if (iLanguageId == rs.getInt("language_id")) {
              ClsExtraPhrases cExtraPhrases = new ClsExtraPhrases();
            
              cExtraPhrases.iId = rs.getInt("id");
              cExtraPhrases.iLanguageId = rs.getInt("language_id");
              cExtraPhrases.sType = rs.getString("type");
              cExtraPhrases.sKey = rs.getString("key");
              cExtraPhrases.sText = rs.getString("text");

              this.lstExtraPhrases.add(cExtraPhrases);
            }
          }
        } else {
          cFnRslt.bIsOk = false;
          cFnRslt.sError = "Stored Proc returns error";
          
          System.out.println("");
          System.out.println("Error...");

          ClsMisc.printResultset(rs);

          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      return cFnRslt;  
    } catch(Exception e) {
      System.out.println("Error: ClsExtraWebLinks.getExtraPhrases Exception e");
      System.out.println(e);
      cFnRslt.bIsOk = false;
     return cFnRslt;
    }
  }


/*
class ClsWebLinks {
  int iId;
  int iLanguageId;
  int iEntityId;
  String sEntityType;
  String sType;
  String sText;
  String sUrl;
  int iSortOrder;
}
  public static boolean stringsEqual(String sTextA, String sTextB, boolean bTrim, boolean bIgnoreCase, boolean bStripNonAlphaNumerics) {

class ClsExtraPhrases {
  int iId;
  int iLanguageId;
  String sType;
  String sKey;
  String sText;
}

*/


  public ClsFunctionResultString getHtml(String sEntityType, String sType, int iEntityId) {
    ClsFunctionResultString cFnRslt = new ClsFunctionResultString();
    
    try {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";
      cFnRslt.sResult = "";
      
      ArrayList<ClsWebLinks> lstWebLinksSubSet = new ArrayList<ClsWebLinks>(); 
      String sHtml = "";
      boolean bIsFound_WebLinks = false;
      boolean bIsFound_LinksTitle = false;
      String sTitle = "";
      int iSortOrderStart = 0;
      int iSortOrderEnd = 0;
      
      
      for (int iPos = 0; iPos < this.lstWebLinks.size(); iPos++) {
        ClsWebLinks cWebLinks = this.lstWebLinks.get(iPos);
        
        /*********************************
        *   Check if we have any links   *
        *********************************/
        
        if (ClsMisc.stringsEqual(cWebLinks.sType, sType, true, true, false)) {
          if (ClsMisc.stringsEqual(cWebLinks.sEntityType, sEntityType, true, true, false)) {
            if (cWebLinks.iEntityId == iEntityId) {
              bIsFound_WebLinks = true;
              
              if (iPos == 0) {
                iSortOrderStart = cWebLinks.iSortOrder;
                iSortOrderEnd = cWebLinks.iSortOrder;
              } else {
                if (iSortOrderStart > cWebLinks.iSortOrder) 
                { iSortOrderStart = cWebLinks.iSortOrder; }
                
                if (iSortOrderEnd < cWebLinks.iSortOrder) 
                { iSortOrderEnd = cWebLinks.iSortOrder; }
              }
              
              lstWebLinksSubSet.add(cWebLinks);
            }
          }
        }
      }
      
      /********************************************
      *   get the title text or report an error   *
      ********************************************/
      if (bIsFound_WebLinks == true) {
        for (int iPos = 0; iPos < this.lstExtraPhrases.size(); iPos++) {
          ClsExtraPhrases cExtraPhrases = this.lstExtraPhrases.get(iPos);
          
          if (ClsMisc.stringsEqual(cExtraPhrases.sType, "links title", true, true, false)) {
            if (ClsMisc.stringsEqual(cExtraPhrases.sKey, sType, true, true, false)) {
               bIsFound_LinksTitle = true;
               sTitle = cExtraPhrases.sText;
            }
          }
        }
        
        if (bIsFound_LinksTitle) {
          sHtml = sHtml + "<h4>" + sTitle + "</h4>";
        } else {
          /*report error*/
          cFnRslt.bIsOk = false;
          cFnRslt.sError = "ClsExtraWebLinks.getHtml - Couldnt find the Link Titles when we have links";
        }
        
        /*************************************************************************************
        *   Loop through the sort order and for each sort order output a line foreach link   *
        *************************************************************************************/
        sHtml = sHtml + "<p>";
        for (int iSortOrderCounter = iSortOrderStart; iSortOrderCounter <= iSortOrderEnd; iSortOrderCounter++) {
          for (int iPos = 0; iPos < lstWebLinksSubSet.size(); iPos++) {
            ClsWebLinks cWebLinks = lstWebLinksSubSet.get(iPos);

            if (cWebLinks.iSortOrder == iSortOrderCounter) {
              sHtml = sHtml 
                    + cWebLinks.sTextPrefix
                    + "<a href='" + cWebLinks.sUrl + "' target='_blank'>"
                    + cWebLinks.sText
                    + "</a>"
                    + cWebLinks.sTextSuffix;
            }
          }
        }
        sHtml = sHtml + "</p>";
      }
      
      cFnRslt.sResult = sHtml;
      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      cFnRslt.sResult = "";
      
      return cFnRslt;
    }
  }
}
