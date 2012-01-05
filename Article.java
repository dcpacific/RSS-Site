/*
 * Article.java
 *
 * Created on January 28, 2005, 8:56 AM
 */

package Auto123;

/**
 * @author  D Chan
 * 
 * update log:
 *    - update file to house article images               + Daniel   01.Jun.2007 
 */

import java.util.HashMap;
import java.util.Vector;
import utils.dbConnection;
import utils.Convert;

public class Article {
    
    /** Holds value of property articleId. */
    private String articleId;
    
    /** Holds value of property info. */
    private HashMap info;
    
    /** Holds value of property page. */
    private int page = 0;
    
    /** Holds value of property countPages. */
    private int countPages = 0;
    
    // + 01.Jun.2007
    private int countImg   = 0;
    
    private static dbConnection dbConn = new dbConnection("jdbc/carreviews");
    
    /** Creates a new instance of Article */
    public Article() {
    }
    
    public Article(String id) {
        setArticleId(id);
    }
    
    public Article(String id, String page) {
        setArticleId(id, page);
    }
    
    /** Fetcher for print article page */
    public String getTitle(String id) {
        this.articleId = "" + Convert.toInteger( id );
        String ret = this.dbConn.getSingleElement("SELECT a.article_title FROM `article` a WHERE a.article_id = '" + this.articleId + "' LIMIT 1");
        return ret;
    }
    
    /** Fetcher for print article page */
    public String getEmailInfo(String id) {
        this.articleId = "" + Convert.toInteger( id );
        String ret = Convert.stripHtml( this.dbConn.getSingleElement("SELECT CONCAT(a.article_title, '\n\n', TRIM(SUBSTRING( a.article_text, 1, LOCATE(' ', a.article_text, 800)))) AS text  FROM `article` a WHERE a.article_id = '" + this.articleId + "' LIMIT 1") ) + "...";
        //String ret = this.dbConn.getSingleElement("SELECT CONCAT(a.article_title, '\n\n', TRIM(SUBSTRING( a.article_text, 1, LOCATE(' ', a.article_text, 800)))) AS text  FROM `article` a WHERE a.article_id = '" + this.articleId + "' LIMIT 1") ;
        return ret;
    }
    
    /** Fetcher for print article page */
    public void fetchInfo() {
        HashMap ret = this.dbConn.getSingleRow("SELECT a.article_id, a.article_title, a.article_text, DATE_FORMAT(a.article_date,'%M %e, %Y') AS article_date, au.author_name, au.author_email, a.article_specs FROM `article` a LEFT JOIN author au ON au.author_id = a.author_id WHERE a.article_id = '" + this.articleId + "' LIMIT 1");
        ret.put("article_text", ((String)ret.get("article_text")).replaceAll("\\<br\\>\\<br\\>", "") );
        this.info = ret;
    }
    
    /** Fetcher for main article page */
    public void fetchInfo(String page) {
        //System.out.println("fetching "+page+" page..");
        this.page = Convert.toInteger( page );
        //System.out.println("fetching "+this.page+" page..");
        HashMap ret = this.dbConn.getSingleRow("SELECT a.article_id, a.article_title, a.article_text, DATE_FORMAT(a.article_date,'%M %e, %Y') AS article_date, a.category_id, c.category_desc, au.author_name, au.author_email, i.image_url, IFNULL(mk.make_name,'Car') AS make_name, IFNULL(md.model_name,'') AS model_name, LENGTH(article_specs) AS specs_size FROM `article` a LEFT JOIN image i ON i.article_id = a.article_id LEFT JOIN author au ON au.author_id = a.author_id LEFT JOIN make mk ON mk.make_id = a.make_id LEFT JOIN model md ON md.model_id = a.model_id LEFT JOIN category c ON a.category_id = c.category_id WHERE a.article_id = '" + this.articleId + "' AND i.type_id = 1 LIMIT 1");
        String article = (String)ret.get("article_text");
        if ( article != null ) {
            String[] pages = article.split("\\<br\\/?\\>\\<br\\/?\\>");
            if(pages.length > 1) {
                this.countPages = pages.length/2;
                if (this.page <= this.countPages ) {
                    if( (pages.length == this.countPages*2 || (this.page*2+1) <= pages.length) && pages.length>1 ) {
                        ret.put("article_text", pages[this.page*2]+pages[this.page*2+1]);
                    } else {
                        ret.put("article_text", pages[this.page*2]);
                    }
                }
            } else {
                ret.put("article_text", article);
                this.countPages = 1;
            }
        }
        ret.put("count_pages", ""+this.countPages);
        ret.put("article_albumimage", ""+ this.dbConn.getSingleElement( "SELECT image_url AS rand FROM image WHERE article_id = '" + this.articleId + "' AND type_id = 2 ORDER BY RAND() LIMIT 1") );

        // + 01.Jun.2007
        Vector ret2 = this.dbConn.getRows("select image_url from image where type_id = 2 and article_id = '" + this.articleId + "' ");
        this.countImg = ret2.size();
        ret.put("type2_images_cnt",this.countImg);
        ret.put("type2_images_url",ret2);
        
        this.info = ret;
        

    }
    
    /** Getter for property articleId.
     * @return Value of property articleId.
     *
     */
    public String getArticleId() {
        return this.articleId;
    }
    
    /** Setter for property articleId.
     * @param articleId New value of property articleId.
     *
     */
    public void setArticleId(String articleId) {
        this.articleId = "" + Convert.toInteger( articleId );
        fetchInfo();
    }
    
    public void setArticleId(String articleId, String page) {
        this.articleId = "" + Convert.toInteger( articleId );
        fetchInfo(page);
    }
    
    /** Getter for property info.
     * @return Value of property info.
     *
     */
    public HashMap getInfo() {
        return this.info;
    }
    
    /** Setter for property info.
     * @param info New value of property info.
     *
     */
    public void setInfo(HashMap info) {
        this.info = info;
    }
    
    /** Getter for property page.
     * @return Value of property page.
     *
     */
    public int getPage() {
        return this.page;
    }
    
    /** Setter for property page.
     * @param page New value of property page.
     *
     */
    public void setPage(int page) {
        this.page = page;
    }
    
    /** Getter for property countPages.
     * @return Value of property countPages.
     *
     */
    public int getCountPages() {
        return this.countPages;
    }
    
    /** Setter for property countPages.
     * @param countPages New value of property countPages.
     *
     */
    public void setCountPages(int countPages) {
        this.countPages = countPages;
    }
    
}
