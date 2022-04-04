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

SELECT tax_class_id, title, description, date_added, date_modified FROM db_shoes.shoes_tax_class
tax_class_id	title	description	date_added	date_modified
9 	Taxable Goods (Sold in EU) 	Taxed goods sold in EU 	2009-01-06 23:21:53 	2020-11-05 08:39:29
10 	Downloadable Products 	Downloadable 	2011-09-21 22:19:39 	2020-11-05 08:36:50



SELECT tax_rate_id, geo_zone_id, name, rate, type, date_added, date_modified FROM db_shoes.shoes_tax_rate
tax_rate_id 	geo_zone_id 	name 	rate 	type 	date_added 	date_modified
86 	5 	Umsatzsteuer-DE (VAT) 	16.0000 	P 	2011-03-09 21:17:10 	2020-11-05 08:37:55



SELECT tax_rate_id, customer_group_id FROM db_shoes.shoes_tax_rate_to_customer_group
tax_rate_id 	customer_group_id
86 	1



SELECT tax_rule_id, tax_class_id, tax_rate_id, based, priority FROM db_shoes.shoes_tax_rule
tax_rule_id	tax_class_id	tax_rate_id	based	priority
129 	10 	86 	payment 	1
131 	9 	86 	shipping 	1



What's this table all about?
CREATE TABLE shoes_tax_rate_to_customer_group (
  tax_rate_id int(11) NOT NULL,
  customer_group_id int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



SELECT `product_id`, `model`,`tax_class_id` FROM `shoes_product` WHERE 1 
product_id	model	tax_class_id
28 	Product 1 	9
29 	Product 2 	9
30 	Product 3 	9
31 	Product 4 	9
32 	Product 5 	9
33 	Product 6 	9
34 	Product 7 	9
35 	Product 8 	9
36 	Product 9 	9
40 	product 11 	9
41 	Product 14 	9
42 	Product 15 	9
43 	Product 16 	9
44 	Product 17 	9
45 	Product 18 	9
46 	Product 19 	9
47 	Product 21 	9
48 	product 20 	9
49 	SAM1 	9


*/

public class ClsTaxClass {
  ArrayList<ClsTaxClassDetails> lstTaxClassDetails; 
  
  public ClsTaxClass(ClsProgressReport cProgressReport, Connection conn) {
    try {
      this.lstTaxClassDetails = new ArrayList<ClsTaxClassDetails>();
      
      ClsFunctionResult cFunctionResult = getTaxClassList(conn);
      
      if (!cFunctionResult.bIsOk) {
        System.out.println("Error - public ClsTaxClass(Connection conn){");
        System.out.println(cFunctionResult.sError);
        cProgressReport.somethingToNote("Code returned error", "ClsTaxClass.getTaxClassList(conn); returned error", 0, cFunctionResult.sError);
      }
      
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cProgressReport.somethingToNote("Code Crashed", "ClsTaxClass.public ClsTaxClass(ClsProgressReport cProgressReport, Connection conn) {", 0, e.toString());
    }
  }

  public ClsFunctionResultInt getId(String sText) {
    ClsFunctionResultInt cFunctionResultInt = new ClsFunctionResultInt();
    
    try {
      cFunctionResultInt.bIsOk = true;
      cFunctionResultInt.sError = "";
      cFunctionResultInt.iResult = ClsMisc.iError;
      boolean bIsFound = false;
      
      for (int iPos = 0; iPos < this.lstTaxClassDetails.size(); iPos++) {
        ClsTaxClassDetails cTaxClassDetails = this.lstTaxClassDetails.get(iPos);
        
        if (ClsMisc.stringsEqual(cTaxClassDetails.sTitle, sText, true, true, true) || ClsMisc.stringsEqual(cTaxClassDetails.sDescription, sText, true, true, true)) {
          bIsFound = true;
          cFunctionResultInt.iResult = cTaxClassDetails.iId;
        }
      }
      
      if (!bIsFound)
      { cFunctionResultInt.bIsOk = true; }
      
      return cFunctionResultInt;
    } catch(Exception e) {
      System.out.println("Error:");
      System.out.println(e);
      cFunctionResultInt.bIsOk = false;
      cFunctionResultInt.sError = e.toString();
      return cFunctionResultInt;
    }
  }
  
  private ClsFunctionResult getTaxClassList(Connection conn) throws Exception {
    ClsFunctionResult cFunctionResult = new ClsFunctionResult();

    try {
      cFunctionResult.bIsOk = true;
      cFunctionResult.sError = "";

      ResultSet rs;
      String sSql = "{Call  getAllTaxClassDetails ( ? )};";

      try (CallableStatement stmt=conn.prepareCall(sSql);) {
        stmt.registerOutParameter(1, Types.BOOLEAN);
               
        //stmt.execute();
        rs = stmt.executeQuery();
        cFunctionResult.bIsOk = stmt.getBoolean(1);
               
        if (cFunctionResult.bIsOk == true) {
          while (rs.next()) {
            ClsTaxClassDetails cTaxClassDetails = new ClsTaxClassDetails();
            
            cTaxClassDetails.iId = rs.getInt("tax_class_id");
            cTaxClassDetails.sTitle = rs.getString("title");
            cTaxClassDetails.sDescription = rs.getString("description");

            this.lstTaxClassDetails.add(cTaxClassDetails);
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
}
