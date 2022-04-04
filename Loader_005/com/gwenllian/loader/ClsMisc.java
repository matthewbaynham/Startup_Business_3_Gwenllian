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

public class ClsMisc {
  public static final String sDateNullValue = "01-01-1900";
  public static final String sDateNullFormat = "dd-MM-yyyy";
  public static final int iError = -1;
  
  public static void printResultset(ResultSet rs) {
    try {
      ResultSetMetaData rsmd = rs.getMetaData();

      while (rs.next()) {
        String sLine = "";
 
        for (int iCol = 1; iCol <= rsmd.getColumnCount(); iCol++) {
          switch(rsmd.getColumnClassName(iCol)) {
            case "java.lang.Integer":
              sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Integer.toString(rs.getInt(rsmd.getColumnName(iCol)));
              break;
            case "java.lang.String":
              sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + rs.getString(rsmd.getColumnName(iCol));
              break;
            case "java.lang.Long":
              sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Long.toString(rs.getLong(rsmd.getColumnName(iCol)));
              break;
            case "java.lang.Double":
              sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Double.toString(rs.getDouble(rsmd.getColumnName(iCol)));
              break;
            case "java.lang.Boolean":
              sLine = sLine + " " + rsmd.getColumnName(iCol) + ": " + Boolean.toString(rs.getBoolean(rsmd.getColumnName(iCol)));
              break;
            default:
              sLine = sLine + "Ooooops have to finish writing ClsMisc.printResultset() add the data type " + rsmd.getColumnClassName(iCol);
          }
        }
        sLine = sLine.trim();
        System.out.println(sLine);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  public static String setAllNumbersToZero(String sNumber) {
    try {
      String sResult = sNumber;
      
      sResult = sResult.replaceAll("1", "0");
      sResult = sResult.replaceAll("2", "0");
      sResult = sResult.replaceAll("3", "0");
      sResult = sResult.replaceAll("4", "0");
      sResult = sResult.replaceAll("5", "0");
      sResult = sResult.replaceAll("6", "0");
      sResult = sResult.replaceAll("7", "0");
      sResult = sResult.replaceAll("8", "0");
      sResult = sResult.replaceAll("9", "0");
      
      return sResult;
    } catch (Exception e) {
      e.printStackTrace();
      return e.toString();
    }
  }
      
  public static boolean isFloat(String strNum) {
    if (strNum == null) {
      return false;
    }
    try {
      float f = Float.parseFloat(strNum);
    } catch (NumberFormatException nfe) {
      return false;
    }
    return true;
  }     
      
  public static boolean isDouble(String strNum) {
    if (strNum == null) {
      return false;
    }
    try {
      double d = Double.parseDouble(strNum);
    } catch (NumberFormatException nfe) {
      return false;
    }
    return true;
  }     
     
  public static boolean isInt(String strNum) {
    if (strNum == null) {
      return false;
    }
    try {
      int i = Integer.parseInt(strNum);
    } catch (NumberFormatException nfe) {
      return false;
    }
    return true;
  }
  
  public static String cutString(String sText, String sLookFor) {
    try {  
      String sResult = sText;
      int iPosMarker = -1;
      boolean bIsFound = false;
      
      if (sText.length() > sLookFor.length()) {
        for (int iPos = 0; iPos < sText.length() - sLookFor.length(); iPos++) {
          String sSub = sText.substring(iPos, iPos+sLookFor.length());

          if (stringsEqual(sSub, sLookFor, true, true, false)) {
            bIsFound = true;
            iPosMarker = iPos;
          }
        }
      }
      
      if (bIsFound)
      { sResult = sText.substring(0, iPosMarker); }
      
      return sResult;
    } catch (Exception e) {
//      e.printStackTrace();
//      return e.printStackTrace().toString();

      StringWriter sw = new StringWriter();
      PrintWriter pw = new PrintWriter(sw);
      e.printStackTrace(pw);
      String stacktraceString = sw.toString();
      System.out.println("String is: " + stacktraceString);
      return stacktraceString;
    }
  }
     
  public static String stripReturnChar(String sText) {
    try {  
      String sResult = sText;
      
      sResult = sResult.replaceAll("\n", " ");//Newline
      sResult = sResult.replaceAll("\r", " ");//Carriage return
      sResult = sResult.replaceAll("\t", " ");//tab
      
      sResult = sResult.replaceAll("               ", " ");
      sResult = sResult.replaceAll("              ", " ");
      sResult = sResult.replaceAll("             ", " ");
      sResult = sResult.replaceAll("            ", " ");
      sResult = sResult.replaceAll("           ", " ");
      sResult = sResult.replaceAll("          ", " ");
      sResult = sResult.replaceAll("         ", " ");
      sResult = sResult.replaceAll("        ", " ");
      sResult = sResult.replaceAll("       ", " ");
      sResult = sResult.replaceAll("      ", " ");
      sResult = sResult.replaceAll("     ", " ");
      sResult = sResult.replaceAll("    ", " ");
      sResult = sResult.replaceAll("   ", " ");
      sResult = sResult.replaceAll("  ", " ");

      return sResult;
    } catch (Exception e) {
//      e.printStackTrace();
//      return e.printStackTrace().toString();

      StringWriter sw = new StringWriter();
      PrintWriter pw = new PrintWriter(sw);
      e.printStackTrace(pw);
      String stacktraceString = sw.toString();
      System.out.println("String is: " + stacktraceString);
      return stacktraceString;
    }
  }

  public static boolean stringsEqual(String sTextA, String sTextB, boolean bTrim, boolean bIgnoreCase, boolean bStripNonAlphaNumerics) {
    try {
        if (bTrim) {
          sTextA = sTextA.trim();
          sTextB = sTextB.trim();
        }
        
        if (bIgnoreCase) {
          sTextA = sTextA.toUpperCase();
          sTextB = sTextB.toUpperCase();
        }
        
        if (bStripNonAlphaNumerics) {
          sTextA = sTextA.replaceAll("[^a-zA-Z0-9]", "");
          sTextB = sTextB.replaceAll("[^a-zA-Z0-9]", "");
        }
        
        char[] chTempA = new char[sTextA.length()]; 
        char[] chTempB = new char[sTextB.length()]; 

        for (int iPos = 0; iPos < sTextA.length(); iPos++)
        { chTempA[iPos] = sTextA.charAt(iPos); } 
        
        for (int iPos = 0; iPos < sTextB.length(); iPos++) 
        { chTempB[iPos] = sTextB.charAt(iPos); } 
        
        return Arrays.equals(chTempA, chTempB);
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  
  public static boolean listArrayStringContains(ArrayList<String> lst, String sText) {
    try {
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < lst.size(); iPos++) {
        if (stringsEqual(lst.get(iPos), sText, true, true, false))
        { bIsFound = true; }
      }
      
      return bIsFound;
    } catch(Exception e) {
      System.out.println("ClsMisc.listArrayStringContains Error:");
      System.out.println(e);
      return false;
    }
  }
  

  public static ArrayList<String> delimitedStringToArrayList(String sText, String sDelimiter, String sQuotes) {
    try {
      ArrayList<String> lstResult = new ArrayList<String>();
      int iCol = 0;
      String sField = "";
      boolean bFieldIsComplete = false;
      
      for (int iPos =0; iPos < sText.length();iPos++) {
        /************************************************************
        *   Loop through each charactor sChar in the string sText   *
        ************************************************************/
        String sChar = sText.substring(iPos, iPos+1);
        
        if (!stringsEqual(sChar, sDelimiter, true, true, false))
        { sField = sField + sChar; }

        bFieldIsComplete = false;
        if (stringsEqual(sChar, sDelimiter, true, true, false) || iPos == sText.length()-1) {  //
          //either hit a delimiter or last field

          /*if (sField.length()>2) {*/
          if (sField.length()>1) {
            if (stringsEqual(sField.substring(0, 1), sQuotes, true, true, false) && stringsEqual(sField.substring(sField.length()-1), sQuotes, true, true, false)) {
              //if field begins and ends with the quotes
              sField = sField.substring(1, sField.length()-1);
              bFieldIsComplete = true;
            }
          }

          if (sField.length()>1) {
            if (!stringsEqual(sField.substring(0, 1), sQuotes, true, true, false) && !stringsEqual(sField.substring(sField.length()-1), sQuotes, true, true, false)) {
              //if field doesn't begins and ends with the quotes
              bFieldIsComplete = true;
            }
          }

          if (sField.length() == 1 && !stringsEqual(sField, sQuotes, true, true, false))
          { bFieldIsComplete = true; }

          if (sField.length() == 0)
          { bFieldIsComplete = true; }
          
          if (iPos == sText.length()-1)
          { bFieldIsComplete = true; }

          /************************
          *   Add field to list   *
          ************************/
          if (bFieldIsComplete) {
            lstResult.add(sField);
            sField = "";  
          }
          
          /*******************************************************************************************************************
          *   Special fix for if the last charactor of the sLine is a delimiter. So the last field is a zero length string   *
          *******************************************************************************************************************/
          if (iPos == sText.length()-1) 
          { lstResult.add(""); }
        }
      }

      return lstResult;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      return new ArrayList<String>();
    }
  }

  public static ClsFunctionResultString getNewFileName(String sImagesDir, String sUrl) {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();
    
    try {
      String sDirFullPath = sImagesDir;
      String sFullPath = "";
      String sPath = "";
      String sFileName = "";
      String sExtension = "";
      int iLastBackSlash = 0;
      int iLastDot = 0;
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";
      cFunctionResultString.sResult = "";
      
      /*
      (1) find last back slash and seperate filename and path
      (2) Take "https://" (or "http://") off the URL
      (3) for each dot or back slash split the string into an array
      (4) each element of the array is a directory level
      (5) except last element because that's the file name
      
      */
      
      
      iLastBackSlash = sUrl.lastIndexOf("/");
      if (iLastBackSlash > -1) {
        sPath = sUrl.substring(0, iLastBackSlash);
        sFileName = sUrl.substring(iLastBackSlash + 1);
        
        iLastDot = sFileName.lastIndexOf(".");
        if (iLastDot > -1) {
          sExtension = sFileName.substring(iLastDot + 1);
          sFileName = sFileName.substring(0, iLastDot);
        }
        
        System.out.println("sUrl: " + sUrl);
        System.out.println("sPath:" + sPath);
        System.out.println("sFileName:" + sFileName);
        System.out.println("sExtension:" + sExtension);
      } else {
        cFunctionResultString.bIsOk = false;
        cFunctionResultString.sError = "ClsMisc.getNewFileName: URL does not include and back slash";
        cFunctionResultString.sResult = "";
      }
      
      if (ClsMisc.stringsEqual(sPath.substring(0, 8), "https://", true, true, true)) {
        sPath = sPath.substring(8);
        System.out.println("sPath (with 'https://' chopped off): " + sPath);
      } 
      
      if (ClsMisc.stringsEqual(sPath.substring(0, 7), "http://", true, true, true)) {
        sPath = sPath.substring(7);
        System.out.println("sPath (with 'http://' chopped off): " + sPath);
      } 
      
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
            System.out.println("-----------------------------------------------------");
  
            System.out.println("iPosStart: " + Integer.toString(iPosStart));
            System.out.println("iPosEnd: " + Integer.toString(iPosEnd));

            sDirName = sPath.substring(iPosStart, iPosEnd);
            
            System.out.println("sDirName: " + sDirName);

            
            if (!ClsMisc.stringsEqual(sDirFullPath.substring(sDirFullPath.length()-1), "/", true, true, false))
            { sDirFullPath = sDirFullPath + "/"; }

            sDirFullPath = sDirFullPath + sDirName+ "/";

            System.out.println("sDirFullPath: " + sDirFullPath);
            
            File flDir = new File(sDirFullPath);
            if (!flDir.exists())
            { flDir.mkdirs(); }
          }
          
          iCounter++;
        }

        System.out.println("-----------------------------------------------------");
        
        sFullPath = sDirFullPath + sFileName + "." + sExtension;
        
	try (BufferedInputStream in = new BufferedInputStream(new URL(sUrl).openStream());
	  FileOutputStream fileOutputStream = new FileOutputStream(sFullPath)) {
	    byte dataBuffer[] = new byte[1024];
	    int bytesRead;
	    while ((bytesRead = in.read(dataBuffer, 0, 1024)) != -1) {
	        fileOutputStream.write(dataBuffer, 0, bytesRead);
	    }
	} catch (IOException e) {
	    // handle exception
          e.printStackTrace();
          cFunctionResultString.bIsOk = false;
          cFunctionResultString.sError = e.toString();
          cFunctionResultString.sResult = "";
	}        
      }

      return cFunctionResultString;
    } catch (Exception e) {
      e.printStackTrace();
      cFunctionResultString.bIsOk = false;
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.sResult = "";

      return cFunctionResultString;
    }
  }

  public static ClsFunctionResultString cutPath(String sPath, String sFindDirectory) {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();
    
    try {
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";
      cFunctionResultString.sResult = "";

      //sFindDirectory should be "catalog" 
      int iPos = sPath.toUpperCase().indexOf(sFindDirectory.toUpperCase());
      
      if (iPos > 0)
      { cFunctionResultString.sResult = sPath.substring(iPos); }
      else
      { cFunctionResultString.sResult = sPath; }

      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsMisc.cutPath Exception e");
      System.out.println(e);
      
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.bIsOk = false;
      return cFunctionResultString;
    }
  }
  
  public static ClsFunctionResultString fixDescription(String sDescription) {
    ClsFunctionResultString cFunctionResultString = new ClsFunctionResultString();
    
    try {
      cFunctionResultString.bIsOk = true;
      cFunctionResultString.sError = "";
      cFunctionResultString.sResult = "";
      
      String sTemp = sDescription;
      
      /*if ":</span>" swap for ": </span>"*/
      
      sTemp = sTemp.replaceAll(":</span>", ": </span>");
      sTemp = sTemp.replaceAll("</div><div", "</div> <div");
      
      cFunctionResultString.sResult = sTemp;
      
      return cFunctionResultString;
    } catch(Exception e) {
      System.out.println("Error: ClsMisc.fixDescription Exception e");
      System.out.println(e);
      
      cFunctionResultString.sError = e.toString();
      cFunctionResultString.bIsOk = false;
      return cFunctionResultString;
    }
  }
  /*
  <div class='pdbDescContainer'><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Gender:</span><span class='pdbDescSectionText'>Man</span></div><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Type:</span><span class='pdbDescSectionText'>Sneakers</span></div><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Upper:</span><span class='pdbDescSectionText'><span class='pdbDescSectionList'><span class='pdbDescSectionItem'>synthetic material</span><span class='pdbDescSectionItem'>leather</span></span></span></div><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Internal lining:</span><span class='pdbDescSectionText'><span class='pdbDescSectionList'><span class='pdbDescSectionItem'>synthetic material</span></span></span></div><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Sole:</span><span class='pdbDescSectionText'>rubber</span></div><div class='pdbDescSection'><span class='pdbDescSectionTitle'>Details:</span><span class='pdbDescSectionText'><span class='pdbDescSectionList'><span class='pdbDescSectionItem'>round toe</span></span></span></div></div>
  */
  
  

  public static String removeCategoryPlural(String sCategory) {
    try {
      String sTemp = sCategory.trim().toLowerCase();
      
      switch (sTemp) {
        case "taschen":
          sTemp = "Tasche";
          break;
        case "bags":
          sTemp = "Bag";
          break;
        case "shoes":
          sTemp = "Shoes";
          break;
        case "schuhe":
          sTemp = "Schuhe";
          break;
        case "clothing":
          sTemp = "Clothing";
          break;
        case "bekleidung":
          sTemp = "Bekleidung";
          break;
        default: 
          sTemp = sCategory.trim();
      }
      
      return sTemp;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return "";
    }
  }

  public static String removeSubCategoryPlural(String sSubCategory) {
    try {
      String sTemp = sSubCategory.trim().toLowerCase();

      switch (sTemp) {
        case "aktentaschen":
          sTemp = "Aktentasche";
          break;
        case "schultertaschen":
          sTemp = "Schultertasche";
          break;
        case "umhängetaschen":
          sTemp = "Umhängetasche";
          break;
        case "handtaschen":
          sTemp = "Handtasche";
          break;
        case "reisetaschen":
          sTemp = "Reisetasche";
          break;
        case "stiefeletten":
          sTemp = "Stiefelette";
          break;
        case "clutch bags":
          sTemp = "Clutch bag";
          break;
        case "shopping bags":
          sTemp = "Shopping bag";
          break;
        case "crossbody Bags":
          sTemp = "Crossbody Bag";
          break;
        case "handbags":
          sTemp = "Handbag";
          break;
        case "shoulder bags":
          sTemp = "Shoulder bag";
          break;
        case "travel bags":
          sTemp = "Travel bag";
          break;
        case "rucksacks":
          sTemp = "Rucksack";
          break;
        case "bodysuits":
          sTemp = "Bodysuits";
          break;
        case "coats":
          sTemp = "Coats";
          break;
        case "mantel":
          sTemp = "Mantel";
          break;
        case "dresses":
          sTemp = "Dresses";
          break;
        case "kleider":
          sTemp = "Kleider";
          break;
        case "formal jacket":
          sTemp = "Formal jacket";
          break;
        case "klassische jacke":
          sTemp = "Klassische Jacke";
          break;
        case "jackets":
          sTemp = "Jackets";
          break;
        case "jacken":
          sTemp = "Jacken";
          break;
        case "jeans":
          sTemp = "Jeans";
          break;
        case "polo":
          sTemp = "Polo";
          break;
        case "scarves":
          sTemp = "Scarves";
          break;
        case "schals":
          sTemp = "Schals";
          break;
        case "shirts":
          sTemp = "Shirts";
          break;
        case "hemden":
          sTemp = "Hemden";
          break;
        case "short":
          sTemp = "Shorts";
          break;
        case "skirts":
          sTemp = "Skirts";
          break;
        case "röcke":
          sTemp = "Röcke";
          break;
        case "suits":
          sTemp = "Suits";
          break;
        case "anzüge":
          sTemp = "Anzüge";
          break;
        case "sweaters":
          sTemp = "Sweaters";
          break;
        case "pullover":
          sTemp = "Pullover";
          break;
        case "sweatshirts":
          sTemp = "Sweatshirts";
          break;
        case "swimwear":
          sTemp = "Swimwear";
          break;
        case "t-shirts":
          sTemp = "T-shirts";
          break;
        case "Tank tops":
          sTemp = "tank tops";
          break;
        case "unterhemden":
          sTemp = "Unterhemden";
          break;
        case "tops":
          sTemp = "Tops";
          break;
        case "tracksuit pants":
          sTemp = "Tracksuit pants";
          break;
        case "jogginghose":
          sTemp = "Jogginghose";
          break;
        case "tracksuits":
          sTemp = "Tracksuits";
          break;
        case "trainingsanzug":
          sTemp = "Trainingsanzug";
          break;
        case "trench coat":
          sTemp = "Trench coat";
          break;
        case "regenmantel":
          sTemp = "Regenmantel";
          break;
        case "trousers":
          sTemp = "Trousers";
          break;
        case "hosen":
          sTemp = "Hosen";
          break;
        case "vest":
          sTemp = "Vest";
          break;
        case "weste":
          sTemp = "Weste";
          break;
        default: 
          sTemp = sSubCategory.trim();
      }
      
      return sTemp;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return "";
    }
  }

  public static String removeAttributeOddOnes(String sAttribute) {
    try {
      String sTemp = sAttribute.trim().toLowerCase();

      switch (sTemp) {
        case "modelltyp":
          sTemp = "Typologie";
          break;
        case "innenfutter":
          sTemp = "Innen";
          break;
        case "passform":
          sTemp = "Fit";
          break;
        default: 
          sTemp = sAttribute.trim();
      }
      
      return sTemp;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return "";
    }
  }

  public static String removeTags(String sText) {
    try {
      String sTemp = sText.trim();
      
      ArrayList<String> lstTags = new ArrayList<String>();
      
      lstTags.add("&nbsp;");
      lstTags.add("<br>");
      lstTags.add("<small>");
      lstTags.add("<i>");
      lstTags.add("</small>");
      lstTags.add("</i>");
      lstTags.add("<div class=\"\"pdbDescContainer\"\">");
      lstTags.add("<div class=\"pdbDescContainer\">");
      lstTags.add("<div class='pdbDescContainer'>");
      lstTags.add("<div class=\"\"pdbDescSection\"\">");
      lstTags.add("<div class=\"pdbDescSection\">");
      lstTags.add("<div class='pdbDescSection'>");
      lstTags.add("<span class=\"\"pdbDescSectionTitle\"\">");
      lstTags.add("<span class=\"pdbDescSectionTitle\">");
      lstTags.add("<span class='pdbDescSectionTitle'>");
      lstTags.add("<span class=\"\"pdbDescSectionText\"\">");
      lstTags.add("<span class=\"pdbDescSectionText\">");
      lstTags.add("<span class='pdbDescSectionText'>");
      lstTags.add("<span class=\"\"pdbDescSectionList\"\">");
      lstTags.add("<span class=\"pdbDescSectionList\">");
      lstTags.add("<span class='pdbDescSectionList'>");
      lstTags.add("<span class=\"\"pdbDescSectionItem\"\">");
      lstTags.add("<span class=\"pdbDescSectionItem\">");
      lstTags.add("<span class='pdbDescSectionItem'>");
      lstTags.add("</div>");
      lstTags.add("</span>");
      lstTags.add("<h1>");
      lstTags.add("</h1>");
      lstTags.add("<h2>");
      lstTags.add("</h2>");
      lstTags.add("<h3>");
      lstTags.add("</h3>");
      lstTags.add("<h4>");
      lstTags.add("</h4>");
      lstTags.add("<h5>");
      lstTags.add("</h5>");
      lstTags.add("<h6>");
      lstTags.add("</h6>");
      lstTags.add("<p>");
      lstTags.add("</p>");
      lstTags.add("\t");
      
      for (int iCounter = 0; iCounter < lstTags.size(); iCounter++) { 
        String sTag = lstTags.get(iCounter);
        sTemp = sTemp.replaceAll(sTag, " ");
      }

      sTemp = sTemp.replaceAll("       ", " ");
      sTemp = sTemp.replaceAll("      ", " ");
      sTemp = sTemp.replaceAll("     ", " ");
      sTemp = sTemp.replaceAll("    ", " ");
      sTemp = sTemp.replaceAll("   ", " ");
      sTemp = sTemp.replaceAll("  ", " ");
      sTemp = sTemp.trim();
      
      return sTemp;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return "";
    }
  }

  public static String stripChars(String sText, boolean bUpperCase, boolean bLowerCase, boolean bNumeric, boolean bSpace, boolean bMinusSign, boolean bBackSlash, boolean bForwardSlash) {
    try {
      String sTemp = sText.trim();
      String sResult = "";
      
      for (int iChar = 0; iChar < sText.length(); iChar++) {
        char cChar = sText.charAt(iChar);
          
        if(bUpperCase) {
          if ( (int)cChar>=65 && (int)cChar<=90)
          { sResult = sResult + cChar; }
        }

        if(bLowerCase) {
          if ( (int)cChar>=97 && (int)cChar<=122)
          { sResult = sResult + cChar; }
        }
        
        if(bNumeric) {
          if ( (int)cChar>=48 && (int)cChar<=57)
          { sResult = sResult + cChar; }
        }
        
        if(bSpace) {
          if ( (int)cChar == 32)
          { sResult = sResult + cChar; }
        }
        
        if(bMinusSign) {
          if ( (int)cChar == 45)
          { sResult = sResult + cChar; }
        }
        
        if(bBackSlash) {
          if ( (int)cChar == 47)
          { sResult = sResult + cChar; }
        }
        
        if(bForwardSlash) {
          if ( (int)cChar == 92)
          { sResult = sResult + cChar; }
        }
      }
      
      return sResult;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);

      return "";
    }
  }
}

