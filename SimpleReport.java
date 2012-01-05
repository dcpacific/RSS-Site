/*
 * SimpleReport.java
 * Copyright (c) D Chan., 2007
 *
 */

package com.bytec.business.action;

import com.elasticpath.commons.Money;
import com.elasticpath.commons.PropertiesFactory;
import com.elasticpath.dataaccess.hibernate.ProductDAO;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Currency;
import java.util.Date;
import java.util.List;
import java.util.Properties;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import org.apache.log4j.Logger;
import org.apache.commons.collections.IterableMap;
import org.apache.commons.collections.map.HashedMap;
// + Jun.18.2007
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Vector;
// + Jun.20.2007
import java.text.StringCharacterIterator;
import java.text.CharacterIterator;

/**
 * @author D Chan
 * Created on June 26, 2006, 11:23 AM
 *
 * Update log :
 *    - the code was based on 23.Feb.2007 and was modified at 29.may.2007 to
 *      house the Campaign reports                        + May.29.2007
 *    - fix the typo regarding Subtotal Report
 *    - update both the Boutique and Classic Reports up to 100 records per page
 *      upon Chris's request                              + May.30.2007
 *    - update script regarding date range bug            + Jun.08.2007
 *    - update script to apply filter for Boutique and 
 *      Classic Reports                                   + Jun.18.2007
 *    - update script to handle escape character          + Jun.20.2007
 *    - update report to house Sold Price                 + Jul.11.2007
 *    - update script to house Product Variation Cost and Profit  + Jul.23.2007 
 */
public class SimpleReport {
    public static final Logger LOG = Logger.getLogger(SimpleReport.class);
    public static final String REPORT_WEEKLY = "WEEK";
    public static final String REPORT_MONTHLY = "MONTH";
    public static final String REPORT_YEARLY = "YEAR";
    public static final String REPORT_QUARTERLY = "QUARTER";
    public static final String REPORT_DAILY = "DATE";
    
    public static final String REPORT_SOURCE_CUSTOMER = "TCUSTOMER";
    public static final String REPORT_CUSTOMER_COUNT_DESCRIPTION = "number of the new customers";
    public static final String REPORT_ORDER_COUNT_DESCRIPTION = "number of the orders";
    public static final String REPORT_ORDER_SUBTOTAL_DESCRIPTION = "order subtotal";
    
    public static final String REPORT_SOURCE_ORDER = "TORDER";
    public static final String REPORT_SUBTOTAL = "SUBTOTAL";
    public static final String REPORT_ORDER_COUNT = "ORDERCOUNT";
    private static final String REPORT_SUM = "SUM";
    private static final String REPORT_COUNT = "COUNT";
    
    private String time_1;
    private String time_2;
    
    /** Creates a new instance of SimpleReport */
    public SimpleReport(String time_1, String time_2) {
        this.time_1 = time_1;
        this.time_2 = time_2;
        
    }
    
    public SimpleReport() {
        
        
    }
    
    public static Connection getConnection() throws Exception {
        Properties BYTEC_PROPERTIES = PropertiesFactory.getInstance().getPropertiesFile("bytec.prop");
        String dbPool = BYTEC_PROPERTIES.getProperty("openClose.dbpool");
        Connection conn = null;
        
        try{
            Context envCtx = (Context) (new InitialContext()).lookup("java:comp/env");
            //Context envCtx = (Context) new InitialContext();
            if(envCtx == null ) {
                throw new Exception("No Environment Context");
            }
            DataSource ds = (DataSource) envCtx.lookup( dbPool );
            if (ds != null) {
                conn = ds.getConnection();
            } else {
                throw new Exception("No DataSource");
            }
        } catch(Exception e) {
            LOG.info("Couldn't establish connection: "+e.toString());
        }
        return conn;
    }
    
    public IterableMap getCount(String frequency, String src) throws Exception {
        
        return getResult(frequency,REPORT_COUNT,"*",src);
        
    }
    
    public IterableMap getSumSubTotal(String frequency,String src) throws Exception {
        //LOG.info("frenquence " + frequency);
        //LOG.info("src " + src);
        if (src.equals(REPORT_SOURCE_ORDER)) {
            return getResult(frequency,REPORT_SUM,"subTotal",src);
        }
        return null;
        
    }
    
