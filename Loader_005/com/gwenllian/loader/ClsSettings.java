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

public class ClsSettings {
  boolean lbIsOk;
  int liLanguageId;
  int liUpload_TypeID;
  String lsUpload_Name;
  String lsUpload_ShortName;
  String lsUpload_Version;
  String lsUpload_FileType;
  boolean lbUpload_HasHeader;
  String lsUpload_Prefix;
  String lsUpload_Delimiter;
  ArrayList<ClsFieldHeader> lstFieldsHeader;
  ArrayList<ClsField> lstFields;
  
  public int languageId() {
    return this.liLanguageId;
  }
  
  public int uploadTypeID() {
    return this.liUpload_TypeID;
  }

  public ClsSettings (Connection conn, String sLanguage, String sFileType){
    try {
      boolean bIsOk = true;
      
      this.liLanguageId = ClsGetId.getLanguageId(bIsOk, conn, sLanguage);
      this.liUpload_TypeID = ClsGetId.getUploadTypeID(bIsOk, conn, sFileType);
      this.getUploadFileDetails(bIsOk, conn, sFileType);
      
      lstFields = new ArrayList<ClsField>();
      
      this.lbIsOk = bIsOk;
      
      this.getFieldSettings(bIsOk, conn, this.liUpload_TypeID);
      ClsField fldUnitWeight = this.findField("unit_weight");  /*tmp_name = unit_weight */
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }

  public void analyseHeaderRow(String sRowHeader) {
    try {
      System.out.println("analyseHeaderRow Begin");

//String csv = "Apple, Google, Samsung";

// step one : converting comma separate String to array of String
//String[] elements = csv.split(",");

// step two : convert String array to list of String
//List<String> fixedLenghtList = Arrays.asList(elements);

// step three : copy fixed list to an ArrayList
//ArrayList<String> listOfString = new ArrayList<String>(fixedLenghtList);

      String sStrangeTag = "sdgshetjfnrfthhbxtjjk";



      sRowHeader = sRowHeader.replaceAll(this.lsUpload_Delimiter, sStrangeTag + this.lsUpload_Delimiter + sStrangeTag);
      
      String[] arrFields = sRowHeader.split(this.lsUpload_Delimiter);
      List<String> lstFields = Arrays.asList(arrFields);
      ArrayList<String> lstTemp = new ArrayList<String>(lstFields);

      System.out.println("sRowHeader: " + sRowHeader);
      System.out.println("lstTemp.size(): " + Integer.toString(lstTemp.size()));
      
      this.lstFieldsHeader = new ArrayList<ClsFieldHeader>();
      
      for(int iCounter = 0; iCounter < lstTemp.size(); iCounter++) {
         ClsFieldHeader oFieldHeader = new ClsFieldHeader();

         oFieldHeader.iPosition = iCounter;
         oFieldHeader.sText = lstTemp.get(iCounter);

         oFieldHeader.sText = oFieldHeader.sText.replaceAll(sStrangeTag, "");

         System.out.println(iCounter);
         System.out.println(oFieldHeader.sText);
         
         this.lstFieldsHeader.add(oFieldHeader);
      }

      System.out.println("this.lstFieldsHeader.size(): " + Integer.toString(this.lstFieldsHeader.size()));

      System.out.println("analyseHeaderRow End");
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }

  public boolean checkIsHeaderRowOK() {
    try {
      boolean bIsOk = true;
      
      if (this.lstFieldsHeader.isEmpty()) {
        bIsOk = false;
      } 
      
      return bIsOk;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return false;
    }
  }

  public String getHeaderFieldName(int iPosition){
    try {
      Iterator<ClsFieldHeader> it = this.lstFieldsHeader.iterator();
      while (it.hasNext()) {
        ClsFieldHeader cResult = it.next();
        if (cResult.iPosition == iPosition) { // Person found, return object
          return cResult.sText;
        }
      }
      return null; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return null;
    }
  }

  public int getHeaderFieldPos(String sFieldText){
    try {
      int iPos = 0;
      int iResult = ClsMisc.iError;
      
      for (iPos = 0; iPos < this.lstFieldsHeader.size(); iPos++) {
        if (ClsMisc.stringsEqual(this.lstFieldsHeader.get(iPos).sText, sFieldText, true, true, true)) {
          iResult = iPos;
        }
      }
  
      return iResult;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return ClsMisc.iError;
    }
  }

  public void getFieldSettings(boolean bIsOk, Connection conn, Integer iUploadTypeId) throws Exception {
    try {
      ResultSet rs;
      String sSql = "{Call  getSettingsUploadStock_uploadField ( ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iUploadTypeId);  
        stmt.registerOutParameter(2, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
        bIsOk = stmt.getBoolean(2);
               
        if (bIsOk == true) {
          while (rs.next()) {
            ClsField oField = new ClsField();
      
            oField.iId = rs.getInt("tmp_id");
            oField.iSupplierId = rs.getInt("tmp_supplier_id");
            oField.sName = rs.getString("tmp_name");
            oField.sHeaderText = rs.getString("tmp_header_text");
            oField.sMySqlName = rs.getString("tmp_mysql_name");
            oField.sFieldType = rs.getString("tmp_field_type");
      
            this.lstFields.add(oField);
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
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }
  
  public ClsField findField(String sName) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sName.equals(sName)) { // Person found, return object
          return objResult;
        }
      }
      return null; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return null;
    }
  }

  public String getField_HeaderText_from_MySqlName(String sMySqlName) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sMySqlName.equals(sMySqlName)) { // found, return object
          return objResult.sHeaderText;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }
  
  public String getField_HeaderText_from_Name(String sName) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sName.equals(sName)) { // found, return object
          return objResult.sHeaderText;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }

