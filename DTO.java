/*
 * DTO.java
 *
 * Created on January 28, 2005, 6:02 AM
 */

package Auto123;

import java.io.*;
import java.net.*;

import javax.servlet.*;
import javax.servlet.http.*;

import java.util.HashMap;
import java.util.Vector;
import java.lang.Math;
import java.util.Date;
import java.text.SimpleDateFormat;

import utils.Convert;

/**
 *
 * @author  D Chan
 * @version
 */
public class DTO extends HttpServlet {
    
    /** Holds value of property recentCarReview. */
    private static HashMap recentCarReview;
    
    /** Holds value of property recentConceptCar. */
    private static HashMap recentConceptCar;
    
    /** Holds value of property carReviews. */
    private static Vector carReviews;
    
    /** Holds value of property conceptCars. */
    private static Vector conceptCars;
    
    /** Holds value of property reviewsColumn. */
    private static String reviewsColumn;
    
    /** Holds value of property conceptColumn. */
    private static String conceptColumn;
    
    /** Holds value of property images. */
    private static HashMap images;
    
    /** Holds value of property imagesColumn. */
    private static String imagesColumn;
    
    /** Initializes the servlet.
     */
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        initVars();
    }
    
    /** Destroys the servlet.
     */
    public void destroy() {
        
    }
    
    /** Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        initVars();
        PrintWriter out = response.getWriter();
        out.println("cache updated.");
        out.close();
    }
    
    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    private void initVars() {
        ConceptCar ConceptCar = new ConceptCar();
        CarReview CarReview = new CarReview();
        this.recentConceptCar = ConceptCar.getRecentConceptCar();
        this.recentCarReview = CarReview.getRecentCarReview();
        this.conceptCars = ConceptCar.getConceptCars();
        this.carReviews = CarReview.getCarReviews();
        this.reviewsColumn =  "" + Math.round( this.carReviews.size()/5 +0.5 );
        this.conceptColumn =  "" + Math.round( this.conceptCars.size()/5 +0.5 );
        this.images = new Image().getMakesImages();
        this.imagesColumn = "" + (int)Math.ceil( ((double)this.images.size()/3) );
    }
    
    /** Getter for property recentCarReview.
     * @return Value of property recentCarReview.
     *
     */
    public HashMap getRecentCarReview() {
        return this.recentCarReview;
    }
    
    public Vector getRecentCarReview(String count) {
        Vector ret = new Vector();
        if ( Convert.toInteger(count) > 0 ) {
            ret = new CarReview().getRecentCarReview(Convert.toInteger(count));
        }
        return ret;
    }
    
    /** Setter for property recentCarReview.
     * @param recentCarReview New value of property recentCarReview.
     *
     */
    public void setRecentCarReview(HashMap recentCarReview) {
        this.recentCarReview = recentCarReview;
    }
    
    /** Getter for property recentConceptCar.
     * @return Value of property recentConceptCar.
     *
     */
    public HashMap getRecentConceptCar() {
        return this.recentConceptCar;
    }
    
    /** Getter for property recentConceptCar.
     * @return Value of property recentConceptCar.
     *
     */
    public Vector getRecentConceptCar(String count) {
        Vector ret = new Vector();
        if ( Convert.toInteger(count) > 0 ) {
            ret = new ConceptCar().getRecentConceptCar(Convert.toInteger(count));
        }
        return ret;
    }
    
    /** Setter for property recentConceptCar.
     * @param recentConceptCar New value of property recentConceptCar.
     *
     */
    public void setRecentConceptCar(HashMap recentConceptCar) {
        this.recentConceptCar = recentConceptCar;
    }
    
    /** Getter for property carReviews.
     * @return Value of property carReviews.
     *
     */
    public Vector getCarReviews() {
        return this.carReviews;
    }
    
    /** Setter for property carReviews.
     * @param carReviews New value of property carReviews.
     *
     */
    public void setCarReviews(Vector carReviews) {
        this.carReviews = carReviews;
    }
    
    /** Getter for property conceptCars.
     * @return Value of property conceptCars.
     *
     */
    public Vector getConceptCars() {
        return this.conceptCars;
    }
    
    /** Setter for property conceptCars.
     * @param conceptCars New value of property conceptCars.
     *
     */
    public void setConceptCars(Vector conceptCars) {
        this.conceptCars = conceptCars;
    }
    
    /** Getter for property makeReviews.
     * @return Value of property makeReviews.
     *
     */
    public Vector getMakeReviews(String id) {
        return new CarReview().getMakeReviews( Convert.toInteger(id) );
    }
    
    /** Getter for property makeConcept.
     * @return Value of property makeConcept.
     *
     */
    public Vector getMakeConcepts(String id) {
        return new ConceptCar().getMakeConcepts( Convert.toInteger(id) );
    }
    
    public String getMakeName(String id) {
        if ( Convert.toInteger(id) < 1 ) {
            return "";
        }
        return new ConceptCar().getMakeName( Convert.toInteger(id) );
    }
    
    /** Getter for property reviewsColumn.
     * @return Value of property reviewsColumn.
     *
     */
    public String getReviewsColumn() {
        return this.reviewsColumn;
    }
    
    /** Setter for property reviewsColumn.
     * @param reviewsColumn New value of property reviewsColumn.
     *
     */
    public void setReviewsColumn(String reviewsColumn) {
        this.reviewsColumn = reviewsColumn;
    }
    
    /** Getter for property conceptColumn.
     * @return Value of property conceptColumn.
     *
     */
    public String getConceptColumn() {
        return this.conceptColumn;
    }
    
    /** Setter for property conceptColumn.
     * @param conceptColumn New value of property conceptColumn.
     *
     */
    public void setConceptColumn(String conceptColumn) {
        this.conceptColumn = conceptColumn;
    }
    
    /** Getter for property images.
     * @return Value of property images.
     *
     */
    public HashMap getImages() {
        return this.images;
    }
    
    /** Setter for property images.
     * @param images New value of property images.
     *
     */
    public void setImages(HashMap images) {
        this.images = images;
    }
    
    /** Getter for property imagesColumn.
     * @return Value of property imagesColumn.
     *
     */
    public String getImagesColumn() {
        return this.imagesColumn;
    }
    
    /** Setter for property imagesColumn.
     * @param imagesColumn New value of property imagesColumn.
     *
     */
    public void setImagesColumn(String imagesColumn) {
        this.imagesColumn = imagesColumn;
    }
    
    public Vector getMakeImages(String make) {
        Vector ret = new Vector();
        if ( Convert.toInteger(make) > 0 ) {
            ret = new Image().getMakeImages(Convert.toInteger(make));
        }
        return ret;
    }
    
    public HashMap getAlbum(String id, String page) {
        HashMap ret = new HashMap();
        if ( Convert.toInteger(id) > 0 ) {
            ret = new Album(id, page).getInfo();
        }
        return ret;
    }
    
    public HashMap getArticle(String id, String page) {
        HashMap ret = new HashMap();
        if ( Convert.toInteger(id) > 0 ) {
            ret = new Article(id, page).getInfo();
        }
        return ret;
    }
    
    public String getArticleTitle(String id) {
        String ret = new String();
        if ( Convert.toInteger(id) > 0 ) {
            ret = new Article().getTitle(id);
        }
        return ret;
    }
    
    public HashMap getSpecs(String id) {
        HashMap ret = new HashMap();
        if ( Convert.toInteger(id) > 0 ) {
            ret = new Specs(id).getInfo();
        }
        return ret;
    }
    
    public HashMap getUsedcarMakes() {
        return new Usedcar().getMakes();
    }
    
    public Vector getUsedcarModels() {
        return new Usedcar().getModels();
    }
    
    public String getUsedcarMake(String make) {
        String ret = new String();
        if( make != null && make.length() > 0 ) {
            ret = new Usedcar().getMakeid(make);
        }
        return ret;
    }
    
    public HashMap getNewsMonths() {
        return new News().getMonths();
    }
    
    public Vector getNewsDays(String year, String month) {
        Vector ret = new Vector();
        if ( Convert.toInteger(year) > 0 && Convert.toInteger(month) > 0 ) {
            ret = new News().getNewsDays(year, month);
        }
        return ret;
    }
    
    public Vector getLastNews() {
        Vector ret = new Vector();
        Date today = new Date();
        try {
            ret = new News().getNewsDays(new SimpleDateFormat("yyyy").format(today), new SimpleDateFormat("MM").format(today));
        }
        catch (Exception e){
            System.out.println(e.toString());
        }
        return ret;
    }
    
}
