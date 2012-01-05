<%@ page import="Auto123.*, java.util.HashMap"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib uri='/tags/struts-tiles' prefix='tiles' %>
<%@ taglib uri='/tags/url-rewrite' prefix='url' %>
<%
HashMap article = new DTO().getArticle( pageContext.getRequest().getParameter("id"), pageContext.getRequest().getParameter("page") );
//pageContext.setAttribute("article", new Article(pageContext.getRequest().getParameter("id"), pageContext.getRequest().getParameter("page")).getInfo(), PageContext.PAGE_SCOPE);
pageContext.setAttribute("article", article, PageContext.PAGE_SCOPE);
String title = "Automobile.com Car Reviews";
String description = "Car reviews and pictures at Automobile.com.";
String keywords = "Car reviews, automobile";

if( article != null ) {
  String make = (String)article.get("make_name");
  if ( make.equals("Car") ) {
    make = "";
  }

  title = "" + article.get("article_title") + " - Automobile.com " + make + " " + article.get("category_desc");
  description = "" + make + " reviews and " + make + " pictures at Automobile.com.";
  keywords = "" + article.get("article_title") + ", " + make + " reviews, automobile";

  pageContext.setAttribute("makes", new DTO().getUsedcarMakes(), PageContext.PAGE_SCOPE);
  pageContext.setAttribute("models", new DTO().getUsedcarModels(), PageContext.PAGE_SCOPE);
  pageContext.setAttribute("usedcarmake", new DTO().getUsedcarMake(""+make), PageContext.PAGE_SCOPE);

}

// + DEBUG : Apr.17.2007
title += " for Daniel's test " ;
// Convert the Article text String to Array + May.01.2007
String tmpStg = (String) article.get("article_text");
int nArraysize = 0 ;

nArraysize = tmpStg.length();

if (nArraysize>0) {

%>
<script>HdlArticleStg(<%=tmpStg%>,<%=nArraysize%>)</script><%
}  // end if       
%>

<!-- 

Update Log : 
 - update script such that article text collects pictures on the left      + May.30.2007

 -->

<tiles:insert page="/layouts/defaultLayout.jsp" flush="true">
    <tiles:put name="title"  value="<%=title%>" />
    <tiles:put name="description"  value="<%=description%>" />
    <tiles:put name="keywords"  value="<%=keywords%>" />
    <tiles:put name="header"  value="/layouts/header.jsp" />
    <tiles:put name="body" type="string">


<script language="JavaScript" type="text/JavaScript">
var makes = new Array();
var makesID = new Array();

for ( i = 0; i < 100; i++) {
  makes[i] = new Array();
  makesID[i] = new Array();
}

function validate() {
    if( document.searchUsedcar.carModelMakeId.value == 0 ) {
        alert('Select a Make');
        return false;
    }
    if ( document.searchUsedcar.carModelId.value == 0 ) {
        alert('Select a Model');
        return false;
    }
    /*if ( document.searchUsedcar.zipCode.value.length == 0 ) {
        alert('Provide a Zip Code');
        return false;
    }
    if ( document.searchUsedcar.zipCode.value.length > 0 && document.searchUsedcar.zipCode.value.length < 5) {
        alert('Zip Code seems to be invalid');
        return false;
    }*/
    return true;
}

function chooseMake(make, model) {
  if ( model == undefined ) {
    model = 0;
  }
  modelList = document.searchUsedcar.carModelId;
  document.searchUsedcar.carModelMakeId.value = make;
  while( modelList.length ) {
    modelList.options[0] = null;
  }
  modelList.options[0] = new Option("Select a Model","0",false,false);
  if ( makes[make] == undefined ) {
    return;
  }
  j = 1;
  for ( i = 0; i < makes[make].length; i++) {
    if ( makesID[make][i] > 0 ) {
      modelList.options[j] = new Option(makes[make][i],makesID[make][i],false,false);
      if ( model == makesID[make][i] ) {
        modelList.options[j].selected = true;
      }
      j++;
    }
  }
  return;
}

/* + May.30.2007 - starts */
function HdlArticleStg(stg,i) {

alert("length of the Stg array : "+i) ;

    if (i>0) {
        str = new String(stg);
        str = str.split("<br/>");
    }

}
/* + May.30.2007 - starts */