  public String getField_MySqlName_from_HeaderText(String sHeaderText) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sHeaderText.equals(sHeaderText)) { // found, return object
          return objResult.sMySqlName;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }
  
  public String getField_MySqlName_from_Name(String sName) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sName.equals(sName)) { // found, return object
          return objResult.sMySqlName;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }
  
  public String getField_Name_from_HeaderText(String sHeaderText) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sHeaderText.equals(sHeaderText)) { // found, return object
          return objResult.sName;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }

  public String getField_Name_from_MySqlName(String sMySqlName) {
    try {
      Iterator<ClsField> it = this.lstFields.iterator();
      while (it.hasNext()) {
        ClsField objResult = it.next();
        if (objResult.sMySqlName.equals(sMySqlName)) { // found, return object
          return objResult.sName;
        }
      }
      return ""; // Not found return NULL
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      
      return "";
    }
  }

  public void getUploadFileDetails(boolean bIsOk, Connection conn, String sUploadTypeName) throws Exception {
    try {
      Integer iUploadTypeId = -1;
      ResultSet rs;

      String sSql = "{Call getSettingsUploadStock_uploadTypeID ( ? , ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setString(1, sUploadTypeName);  
        stmt.registerOutParameter(2, Types.VARCHAR);
        stmt.registerOutParameter(3, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
               
        iUploadTypeId = stmt.getInt(2);
        bIsOk = stmt.getBoolean(3);

        this.liUpload_TypeID = -1;
        this.lsUpload_Name = "";
        this.lsUpload_ShortName = "";
        this.lsUpload_Version = "";
        this.lsUpload_FileType = "";
        this.lbUpload_HasHeader = false;
        this.lsUpload_Prefix = "";
        this.lsUpload_Delimiter = ",";
               
        if (bIsOk == true) {
          while (rs.next()) {
            this.liUpload_TypeID = rs.getInt("tmp_id");
            this.lsUpload_Name = rs.getString("tmp_name");
            this.lsUpload_ShortName = rs.getString("tmp_shortName");
            this.lsUpload_Version = rs.getString("tmp_version");
            this.lsUpload_FileType = rs.getString("tmp_filetype");
            this.lbUpload_HasHeader = rs.getBoolean("tmp_has_header");
            this.lsUpload_Prefix = rs.getString("tmp_prefix");
            this.lsUpload_Delimiter = rs.getString("tmp_delimit");
          };
        } else {
          System.out.println("Error:");
          ClsMisc.printResultset(rs);
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
    }
  }

  public int getUpload_TypeID() {
    try {
      return this.liUpload_TypeID;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return -1;
    }
  }

  public String getUpload_Name() {
    try {
      return this.lsUpload_Name;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }

  public String getUpload_ShortName() {
    try {
      return this.lsUpload_ShortName;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }

  public String getUpload_Version() {
    try {
      return this.lsUpload_Version;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }

  public String getUpload_FileType() {
    try {
      return this.lsUpload_FileType;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }

  public Boolean getUpload_HasHeader() {
    try {
      return this.lbUpload_HasHeader;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return false;
    }
  }

  public String getUpload_Prefix() {
    try {
      return this.lsUpload_Prefix;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }

  public String getUpload_Delimiter() {
    try {
      return this.lsUpload_Delimiter;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return "";
    }
  }
}
