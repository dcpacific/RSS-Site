/*
 * RSSDataUpdate.java
 * Copyright (c) D Chan., 2006
 */

package DataFeed;

import java.io.*;
import java.util.Iterator;
import java.sql.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Date;

/**
 * @author Daniel T Chan
 * Created on July 1, 2007, 2:53 PM
 */
public class RSSDataUpdate {

   /** Creates a new instance of RSSDataUpdate */
    public RSSDataUpdate() {
    } // end RSSDataUpdate()

    public static void main(String args[]){

       List NewArticles = new ArrayList(); 
       NewArticles =  hdlDocument(args[0]);
       
       
        
        
    }

    private static Connection getDBConnection() {
        Connection conn = null;
/*        
        String userName = "eric";
        String password = "12345";

        String userName = "carreviews";
        String password = "carreviews_pwd";
        String url = "jdbc:mysql://10.7.0.75/carreviews";
 */
        String userName = "dchan";
        String password = "dchan_pwd";
        String url = "jdbc:mysql://localhost/carreviews";
        
        try {
            Class.forName ("com.mysql.jdbc.Driver").newInstance ();
            conn = DriverManager.getConnection (url, userName, password);
            System.out.println ("Database connection established");
        } catch(Exception e) {
            System.out.println("Cannot connect to database server: "+e);
        } 
        
        return conn;
    }   

    private static List hdlDocument(String uri) {
	        
        StringBuffer buff = new StringBuffer();
        Connection conn   = getDBConnection();
        List toReturn     = new ArrayList();
        
        // retrieve the dataset
        buff.append("SELECT article_id,article_title,article_date,");
        buff.append("category_id,article_subtitle,article_text ");
        buff.append("from article WHERE article_text LIKE '%<br/>%' ");
        buff.append("and category_id in (2,4) ");
        buff.append("ORDER BY article_date DESC ");
        
        try {
             conn = getDBConnection();
             // individual Campaign
             Statement s = conn.createStatement();

             ResultSet rs = s.executeQuery(buff.toString());
             if(rs != null){
                 while(rs.next()){

                     int    article_id    = rs.getInt("article_id");
                     String article_title = rs.getString("article_title");
                     Date   article_date  = rs.getDate("article_date");
                     int    category_id   = rs.getInt("category_id"); 
                     String article_subtitle = rs.getString("article_subtitle");
                     String article_text  = rs.getString("article_text") ;

                     // replace content
                     article_text = replace(article_text,"<br/>","<br />");
                     
                     List vec = new ArrayList();
                     vec.add(0, article_id);
                     vec.add(1, article_title);
                     vec.add(2, article_date);
                     vec.add(3, category_id);
                     vec.add(4, article_subtitle);
                     vec.add(5, article_text);
                        
                     toReturn.add(vec);
                 }
                 s.close();

             } else {
               System.out.println ("No resultset is available ...");
             } // end if

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception e) { /* ignore close errors */ }
            }
        }

        if (conn != null) {
            try {
                conn.close ();
                System.out.println ("Database connection closed");
            } catch (Exception e) { /* ignore close errors */ }
        }   // end if
        
        return toReturn;
    }       // end hdlDocument()
    
   /***********************replace Substring METHODS**********************
    * remove "\n"                                           + Feb.07.2007
    **********************************************************************/ 
    public static String replace(String str, String pattern, String replace) {
        int s = 0;
        int e = 0;
        StringBuffer result = new StringBuffer();
        while ((e = str.indexOf(pattern, s)) >= 0) {
           result.append(str.substring(s, e));
           result.append(replace);
           s = e+pattern.length();
        }
        result.append(str.substring(s));
        return result.toString();
    }
    