<c:set var="id" value="0"/>
<c:forEach var="item" items="${models}">
  <c:if test="{make_id ne item['make_id']}">
    <c:set var="id" value="0"/>
  </c:if>
  <c:set var="make_id" value="${item['make_id']}"/>
  makes[<c:out value="${item['make_id']}"/>][<c:out value="${id}"/>] = '<c:out value="${item['model_name']}"/>';
  makesID[<c:out value="${item['make_id']}"/>][<c:out value="${id}"/>] = '<c:out value="${item['model_id']}"/>';
  <c:set var="id" value="${id+1}"/>
</c:forEach>

</script>
		<tr>
		<td valign="top" align="center" colspan="2">			
<!-- note: open HTML table ends with struts_tiles file footer.jsp -->                    
			<table bgcolor="#FFFFFF" width="940" border="0" cellpadding="0" cellspacing="0">
			<tr>
 			<td class="breadcrumbs" colspan="2" style="padding:5px 0 5px 16px;">
 			<img src="images/arrow_blue.gif"> <a href="http://www.automobile.com" class="breadcrums">Home</a> - <a href="http://car-reviews.automobile.com/" class="breadcrums">Automobile Reviews</a> - Auto Reviews & Articles
			</td>
			</tr>
			<tr>
 			<td valign="top" align="center">				
				<table border="0" cellspacing="0" cellpadding="0" width="758" id="grey_bg">
  				<tr>
    				<td valign="top" align="center">
						<div style="padding-bottom:3px;">
              <table bgcolor="#dadee9" width="756" border="0" cellpadding="0" cellspacing="0"><tr>
 			<td valign="middle" align="left" width="100%" height="20" style="padding:0 0 0 10px;">Automobile Reviews & Related Articles</td></tr></table></div>
						
						<table border="0" cellspacing="0" cellpadding="0" width="756" id="grey_brd">
      					<tr>
						<td valign="top" align="center" bgcolor="#FFFFFF" style="padding:10px; height:550;">
<!--  + Apr.17.2007 - start of article block -->								
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr>
							<td valign="top"><c:if test="${!empty article['article_id']}">
							
								<table width="100%" cellpadding="0" cellspacing="0">
								<tr>
								<td width="170" valign="top" align="left"><img src="<c:out value="${article['image_url']}"/>" width="150" height="80" alt="<c:out value="${article['make_name']}"/> <c:out value="${article['model_namel']}"/>"></td>
								<td valign="top" style="padding:0 0 0 10px;"><span class="article_title"><b><c:out value="${article['article_title']}"/></b></span>
  <div class="revDate"><c:out value="${article['article_date']}"/></div>
  <div class="revAuthor">by <a href="mailto:<c:out value="${article['author_email']}"/>" class="grey"><c:out value="${article['author_name']}"/></a>&nbsp;/ <a href="http://www.americanautopress.com/content/copyright/index.htm" class="grey" target="_new">American Auto Press</a></div>
  <img src="images/review_header_sep.gif" width="380" height="3" vspace="3">
  								</td>
								</tr>
								</table>
<!-- + Apr.17.2007 Car Review Tools on the right -->								<table width="180" cellpadding="0" cellspacing="0" align="right" style="padding-left:10px;">
								<tr>
								<tr>
								<td valign="middle" align="center" height="16" bgcolor="#dadee9">&nbsp;&nbsp;<c:out value="${article['category_desc']}"/> Tools</td>
								</tr>
								<tr>
								<td height="18">&#149;&nbsp;&nbsp;<a href="/<c:if test="${article['category_id'] eq '1'}">news/</c:if>" class="grey"><b><c:out value="${article['category_desc']}"/> Home</b></a></td>
								</tr>
								<tr><td height="18">&#149;&nbsp;&nbsp;<a href="<url:urlrewrite key='picture' item='article'/>" class="grey">Photos of <c:out value="${article['make_name']}"/>&nbsp;<c:out value="${article['model_name']}"/></a></td>
								</tr>
								<c:if test="${article['specs_size'] > 0}">
								<tr>								
								<td height="18">&#149;&nbsp;&nbsp;<a href="<url:urlrewrite key='specs' item='article'/>" class="grey"><c:out value="${article['make_name']}"/>&nbsp;<c:out value="${article['model_name']}"/> Specs</a></td>
								</tr>
								</c:if>
								<tr>
								<td height="18">&#149;&nbsp;&nbsp;<a href="/print.jsp?id=<c:out value="${article['article_id']}"/>" onclick="window.open('/print.jsp?id=<c:out value="${article['article_id']}"/>', '_blank', 'left=20,top=20,toolbar=0,scrollbars=1,width=600,height=550');return false;" class="grey">Print this <c:out value="${article['category_desc']}"/></a></td>
								</tr>
								<tr>
								<td height="18">&#149;&nbsp;&nbsp;<a href="/email.jsp?id=<c:out value="${article['article_id']}"/>" onclick="window.open('/email.jsp?id=<c:out value="${article['article_id']}"/>', '_blank', 'left=20,top=20,toolbar=0,scrollbars=1,width=500,height=460');return false;" class="grey">Email this <c:out value="${article['category_desc']}"/></a></td>
								</tr>
								<tr>
								<td height="18">&nbsp;&nbsp; Page: 
