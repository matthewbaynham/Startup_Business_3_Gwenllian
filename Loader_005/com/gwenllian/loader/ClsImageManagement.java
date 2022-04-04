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
import java.net.*;

/*
class ClsImages {
  int iId;
  String sUrl;
  String sPath;
}
*/

public class ClsImageManagement {
  ArrayList<ClsImages> lstImages; 

  public ClsImageManagement(Connection conn){
    try {
      this.lstImages = new ArrayList<ClsImages>(); 
      
      ClsFunctionResult cFunctionResult = getAllImagePath(conn);
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("ClsImageManagement Error:");
        System.out.println(cFunctionResult.sError);
      }
    } catch(Exception e) {
      System.out.println("Error: ClsImageManagement.ClsImageManagement Exception e");
      System.out.println(e);
    }
  }

  private ClsFunctionResult getAllImagePath(Connection conn) {
    ClsFunctionResult cFunctionResultString = new ClsFunctionResult();

    try {
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";

      ResultSet rs;
      String sSql = "{Call getAllImageManagement( ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResultString.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResultString.bIsOk) {
          while (rs.next()) {
            ClsImages cImages = new ClsImages();

            cImages.iId = rs.getInt("im_id");
            cImages.sUrl = rs.getString("im_url");
            cImages.sPath = rs.getString("im_fullpath");
      
            this.lstImages.add(cImages);
          }
        } else {
          System.out.println("");
          System.out.println("Error...");
          ClsMisc.printResultset(rs);
          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
        cFunctionResultString.bIsOk = false;
        cFunctionResultString.sError = e.toString();
      }

      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsImageManagement.getAllImagePath Exception e");
      System.out.println(e);
      e.printStackTrace();
      cFunctionResultString.bIsOk = false;
      cFunctionResultString.sError = e.toString();
      return cFunctionResultString;
    }
  }

  private ClsFunctionResult insertImagePath(int iUploadTypeId, String sUrl, String sFullPath, boolean bOverwrite, Connection conn) {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call insertImageManagement( ? , ? , ? , ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setInt(1, iUploadTypeId);  
        stmt.setString(2, sUrl);  
        stmt.setString(3, sFullPath);  
        stmt.setBoolean(4, bOverwrite);  
        stmt.registerOutParameter(5, Types.BOOLEAN);
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(5);

        if (cFunctionResult.bIsOk) {
          while (rs.next()) {
            ClsImages cImages = new ClsImages();
            cImages.iId = rs.getInt("im_id");
            cImages.sUrl = rs.getString("im_url");
            cImages.sPath = rs.getString("im_fullpath");
      
            this.lstImages.add(cImages);
          }
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
      System.out.println("Error: ClsImageManagement.insertImagePath Exception e");
      System.out.println(e);
      e.printStackTrace();
      cFunctionResult.bIsOk = false;
      cFunctionResult.sError = e.toString();
      return cFunctionResult;
    }
  }
  
  private ClsFunctionResult deleteImagePath(String sUrl, String sFullPath, Connection conn) {
    ClsFunctionResult cFunctionResultString = new ClsFunctionResult();

    try {
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";

      ResultSet rs;

      String sSql = "{Call deleteImageManagement( ? , ? , ? )};";
      
      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.setString(1, sUrl);  
        stmt.setString(2, sFullPath);  
        stmt.registerOutParameter(3, Types.BOOLEAN);
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResultString.bIsOk = stmt.getBoolean(3);
        
        if (cFunctionResultString.bIsOk) {
          while (rs.next()) {
            ClsImages cImages = new ClsImages();
            cImages.iId = rs.getInt("im_id");
            cImages.sUrl = rs.getString("im_url");
            cImages.sPath = rs.getString("im_fullpath");
      
            this.lstImages.add(cImages);
          }
        } else {
          System.out.println("");
          System.out.println("Error...");
          ClsMisc.printResultset(rs);
          System.out.println("");
        }
      } catch (SQLException e) {
        e.printStackTrace();
        cFunctionResultString.bIsOk = false;
        cFunctionResultString.sError = e.toString();
      }

      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsImageManagement.deleteImagePath Exception e");
      System.out.println(e);
      e.printStackTrace();
      cFunctionResultString.bIsOk = false;
      cFunctionResultString.sError = e.toString();
      return cFunctionResultString;
    }
  }
  
  public ClsFunctionResultString getImagePath(int iUploadTypeId, String sParentDir, String sUrl, Connection conn) {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();

    try {
      String sDirFullPath = sParentDir;
      String sFullPath = "";
      String sPath = "";
      String sFileName = "";
      String sExtension = "";
      int iLastBackSlash = 0;
      int iLastDot = 0;
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";
      cFunctionResultString.sResult = "";
      boolean bIsFound = false;
      int iPosFound = ClsMisc.iError;
      
      /*****************************************************
      *   From the URL is it in the list in the database   *
      *****************************************************/   
      for (int iPos = this.lstImages.size()-1; iPos > -1; iPos--) {
        ClsImages cImages = this.lstImages.get(iPos);
        if (ClsMisc.stringsEqual(cImages.sUrl, sUrl, true, true, false)) {
          sFullPath = cImages.sPath;
          File f = new File(sFullPath); 
          
          if (f.exists()) {
            bIsFound = true;
            iPosFound = iPos;
          } else {
            // if the file is in the database but doesn't exist in the directy delete the entry in the database
            ClsFunctionResult cFunctionResultDelete = new ClsFunctionResult();
            cFunctionResultDelete = deleteImagePath(cImages.sUrl, sFullPath, conn);
            
            if (cFunctionResultDelete.bIsOk) { 
              this.lstImages.remove(iPos); 
            }
          }
        }
      }

      if (bIsFound) {
        ClsImages cImageFound = this.lstImages.get(iPosFound);
      
        cFunctionResultString.bIsOk = true;
        cFunctionResultString.sResult = cImageFound.sPath;
        cFunctionResultString.sError = "";
      } else {
        /*   The path I'm giving is a parent path of where to create a diectory   */
        cFunctionResultString = createPathCopyFile(iUploadTypeId, sParentDir, sUrl, conn);
      }

      return cFunctionResultString;
    } catch (Exception e) {
      System.out.println("Error: ClsImageManagement.getImagePath Exception e");
      e.printStackTrace();
      cFunctionResultString.bIsOk = false;
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.sResult = "";
      return cFunctionResultString;
    }
  }

  private ClsFunctionResultString createPathCopyFile(int iUploadTypeId, String sParentDir, String sUrl, Connection conn) {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();

    try {
      /*********************************************************
      *   Get file name and extension off the end of the url   *
      *********************************************************/
      int iLastBackSlash = sUrl.lastIndexOf("/");
      String sPath = "";
      String sFileName = "";
      int iLastDot = -1;
      String sExtension = "";
      String sDirFullPath = sParentDir;

      if (iLastBackSlash > -1) {
        sPath = sUrl.substring(0, iLastBackSlash);
        sFileName = sUrl.substring(iLastBackSlash + 1);
        iLastDot = sFileName.lastIndexOf(".");
        sExtension = "";

        if (iLastDot > -1) {
          sExtension = sFileName.substring(iLastDot + 1);
          sFileName = sFileName.substring(0, iLastDot);
        }
      } else {
        cFunctionResultString.bIsOk = false;
        cFunctionResultString.sError = "ClsMisc.getNewFileName: URL does not include and back slash";
        cFunctionResultString.sResult = "";
      }
      
      /********************************************************
      *   remove the http:// or the https:// from the front   *
      ********************************************************/
      if (ClsMisc.stringsEqual(sPath.substring(0, 8), "https://", true, true, true)) {
        sPath = sPath.substring(8);
      } 
      
      if (ClsMisc.stringsEqual(sPath.substring(0, 7), "http://", true, true, true)) {
        sPath = sPath.substring(7);
      } 
      
      /*************************************************************************
      *  Loop through the url and use back slash to delimit it                 *
      *  for each part of the url create a folder under the parent directory   *
      *************************************************************************/
      if (cFunctionResultString.bIsOk) {
        String sDirName;
        int iPosStart = 0;
        int iPosEnd = 0;
        int iCounter = 0;
        
        while (iCounter<100 && iPosStart > -1 && iPosEnd > -1) {
          if (iCounter == 0) {
            iPosStart = 0;
            iPosEnd = sPath.indexOf("/", iPosStart);
          } else {
            iPosStart = iPosEnd + 1;
            iPosEnd = sPath.indexOf("/", iPosStart);
          }
          
          if (iPosStart > -1 && iPosEnd > -1) {
            sDirName = sPath.substring(iPosStart, iPosEnd);

            if (!ClsMisc.stringsEqual(sDirFullPath.substring(sDirFullPath.length()-1), "/", true, true, false))
            { sDirFullPath = sDirFullPath + "/"; }

            sDirFullPath = sDirFullPath + sDirName + "/";
            File flDir = new File(sDirFullPath);
            if (!flDir.exists())
            { flDir.mkdirs(); }
          }
          
          iCounter++;
        }

        if (cFunctionResultString.bIsOk) { 
          cFunctionResultString.sResult = sDirFullPath + sFileName + "." + sExtension;
          ClsFunctionResult cFunctionResult = downloadFile(iUploadTypeId, sDirFullPath + sFileName + "." + sExtension, sUrl, conn); 
          
          cFunctionResultString.bIsOk = cFunctionResult.bIsOk;
          cFunctionResultString.sError = cFunctionResult.sError;
        }
      }

      /****************************************************************************
      *   Return the directory that has been created under the parent directory   *
      ****************************************************************************/

      return cFunctionResultString;
    } catch (Exception e) {
      System.out.println("Error: ClsImageManagement.createPathCopyFile Exception e");
      e.printStackTrace();
      cFunctionResultString.bIsOk = false;
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.sResult = "";

      return cFunctionResultString;
    }
  }

  private ClsFunctionResult downloadFile(int iUploadTypeId, String sFullPath, String sUrl, Connection conn) {
    ClsFunctionResult cFnRslt = new ClsFunctionResult();

    try (BufferedInputStream in = new BufferedInputStream(new URL(sUrl).openStream());
         FileOutputStream fileOutputStream = new FileOutputStream(sFullPath)) {
      cFnRslt.bIsOk = true;
      cFnRslt.sError = "";

      byte dataBuffer[] = new byte[1024];
      int bytesRead;

      while ((bytesRead = in.read(dataBuffer, 0, 1024)) != -1)
      { fileOutputStream.write(dataBuffer, 0, bytesRead); }
      
      ClsFunctionResult cFnRslt_Image = insertImagePath(iUploadTypeId, sUrl, sFullPath, true, conn);
      
      if (!cFnRslt_Image.bIsOk) {
        System.out.println("Error: ");
        System.out.println(cFnRslt_Image.sError);
        cFnRslt.bIsOk = cFnRslt_Image.bIsOk;
        cFnRslt.sError = cFnRslt_Image.sError;
      }
      
      return cFnRslt;
    } catch (IOException e) {
      System.out.println("Error: ClsImageManagement.downloadFile IOException e");
      System.out.println("Cannot download file: " + sUrl);
      e.printStackTrace();
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();

      return cFnRslt;
    } catch (Exception e) {
      System.out.println("Error: ClsImageManagement.downloadFile Exception e");
      e.printStackTrace();
      cFnRslt.bIsOk = false;
      cFnRslt.sError = e.toString();

      return cFnRslt;
    }       
  }
}