/********************Update Article Method****************************
*  Method Update Article to dB   ??? to be continued 
******************************************************************/
    public void UpdArticles(ArrayList articles) {
        
     
        try {

            pstmt = conn.prepareStatement("Update ");
            
            for (int i = 0; i < articles.size(); i++) {

                // + Feb.08.2007
                nCurArticleId = this.getArticleId(articles.get(i).getArticleLink()); 
                if (nCurArticleId > 0) {
                    // in case duplicate article existed, display warning and bypass
                    // else dB bombs out
                    System.out.println("Warning! duplicate article with no." + nCurArticleId
                            + " already existed ... i = " + i ) ;
                    
                } else {

// + DEBUG 
TmpStg = articles.get(i).getArticleSubtitle().trim() ;

//if (TmpStg.indexOf("Attempt")>0) {
//    System.out.println(" BMW ... ") ;
//}
                    
                    pstmt.setString(1, articles.get(i).getArticleTitle());
                    pstmt.setString(2, articles.get(i).getArticleSubtitle());
                    pstmt.setString(3, articles.get(i).getArticleText());
// + Feb.05.2007                
//                  pstmt.setString(4, "");
                    pstmt.setString(4,articles.get(i).getArticleSpec());

                    pstmt.setString(5, articles.get(i).getArticleLink());
                    pstmt.setInt(6, articles.get(i).getArticleType());
                    pstmt.setInt(7, articles.get(i).getCategoryId());
                
                    authorId = articles.get(i).getAuthorId();
                
                    if (authorId <= 0) {
                        authorId = Author.getMatchedAuthorId(new Author(articles.get(i).getAuthorEmail(), 
                                                                    articles.get(i).getAuthorName()), authors);
                    }
                
                    pstmt.setInt(8, authorId);
                    
                    makeId = articles.get(i).getMakeId();
                
                    if (makeId <= 0) {
                        makeId = Make.getMatchedMakeId(new Make(articles.get(i).getMakeName()), makes);
                    }
                
                    pstmt.setInt(9, makeId);

                    modelId = articles.get(i).getModelId();
                
                    if (modelId <= 0) {
                        modelId = Model.getMatchedModelId(new Model(articles.get(i).getModelName()), models);
                    }
                
                    pstmt.setInt(10, modelId);
                    pstmt.setDate(11, new java.sql.Date(articles.get(i).getArticleDate().getTime()));
                
                    //pstmt.setDate(11, new java.sql.Date(System.currentTimeMillis()));
                
                    pstmt.addBatch();
                } // end if nCurArticleId
            
            }  // end for 
            pstmt.executeBatch();
            /**********************************************************
             *  loop through the array, query for article id and insert images
             *  + Feb.07.2007
             *********************************************************/
            for (int i = 0; i < articles.size(); i++) {

                nArticleImg = articles.get(i).getMainImgArticleLink();
                if (nArticleImg > 0) {
                    
                    //+ FEB.07.2007
                    nCurArticleId = this.getArticleId(articles.get(i).getArticleLink()); 
 
                    if (nCurArticleId > 0) {
                        imageDO.addImages(nCurArticleId,nArticleImg,newImages);

                        // + Feb.12.2007
                        makeId = articles.get(i).getMakeId();
                        modelId = articles.get(i).getModelId();
                        if (modelId == 0) {
                            modelId = getModelId (nCurArticleId);
                        }
                        modelYearDO.addModelYears(nCurArticleId,nArticleImg,makeId,modelId,newModelYears) ;
                        // + feb.13.2007
                        modelPriceDO.addModelPrice(nCurArticleId,nArticleImg,makeId,modelId,newModelPrices);
                        // + feb.14.2007
                        modelTypeDO.addModelTypes(nCurArticleId,nArticleImg,makeId,modelId,newModelTypes);
                        
                    } else {
                        System.out.println("Error - i: " + i + " no image files are processed ...");
                    }
                    
                } else {

                    System.out.println(" the corresponding Article Image code is not found" + 
                                       " no embedded images are posted ... i :" + i + " title: "+
                                       articles.get(i).getArticleTitle());
                }

                
                
            } // end for
            
            System.out.println("end of executing batch");

        } catch(SQLException sqlEx) {
            System.out.println("Error Code: " + sqlEx.getErrorCode() + "\n" + "Error Message: " + sqlEx.getMessage());
        }
        
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException sqlEx) {
                System.out.println("Error Code: " + sqlEx.getErrorCode() + "\n" + "Error Message: " + sqlEx.getMessage());
            }
            pstmt = null;
        }   // end if

    } // end Method addArticles

    
} // end class
