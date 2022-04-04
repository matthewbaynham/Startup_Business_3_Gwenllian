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

class ClsFilterDescription {
    int iFilterId;
    int iLanguageId;
    int iFilterGroupId;
    String sName;
}

class ClsFilterGroupDescription {
    int iFilterGroupId;
    int iLanguageId;
    String sName;
}

class ClsProductFilter {
  int iProductId;
  int iFilterId;
  bool bIsUsed;
}
*/

public class ClsFilterClass {
  ArrayList<ClsFilterDescription> lstFilterDescription; 
  ArrayList<ClsFilterGroupDescription> lstFilterGroupDescription; 
  ArrayList<ClsProductFilter> lstProductFilter; 
  ArrayList<String> lstNotFoundFilterGroup; 
  
  public ClsFilterClass(ClsProgressReport cProgressReport, int iLanguageId, int iUploadTypeId, Connection conn) {
    try {
      this.lstFilterDescription = new ArrayList<ClsFilterDescription>();
      this.lstFilterGroupDescription = new ArrayList<ClsFilterGroupDescription>(); 
      this.lstProductFilter = new ArrayList<ClsProductFilter>(); 

      this.lstNotFoundFilterGroup = new ArrayList<String>();

      ClsFunctionResult cFnRslt_getAllProductFilters = getAllProductFilters(cProgressReport, iUploadTypeId, iLanguageId, conn);
      
      if (!cFnRslt_getAllProductFilters.bIsOk) {
        cProgressReport.somethingToNote("Error", "ClsFilterClass.getAllProductFilters(cProgressReport, " + Integer.toString(iUploadTypeId) + ", " + Integer.toString(iLanguageId) + ", conn) - " + cFnRslt_getAllProductFilters.sError, 0, "Error");
      
      }

      ClsFunctionResult cFnRslt_getAllFilterDescription = getAllFilterDescription(cProgressReport, iLanguageId, conn);
      
      if (!cFnRslt_getAllFilterDescription.bIsOk) {
        cProgressReport.somethingToNote("Error", "ClsFilterClass.getAllFilterDescription(cProgressReport, " + Integer.toString(iLanguageId) + ", conn) - " + cFnRslt_getAllFilterDescription.sError, 0, "Error");
      
      }

      ClsFunctionResult cFnRslt_getAllFilterGroupDescription = getAllFilterGroupDescription(cProgressReport, conn);
      
      if (!cFnRslt_getAllFilterGroupDescription.bIsOk) {
        cProgressReport.somethingToNote("Error", "ClsFilterClass.getAllFilterGroupDescription(cProgressReport, " + Integer.toString(iLanguageId) + ", conn) - " + cFnRslt_getAllFilterGroupDescription.sError, 0, "Error");
      
      }







      
      
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cProgressReport.somethingToNote("Code Crashed", "ClsTaxClass.public ClsTaxClass(ClsProgressReport cProgressReport, Connection conn) {", 0, e.toString());
    }
  }