<c:forEach var="row" begin="0" end="${article['count_pages']-1}">
<c:choose>
<c:when test="${row != param.page and ( !empty param.page or row > 0 ) }">
&nbsp;<a href="<url:urlrewrite key='review' item='article'/><c:out value="${row}"/>" class="grey"><c:out value="${row+1}"/></a>
</c:when>
<c:otherwise>
&nbsp;<b><c:out value="${row+1}"/></b>
</c:otherwise>
</c:choose>
</c:forEach>
  								</td>
								</tr>
								<tr>
  								<td align="center"><a href="<url:urlrewrite key='picture' item='article'/>" class="grey"><img src="<c:out value="${article['article_albumimage']}"/>" width="150" height="112" border="0" alt="<c:out value="${article['make_name']}"/>&nbsp;<c:out value="${article['model_name']}"/>"></a></td>
								</tr>
								<tr>
  								<td align="center"><a href="<url:urlrewrite key='picture' item='article'/>" class="grey">more photos</a><br><br></td>
								</tr>
								<c:if test="${!empty makes}">
<!-- DISPLAY QUICK LINK FORM TO USED CARS -->
								<tr>
								<td valign="middle" align="center" height="16" bgcolor="#dadee9">&nbsp;&nbsp;Used Car Finder</td>
								</tr>
								<tr>
								<td align="center">
								
									<table width="150" height="130" cellpadding="0" cellspacing="0" border="0">
									<tr>
									<td valign="top" align="left" height="100">
									<table width="140" border="0" cellspacing="3" cellpadding="0">
									<form name="searchUsedcar" action="http://buysell.automobile.com/search.do" method="GET">
									<input type="hidden" name="distance_i" value="50">
									<input type="hidden" name="price" value="0">
									<input type="hidden" name="price2" value="0">
									<tr>
									<td valign="top" align="left">Make:</td>
									</tr>
									<tr>
									<td valign="top" align="left">
			 						<select name="carModelMakeId" onchange="chooseMake(this.value)" class="med">
			   						<option value="0">Select a Make</option>
									<c:forEach var="item" items="${makes}">
									<option value="<c:out value="${item.key}"/>"><c:out value="${item.value}"/></option>
                           	 		</c:forEach>
									</select>
									</td>
									</tr>
									<tr>
									<td valign="top" align="left">Model:</td>
									</tr>
									<tr>
									<td valign="top" align="left"><select name="carModelId" class="med">
			   						<option value="0">Select a Model</option>
									</select>
									</td>
<!--temporary commented zip code field by Sergiy L 20070109-->
<!--<tr>
<td valign="top" align="left">Zip/Postal Code:</td>
</tr>-->
									<tr>
									<td valign="top" align="right" style="padding-top:3px;"><!--<input type="text" name="zipCode" maxlength="6" size="6" value="" class="sm"> &nbsp;-->
									<input type="submit" name="submit" value=" Go " onclick="JavaScript:return validate();" class="go_button"></td>
									</tr>
									</form>
									</table>
									</td>
									</tr>
									</table>
								
								</td>
								</tr>
<!-- END: USED CAR FINDER ... -->
								</c:if>
								</table>
								<br>
<!-- + May.02.2007 Car Review Article on the left starts -->
DEBUG : the 5th testing  
<br>
String content is :
<br>
<script type="text/javascript">
            document.write(str[0]+"<br/>")
            document.write(str[1]+"<br/>")