    private IterableMap getResult(String frequency,String function, String field, String table) throws Exception {
        String query = getCreationDateSql(frequency,function,field,table);
        IterableMap iterableMap = new HashedMap();
        
        Connection conn =null;
        try {
            conn = getConnection();
            Statement s = conn.createStatement();
            
            ResultSet rs = s.executeQuery(query);
            //There is a strange thing in cewolf graphic drawing, whenever there is
            //only one dataset, NO graphic is drawing, So I add 2 dummy datasets in it !!!
            //J Liu
            int i = 0;
            Object dummyKey = null;
            Object dummy1Key = null;
            Object dummy2Key = null;
            while (rs.next()) {
                if (frequency.equals(REPORT_DAILY)) {
                    if (i == 0) {
                        dummyKey = new Date(rs.getDate(4).getTime());
                        dummy1Key = new Date(rs.getDate(5).getTime());
                        iterableMap.put(dummyKey,new BigDecimal(0.00));
                        
                    }
                    dummy2Key = new Date(rs.getDate(5).getTime());
                    iterableMap.put(new Date(rs.getDate(2).getTime()),rs.getBigDecimal(1));
                    //LOG.info(rs.getDate(2) + " " + rs.getBigDecimal(1));
                } else {
                    if (i == 0) {
                        dummyKey = rs.getString(4);
                        dummy1Key = rs.getString(5);
                        iterableMap.put(dummyKey,new BigDecimal(0.00));
                    }
                    
                    iterableMap.put(rs.getString(2)+"_" +rs.getString(3),rs.getBigDecimal(1));
                    //if (!frequency.equals(REPORT_WEEKLY)) {
                    //after this loop, this dummy2Key will store the next key after the last data
                    
                    dummy2Key = rs.getString(5);
                    //}
                    //LOG.info(rs.getString(2)+"_" +rs.getString(3) + " " +rs.getBigDecimal(1));
                    //rs.getDouble(2);
                }
                i++ ;
            }
            
            
            
            if (i > 1) {
                
                iterableMap.remove(dummyKey);
                iterableMap.put(dummy2Key,new BigDecimal(0.00));
                
                
            } else {
                iterableMap.put(dummy1Key,new BigDecimal(0.00));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
            throw new Exception(e);
        } finally {
            
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        
        return iterableMap;
        
        
    }
    
    private String getCreationDateSql(String frequency,String function, String field, String table) {
        //value can be count(*) or sum(subTotal)
        
        
        String f_1;
        String f_2;
        String f_3;
        String f_4;
        String cond1;
        String cond2;
        String format = null;
        String dummy = "";
        String dummy1 = "";
        if (frequency.equals(SimpleReport.REPORT_DAILY)) {
            format = "%Y%j";
            dummy = ",date(creationdate - interval 1 day)";
            dummy1 = ",date(creationdate + interval 1 day)";
        } else if (frequency.equals(SimpleReport.REPORT_WEEKLY)) {
            format = "%Y%V";
            dummy = ",date_format(creationdate - interval 7 day,'%V_%Y')";
            dummy1 = ",date_format(creationdate + interval 7 day,'%V_%Y')";
        } else if (frequency.equals(SimpleReport.REPORT_MONTHLY)) {
            format = "%Y%m";
            dummy = ",date_format(creationdate - interval 1 month,'%m_%Y')";
            dummy1 = ",date_format(creationdate + interval 1 month,'%m_%Y')";
        } else  if (frequency.equals(SimpleReport.REPORT_YEARLY)) {
            format = "%Y";
            dummy = ",date_format(creationdate - interval 12 month,'%y_%Y')";
            dummy1 = ",date_format(creationdate + interval 12 month,'%y_%Y')";
            
        }
        
        f_1 = "date_format(creationdate,'"+format + "')";
        f_2 = "date_format('";
        f_3 = "','" + format + "')";
        cond1 =f_1 + ">=" + f_2 + time_1 + f_3;
        cond2 =f_1 + "<=" + f_2 + time_2 + f_3;
        
        if (frequency.equals(SimpleReport.REPORT_QUARTERLY)) {
            f_1 = "concat(year(creationdate),QUARTER(creationdate))";
            f_2 = "concat(year('";
            f_3 = "'),QUARTER('";
            f_4 = "'))";
            cond1=f_1 + ">=" + f_2 + time_1 + f_3 + time_1 + f_4;
            cond2=f_1 + "<=" + f_2 + time_2 + f_3 + time_2 + f_4;
            dummy = ",concat(quarter(creationdate - interval 3 month),date_format(creationdate - interval 3 month,'_%Y'))";
            dummy1 = ",concat(quarter(creationdate + interval 3 month),date_format(creationdate + interval 3 month,'_%Y'))";
            
        }
        StringBuffer query = new StringBuffer();
        if (frequency.equals(REPORT_DAILY) ||
                frequency.equals(REPORT_MONTHLY) ||
                frequency.equals(REPORT_QUARTERLY) ||
                frequency.equals(REPORT_WEEKLY) ||
                frequency.equals(REPORT_YEARLY)) {
            query.append("select ");
            query.append(function);
            query.append("(");
            query.append(field);
            query.append("),");
            query.append(frequency);
            query.append("(creationdate), YEAR(creationdate) ");
            query.append(dummy);
            query.append(dummy1);
            query.append(" from ");
            query.append(table);
            query.append(" where deleted = 0 ");
            if (this.time_1 != null && this.time_2 != null) {
                query.append(" and ");
                query.append(cond1);
                query.append(" and ");
                query.append(cond2);
            }
            query.append(" group by YEAR(creationdate),");
            query.append(frequency);
            query.append("(creationdate)") ;
        }
        LOG.info("Query " + query);
        return query.toString();
    }
    
    public String getFrequency(String frequency) {
        //For display only !
        String fr = null;
        if (frequency.equals(SimpleReport.REPORT_DAILY)) {
            fr = "Daily";
        } else if (frequency.equals(SimpleReport.REPORT_MONTHLY)) {
            fr ="Monthly";
        } else if (frequency.equals(SimpleReport.REPORT_WEEKLY)) {
            fr ="Weekly";
        } else if (frequency.equals(SimpleReport.REPORT_QUARTERLY)) {
            fr ="Quarterly";
        } else if (frequency.equals(SimpleReport.REPORT_YEARLY)) {
            fr ="Yearly";
        }
        return fr;
    }
        
    //madhuri
    public List getTopSellingProducts(int templateUID, String t1, String t2, boolean orderByDollarAmt){
        String orderBy = "CT"; 
        if(orderByDollarAmt == true){
            orderBy = "AMOUNT";
        }
        StringBuffer buff = new StringBuffer();
        buff.append("SELECT SUM(opv.QUANTITY) as CT,opv.PRODUCTCODE, opv.PRODUCTUID,(SUM(opv.QUANTITY) * opv.SALEPRICE) as AMOUNT ");
        buff.append("FROM TORDERPRODUCTVARIATION opv  INNER JOIN TORDER ord ON ord.UID_PK = opv.ORDERUID ");
        buff.append("INNER JOIN TPRODUCT tp ON tp.UID_PK = opv.PRODUCTUID where ord.CREATIONDATE >= '" + t1 + "' ");
        buff.append("and ord.CREATIONDATE < date('"+ t2 + "' + interval 1 day) and tp.TEMPLATEUID = " + templateUID );
        buff.append(" and ord.deleted=0 and opv.deleted=0 GROUP BY opv.PRODUCTCODE ORDER BY " + orderBy + " desc");
        
        List toReturn = new ArrayList();
        List toReturn1 = new ArrayList();
        Connection conn = null;
        try {
            conn = SimpleReport.getConnection();
            //list details
            toReturn = this.exectuteQuery(conn,buff.toString(),false);
            //header summary
            toReturn1 = this.exectuteQuery(conn,buff.toString(),true);
            toReturn1.addAll(toReturn);
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        return toReturn1;
    }
    
    //madhuri
    private List exectuteQuery(Connection conn, String sql,boolean totals){
        List toReturn = new ArrayList();
        try {
            if(totals == false){
                Statement s = conn.createStatement();
// + May.30.3007
//              sql = sql + " LIMIT 25";
                sql = sql + " LIMIT 100";

                ResultSet rs = s.executeQuery(sql);
                if(rs == null){
                    return null;
                }
                
                while(rs.next()){
                    int ct = rs.getInt("CT");
                    String productCode = rs.getString("PRODUCTCODE");
                    int pId = rs.getInt("PRODUCTUID");
                    Money money = new Money(rs.getBigDecimal("AMOUNT"),Currency.getInstance("USD"));
                    ProductDAO pdao = new ProductDAO();
                    List vec = new ArrayList();
                    vec.add(0, new Integer(ct));
                    vec.add(1, productCode);
                    vec.add(2, money.setScale(2));
                    vec.add(3, pdao.load(new Integer(pId)));
                    toReturn.add(vec);
                }
                s.close();
            }else{
                
                StringBuffer buff1 = new StringBuffer();
                buff1.append("SELECT SUM(temp.CT) as CNT, SUM(temp.AMOUNT) as AMT FROM (");
                buff1.append(sql);
                buff1.append(" ) as temp");
                Statement s = conn.createStatement();
                ResultSet rs1 = s.executeQuery(buff1.toString());
                if(rs1 == null){
                    return null;
                }
                
                while(rs1.next()){
                    int totalcnt = rs1.getInt("CNT");
                    Money totalmoney = new Money(rs1.getBigDecimal("AMT"),Currency.getInstance("USD"));
                    List vec1 = new ArrayList();
                    vec1.add(0,new Integer(totalcnt));
                    vec1.add(1,totalmoney.setScale(2));
                    toReturn.add(vec1);
                }
                
                s.close();
                
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        }
        
        return toReturn;
        
    }

    //Daniel T Chan + May.29.2007
    public List getCampaignLst(String t1, String t2, boolean bOrderByValueSUbtotal, boolean bSortOrder){
        //local var.
        String orderBy = "Value";
        String SortOrder = "ASC";
        
        StringBuffer buff = new StringBuffer();
        List toReturn     = new ArrayList();
        List toReturn1    = new ArrayList();
        Connection conn   = null;
        
        if(bOrderByValueSUbtotal == false){
            orderBy = "subtotal";
        }
        
        if (bSortOrder == false) {
            SortOrder = "DESC";
        }

// + May.29.2007        
        buff.append("SELECT c.Value,");
        buff.append("SUM(c.nRecCnt) AS RECCNT,");
        buff.append("SUM(c.subtotal) AS SUBTOTAL,SUM(c.shippingcost) as SHIPPINGCOST ");
        buff.append("FROM ( ");
        buff.append("SELECT TRIM(substring_index(substring_index(b.value,'campaign%3D',-1),'%26',1)) as Value, ");
        buff.append("COUNT(*) AS nRecCnt,");
        buff.append("SUM(a.subtotal) AS subtotal,");
        buff.append("SUM(a.shippingcost) AS shippingcost ");
        buff.append("FROM newmakeup.TORDER a INNER JOIN newmakeup.TORDERATTRIBUTE b ");
        buff.append("ON a.UID_PK = b.ORDERUID ");
        buff.append("WHERE a.deleted = 0 ");
        buff.append("AND b.ATTRIBUTEUID = 77 ");
        buff.append("AND b.value like '%campaign%' ");
        buff.append("AND a.creationdate >= '" + t1 +"' ") ;
        buff.append("AND a.creationdate <= '" + t2 +"' ") ;
        buff.append("GROUP BY b.value ) c ");
        buff.append("GROUP BY c.Value ");
        buff.append("ORDER BY " + orderBy + " " + SortOrder + " ");
        
        try {
            conn = SimpleReport.getConnection();
            // Generate the detail list of the group Campaign
            toReturn = this.exectuteQuery2(conn,buff.toString(),false);
            // Generate the total Amount of Subtotal and ShippingCost
            toReturn1 = this.exectuteQuery2(conn,buff.toString(),true);
            toReturn1.addAll(toReturn);

        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        return toReturn1;
    }
 
    //Daniel T Chan + May.29.2007
    public List getCampaignLst2(String t1, String t2, Integer nOrderByValueSUbtotal, boolean bSortOrder) {
        //local var.
        String orderBy = "Value";
        String SortOrder = "ASC";
        
        StringBuffer buff = new StringBuffer();
        List toReturn     = new ArrayList();
        List toReturn1    = new ArrayList();
        Connection conn   = null;
        
        if(nOrderByValueSUbtotal == 0){
            orderBy = "Value";
        } else if (nOrderByValueSUbtotal == 1) {
            orderBy = "subtotal";
        } else if (nOrderByValueSUbtotal == 2) {
            orderBy = "RECCNT";
        }
        
        if (bSortOrder == false) {
            SortOrder = "DESC";
        }
        
        // + Jun.08.2007
        t1 += "000000";
        t2 += "235959";

// + May.29.2007        
        buff.append("SELECT c.Value,");
        buff.append("SUM(c.nRecCnt) AS RECCNT,");
        buff.append("SUM(c.subtotal) AS SUBTOTAL,SUM(c.shippingcost) as SHIPPINGCOST ");
        buff.append("FROM ( ");
        buff.append("SELECT TRIM(substring_index(substring_index(b.value,'campaign%3D',-1),'%26',1)) as Value, ");
        buff.append("COUNT(*) AS nRecCnt,");
        buff.append("SUM(a.subtotal) AS subtotal,");
        buff.append("SUM(a.shippingcost) AS shippingcost ");
        buff.append("FROM newmakeup.TORDER a INNER JOIN newmakeup.TORDERATTRIBUTE b ");
        buff.append("ON a.UID_PK = b.ORDERUID ");
        buff.append("WHERE a.deleted = 0 ");
        buff.append("AND b.ATTRIBUTEUID = 77 ");
        buff.append("AND b.value like '%campaign%' ");
        buff.append("AND a.creationdate >= '" + t1 +"' ") ;
        buff.append("AND a.creationdate <= '" + t2 +"' ") ;
        buff.append("GROUP BY b.value ) c ");
        buff.append("GROUP BY c.Value ");
        buff.append("ORDER BY " + orderBy + " " + SortOrder + " ");
        
        try {
            conn = SimpleReport.getConnection();
            // Generate the detail list of the group Campaign
            toReturn = this.exectuteQuery2(conn,buff.toString(),false);
            // Generate the total Amount of Subtotal and ShippingCost
            toReturn1 = this.exectuteQuery2(conn,buff.toString(),true);
            toReturn1.addAll(toReturn);

        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        return toReturn1;
    };
    
    //Daniel T Chan + May.29.2007
    private List exectuteQuery2(Connection conn, String sql,boolean totals){
        //local var.
        List toReturn = new ArrayList();

        try {

            if(totals == false){
                // individual Campaign
                Statement s = conn.createStatement();

// + May.29.2007 record listing up to 75 upon Chris's request               
//              sql = sql + " LIMIT 25";
                sql = sql + " LIMIT 75";

                ResultSet rs = s.executeQuery(sql);
                if(rs == null){
                    return null;
                }
                while(rs.next()){

                    String Value = rs.getString("Value");
// + May.29.2007        
                    int nRecCnt  = rs.getInt("RECCNT");
// + 28.May.2007
                    int Subtotal = rs.getInt("Subtotal");
                    int ShippingCost = rs.getInt("shippingcost");
/*
                    Money Subtotal = new Money(rs.getBigDecimal("Subtotal"),Currency.getInstance("USD"));
                    Money ShippingCost = new Money(rs.getBigDecimal("shippingcost"),Currency.getInstance("USD"));
*/
                    
                    List vec = new ArrayList();
                    vec.add(0, Value);
// + May.29.2007        
                    vec.add(1, nRecCnt);
// + 28.May.2007
                    vec.add(2, Subtotal);
                    vec.add(3, ShippingCost);
/*
                    vec.add(2, Subtotal.setScale(2));
                    vec.add(3, ShippingCost.setScale(2));
*/

                    toReturn.add(vec);
                }
                s.close();

            }else{
                //lumpsum Campaign
                StringBuffer buff1 = new StringBuffer();

// + May.29.2007        
//              buff1.append("SELECT SUM(temp.SUBTOTAL) as TotalAmt, SUM(temp.SHIPPINGCOST) as TotalCost FROM (");
                buff1.append("SELECT SUM(temp.RECCNT) as TotalRCnt ,SUM(temp.SUBTOTAL) as TotalAmt, SUM(temp.SHIPPINGCOST) as TotalCost FROM (");
                
                buff1.append(sql);
                buff1.append(" ) as temp ");
                Statement s = conn.createStatement();
                ResultSet rs1 = s.executeQuery(buff1.toString());
                if(rs1 == null){
                    return null;
                }
                
                while(rs1.next()){

// + May.29.2007        
                    int totalRCnt= rs1.getInt("TotalRCnt");                    
// + May.28.2007                    
                    int totalAmt = rs1.getInt("TotalAmt");
                    int totalCost= rs1.getInt("TotalCost");
/*
                    Money totalAmt = new Money(rs1.getBigDecimal("TotalAmt"),Currency.getInstance("USD"));
                    Money totalCost= new Money(rs1.getBigDecimal("TotalCost"),Currency.getInstance("USD"));
*/

                    List vec1 = new ArrayList();

// + May.29.2007        
                    vec1.add(0,new Integer(totalRCnt));
// + May.28.2007
                    vec1.add(1,new Integer(totalAmt));
                    vec1.add(2,new Integer(totalCost));
/*
                    vec1.add(1,totalAmt.setScale(2));
                    vec1.add(2,totalCost.setScale(2));
*/
                    toReturn.add(vec1);
                }
                s.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        }
        
        return toReturn;
        
    }
    
    //Daniel T Chan + Jun.18.2007
    public List getCtgBrand(Integer grp) {

//DEBUG
//System.out.println("getCtgBrand is called ... grp="+grp) ;
        
        int columnToGrab  = 2;
        StringBuffer Cbuff= new StringBuffer();
        List   tcReturn   = new ArrayList();
 //       Vector ret        = new Vector();
 //       Vector grab       = new Vector();
        Connection conn   = null;
 
        String sql         ;
        //determine Brand
        switch (grp) {
            
            //Boutique Brand
            case 0:
                sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 1712 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                break;
            //Classic Brand
            case 1:
                sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 2 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                break;
            //Boutique category
            case 2:  
                sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 0 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                break;
            //Classic category
            case 3:  
                sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 79 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                break;
            default:
                sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 1712 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
        }
        
        Cbuff.append(sql);

        try {
            conn = SimpleReport.getConnection();
            Statement s = conn.createStatement();
            ResultSet rs = s.executeQuery(Cbuff.toString());
            if(rs != null){

//DEBUG
//System.out.println("getCtgBrand is called ... rs is not empty ... ") ;
                
                while(rs.next()){
                    int    nId   = rs.getInt("uid_pk");
                    String cId   = Integer.toString(nId);
                    String cName = rs.getString("name");

                    // + Jun.20.2007
                    cName = this.HdlEscChar(cName);
//DEBUG
//System.out.println("getCtgBrand is called ... cId="+cId) ;
//System.out.println("getCtgBrand is called ... cName="+cName) ;

                    List tmpAL = new ArrayList();
                    tmpAL.add(0,cId);
                    tmpAL.add(1,cName);
                    
                    tcReturn.add(tmpAL);
/*
                    HashMap row = new HashMap();
                    int columns = rs.getMetaData().getColumnCount();
                    if( columnToGrab > 0 && columnToGrab <= columns ) {
                        grab.addElement(rs.getString(columnToGrab));
                    }
                    for ( int i = 1; i < columns+1; i++ ) {
                    row.put( rs.getMetaData().getColumnName(i), rs.getString(i) );
                }
                ret.addElement(row);
*/                
                }
                s.close();

            } // end if
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }   //end if
        }       //end finally
        
//        return ret;
        return tcReturn;
    }  
    
    // + Jun.19.2007
    public Vector getBrdCtgRows(String sql, int columnToGrab ) {
        Vector ret = new Vector();
        Vector grab = new Vector();
        Statement stmt = null;
        ResultSet rs = null;
        Connection conn   = null;

        try {
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while ( rs.next() ) {
                HashMap row = new HashMap();
                int columns = rs.getMetaData().getColumnCount();
                if( columnToGrab > 0 && columnToGrab <= columns ) {
                    grab.addElement(rs.getString(columnToGrab));
                }
                for ( int i = 1; i < columns+1; i++ ) {
                    row.put( rs.getMetaData().getColumnName(i), rs.getString(i) );
                }
                ret.addElement(row);
            }
        }
        catch (Exception e) {
            System.out.println(e.toString()+": "+sql);
        }
        finally {
            try {
                rs.close();
                stmt.close();
            }
            catch (Exception e) {
                System.out.println(e.toString()+": "+sql);
            }
        }
        return ret;
    }
    // + Jun.19.2007
    //-------------------------------------------------------------------
    // Obtain the list of articles based on the make Id 
    //-------------------------------------------------------------------
    public Vector getMKUpBrdCtg(int Idx) {

        Vector ret3 = new Vector();
        String sql;

//DEBUG:
//System.out.println("getMKUpBrdCtg is called ... Idx="+Idx);        
        
        if (Idx > 0) {
            //determine Brand
            switch (Idx) {
                //Boutique Brand
                case 0:
                    sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 1712 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                    break;
                //Classic Brand
                case 1:
                    sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 2 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                    break;
                //Boutique category
                case 2:  
                    sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 0 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                    break;
                //Classic category
                case 3:  
                    sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 79 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
                    break;
                default:
                    sql = "SELECT  uid_pk,name FROM TCATEGORY WHERE parentcategory = 1712 AND disabled = 0 AND deleted=0 ORDER BY NAME" ;
            }

            ret3 = this.getBrdCtgRows(sql,2); 

 //DEBUG
int r3Cnt = ret3.size();
//System.out.println("getMKUpBrdCtg is called ... r3Cnt="+r3Cnt);        

            
        } // end if
        
        return ret3;
    }
        
    // + Jun.20.2007
    //-------------------------------------------------------------------
    // Handle Escape character
    //-------------------------------------------------------------------
    public static String HdlEscChar(String aTagFragment){
    final StringBuffer result = new StringBuffer();

    final StringCharacterIterator iterator = new StringCharacterIterator(aTagFragment);
    char character =  iterator.current();
    while (character != CharacterIterator.DONE ){
        
      if (character == '"') {
        result.append(" ");
      }
      else {
        //the char is not a special one then add it to the result as is
        result.append(character);
      }
      character = iterator.next();
    }
    return result.toString();
  }
    
    // + Jun.20.2007
    //-------------------------------------------------------------------
    // getTopSellingProducts2 based on getTopSellingProducts to allow filter
    //-------------------------------------------------------------------
    public List getTopSellingProducts2(int templateUID, String t1, String t2, boolean orderByDollarAmt, String cPrdId){
        String orderBy = "CT"; 
        if(orderByDollarAmt == true){
            orderBy = "AMOUNT";
        }
        StringBuffer buff = new StringBuffer();
        buff.append("SELECT SUM(opv.QUANTITY) as CT,opv.PRODUCTCODE, opv.PRODUCTUID,(SUM(opv.QUANTITY) * opv.SALEPRICE) as AMOUNT ");
        buff.append("FROM TORDERPRODUCTVARIATION opv  INNER JOIN TORDER ord ON ord.UID_PK = opv.ORDERUID ");
        buff.append("INNER JOIN TPRODUCT tp ON tp.UID_PK = opv.PRODUCTUID where ord.CREATIONDATE >= '" + t1 + "' ");
        buff.append("and ord.CREATIONDATE < date('"+ t2 + "' + interval 1 day) and tp.TEMPLATEUID = " + templateUID );
        buff.append(" and ord.deleted=0 and opv.deleted=0 ");
        
        buff.append(" and tp.UID_PK IN (SELECT tpc.productUID FROM TPRODUCTCATEGORY tpc WHERE tpc.categoryUID = "+cPrdId+") ");

        buff.append(" GROUP BY opv.PRODUCTCODE ORDER BY " + orderBy + " desc");

        
        List toReturn = new ArrayList();
        List toReturn1 = new ArrayList();
        Connection conn = null;
        try {
            conn = SimpleReport.getConnection();
            //list details
            toReturn = this.exectuteQuery(conn,buff.toString(),false);
            //header summary
            toReturn1 = this.exectuteQuery(conn,buff.toString(),true);
            toReturn1.addAll(toReturn);
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");
                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        return toReturn1;
    }

        //-------------------------------------------------------------------
        // getTopSellingProducts3 based on getTopSellingProducts to house Sold$
        // Modify existing list to house SoldPrice
        //
        // note : The following discount attributes 30,31,32,49,81,86,89 applies to promotion
        //        30 - Promotion Type
        //        31 - Min. Prmotion Purchase
        //        32 - Prmotion fixed price
        //        89 - Promotion Max. Count
        // special cases (1) Order # 8939 with Dicount # 49, needs attention as NO Discount Templates,
        //                   nor percentage, fixed price promotion applies. However, discount attributes 32
        //                   does applies.
        //               (2) Order # 9373 with Dicount #350, needs attention as NO Discount Templates,
        //                   nor percentage, fixed price promotion applies. However, discount attributes 32
        //                   does applies.
        // decision tables:
        //      
        // Order# Samples|Fixed Price|Percentage|Template|Product Lists|Actions
        // ==============+===========+==========+========+=============+==============
        // 5970,9823     |     Y     |    N     |    N   |    N        |Even distributed the fixed Price to 
        //               |           |          |        |             |all product items in same Order
        // ==============+===========+==========+========+=============+==============
        // 6128          |     N     |    Y     |    Y   |    N        |Apply percentage to products 
        //               |           |          |        |             |dedicated to same category (TemplateUID)
        // ==============+===========+==========+========+=============+==============
        // 6720          |     N     |    Y     |    N   |    N        |Apply percentage to all product items in same Order 
        // ==============+===========+==========+========+=============+==============
        // 6961,6957     |     Y     |    N     |    Y   |    N        |Even distributed the fixed Price to products 
        //               |           |          |        |             |dedicated to same category (TemplateUID)
        // ==============+===========+==========+========+=============+==============
        // 8517,8518     |     Y     |    Y     |    N   |    N        |Percentage dominates 
        // ==============+===========+==========+========+=============+==============
        // 8939          |     N     |    N     |    N   |    N        |Check Discount attributes 32 for  
        //               |           |          |        |             |fixed price 
        // ==============+===========+==========+========+=============+==============
        // 9757,9770     |     N     |    Y     |    N   |    Y        |Apply percentage to products
        //               |           |          |        |             |dedicated to Product Lists
        //
        // The query must be updated to sychronized if additional Discount code other than 360,362
        // + Jul.11.2007
        //-------------------------------------------------------------------
    public List getTopSellingProducts3(int templateUID, String t1, String t2, boolean orderByDollarAmt,boolean bFlag,String cPrdId) {

        //------------------------------------
        // init. local var.
        //------------------------------------
        String cNewSQL ;
        String orderBy = "CT"; 
        List toReturn  = new ArrayList();
        List toReturn1 = new ArrayList();

        if(orderByDollarAmt == true){
            orderBy = "AMOUNT";
        }

        // + Jul.12.2007
        t1 = t1 + "000000";
        t2 = t2 + "235959";
        
        StringBuffer buff = new StringBuffer();
       
        buff.append(" SELECT  SUM(j.QUANTITY) as CT,");
        buff.append("j.PRODUCTCODE,j.PRODUCTUID,");
        buff.append("(SUM(j.QUANTITY) * j.SALEPRICE) as AMOUNT,");
        buff.append("(SUM(j.QUANTITY) * (j.SALEPRICE - j.discount_value )) AS SoldPrice  ");
        
// + Jul.23.2007 starts        
        buff.append(",( ");
        buff.append(" SELECT DISTINCT p.value ");
        buff.append(" FROM TPRODUCTVARIATIONATTRIBUTE p  INNER JOIN TPRODUCTVARIATION q ");
        buff.append(" ON p.productvariationuid = q.UID_PK ");
        buff.append(" WHERE p.attributeuid = 70 ");
        buff.append(" and p.value IS NOT NULL ");
        buff.append(" and p.VALUE <> 'null' ");
        buff.append(" AND q.disabled = 0 AND q.deleted = 0 ");
        buff.append(" AND q.productuid = j.PRODUCTUID ");
        buff.append(" AND q.productcode= j.PRODUCTCODE ");
        buff.append(" ) AS SoldCost ");
// + Jul.23.2007 ends        
        
        buff.append("FROM  ( ");
        
        buff.append("SELECT h.QUANTITY,h.PRODUCTCODE,h.PRODUCTUID,h.SALEPRICE,h.ORDER_ID,h.templateUID,");
        buff.append("i.Rec_Cnt,i.fixedprice,i.percentage,i.TOA_templateUID,i.FxDsc_Value,i.PRODUCTIDS,");

        // discount value block - starts
        buff.append(" ( ");
        // block no Discount TcNewSQLemplateUID is applied
        buff.append("IF( i.TOA_templateUID IS NULL,");
        buff.append("IF( i.percentage is null,");
        buff.append("IF( i.fixedprice is null,");
        buff.append("IF( i.Discount_UID is null,0.00,");
        buff.append("IF( i.FxDsc_Value is null,0.00,(i.FxDsc_Value*1.00))),ROUND(i.fixedprice/i.Rec_Cnt,2)),");
        buff.append("IF( i.Discount_UID IN (360,362),");
        buff.append("IF( h.PRODUCTUID IN ( i.PRODUCTIDS),");
        buff.append("ROUND(h.SALEPRICE *   i.percentage / 100.00,2),0.00 ),");
        buff.append("ROUND(h.SALEPRICE *   i.percentage / 100.00,2)) ),");
        // block Discount TemplateUID is applied
        buff.append("IF( i.TOA_templateUID =  h.templateUID,");
        buff.append("IF( i.percentage is null,");
        buff.append("IF( i.fixedprice is null,");
        buff.append("IF( i.Discount_UID is null,0.00,");
        buff.append("IF( i.FxDsc_Value is null,0.00,(i.FxDsc_Value*1.00))),");
        buff.append("ROUND(i.fixedprice/i.Rec_Cnt,2)),");
        buff.append("IF( i.Discount_UID IN (360,362),");
        buff.append("IF( h.PRODUCTUID IN ( i.PRODUCTIDS),");
        buff.append("ROUND(h.SALEPRICE *   i.percentage / 100.00,2), 0.00 ),");
        buff.append("ROUND(h.SALEPRICE *   i.percentage / 100.00,2) )),   0.00)) ");
        buff.append(" ) AS discount_value  ");
        // discount value block - ends

        buff.append(" FROM ( ");
        //
        // base table handling date range Buffer t1 -starts
        //
        buff.append("SELECT opv2.QUANTITY,opv2.PRODUCTCODE,opv2.PRODUCTUID,");
        buff.append("opv2.SALEPRICE,");
        buff.append("ord2.UID_PK  AS ORDER_ID,");
        buff.append("tp2.templateUID  ");
        buff.append("FROM TORDERPRODUCTVARIATION opv2  INNER JOIN TORDER   ord2  ");
        buff.append("ON ord2.UID_PK = opv2.ORDERUID    INNER JOIN TPRODUCT tp2 ");
        buff.append("ON tp2.UID_PK  = opv2.PRODUCTUID  ");
        buff.append("where ord2.CREATIONDATE >= '" + t1 + "' ");
// + Jul.12.2007        
//      buff.append("and ord2.CREATIONDATE < date('"+ t2 + "' + interval 1 day) ");
        buff.append("and ord2.CREATIONDATE <= '" + t2 + "' ");

        buff.append("and tp2.TEMPLATEUID = " + templateUID );
        buff.append(" and ord2.deleted = 0 and opv2.deleted = 0 ");
        //
        // base table handling date range Buffer t1 -finishs
        //
        buff.append(" ) h LEFT JOIN ( ");
        //
        // buffer t2 links t1(TProduct,TOrderProductVariation,TOrder) and t3(TOrderAttributeReport,TDiscount) starts
        //
        buff.append("SELECT a.ORDER_ID, COUNT(*) AS Rec_Cnt,");
        buff.append("b.fixedprice,b.percentage,b.TOA_templateUID,");
        buff.append("b.Discount_UID,b.FxDsc_Value,b.PRODUCTIDS   ");
        buff.append(" FROM ( ");
        //
        // Alias buffer t1 - starts
        //
        buff.append("SELECT opv.QUANTITY,opv.PRODUCTCODE,opv.PRODUCTUID,");
        buff.append("opv.SALEPRICE,");
        buff.append("ord.UID_PK AS ORDER_ID,");
        buff.append("tp.templateUID   ");
        buff.append("FROM TORDERPRODUCTVARIATION opv  INNER JOIN TORDER ord  ");
        buff.append("ON ord.UID_PK = opv.ORDERUID     INNER JOIN TPRODUCT tp  ");
        buff.append("ON tp.UID_PK  = opv.PRODUCTUID ");
        buff.append("where ord.CREATIONDATE >= '" + t1 + "' ");

// + Jul.12.2007
//      buff.append("and ord.CREATIONDATE < date('"+ t2 + "' + interval 1 day) ");
        buff.append("and ord.CREATIONDATE <= '" + t2 + "' ");

        buff.append("and tp.TEMPLATEUID = " + templateUID );
        buff.append(" and ord.deleted = 0 and opv.deleted = 0 ");
        //
        // Alias buffer t1 - finishes
        //
        buff.append(" )  a INNER JOIN ( ");
        //
        // buffer t3 house TDISCOUNT_ID on TOrderAttributeReport - starts
        // note: TDISCOUNTATTRIBUTE.attributeUID 32 is the promotion fixed price
        //       TORDERATTRIBUTEREPORT ( a clone copy of TORDERATTRIBUTE ) with attributeUID 86
        //       is the promotion applied attribute
        //
        buff.append("SELECT d.fixedprice,d.percentage,");
        buff.append("d.templateUID AS TOA_templateUID ,");
        buff.append("d.UID_PK      AS  Discount_UID,");
        buff.append("d.PRODUCTIDS,c.ORDERUID,");
        // column FxDsc_Value starts

// + JUL.12.2007 - bug???       
//      buff.append("( SELECT g.value FROM TDISCOUNTATTRIBUTE  g ");
        buff.append("( SELECT (1.00 * cast(g.value AS unsigned)) FROM TDISCOUNTATTRIBUTE  g ");
        
        buff.append("WHERE g.DISCOUNTUID  =  d.UID_PK ");
        buff.append("AND g.attributeUID = 32  )  AS FxDsc_Value ");
        // column FxDsc_Value finishs
        buff.append("FROM TDISCOUNT d INNER JOIN TORDERATTRIBUTEREPORT c ");
        buff.append("ON d.UID_PK = c.DISCOUNTUID ");
        buff.append("WHERE d.disabled = 0 and d.deleted = 0 and c.attributeUID = 86 ");
        //
        // buffer t3 house TDISCOUNT_ID on TOrderAttributeReport - finishes
        //
        buff.append(" ) b  ON a. ORDER_ID = b.ORDERUID ");
        buff.append("GROUP BY a.ORDER_ID ");
        //
        // buffer t2 - finishes
        //
        buff.append(" ) i ON h.ORDER_ID = i.ORDER_ID   ");
        buff.append(" ) j  ");
        
        //------------------------------------
        // Other than full report
        //------------------------------------
        if (bFlag) {
            buff.append(" WHERE j.PRODUCTUID IN (SELECT tpc2.productUID FROM TPRODUCTCATEGORY tpc2 WHERE tpc2.categoryUID = "+cPrdId+" ) ");
        }
        
        buff.append(" GROUP BY j.PRODUCTCODE ");
        
        Connection conn = null;
        try {
            conn = SimpleReport.getConnection();

            cNewSQL = buff.toString() ;

            //list details
//          buff.append(" ORDER BY " + orderBy + " desc " );
            cNewSQL = cNewSQL + " ORDER BY " + orderBy + " desc " ;
            toReturn = this.exectuteQuery3(conn,cNewSQL,false);
//DEBUG
System.out.println(" cNewSQL = "+cNewSQL+"*** ");
int tmpCnt = toReturn.size();            

            //header summary
            toReturn1 = this.exectuteQuery3(conn,buff.toString(),true);

//debug: + Jul.12.2007            
System.out.println("Both Header and Detail are now done ... tmpCnt ="+tmpCnt);

            toReturn1.addAll(toReturn);

//debug: + Jul.12.2007            
//System.out.println("ready to return call to caller ...");
            
            
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    LOG.info("Database connection terminated");

                } catch (Exception e) { /* ignore close errors */ }
            }
        }
        
        return toReturn1;
    } // end getTopSellingProducts3
    
    //-------------------------------------------------------------------
    // exectuteQuery3 is based on exectuteQuery             + Jul.11.2007
    //-------------------------------------------------------------------
    private List exectuteQuery3(Connection conn, String sql,boolean totals){
 
        // local var.
        int         totalcnt ;
        Money       totalmoney ;
        Money       totalSPmoney ;
        Money       totalSPmoney2;
        BigDecimal  tmpMoney ;
        // + JUl.18.2007
        BigDecimal  tmpMoney2;
        // + Jul.24.2007
        BigDecimal  tmpMoney3;
        BigDecimal  tmpMoney4;
        BigDecimal  SC_bd ;
        
        Money       totalSCmoney3,totalSCmoney4;
        
        List toReturn = new ArrayList();

        try {
            if(totals == false){
                //----------------------------------
                // detail 
                //----------------------------------
                Statement s = conn.createStatement();
// + May.30.3007
//              sql = sql + " LIMIT 25";
                sql = sql + " LIMIT 100";

// DEBUG : + Jul.11.2007
System.out.println("exectuteQuery -DETAIL BLOCK- is called ... ") ;                
                
                ResultSet rs = s.executeQuery(sql);
              
                if(rs == null){
                    return null;
                }
                
// DEBUG : + Jul.11.2007
System.out.println("Query Resultset-DETAIL is not empty ... ") ;                

                while(rs.next()){
                    int ct = rs.getInt("CT");
                    String productCode = rs.getString("PRODUCTCODE");
                    int pId = rs.getInt("PRODUCTUID");

                    Money money   = new Money(rs.getBigDecimal("AMOUNT"),Currency.getInstance("USD"));

                    BigDecimal SP_bd = rs.getBigDecimal("SoldPrice") ;
                    if (rs.getBigDecimal("SoldCost") == null) {
                        SC_bd = new BigDecimal("0.00")  ;
                    } else {
                        SC_bd = rs.getBigDecimal("SoldCost")  ;
                    }                   
                    
                    BigDecimal Pft_bd= SP_bd.subtract(SC_bd);

                    Money SPmoney = new Money(SP_bd,Currency.getInstance("USD"));
                    Money SCmoney = new Money(SC_bd,Currency.getInstance("USD"));
                    Money Pfmoney = new Money(Pft_bd,Currency.getInstance("USD"));
                    
                    ProductDAO pdao = new ProductDAO();
                    List vec = new ArrayList();
                    vec.add(0, new Integer(ct));
                    vec.add(1, productCode);
                    vec.add(2, money.setScale(2));
                    vec.add(3, pdao.load(new Integer(pId)));
                    vec.add(4, SPmoney.setScale(2));
                    vec.add(5, SCmoney.setScale(2));
                    vec.add(6, Pfmoney.setScale(2));
                    
                    toReturn.add(vec);
// DEBUG : + Jul.11.2007
System.out.print(".");
                }
                s.close();
// DEBUG : + Jul.11.2007
System.out.println("exectuteQuery -Detail BLOCK- completed ... ") ;                
            }else{
                
                //----------------------------------
                // header
                //----------------------------------
                StringBuffer buff1 = new StringBuffer();

// DEBUG : + Jul.11.2007
System.out.println("exectuteQuery -Header BLOCK- is called ... ") ;                

// + Jul.24.2007              
//              buff1.append("SELECT SUM(t5.CT) as CNT, SUM(t5.AMOUNT) as AMT, SUM(t5.SoldPrice)  as SLD FROM ( " );
                buff1.append("SELECT SUM(t5.CT) as CNT,");
                buff1.append("SUM(IF(t5.AMOUNT IS NULL,0,t5.AMOUNT)) as AMT,");
                buff1.append("SUM(IF(t5.SoldPrice IS NULL,0,t5.SoldPrice)) as SLD,");
                buff1.append("SUM(IF(t5.SoldCost  IS NULL,0,t5.SoldCost))  as CST FROM ( " );

                buff1.append(sql);
                buff1.append(" ) t5 ");

// DEBUG : + Jul.11.2007
System.out.println("exectuteQuery -Header BLOCK- sql is : "+buff1.toString()) ;                
                
                Statement s = conn.createStatement();
                ResultSet rs1 = s.executeQuery(buff1.toString());
                if(rs1 == null){
                    return null;
                }
// DEBUG : + Jul.11.2007
System.out.println("Query Resultset-HEADER is not empty ... ") ;                
                
                while(rs1.next()){

// DEBUG : + Jul.11.2007
System.out.println("processing header  ... ") ;                
    
                    totalcnt = rs1.getInt("CNT");

// DEBUG : + Jul.11.2007
System.out.println("CNT="+totalcnt) ;                
                    
                    totalmoney  = new Money(rs1.getBigDecimal("AMT"),Currency.getInstance("USD"));

// DEBUG : + Jul.11.2007
System.out.println("AMT="+totalmoney.toString()) ;                

// + Jul.18.2007    
//                    totalSPmoney= new Money(rs1.getBigDecimal("SLD"),Currency.getInstance("USD"));
                      totalSPmoney2=new Money(rs1.getBigDecimal("SLD"),Currency.getInstance("USD")).USDollars(rs1.getBigDecimal("SLD"));
// + Jul.24.2007    
                      totalSCmoney3=new Money(rs1.getBigDecimal("CST"),Currency.getInstance("USD")).USDollars(rs1.getBigDecimal("CST"));

// DEBUG : + Jul.11.2007
tmpMoney = rs1.getBigDecimal("SLD");
System.out.println("tmpMoney="+tmpMoney.toString()) ;

//DEBUG : + JUl.18.2007
//System.out.println("Sold="+totalSPmoney.toString()) ;                
System.out.println("Sold="+totalSPmoney2.toString()) ;                
System.out.println("Cost="+totalSCmoney3.toString()) ;                

tmpMoney2 = rs1.getBigDecimal("SLD");
//DEBUG : + JUl.24.2007
tmpMoney3 = rs1.getBigDecimal("CST");
tmpMoney4 = tmpMoney2.subtract(tmpMoney3);
totalSCmoney4=new Money(tmpMoney4,Currency.getInstance("USD")).USDollars(tmpMoney4);


                    List vec1 = new ArrayList();
                    vec1.add(0,new Integer(totalcnt));
                    vec1.add(1,totalmoney.setScale(2));
                    
                    // + Jul.18.2007              
//                  vec1.add(1,totalSPmoney.setScale(2));
                    vec1.add(2,totalSPmoney2.setScale(2));
                    // + Jul.24.2007              
                    vec1.add(3,totalSCmoney3.setScale(2));
                    vec1.add(4,totalSCmoney4.setScale(2));

                    
// DEBUG : + Jul.11.2007
System.out.print("+");

                    toReturn.add(vec1);
                }
                
                s.close();
                
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.info(e.getMessage());
        }
        
        return toReturn;
        
    } // end exectuteQuery3
    
}