  public ClsFunctionResultInt getFilterId(ClsProgressReport cProgressReport, String sName, int iFilterGroupId, int iLanguageId, int iProductId, Connection conn) throws Exception {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();

    try {
      boolean bIsFound_FilterDescription = false;
      boolean bIsFound_ProductFilter = false;
      cFnRslt.bIsOk = false;
      cFnRslt.iResult = ClsMisc.iError;
      cFnRslt.sError = "";
      
      
/*************************************
*   Look for the name of the group   *
*************************************/

      for (int iPos = 0; iPos < this.lstFilterDescription.size(); iPos++) {
        ClsFilterDescription cFilter = this.lstFilterDescription.get(iPos);
        
        if (cFilter.iFilterGroupId == iFilterGroupId) {
          if (ClsMisc.stringsEqual(cFilter.sName, sName, true, true, true)) {
            bIsFound_FilterDescription = true;
            cFnRslt.iResult = cFilter.iFilterId;
          }
        }
      }

      for (int iPos = 0; iPos < this.lstProductFilter.size(); iPos++) {
        ClsProductFilter cFilter = this.lstProductFilter.get(iPos);
        
        if (cFilter.iProductId == iProductId) {
          if (ClsMisc.stringsEqual(cFilter.sFilterName, sName, true, true, true)) {
            bIsFound_ProductFilter = true;
            cFnRslt.iResult = cFilter.iFilterId;
          }
        }
      }

/*************************************************************************
*   If cant find name of filter add it


*************************************************************************/
      if (!(bIsFound_FilterDescription && bIsFound_ProductFilter)) {
        ClsFunctionResultInt cFnRsltInt_insertFilter = insertFilter(cProgressReport, iLanguageId, iFilterGroupId, sName, iProductId, conn);
      
        if (cFnRsltInt_insertFilter.bIsOk) {
          cFnRslt.iResult = cFnRsltInt_insertFilter.iResult;
          
          ClsFilterDescription cFilterDescription_New = new ClsFilterDescription();
          
          cFilterDescription_New.iFilterId = cFnRsltInt_insertFilter.iResult;
          cFilterDescription_New.iLanguageId = iLanguageId;
          cFilterDescription_New.iFilterGroupId = iFilterGroupId;
          cFilterDescription_New.sName = sName;

          this.lstFilterDescription.add(cFilterDescription_New);
          
        } else {
          System.out.println("Error: insertFilter(cProgressReport, iLanguageId " + Integer.toString(iLanguageId) + ", iFilterGroupId " + Integer.toString(iFilterGroupId) + ", sName " + sName + ", iProductId " + Integer.toString(iProductId) + ", conn)");
        }
      }
      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }
  
  private ClsFunctionResultInt insertFilter(ClsProgressReport cProgressReport, int iLanguageId, int iFilterGroupId, String sFilterName, int iProductId, Connection conn) throws Exception {
    ClsFunctionResultInt cFnRsltInt = new ClsFunctionResultInt();

    try {
      cFnRsltInt.bIsOk = true;
      cFnRsltInt.sError = "";
      cFnRsltInt.iResult = -1;

//      this.lstProductFilter = new ArrayList<ClsProductFilter>(); 
      
      ResultSet rs;
      String sSql = "{Call insertFilter( ? , ? , ? , ? , ? , ? )};";

/*CREATE PROCEDURE insertFilter(OUT p_bIsOk boolean, OUT p_filter_id int, IN p_language_id int, IN p_filter_group_id int, IN p_name varchar(64), IN p_product_id INT)*/

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.registerOutParameter(2, Types.INTEGER);
        stmt.setInt(3, iLanguageId);
        stmt.setInt(4, iFilterGroupId);
        stmt.setString(5, sFilterName);
        stmt.setInt(6, iProductId);

        rs = stmt.executeQuery();
        cFnRsltInt.bIsOk = stmt.getBoolean(1);
        cFnRsltInt.iResult = stmt.getInt(2);
               
        if (cFnRsltInt.bIsOk == true) {
          while (rs.next()) {
            System.out.println("Added filter - Filter ID: " + Integer.toString(rs.getInt("filter_id")) + " Filter Group ID: " + Integer.toString(rs.getInt("Filter_Group_id")) + " Language Id: " + Integer.toString(rs.getInt("Language_id")) + " Name " + rs.getString("Name"));
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
  
  
  
  public ClsFunctionResultInt getFilterGroupId(ClsProgressReport cProgressReport, String sName, Connection conn) throws Exception {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();

    try {
      boolean bIsFound = false;
      cFnRslt.bIsOk = true;
      cFnRslt.iResult = ClsMisc.iError;
      cFnRslt.sError = "";
      
/*************************************
*   Look for the name of the group   *
*************************************/
      for (int iPos = 0; iPos < this.lstFilterGroupDescription.size(); iPos++) {
        ClsFilterGroupDescription cGroup = this.lstFilterGroupDescription.get(iPos);
        
        if (ClsMisc.stringsEqual(cGroup.sName, sName, true, true, true)) {
          bIsFound = true;
          cFnRslt.iResult = cGroup.iFilterGroupId;
        }
      }

/*************************************************************************
*   If cant find name of group sort the name in the list of not found    *
*   and come back to this later so we can report all these to the user   * 
*   at the end of running the code                                       *
*************************************************************************/
      if (!bIsFound) {
        cProgressReport.somethingToNote("Filter Group not found", "Cant find Filter group name. Solution is to add group name to the tables db_shoes. shoes_filter_group_description and db_shoes.shoes_filter_group " + sName, 0, "Filter Group not found");

        boolean bIsFound_notFound = false;
        
        for (int iPosNotFound = 0; iPosNotFound < this.lstNotFoundFilterGroup.size(); iPosNotFound++) {
          String sNotFound = this.lstNotFoundFilterGroup.get(iPosNotFound);

          if (ClsMisc.stringsEqual(sNotFound, sName, true, true, true)) {
            bIsFound_notFound = true;
          }
        }
        
        if (!bIsFound_notFound)
        { this.lstNotFoundFilterGroup.add(sName); }
      }
      
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }
  
  public ClsFunctionResult printNotFoundGroupNames() {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try {
      cFnRslt.bIsOk = false;
      cFnRslt.sError = "";
      int iTableWidth = 40;

      if (this.lstNotFoundFilterGroup.size() > 0) {
        String sLineTitle;
        String sTemp;
          
        System.out.println("");


        sTemp = "----------------------------------------------------------------------------------------------";
        sLineTitle = "|" + sTemp.substring(0, iTableWidth) + "|";
        System.out.println(sLineTitle);

        sTemp = "Filter Group Names not found                                                    ";
        sLineTitle = "|" + sTemp.substring(0, iTableWidth) + "|";
        System.out.println(sLineTitle);

        sTemp = "need to add to Filter Group tables                                          ";
        sLineTitle = "|" + sTemp.substring(0, iTableWidth) + "|";
        System.out.println(sLineTitle);

        sTemp = "----------------------------------------------------------------------------------------------";
        sLineTitle = "|" + sTemp.substring(0, iTableWidth) + "|";
        System.out.println(sLineTitle);

        for (int iPosNotFound = 0; iPosNotFound < this.lstNotFoundFilterGroup.size(); iPosNotFound++) {
          String sNotFound = this.lstNotFoundFilterGroup.get(iPosNotFound);
          String sLine;

          sTemp = sNotFound + "                                                    ";
          sLine = "|" + sTemp.substring(0, iTableWidth) + "|";
        
          System.out.println(sLine);
        }

        sTemp = "----------------------------------------------------------------------------------------------";
        sLineTitle = "|" + sTemp.substring(0, iTableWidth) + "|";
        System.out.println(sLineTitle);

        System.out.println("");
      }
        
      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }
  
  
/*
  public ClsFunctionResultInt getFilterId(ClsProgressReport cProgressReport, int iUploadTypeId, Connection conn) throws Exception {
    ClsFunctionResultInt cFnRslt = new ClsFunctionResultInt();

    try {
      cFnRslt.bIsOk = false;
      cFnRslt.iResult = ClsMisc.iError;
      cFnRslt.sError = "";






      return cFnRslt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();
      return cFnRslt;
    }
  }
*/
  private ClsFunctionResult getAllProductFilters(ClsProgressReport cProgressReport, int iUploadTypeId, int iLanguageId, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      this.lstProductFilter = new ArrayList<ClsProductFilter>(); 
      
      ResultSet rs;
      String sSql = "{Call getAllProductFilters ( ? , ?  , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, iUploadTypeId);
        stmt.setInt(3, iLanguageId);

        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {

            ClsProductFilter cProductFilter = new ClsProductFilter();
            
            cProductFilter.iProductId = rs.getInt("product_id");
            cProductFilter.iFilterId = rs.getInt("filter_id");
            cProductFilter.sFilterName = rs.getString("filter_name");
            cProductFilter.bIsUsed = false;

            this.lstProductFilter.add(cProductFilter);
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
/*CREATE PROCEDURE fixCategoryFilter(OUT p_bIsOk boolean)
*/
  public ClsFunctionResult fixCategoryFilter(ClsProgressReport cProgressReport, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call fixCategoryFilter ( ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);

        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {

            int iDummy_category_id = rs.getInt("category_id");
            int iDummy_filter_id = rs.getInt("filter_id");
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


  private ClsFunctionResult getAllFilterDescription(ClsProgressReport cProgressReport, int iLanguageId, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      this.lstFilterDescription = new ArrayList<ClsFilterDescription>(); 

      ResultSet rs;
      String sSql = "{Call  getAllFilterDescription ( ? , ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, iLanguageId);
        
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsFilterDescription cFilterDescription = new ClsFilterDescription();
            
            cFilterDescription.iFilterId = rs.getInt("filter_id");
            cFilterDescription.iLanguageId = rs.getInt("language_id");
            cFilterDescription.iFilterGroupId = rs.getInt("filter_group_id");
            cFilterDescription.sName = rs.getString("name");

            this.lstFilterDescription.add(cFilterDescription);
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

  private ClsFunctionResult getAllFilterGroupDescription(ClsProgressReport cProgressReport, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      this.lstFilterGroupDescription = new ArrayList<ClsFilterGroupDescription>(); 
      
      ResultSet rs;
      String sSql = "{Call  getAllFilterGroupDescription ( ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsFilterGroupDescription cFilterGroupDescription = new ClsFilterGroupDescription();
            
            cFilterGroupDescription.iFilterGroupId = rs.getInt("filter_group_id");
            cFilterGroupDescription.iLanguageId = rs.getInt("language_id");
            cFilterGroupDescription.sName = rs.getString("name");

            this.lstFilterGroupDescription.add(cFilterGroupDescription);
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

  private ClsFunctionResult removeUnusedProductFilters(ClsProgressReport cProgressReport, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";
      
      for (int iPos = 0; iPos < this.lstProductFilter.size(); iPos++) {
        ClsProductFilter cProductFilter = this.lstProductFilter.get(iPos);
        
        if (!cProductFilter.bIsUsed) {
            ClsFunctionResult cFnRslt = deleteProductFilter(cProgressReport, cProductFilter.iProductId, cProductFilter.iFilterId, conn);
            
            if (!cFnRslt.bIsOk) {
                cProgressReport.somethingToNote("Error", "ClsFilterClass.removeUnusedProductFilters(cProgressReport, " + Integer.toString(cProductFilter.iProductId) + ", " + Integer.toString(cProductFilter.iFilterId) + ", conn) - " + cFnRslt.sError, 0, "Error");
            }
        }
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

  private ClsFunctionResult deleteProductFilter(ClsProgressReport cProgressReport, int iProductId, int iFilterId, Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call deleteProductFilter ( ? , ? , ? )};";
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        stmt.setInt(2, iFilterId);
        stmt.setInt(3, iProductId);

        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk != true) {
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