</script>
<br>
<!-- + May.30.2007 -->                                                                
<c:set var="test"    value="${article['article_text']}" scope="session" />
<c:set var="imgCnt"  value="${article['type2_images_cnt']}" scope="session" />
<c:set var="PgCnt"   value="${article['countPages']}" scope="session" />
<c:set var="ImgObj"  value="${article['type2_images_url']}" scope="session" />

<%
// <c:out value="${test}" />
%>
<br>
-- String test begins : -- 
<br>
Article text count : <% out.println(session.getAttribute("PgCnt")); %>
<br>
imgcnt : <% out.println(session.getAttribute("imgCnt")); %>  
<br>
Type 2 imgObj : <% out.println(session.getAttribute("ImgObj")); %>  
<br>
<% out.println(session.getAttribute("test")); %>                                                                
<br>
<br>
-- String test ends : -- 
<br>
								<c:out value="${article['article_text']}" escapeXml="true"/>

                                                                
                                                                
                                                                <br><br>
<!-- + May.02.2007 Car Review Article on the left ends   -->
								<table width="100%" cellpadding="0" cellspacing="0">
  								<tr>
    							<td width="98%" bgcolor="#000000"><img src="images/spacer.gif" width="1" height="1"></td>
  								</tr>
  								<tr>
    							<td valign="top" align="right" width="100%">
								Page:

<c:forEach var="row" begin="0" end="${article['count_pages']-1}">
<c:choose>
<c:when test="${row != param.page and ( !empty param.page or row > 0 ) }">
&nbsp;&nbsp;<a href="<url:urlrewrite key='review' item='article'/><c:out value="${row}"/>" class="grey"><c:out value="${row+1}"/></a>
</c:when>
<c:otherwise>
&nbsp;&nbsp;<c:out value="${row+1}"/>
</c:otherwise>
</c:choose>
</c:forEach>			
								</td>
								</tr>
								</table> 
<!--  + Apr.17.2007 - end of article block -->                                                                
							</c:if>
							</td>
							</tr>
							</table>
<!--  + Apr.17.2007 - end of article block -->								
<c:if test="${usedcarmake > 0}">
<script language="JavaScript" type="text/JavaScript">
  chooseMake(<c:out value="${usedcarmake}"/>);
</script>
</c:if>					</td>
	  					</tr>
    					</table>
				</td>
				</tr>	
				</table>				
								
			</td>
<td align="right" valign="top" width="160">
<!--Advertising area -->
<table border="0" cellpadding="0" cellspacing="0">
<tr><td>
<iframe src="http://www.automobile.com/banner/vertical_directory.html" width="166" scrolling="no" marginheight="0" height="278" frameborder="0"></iframe>
<iframe src="http://www.automobile.com/banner/vertical_directory_2.html" width="166" scrolling="no" marginheight="0" height="278" frameborder="0"></iframe>
</td></tr>
<!--end of drop-down to make pages-->
<tr><td><table bgcolor="#ffffff" border="0" cellpadding="0"
cellspacing="0" height="20" width="165">
<tr><td style="padding:3px 0 3px 0;"><a
href="http://www.automobile.com/landing_pre_lanch.php">
<img src="http://www.automobile.com/images/bnr_cldr.jpg" 
border="0"></a>
</td></tr>
<tr><td height="20" align="center" bgcolor="#dadee9">Sponsored
links</td></tr></table></td></tr>
<tr><td bgcolor="#f2f5fc" align="center" valign="top"><table
border="0" cellpadding="0" cellspacing="0" style="border: solid 1px
#c0c5c9;" bgcolor="#ffffff">
<tr><td valign="top"><span style="padding:0 0 0 3px;">
<script language="JavaScript" type="text/javascript">
<!--
ctxt_ad_partner = "1012663332";
ctxt_ad_section = "";
ctxt_ad_bg = "";
ctxt_ad_width = 160;
ctxt_ad_height = 600;
ctxt_ad_bc = "ffffff";
ctxt_ad_cc = "ffffff";
ctxt_ad_lc = "464646";
ctxt_ad_tc = "464646";
ctxt_ad_uc = "990100";
// -->
</script>
<script language="JavaScript"
src="http://ypn-js.overture.com/partner/js/ypn.js">
</script></span>
</td></tr></table>

</td></tr>
			</table>
<!-- End of Advertising area -->		
		</td>
	</tr>
</tiles:put>
<tiles:put name="footer"  value="/layouts/footer.jsp" />
</tiles:insert>
