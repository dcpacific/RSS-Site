<%@page import="com.bytec.business.action.*"%>
<%@page import="com.bytec.dataaccess.*"%>
<%@page import="com.elasticpath.commons.datatransfer.*"%>
<%@page import="org.apache.commons.collections.IterableMap"%>
<%@page import="org.apache.commons.collections.map.ListOrderedMap"%>
<%@page import="org.apache.commons.collections.MapIterator"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.apache.commons.collections.map.HashedMap"%>
<%@page import="java.text.SimpleDateFormat"%>
<!-- + Jul.19.2007 -->
<%@page import="java.text.DateFormat"%>

<%@page import="de.laures.cewolf.*"%>
<%@page import="java.math.BigInteger"%>
<!-- + Jul.18.2007 -->
<%@page import="java.math.BigDecimal"%>

<%@page import="com.elasticpath.commons.Money"%>
<%@page import="org.jfree.chart.JFreeChart" %>
<%@page import="org.jfree.chart.plot.Plot" %>
<%@page import="org.jfree.chart.plot.XYPlot" %>
<%@page import="com.elasticpath.commons.RequestHelper" %>
<%@page import="org.jfree.chart.renderer.xy.XYItemRenderer" %>
<%@page import="com.elasticpath.commons.exception.EPIllegalInputDataException" %>
<%@page import="java.awt.Color" %>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<!-- + Jun.19.2007 -->
<%@page import="java.util.Vector"%>
<!-- + Jul.18.2007 -->
<%@page import="java.util.Currency"%>
<!-- + Jul.19.2007 -->
<%@page import="java.util.Date"%>

<%@ include file="includes/paths.jsp" %>
<%@ include file="includes/secure.jsp" %>
<%@ include file="includes/header.jsp" %>

<jsp:useBean id="order" class="com.bytec.business.action.report.datasetproducer.OrderDataSetProducer"/>
<jsp:useBean id="customer" class="com.bytec.business.action.report.datasetproducer.CustomerDataSetProducer"/>
<jsp:useBean id="bytecPastProcessor" class="com.bytec.business.action.report.datasetproducer.BytecChartPastProcessor"/>

<jsp:useBean id="items" class="com.bytec.business.action.report.datasetproducer.ItemDataSetProducer"/>
<jsp:useBean id="cust" class="com.bytec.business.action.report.datasetproducer.RepeatCustomerDataSetProducer"/>

<jsp:useBean id="catPastProcessor" class="com.bytec.business.action.report.datasetproducer.CategoryPlotPastProcessor"/>

<!-- Update Log :
    - update the report to house the date list, the blank start date box is 
      defaulted to the 1st date of the month, the blank end date box is defaulted to
      last date of the month 
    - need to have Javascript generate an Http request to a servlet which can 
      execute the Java code for onchange event and optionally return the update 
      which Javascript could then use to generate content for your page     + 07.jun.2007
    - update script to apply filters for Boutique or Classic Reports        + 18.jun.2007
    - update script as Classic Category is equivalent to Sales Categalory   + 21.Jun.2007
    - update script to restrict date range to 35 days                       + 19 Jul.2007
    - update script to house    Cost and Profit                             + 24.Jul.2007
-->

<html>
<head>
<style type="text/css">
        <!-- 
        #cell {border-bottom:1px solid #ccc;padding:3px;}
        #header{font-weight:bold;padding:3px;border-bottom:1px solid #ccc;border-top:1px solid #ccc; background-color:#f2f2f2; height:30px;}
        -->
</style>
<script type="text/javascript"> 
//-------------------------------------------------------
// function initRpt
//-------------------------------------------------------
function initRpt() {

    var cStg = document.forms[0].src.options[document.forms[0].src.selectedIndex].value ;
//DEBUG
//alert('initRpt is called ...cStg='+cStg);
    
    doCheck2(cStg) ;
    // + Jun.20.2007
    InitSrvRT3();
    
}
window.onload=initRpt;
</script>

</head>
<!-- + 06.Jun.2007 -->
<body onload="">
<!-- + May.29.2007 -->
<script type="text/JavaScript" language="JavaScript">
// + 06.JUN.2007       starts ---
// Variables 
var optionTest1 = true;
var optionTest2 = true;

var scriptVar = "" ;
//-------------------------------------------------------
// function populateMD
//-------------------------------------------------------
function populateMD(bFlag,nIndex,cSMIdx,cEMIdx) {

    var nMaxMonthCnt = 0 ;
    var MonthDays = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    var oMnbox ;
    var oMDaybox ;
    var number ;
    var cPtr = "";  
    var cPtr2= "";
    var nX   =  0;
    var NewDate ;
    
//debug
//alert('<p>inside populateMD... <\/p>');

    if (bFlag == true) {
        //very beginning, load both start and end Month-date list
        NewDate = new Date();
        if ( isEmpty(cSMIdx) || isWhitespace(cSMIdx) ) {
            nX = NewDate.getMonth();
            cSMIdx = new String(nX) ; 
        } //end if
        if ( isEmpty(cEMIdx) || isWhitespace(cEMIdx) ) {
            nX = NewDate.getMonth();
            cSMIdx = new String(nX) ; 
        } //end if

        //cleanup
        document.forms[0].b_d2.options.length = 0;
        document.forms[0].b_d1.options.length = 0;

            oMnbox = document.forms[0].b_m2;
            nX = parseInt(cSMIdx);
            if (!nX) { 
                document.writeln('<p>Error - nX - No start month is set, Start-Month_Date list is not populated ...<\/p>');
                return; 
            }
            nMaxMonthCnt = MonthDays[nX-1] ;

            oMDaybox = document.forms[0].b_d2;
            oMDaybox.options.length = 0;
            for(i=0;i<nMaxMonthCnt;i+=1)
            {
                if (i==0) {
                    cPtr = new String(i) ;
                    oMDaybox.options[i] = new Option(cPtr," ");
                } else {
                    cPtr = new String(i)
                    if ( cPtr.length < 2 ) {
                        cPtr2 = '0' + cPtr;
                    } else {
                        cPtr2 = cPtr;
                    }
                    oMDaybox.options[i] = new Option(cPtr,cPtr2);
                }  // end if
            }      // end for
            
        //load end Month-date list
//
            oMnbox = document.forms[0].b_m1;
            nX = parseInt(cSMIdx);
            if (!nX) { 
                document.writeln('<p>Error - nX - No End month is set, End-Month_Date list is not populated ...<\/p>');
                return; 
            }
            nMaxMonthCnt = MonthDays[nX-1] ;
            oMDaybox = document.forms[0].b_d1;
            oMDaybox.options.length = 0;
            for(i=0;i<nMaxMonthCnt;i+=1)
            {
                if (i==0) {
                    cPtr = new String(i) ;
                    oMDaybox.options[i] = new Option(cPtr," ");
                } else {
                    cPtr = new String(i)
                    if ( cPtr.length < 2 ) {
                        cPtr2 = '0' + cPtr;
                    } else {
                        cPtr2 = cPtr;
                    }
                    oMDaybox.options[i] = new Option(cPtr,cPtr2);
                }  // end if
            }      // end for
//
        } else {
//
//on change event, then update the only corresponding Month-date list
//
            if (nIndex == 1) {
//debug
//alert('<p>inside populateMD; very Only start Month-date list ... <\/p>');
            oMnbox = document.forms[0].b_m2;
            number = oMnbox.options[oMnbox.selectedIndex].value;

            if (!number) { 
                document.writeln('<p>No start month is selected, Start-Month_Date list is not populated ...<\/p>');
                return; 
            }
            nMaxMonthCnt = MonthDays[number] ;
//debug
//alert('<p>number : '+number+' <\/p>');
            oMDaybox = document.forms[0].b_d2;
            oMDaybox.options.length = 0;
            for(i=0;i<=nMaxMonthCnt;i+=1)
            {
                if (i==0) {
                    cPtr = new String(i) ;
                    oMDaybox.options[i] = new Option(cPtr,"");
                } else {
                    cPtr = new String(i)
                    if ( cPtr.length < 2 ) {
                        cPtr2 = '0' + cPtr;
                    } else {
                        cPtr2 = cPtr;
                    }
                    oMDaybox.options[i] = new Option(cPtr,cPtr2);
                }  // end if
            }      // end for

//debug
//alert('<p>box[0] : '+oMDaybox.options[0].value+' <\/p>');
                // + 07.Jun.2007  
                    oMDaybox.options[0].value = ' ' ;

            } else {
//debug
//alert('<p>inside populateMD; very Only End Month-date list ... <\/p>');
            oMnbox = document.forms[0].b_m1;
            number = oMnbox.options[oMnbox.selectedIndex].value;

            if (!number) { 
                document.writeln('<p>Error -number- No End month is selected, End-Month_Date list is not populated ...<\/p>');
                return; 
            }
            nMaxMonthCnt = MonthDays[number] ;
//debug
//alert('<p>nMaxMonthCnt : '+nMaxMonthCnt+' <\/p>');
            oMDaybox = document.forms[0].b_d1;
            oMDaybox.options.length = 0;
            for(i=0;i<=nMaxMonthCnt;i+=1)
            {
                if (i==0) {
                    cPtr = new String(i) ;
                    oMDaybox.options[i] = new Option(cPtr," ");
                } else {
                    cPtr = new String(i)
                    if ( cPtr.length < 2 ) {
                        cPtr2 = '0' + cPtr;
                    } else {
                        cPtr2 = cPtr;
                    }
                    oMDaybox.options[i] = new Option(cPtr,cPtr2);
                }  // end if
            }      // end for

//debug
//alert('<p>box[0] : '+oMDaybox.options[0].value+' <\/p>');
                    oMDaybox.options[0].value = ' ' ;

//
        } //end if
        
    }   // end if 

return true;    
    
}
// + 06.JUN.2007       ends ---
//-------------------------------------------------------
// function doCheck    + May.29.2007
//-------------------------------------------------------
function doCheck() {
    var mySelectelem = document.getElementById('src');
    var data1elem    = document.getElementById('type');

    if (mySelectelem.value == '10' || mySelectelem.value == '11' || mySelectelem.value == '12') {
        data1elem.style.visibility = 'hidden';
    } else {
        data1elem.style.visibility = 'visible';
    }
}
//-------------------------------------------------------
// function TypeOff
//-------------------------------------------------------
function TypeOff() {
//debug
//alert('TypeOff - LIST Reports are called !');

    document.getElementById('type').style.visibility='hidden';
    document.getElementById('RptType').style.visibility='hidden';
    document.getElementById('div05').style.visibility='visible';
    document.getElementById('div06').style.visibility='visible';
    //since the very first option is full report, so hide the sublist
    //only available when user pick the barand or category filer
    document.getElementById('div07').style.visibility='hidden';
    document.getElementById('div08').style.visibility='hidden';
}
//-------------------------------------------------------
// function TypeOn
//-------------------------------------------------------
function TypeOn() {
//debug
//alert('TypeOn - Graphics Reports are called !');

    document.getElementById('type').style.visibility='visible';
    document.getElementById('RptType').style.visibility='visible';
    document.getElementById('div05').style.visibility='hidden';
    document.getElementById('div06').style.visibility='hidden';
    document.getElementById('div07').style.visibility='hidden';
    document.getElementById('div08').style.visibility='hidden';
}
//-------------------------------------------------------
// function doCheck2
//-------------------------------------------------------
function doCheck2(src) {

//debug
//alert('doCheck2 is called ... src='+src);

    if (src == '6' || src == '7' || src == '8' || src == '9'|| 
        src == '10'|| src == '11'|| src == '12') {
        //list type reports
        TypeOff();

        if (src == '10' || src == '11' || src == '12') {
            // Campaign Reports
            document.getElementById('div05').style.visibility='hidden';
            document.getElementById('div06').style.visibility='hidden';
            document.getElementById('div07').style.visibility='hidden';
            document.getElementById('div08').style.visibility='hidden';
        }  else {
            loadRT2(src) ; 
        }
        
    } else {
        //Graphic type reports
        TypeOn();
    } // end if
//debug
//alert('exit doCheck2 .. ');
}
</script>

<!-- + Jun.14.2007 -->
<script type="text/JavaScript" language="JavaScript">

//-------------------------------------------------------
// function loadRT2
//-------------------------------------------------------
function loadRT2(src) {

//Boutique Report type Menu
var BtqArray = new Array() ;
BtqArray[0]  = "Full Report";
BtqArray[1]  = "Filter by Brand";
BtqArray[2]  = "Filter by Boutique Category";
BtqArray[3]  = "Filter by Sales    Category";
//Classic Report type Menu
var CscArray = new Array() ;
CscArray[0]  = "Full Report";
CscArray[1]  = "Filter by Brand";
CscArray[2]  = "Filter by Classic Category";

var tmpStg   = "" ;
//debug
//alert('loadRT2 is called ... src='+src);

    var LstObj = document.forms[0].bLstRT2;
    var cKey   = '';
    var cValue = ''
    
    var nLstLgth = LstObj.options.length;
    //cleanup
    if ( nLstLgth > 0) { LstObj.options.length = 0; }

    // Boutique Reports
    if (src == '6' || src == '7') {
//debug
//alert('array BtqArray length ='+BtqArray.length);
        
        for(i=0;i<BtqArray.length;i++) {
//debug
//alert('i ='+i+' BtqArray[i]= '+BtqArray[i]);
            cKey = new String(i);
            cValue = BtqArray[i];
            LstObj.options[i] = new Option(cValue,cKey);
//debug
//alert('list value= '+LstObj.options[i].value);
            }
    }
    
    // Classic Reports
    if (src == '8' || src == '9') {

//debug
//alert('array CscArray length ='+CscArray.length);
        
        for(i=0;i<CscArray.length;i++) {
//debug
//alert('i ='+i+' CscArray[i]= '+CscArray[i]);

          cKey = new String(i);
          cValue = CscArray[i];
          LstObj.options[i] = new Option(cValue,cKey);
//debug
//alert('list value= '+LstObj.options[i].value);
        }
    }
}
</script>

<script language="JavaScript" type="text/JavaScript">
    //Array Declaration
    var BBArray_Key   = new Array() ;
    var BBArray_Value = new Array() ;
    var CBArray_Key   = new Array() ;
    var CBArray_Value = new Array() ;
    var BCArray_Key   = new Array() ;
    var BCArray_Value = new Array() ;
    var CCArray_Key   = new Array() ;
    var CCArray_Value = new Array() ;
//-------------------------------------------------------
// function InitSrvRT3
//-------------------------------------------------------
function InitSrvRT3() {
//DEBUG
//        alert('function InitSrvRT3 is called ... ');
/*
    CBArray_Value[0] = "ABC" ;
    CBArray_Value[1] = "DEF" ;
*/        
    var arlgth = 0 ;

<%
List liBB ;
int lCnt = 0;
int nBBCnt = 0;
int nTmpi;
String  cTmpId ;
String  cTmpNm;

//Boutique Brand
liBB = new SimpleReport().getCtgBrand(0) ;
//-------------------------------------------------------
//prepare array from server side   + Jun.18.2007
//-------------------------------------------------------
if (liBB != null) {
   //init. var.
   lCnt = liBB.size();
   
   nBBCnt = 0;
   Iterator iterBB = liBB.iterator();
           
   while(iterBB.hasNext()) {

      List liBB5 = (ArrayList) iterBB.next();

      if (liBB5 != null) {

         nTmpi = 0;
         cTmpId= "";
         cTmpNm= "";

         Iterator itrBB5 = liBB5.iterator();
         while(itrBB5.hasNext()) {
            if (nTmpi==0) {
               cTmpId= (String) itrBB5.next();
            } else if (nTmpi==1) {
               cTmpNm= (String) itrBB5.next();
            }   // end if 
            nTmpi++;   
         }  // end while

 //System.out.println("nBBCnt = "+nBBCnt);
 //System.out.println("cName  = "+cTmpNm);
         // fill up javascript array
//         out.println(" BBArray_Key[" + nBBCnt + "]=" + cTmpId);
//         out.println(" BBArray_Value[" + nBBCnt + "]=" + cTmpNm);
%>        
    BBArray_Key[<%=nBBCnt%>] = "<%=cTmpId%>" ;
    BBArray_Value[<%=nBBCnt%>] = "<%=cTmpNm%>" ;
<%
         }     // end if
      nBBCnt++;
    }     // end while
}   // end if
%>


<%
//Boutique Category
int nBCCnt = 0;
List liBC = new SimpleReport().getCtgBrand(2) ;
//-------------------------------------------------------
//prepare array from server side   + Jun.18.2007
//-------------------------------------------------------
if (liBC != null) {
   //init. var.
   lCnt = liBC.size();
   
   nBCCnt = 0;
   Iterator iterBC = liBC.iterator();
           
   while(iterBC.hasNext()) {

      List liBC5 = (ArrayList) iterBC.next();

      if (liBC5 != null) {

         nTmpi = 0;
         cTmpId= "";
         cTmpNm= "";

         Iterator itrBC5 = liBC5.iterator();
         while(itrBC5.hasNext()) {
            if (nTmpi==0) {
               cTmpId= (String) itrBC5.next();
            } else if (nTmpi==1) {
               cTmpNm= (String) itrBC5.next();
            }   // end if 
            nTmpi++;   
         }  // end while

 //System.out.println("nBCCnt = "+nBCCnt);
 //System.out.println("cName  = "+cTmpNm);
         // fill up javascript array
%>        
    BCArray_Key[<%=nBCCnt%>] = "<%=cTmpId%>" ;
    BCArray_Value[<%=nBCCnt%>] = "<%=cTmpNm%>" ;
<%
         }     // end if
      nBCCnt++;
    }     // end while
}   // end if
%>


<%
//Classic Brand
int nCBCnt = 0;
List liCB = new SimpleReport().getCtgBrand(1) ;
//-------------------------------------------------------
//prepare array from server side   + Jun.18.2007
//-------------------------------------------------------
if (liCB != null) {
   //init. var.
   lCnt = liCB.size();
   
   nCBCnt = 0;
   Iterator iterCB = liCB.iterator();

   while(iterCB.hasNext()) {
      List liCB5 = (ArrayList) iterCB.next();
      if (liCB5 != null) {
         nTmpi = 0;
         cTmpId= "";
         cTmpNm= "";

         Iterator itrCB5 = liCB5.iterator();
         while(itrCB5.hasNext()) {
            if (nTmpi==0) {
               cTmpId= (String) itrCB5.next();
            } else if (nTmpi==1) {
               cTmpNm= (String) itrCB5.next();
            }   // end if 
            nTmpi++;   
         }  // end while

 //System.out.println("nCBCnt = "+nCBCnt);
 //System.out.println("cTmpId = "+cTmpId);
 //System.out.println("cTmpNm = "+cTmpNm);
         // fill up javascript array
 
//cTmpNm
%>        
    CBArray_Key[<%=nCBCnt%>] = "<%=cTmpId%>" ;
    CBArray_Value[<%=nCBCnt%>] = "<%=cTmpNm%>" ;
<%
//    out.println("CBArray_Value[" + nCBCnt + "]=" + cTmpNm);

         }     // end if
      nCBCnt++;
    }     // end while
}   // end if
%>


<%
//Classic Category
int nCCCnt = 0;
List liCC = new SimpleReport().getCtgBrand(3) ;
//-------------------------------------------------------
//prepare array from server side   + Jun.18.2007
//-------------------------------------------------------
if (liCC != null) {
   //init. var.
   lCnt = liCC.size();
   
   nCCCnt = 0;
   Iterator iterCC = liCC.iterator();

   while(iterCC.hasNext()) {
      List liCC5 = (ArrayList) iterCC.next();
      if (liCC5 != null) {
         nTmpi = 0;
         cTmpId= "";
         cTmpNm= "";

         Iterator itrCC5 = liCC5.iterator();
         while(itrCC5.hasNext()) {
            if (nTmpi==0) {
               cTmpId= (String) itrCC5.next();
            } else if (nTmpi==1) {
               cTmpNm= (String) itrCC5.next();
            }   // end if 
            nTmpi++;   
         }  // end while

 //System.out.println("nCCCnt = "+nCCCnt);
 //System.out.println("cTmpId = "+cTmpId);
 //System.out.println("cTmpNm = "+cTmpNm);
         // fill up javascript array
%>        
    CCArray_Key[<%=nCCCnt%>] = "<%=cTmpId%>" ;
    CCArray_Value[<%=nCCCnt%>] = "<%=cTmpNm%>" ;
<%
         }     // end if
      nCCCnt++;
    }     // end while
}   // end if
%>

//DEBUG
/*
    arlgth = BBArray_Key.length ;
alert('InitSrvRT3 is called ...BB Key   arlgth = '+arlgth);
    arlgth = BBArray_Value.length ;
alert('InitSrvRT3 is called ...BB value arlgth = '+arlgth);
    arlgth = CBArray_Key.length ;
alert('InitSrvRT3 is called ...CB Key   arlgth = '+arlgth);
    arlgth = CBArray_Value.length ;
alert('InitSrvRT3 is called ...CB value arlgth = '+arlgth);
    arlgth = BCArray_Key.length ;
alert('InitSrvRT3 is called ...BC Key   arlgth = '+arlgth);
    arlgth = BCArray_Value.length ;
alert('InitSrvRT3 is called ...BC value arlgth = '+arlgth);
    arlgth = CCArray_Key.length ;
alert('InitSrvRT3 is called ...CC Key   arlgth = '+arlgth);
    arlgth = CCArray_Value.length ;
alert('InitSrvRT3 is called ...CC value arlgth = '+arlgth);
*/
}
//-------------------------------------------------------
// function DebugliBB
//-------------------------------------------------------
    function DebugliBB(nCnt) {
        alert('function DebugliBB is called , nCnt='+nCnt);
    }
//-------------------------------------------------------
// function popRT3
//-------------------------------------------------------
function popRT3(src,Rt2Ptr) {
    var Idx = -1;
//DEBUG
//    alert('popRT3 is called ... Rt2Ptr='+Rt2Ptr+' and src='+src);
    
    if (src == '6' || src == '7' ) {
        if (Rt2Ptr == '1') {
            // BB
            Idx = 0;
        } else if (Rt2Ptr == '2') {
            //BC
            Idx = 2;
        } else if (Rt2Ptr == '3') {
            //CC                  + Jun.21.2007
            Idx = 3;
        }
    } else if (src == '8' || src == '9' ) {
        if (Rt2Ptr == '1') {
            //CB
            Idx = 1;
        } else if (Rt2Ptr == '2') {
            //CC
            Idx = 3;
        }
    }
    
//DEBUG
//alert('popRT3 is called ... Idx'+Idx);
    
    if (Idx >= 0) {
        
        //update list box
        var LstObj = document.forms[0].bLstRT3;
        var cKey   = '';
        var cValue = ''
    
        var nLstLgth = LstObj.options.length;
        //cleanup
        if ( nLstLgth > 0) { LstObj.options.length = 0; }

        switch (Idx) {
            case 0:
                    for(i=0;i<BBArray_Key.length;i++) {
                        cKey  =BBArray_Key[i];
                        cValue=BBArray_Value[i];
                        LstObj.options[i] = new Option(cValue,cKey);
                    } // end for
                    break;
            case 1:
                    for(i=0;i<CBArray_Key.length;i++) {
                        cKey  =CBArray_Key[i];
                        cValue=CBArray_Value[i];
                        LstObj.options[i] = new Option(cValue,cKey);
                    } // end for
                    break;
            case 2:

//DEBUG
//alert(' Idx = '+Idx);
            
                    for(i=0;i<BCArray_Key.length;i++) {
                        cKey  =BCArray_Key[i];
                        cValue=BCArray_Value[i];

//DEBUG
//alert('i = '+i+' cKey='+cKey+' cValue='+cValue);
                        
                        
                        LstObj.options[i] = new Option(cValue,cKey);
                    } // end for
                    break;
            case 3:
                    for(i=0;i<CCArray_Key.length;i++) {
                        cKey  =CCArray_Key[i];
                        cValue=CCArray_Value[i];
                        LstObj.options[i] = new Option(cValue,cKey);
                    } // end for
                    break;
        } // end switch
    } // end if
    
    //artivate sublist only if not Full report
    if (Rt2Ptr != '0') {
        document.getElementById('div07').style.visibility='visible';
        document.getElementById('div08').style.visibility='visible';
    } else {
        document.getElementById('div07').style.visibility='hidden';
        document.getElementById('div08').style.visibility='hidden';
    }
    // end if
    
}
</script>
<!-- + JUN.19.2007 -->

<H1></H1>
<p>
<table border=0>
<TR>
<TD>


<%
//default value

Calendar c = Calendar.getInstance();

//String frequency = "WEEK";
String frequency = "DATE";
//defualt to Ordercount Report
String src="2";
String name = "ORDERCOUNT";
String type = "1";


final SimpleDateFormat dateformat = new SimpleDateFormat("yyyyMMdd");
//Starting Date
//String b_m1 = "06";
//String b_y1 = "2005";

//Date today = c.getTime();
//Today
String b_date_2 = dateformat.format(c.getTime());
String b_m2=b_date_2.substring(4,6);
BigInteger bi_2 = new BigInteger(b_m2).subtract(BigInteger.ONE);
b_m2 = bi_2.toString();

if (b_m2.length() < 2) {
b_m2 = "0"+b_m2;
}
        

String b_y2=b_date_2.substring(0,4);
String b_m1 = b_date_2.substring(4,6);
BigInteger bi_1 = new BigInteger(b_m1).subtract(BigInteger.ONE);
b_m1 = bi_1.toString();

if (b_m1.length() < 2) {
b_m1 = "0"+b_m1;
}

String b_y1 = b_date_2.substring(0,4);

// retrieve the date + 06.Jun.2007
String b_d2=b_date_2.substring(6);
if (b_d2.length()<2) {
    b_d2 = "0" + b_d2;    
}
String b_d1=b_date_2.substring(6);
if (b_d1.length()<2) {
    b_d1 = "0" + b_d1;    
}


// report type for graphical report
IterableMap reportType = new ListOrderedMap();
reportType.put("1","Daily");
reportType.put("2","Weekly");
reportType.put("3","Monthly");
reportType.put("4","Quarterly");
reportType.put("5","Yearly");

IterableMap sourceType = new ListOrderedMap();
sourceType.put("1","SUBTOTAL");
sourceType.put("2","ORDERCOUNT");
sourceType.put("3","NEWLY JOINED CUSTOMERS");
sourceType.put("4","REPEAT CUSTOMERS");
sourceType.put("5","ITEMS SOLD BY SECTION");
sourceType.put("6","TOP(#) BOUTIQUE PRODUCTS");
sourceType.put("7","TOP($) BOUTIQUE PRODUCTS");
sourceType.put("8","TOP(#) CLASSIC PRODUCTS");
sourceType.put("9","TOP($) CLASSIC PRODUCTS");
// + May.25.2007
sourceType.put("10","Campaign Report by Name");
sourceType.put("11","Campaign Report by Revenue");
sourceType.put("12","Campaign Report by Order Count");
// + May.29.2007


IterableMap query = new HashedMap();
query.put("1",SimpleReport.REPORT_DAILY);
query.put("2",SimpleReport.REPORT_WEEKLY);
query.put("3",SimpleReport.REPORT_MONTHLY);
query.put("4",SimpleReport.REPORT_QUARTERLY);
query.put("5",SimpleReport.REPORT_YEARLY);


IterableMap months = new ListOrderedMap();
months.put("0","Jan");
months.put("1","Feb");
months.put("2","Mar");
months.put("3","Apr");
months.put("4","May");
months.put("5","Jun");
months.put("6","Jul");
months.put("7","Aug");
months.put("8","Sep");
months.put("9","Oct");
months.put("10","Nov");
months.put("11","Dec");


IterableMap years = new ListOrderedMap();

int curYear = c.get(Calendar.YEAR);
for (int i=2005;i<=curYear; i++) {
    years.put(""+i,""+i);
}

String paramSrc = request.getParameter("src");

if (paramSrc !=null && sourceType.containsKey(paramSrc)) {
    src = paramSrc;
    name = (String)sourceType.get(src); 
}

String paramType = request.getParameter("type");

if (paramType !=null && query.containsKey(paramType)) {
    frequency = (String)query.get(paramType);
    type = paramType; 
}

String paramY1 = request.getParameter("b_y1");
String paramY2 = request.getParameter("b_y2");
String paramM1 = request.getParameter("b_m1");
String paramM2 = request.getParameter("b_m2");

// + Jun.07.2007
String paramD1 = request.getParameter("b_d1");
String paramD2 = request.getParameter("b_d2");

if (paramY1 !=null && years.containsKey(paramY1)) {
    b_y1 = paramY1;
}

if (paramY2 !=null && years.containsKey(paramY2)) {
    b_y2 = paramY2;
}

if (paramM1 !=null && months.containsKey(paramM1)) {
if (paramM1.length() < 2)
    b_m1 = "0"+paramM1;
else
    b_m1=paramM1;
}

if (paramM2 !=null && months.containsKey(paramM2)) {
if (paramM2.length() < 2)
    b_m2 = "0"+paramM2;
else
    b_m2=paramM2;
}


ArrayList errorList = new ArrayList();		                
String sDate = null;
String eDate = null;
String tmp = null;


// + Jul.19.2007
/*
if ((new Integer(b_y1+b_m1)).intValue() < (new Integer(b_y2+b_m2)).intValue()) {
    errorList.add("Start date should NOT be later than End date ");
    request.setAttribute("errorMsgs",errorList);
//tmp = b_y1;
//b_y1=b_y2;
//b_y2 = tmp;
//tmp = b_m1;
//b_m1=b_m2;
//b_m2 = tmp;
} 
*/

c.set((new Integer(b_y2)).intValue(),(new Integer(b_m2)).intValue(),1);
sDate = dateformat.format(c.getTime());

c.set((new Integer(b_y1)).intValue(),(new Integer(b_m1)).intValue(),1);
int lastDayOfThisMonth = c.getActualMaximum(Calendar.DAY_OF_MONTH);
c.set(Calendar.DATE,lastDayOfThisMonth);
eDate = dateformat.format(c.getTime());

// + Jun.07.2007
IterableMap SMday2 = new ListOrderedMap();
IterableMap SMday1 = new ListOrderedMap();


MapIterator itType = reportType.mapIterator();
MapIterator itSource = sourceType.mapIterator();
MapIterator itMonths = months.mapIterator();
MapIterator itMonths_0 = months.mapIterator();
MapIterator itYears = years.mapIterator();
MapIterator itYears_0 = years.mapIterator();

// + Jun.08.2007
String s2Date ;

// + 06.Jun.2007  -- starts
int[] MonthDays = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
int tmpDD = 0;
String sDate_DD;
String eDate_DD;
String tmpKeyStg ;
String tmpValueStg ;

int jj;

//+ Jun.08.2007
char tmpChar ;

if (sDate != null) {

    
    if (sDate.substring(4,6).equals("0") ){
        sDate_DD = sDate.substring(4,6);
    } else {
        sDate_DD = sDate.substring(5,6);
    }

    jj = new Integer(sDate_DD);

    for(int i=0;i<MonthDays[jj];i++) {
        tmpKeyStg = Integer.toString(i);
        tmpValueStg = Integer.toString(i+1);
        SMday2.put(tmpKeyStg,tmpValueStg);
    } // end for
} else {
    sDate_DD = "" ;
}

if (eDate != null) {

    if (eDate.substring(4,6).equals("0") ){
        eDate_DD = eDate.substring(4,6);
    } else {
        eDate_DD = eDate.substring(5,6);
    }

    jj = new Integer(eDate_DD);

    for(int i=0;i<MonthDays[jj];i++) {
        tmpKeyStg = Integer.toString(i);
        tmpValueStg = Integer.toString(i+1);
        SMday1.put(tmpKeyStg,tmpValueStg);
    } // end for
} else {
    eDate_DD = "" ;
} // end if


// + JUN.07.2007
MapIterator itSMday2  = SMday2.mapIterator();
MapIterator itSMday1  = SMday1.mapIterator();

if (paramD2 !=null && SMday2.containsKey(paramD2)) {
if (paramD2.length() < 2)
    b_d2 = "0"+paramD2;
else
    b_d2=paramD2;
}

if (paramD1 !=null && SMday1.containsKey(paramD1)) {
if (paramD1.length() < 2)
    b_d1 = "0"+paramD1;
else
    b_d1=paramD1;
}
// + 06.Jun.2007  -- ends


String title = reportType.get(type) + " Report";

String yLabel = "SubTotal ($)";
String producerId = "order";
Color dataColor = new Color(0,153,102);


if (src.equals("2")) {
yLabel = "# of Orders";
dataColor = new Color(102,153,0);
} else if (src.equals("3")) {
yLabel = "# of new customers";
producerId = "customer";
dataColor = new Color(204,102,0);
}


// + DEBUG at 05.Jun.2007
//System.out.println("b_date_2 : "+b_date_2);  
//System.out.println("b_m2     : "+b_m2);  
//System.out.println("bi_2     : "+bi_2);  
//System.out.println("b_y2     : "+b_y2);
//System.out.println("b_d2     : "+b_d2);  
//System.out.println("b_m1     : "+b_m1); 
//System.out.println("bi_1     : "+bi_1); 
//System.out.println("b_y1     : "+b_y1);
//System.out.println("b_d1     : "+b_d1);  

// + Jun.20.2007
String bLstRT2 = request.getParameter("bLstRT2");
String bLstRT3 = request.getParameter("bLstRT3");
%>
<!-- + JUN.20.2007 -->
<!--
<script>InitSrvRT3();</script>
-->


<% 
RequestHelper rh = new RequestHelper(request);
%>
<!-- the error msg directive is relocated + Jul.19.2007  -->

<%
// Reset the dates in case of these reports                       + Jun.07.2007
        if (src.equals("6") || src.equals("7") || src.equals("8") || src.equals("9") || 
            src.equals("10")|| src.equals("11")|| src.equals("12") ) {

// reset the dates to synchronize with param    + Jun.07.2007
    
//reset the sDate
paramY2 = request.getParameter("b_y2");
paramM2 = request.getParameter("b_m2");
paramD2 = request.getParameter("b_d2");

if (paramY2 !=null && years.containsKey(paramY2)) {
    b_y2 = paramY2;
}
if (paramM2 !=null && months.containsKey(paramM2)) {
    if (paramM2.length() < 2)
        b_m2 = "0"+paramM2;
    else
        b_m2=paramM2;
}

if (paramD2 !=null ) {

    if (paramD2.substring(0,1).equals("0")) {
        if (SMday2.containsKey(paramD2.substring(1))) {
            b_d2=paramD2;
        } else {
            //case the null box is picked, then set to last date of the month
            jj = Integer.parseInt(b_m2.trim());
            b_d2=  new Integer(MonthDays[jj]).toString()   ;
        }
    } else {
        if (SMday2.containsKey(paramD2)){
            b_d2=paramD2;
        } else {
    //case the null box is picked, then set to first date of the month
            b_d2= "01"   ;
        } // end if
    }     // end if
}
    
if ( b_d2.equals("0") || b_d2.equals("1") || b_d2.equals(" ") || b_d2.equals("00")    ) {
    c.set((new Integer(b_y2)).intValue(),(new Integer(b_m2)).intValue(),1);
} else {
    c.set((new Integer(b_y2)).intValue(),(new Integer(b_m2)).intValue(),(new Integer(b_d2)).intValue());
}

s2Date = sDate ;

sDate = dateformat.format(c.getTime());


//reset the eDate
paramY1 = request.getParameter("b_y1");
paramM1 = request.getParameter("b_m1");
paramD1 = request.getParameter("b_d1");

if (paramY1 !=null && years.containsKey(paramY1)) {
    b_y1 = paramY1;
}
if (paramM1 !=null && months.containsKey(paramM1)) {
    if (paramM1.length() < 2)
        b_m1 = "0"+paramM1;
    else
        b_m1=paramM1;
} 

if (paramD1 !=null ) {

    if (paramD1.substring(0,1).equals("0")) {
        if (SMday1.containsKey(paramD1.substring(1))) {
            b_d1=paramD1;
        } else {
            //case the null box is picked, then set to last date of the month
            jj = Integer.parseInt(b_m1.trim());
            b_d1=  new Integer(MonthDays[jj]).toString()   ;
        }
    } else {
        if (SMday1.containsKey(paramD1)){
            b_d1=paramD1;
        } else {
    //case the null box is picked, then set to last date of the month
            jj = Integer.parseInt(b_m1.trim());
            b_d1=  new Integer(MonthDays[jj]).toString()   ;
        } // end if
    }     // end if
}

if ( b_d1.equals("0") || b_d1.equals("1") || b_d1.equals(" ")) {
    c.set((new Integer(b_y1)).intValue(),(new Integer(b_m1)).intValue(),1);
}else{
    c.set((new Integer(b_y1)).intValue(),(new Integer(b_m1)).intValue(),(new Integer(b_d1)).intValue());
}


eDate = dateformat.format(c.getTime());

        }else{
// + Jun.08.2007
s2Date = sDate;
        }

%>        
        
<%
// + 19.Jul.2007  -- starts
boolean bFlag2007 = true;

// Use the java Date difference function to calcuate the actual date difference 

/* 
        if (b_d1.length()==1) {
            b_d1 = "0" + b_d1;
        }
        if (b_d2.length()==1) {
            b_d2 = "0" + b_d2;
        }
        
        int nEDate = Integer.parseInt(b_y1+b_m1+b_d1);
        int nSDate = Integer.parseInt(b_y2+b_m2+b_d2);
        int nDateDiff = nEDate - nSDate ;
        if (nDateDiff > 35) {
            errorList.add("date range should not greater than 35 days ");
            request.setAttribute("errorMsgs",errorList);
            bFlag2007 = false;
        }

note: do not mess up b_m1 and b_m2 as both are ued to match picklist         
*/
        int nTmp = 0;
        if (b_d1.length()==1) {
            b_d1 = "0" + b_d1;
        }
        if (b_d2.length()==1) {
            b_d2 = "0" + b_d2;
        }

        nTmp = Integer.parseInt(b_m1) ; 
        nTmp += 1;
        String bmm1 = Integer.toString(nTmp).trim(); 
        if (bmm1.length()==1){
            bmm1 = "0"+bmm1;
        }
        nTmp = Integer.parseInt(b_m2) ; 
        nTmp += 1;
        String bmm2 = Integer.toString(nTmp).trim(); 
        if (bmm2.length()==1){
            bmm2 = "0"+bmm2;
        }
        
        DateFormat df = new SimpleDateFormat ("yyyy-MM-dd");
        String cSdate = new String(b_y2+"-"+bmm2+"-"+b_d2);
        String cEdate = new String(b_y1+"-"+bmm1+"-"+b_d1);

//DEBUG
//System.out.println("cSdate="+cSdate+"...");        
//System.out.println("cEdate="+cEdate+"...");        

        Date dSDate = df.parse(cSdate);
        Date dEDate = df.parse(cEdate);
        
//DEBUG
//System.out.println("startday="+b_d2+"...");        
//System.out.println("endday="+b_d1+"...");        
//System.out.println("startmonth="+bmm2+"...");        
//System.out.println("enddmonth="+bmm1+"...");        
        
        long diff = dEDate.getTime() - dSDate.getTime(); 
        long diff2= diff / (1000*60*60*24) ;

//DEBUG
//System.out.println("dSDate="+dSDate);        
//System.out.println("dEDate="+dEDate);        
//System.out.println("nDateDiff="+diff2);        

//if ((new Integer(b_y1+b_m1)).intValue() < (new Integer(b_y2+b_m2)).intValue()) {
//    errorList.add("Start date should NOT be later than End date ");
//    request.setAttribute("errorMsgs",errorList);
//} else {
if (diff2 < 0) {
    errorList.add("Start date should NOT be later than End date ");
    request.setAttribute("errorMsgs",errorList);
} else {    
    // case End date is greater than equal to start date
    // restrict 35 day restriction only for these reports
    if (src.equals("6") || src.equals("7") || src.equals("8") || src.equals("9")) {

            if (diff2 > 35.00) {
                errorList.add("date range should not greater than 35 days ");
                request.setAttribute("errorMsgs",errorList);
                bFlag2007 = false;
            }

    }  // end if

}  //end if

if (rh.hasErrors()) {
%>
                <%@ include file="includes/errorMsgBox.jsp" %>
                <br><br>
<% 
    } 

// + 19.Jul.2007  -- ends
%>




<!-- + 25.May.2007 Campaign Report starts 

Form parameters 10,11 and 12 are assigned to Campaign Reports, namely :
(10) Campaign Report order by Name
(11) Campaign Report order by Revenue (Subtotal)
(12) Campaign Report order by Shipping_Order_Cnt

-->
<% 

// + May.29.2007
        if (src.equals("10") || src.equals("11") || src.equals("12") ) {
        
// + May.29.2007_B        
//      SimpleReport2 rep2 = new SimpleReport2();
        SimpleReport  rep2 = new SimpleReport();

// + May.29.2007
        int nOrderByValueSUbtotal = 0 ;           // order by Campaign
        if (src.equals("11")) {
            nOrderByValueSUbtotal = 1;            // order by subtotal      
        } else if (src.equals("12")) {
            nOrderByValueSUbtotal = 2;            // order by rec count      
        } // end if

%>

<br>
Start Date : <%=sDate%>
<br>
End Date : <%=eDate%>
<br>
<%        
//      List li2 = rep2.getCampaignLst(sDate,eDate,bOrderByValueSUbtotal,true);
        List li2 = rep2.getCampaignLst2(sDate,eDate,nOrderByValueSUbtotal,true);
        
%>
<table cellpadding="0" cellspacing="0" border="0">
<%    
        if (li2 != null) {
            //init. var.
            int nLoopCnt = 0;
            Iterator iter2 = li2.iterator();

// + May.29.2007
            Integer  nTotalRCnt= new Integer(0); 
// + May.28.2007            
            Integer  nTotalAmt = new Integer(0);
            Integer  nTotalCost= new Integer(0);
/*            
            Money  nTotalAmt = null;
            Money  nTotalCost= null;
*/
                
                while(iter2.hasNext()) {
                
                List list2 = (ArrayList) iter2.next();
                if (list2 != null) {
                    Iterator iter5 = list2.iterator();

                    if (nLoopCnt != 0){
                        // detail Campaign
%> 
<tr>

<%                        
                        int i = 0;
                        String  vName = "";
// + May.29.2007
                        Integer nRecCnt   = new Integer(0);                        
// + May.28.2007
                        Integer nSubtotal = new Integer(0);
                        Integer nShpCost  = new Integer(0);

                        while (iter5.hasNext()) {

                            if (i==0) {
                                vName = (String) iter5.next();
//                                System.out.println("Value:"+vName);
                            } else if (i==1) {
// + May.29.2007
                                nRecCnt   = (Integer) iter5.next();

                            } else if (i==2) {
// + May.28.2007
                                nSubtotal = (Integer) iter5.next();
//                                nSubtotal = (Money) iter5.next();

                            } else if (i==3) {    
// + May.28.2007
                                nShpCost  = (Integer) iter5.next();
//                                nShpCost  = (Money) iter5.next();
                                
%>
<td id="cell" align="center">&nbsp;<%=vName%></td>
<td id="cell" align="center">&nbsp;<%=nRecCnt%></td>
<td id="cell" align="center">&nbsp;<%=nSubtotal%></td>
<td id="cell" align="center">&nbsp;<%=nShpCost%></td>
<%                                
                            }   // end if 
                         i++;   
                        }     // end while 
%>                        
</tr>                        
<%                        
                    } else {    
                        // Campaign Header
                        int j = 0;
%>
<tr>                        

<%                        
    while (iter5.hasNext()) {

         if (j==0) {
// + May.29.2007
    nTotalRCnt= (Integer) iter5.next();

         } else if (j==1) {
// + May.28.2007
   nTotalAmt = (Integer) iter5.next();
//     nTotalAmt = (Money)iter5.next();
  
         } else if (j==2) {
// + May.28.2007
  nTotalCost= (Integer) iter5.next();
//    nTotalCost= (Money)iter5.next();
  
%>
    <td align="center" id="header"><b>Campaign</b></td>
    <td align="center" id="header"><b>&nbsp;Total Rec Count:<%=nTotalRCnt%></b></td>
    <td align="center" id="header"><b>&nbsp;Total Revenue:<%=nTotalAmt%></b></td>
    <td align="center" id="header"><b>&nbsp;Total ShippingCost:<%=nTotalCost%></b></td>
<%                                
    } // end if
    j++;
    }  // end while
    %>
</tr>
<%
                    }  // end if
                }      // end if
// + May.28.2007                
    nLoopCnt++;
                }     // end while
        }   // end if
%>    
</table>

<% 
}
%>
<!-- + 25.May.2007 Campaign Report ends -->
               
<% if (src.equals("6") || src.equals("7") || src.equals("8") || src.equals("9")) { %> 

<!-- Start the block regarding 35 days restriction  + Jul.19.2007-->
<% if (bFlag2007){%>

<% 
    SimpleReport rep = new SimpleReport();
    int templateUID = 5;
    boolean orderByAmt = false;
    if(src.equals("6") || src.equals("7")){
        templateUID = 2;
    }
    
    if(src.equals("7") || src.equals("9")){
        orderByAmt = true;
    }

// + Jun.20.2007    
//    List li = rep.getTopSellingProducts(templateUID,sDate,eDate,orderByAmt);
    List li ;

    
/*  DEBUG  + Jul.11.2007    
    if (bLstRT2.equals("0")) {
        // full report
        li = rep.getTopSellingProducts(templateUID,sDate,eDate,orderByAmt);
    } else {
        li = rep.getTopSellingProducts2(templateUID,sDate,eDate,orderByAmt,bLstRT3);
    }
*/
    boolean bFlag = false;
    if (bLstRT2.equals("0")) {
        // full report
        bFlag = false;
        } else {
        bFlag = true;
    }
//System.out.println("DEBUG: before calling getTop3 ...") ;  
    li = rep.getTopSellingProducts3(templateUID,sDate,eDate,orderByAmt,bFlag,bLstRT3) ;
//System.out.println("DEBUG: after calling getTop3 ...") ;    
    
%>

<!-- + 07.Jun.2007 -->
<br>
Start Date : <%=sDate%>
<br>
End Date : <%=eDate%>
<br>

<!-- Graphic block -->
<table cellpadding="0" cellspacing="0" border="0">

<%

if(li != null){    

    // local var.
    int i1 = 0;
    Iterator iter = li.iterator();
    Integer totalcnt = new Integer(0);
    Money totalamt   = null;
    // + JUl.11.2007
    Money totalSld   = null;
    // + Jul.18.2007
    Money totalSld2  = null;
    
    // + Jul.24.2007
    Money totalCst2 = null;
    Money totalPft2= null;
    
%>

<%while(iter.hasNext()){%>   

<%List list = (ArrayList)iter.next();


if(list != null){     
Iterator iter1 = list.iterator();

if(i1 != 0){  
    
    // block processing the details
    
int i = 0; 
Integer pID = new Integer(0);
Integer pvID = new Integer(0);
Integer cnt = new Integer(0);
Integer stockCount = new Integer(0);
String pName = "";
String mName = "";
String pvName = "";
String pCode = "";
Money amt = null;

// + Jul.11.2007
Money Sld = null;
// + Jul.24.2007
Money Cost = null;
Money Profit= null;

// + Jul.18.2007
String ctStg = new String("");

ProductDTO pDTO = null;%>

<tr>
<% while(iter1.hasNext()){ 
    
//DEBUG
System.out.println(" Detail block, iter1 has NExt , i=" + i);

%> 

<% if(i == 0){ %>
<%   cnt = (Integer)iter1.next();%>

<% } else if(i == 1) {%>
<%   pCode = (String)iter1.next();

//DEBUG
//System.out.println("pCode:"+pCode);
%>
<% } else if(i == 2) {%>
<%   
amt = (Money)iter1.next();

// + Jul.11.2007 
   } else if(i == 4) {

    Sld = (Money)iter1.next();

// + Jul.24.2007 
   } else if(i == 5) {

    Cost  = (Money)iter1.next();

// + Jul.24.2007 
   } else if(i == 6) {    

    Profit= (Money)iter1.next();

%>
<td id="cell">
<a href="http://www.makeup.com/shop.do?pID=<%=pDTO.getUidPk()%>&pvID=<%=pvID%>" target="_blank"><%=mName%> - <%=pName%> - <%=pvName%></a>
</td>
<td id="cell" align="center">&nbsp;<%=cnt%></td>
<td id="cell" align="center">&nbsp;$<%=amt.printMoneyValue()%></td>
<!-- + Jul.11.2007 -->
<td id="cell" align="center">&nbsp;$<%=Sld.printMoneyValue()%></td>
<!-- + Jul.24.2007 -->
<td id="cell" align="center">&nbsp;$<%=Cost.printMoneyValue()%></td>
<td id="cell" align="center">&nbsp;$<%=Profit.printMoneyValue()%></td>

<td id="cell" align="center">&nbsp;<%=stockCount%></td>
<%

//DEBUG
System.out.println(" Detail block, after detail rec is printed , i=" + i);

   } else { %>
<%   pDTO = (ProductDTO)iter1.next(); %>
<%   pName = pDTO.getName(); %>
<%   mName = pDTO.getManufacturer().getName(); %>
<%BytecProductVariationDAO bpvDAO = new BytecProductVariationDAO();
List pvList = bpvDAO.findByProductCodeforNav(pCode);

if(pvList != null){
Iterator iter2 = pvList.iterator();
while(iter2.hasNext()){
    ProductVariationDTO pvDTO = (ProductVariationDTO)iter2.next();
    pvID = pvDTO.getUidPk();
    pvName = pvDTO.getName();
    stockCount = pvDTO.getStockCount();
} 
}%>
<% } %>
<% i++;}%>
</tr>

<% } else {

    // block processing the header
    
int i2 = 0;%>
<tr>
<% while(iter1.hasNext()){ %>

<% if(i2 == 0){ %>

<!-- total Count -->
<%   totalcnt = (Integer)iter1.next();%>

<!-- total Cost -->
<%
   // + Jul.24.2007
   } else if(i2 == 3) { 

/*    
    BigDecimal BDCst = new BigDecimal(iter1.next().toString())   ;
    totalCst2 = new Money(BDCst,Currency.getInstance("USD"));
    BigDecimal BDPft = BDCst.subtract(BDSld);
    totalPft2 = new Money(BDPft,Currency.getInstance("USD"));
*/
    BigDecimal BDCst = new BigDecimal(iter1.next().toString())   ;
    totalCst2 = new Money(BDCst,Currency.getInstance("USD"));
%>

<!-- total Profit -->
<%    
   // + Jul.24.2007
   } else if(i2 == 4) { 

    BigDecimal BDPft = new BigDecimal(iter1.next().toString()) ;
    totalPft2 = new Money(BDPft,Currency.getInstance("USD"));

%>
<td align="center" id="header"><%if(templateUID == 2){%>BOUTIQUE<% }else{ %>CLASSIC <% } %></td>
<td align="left" id="header">&nbsp;Total Items Sold:<%=totalcnt%></td>
<td align="left" id="header">&nbsp;Total Amt: $<%=totalamt.printMoneyValue()%></td>
<!-- + Jul.11.2007 -->
<td align="left" id="header">&nbsp;Total Sold: $<%=totalSld2.setScale(2)%></td>
<!-- + Jul.24.2007 -->
<td align="left" id="header">&nbsp;Total Cost: $<%=totalCst2.setScale(2)%></td>
<td align="left" id="header">&nbsp;Total Profit: $<%=totalPft2.setScale(2)%></td>

<td align="left" id="header">&nbsp;Stock</td>

<!-- total Sold -->
<%
   // + Jul.11.2007
   } else if(i2 == 2) {
     
    BigDecimal BDSld = new BigDecimal(iter1.next().toString())   ;
    totalSld2 = new Money(BDSld,Currency.getInstance("USD"));

//DEBUG
System.out.println("BDSld = "+ BDSld.toString());    
    
%>

<!-- total Amount -->
<% } else if(i2 == 1) {%>
<%   totalamt = (Money)iter1.next();%>
<% } %>

<% 
    i2++; 
    } %>
</tr>
<% } %> 
<% } %> 

<% i1++; } %>

<% } %>

</table>

<!-- End the block regarding 35 days restriction  + Jul.19.2007-->
<%}%>

<!-- + Jun.20.2007 starts -->
<!-- + Jun.20.2007 ends   -->
<% } else if (src.equals("5")) { %> 

  <cewolf:chart id="chart3d" type="stackedverticalBar3D" 
    xaxislabel="" yaxislabel="# of items">
      <cewolf:data>
          <cewolf:producer id="items" >

                              <cewolf:param name="FREQUENCY" value="<%= frequency %>"/>
                              <cewolf:param name="REPORT_TYPE" value="<%= name %>"/>
                              <cewolf:param name="TIME_1" value="<%= sDate %>" />
                              <cewolf:param name="TIME_2" value="<%= eDate %>" />
          </cewolf:producer>
      </cewolf:data>
      <cewolf:colorpaint color="#FFFFFF"/>
		<cewolf:chartpostprocessor id="catPastProcessor" >
                </cewolf:chartpostprocessor>
  </cewolf:chart>
  <cewolf:img chartid="chart3d" renderer="/cewolf" border="0" width="720" height="400">
  <cewolf:map tooltipgeneratorid="items" />
  </cewolf:img>

<%} else if (src.equals("4")) { %> 

 <cewolf:chart id="chart3d" type="stackedverticalBar3D" 
    xaxislabel="" yaxislabel="# of customers">
      <cewolf:data>
          <cewolf:producer id="cust" >

                              <cewolf:param name="FREQUENCY" value="<%= frequency %>"/>
                              <cewolf:param name="REPORT_TYPE" value="<%= name %>"/>
                              <cewolf:param name="TIME_1" value="<%= sDate %>" />
                              <cewolf:param name="TIME_2" value="<%= eDate %>" />
          </cewolf:producer>
      </cewolf:data>
      <cewolf:colorpaint color="#FFFFFF"/>
		<cewolf:chartpostprocessor id="catPastProcessor" >
                </cewolf:chartpostprocessor>
  </cewolf:chart>
  <cewolf:img chartid="chart3d" renderer="/cewolf" border="0" width="720" height="400">
<cewolf:map tooltipgeneratorid="items" />
  </cewolf:img>

<!-- + May.30.2007 -->
<% } else if ( src.equals("1") || src.equals("2") || src.equals("3") || src.equals("6") || src.equals("7") || src.equals("8") || src.equals("9") ) {%>

<cewolf:overlaidchart 
	id="chart" 
	title="<%= title %>" 
	type="overlaidxy" 
	xaxistype="date"
	yaxistype="number"
	xaxislabel="" 
	yaxislabel="<%= yLabel %>">
    <cewolf:colorpaint color="#FFFFFF"/>

		<cewolf:plot type="xyverticalbar" xaxislabel="month">
			<cewolf:data>
      			<cewolf:producer id="<%= producerId %>" >
                              <cewolf:param name="FREQUENCY" value="<%= frequency %>"/>
                              <cewolf:param name="REPORT_TYPE" value="<%= name %>"/>
                              <cewolf:param name="TIME_1" value="<%= sDate %>" />
                              <cewolf:param name="TIME_2" value="<%= eDate %>" />                             
                        </cewolf:producer>
    		</cewolf:data>
		</cewolf:plot>
		<cewolf:chartpostprocessor id="bytecPastProcessor" >
                              <cewolf:param name="BARCOLOR" value="<%= dataColor %>" />
                </cewolf:chartpostprocessor>
</cewolf:overlaidchart>

<!-- this demonstrates that links work with overlaid chart too -->

<cewolf:img chartid="chart" renderer="/cewolf" width="700" height="400">
	<cewolf:map tooltipgeneratorid="<%= producerId %>" />
</cewolf:img>

<%}%>

</TD>
</TR>

</TABLE>

<!-- <form action="report.jsp" >  + 06.Jun.2007 -->
    <form  name="MakeUpreport" action="report.jsp" >
        <!-- + 06.Jun.2007 -->
        <input type="hidden" name="HBuffer">

    <table border=0>
        <tr>
            <td>Source :</td>
            <td colspan="5" align="left">
<!-- + May.29.2007    
<select name="src">
-->
<select name="src" id="src" onchange="doCheck2(document.forms[0].src.options[document.forms[0].src.selectedIndex].value);">
    
<% while (itSource.hasNext()) { String key = (String)itSource.next(); %>
<option value="<%= key %>" <% if (key.equals(src)) {%> selected <%}%> ><%=itSource.getValue() %></option>
<%}%>
</select>
            </td>
        <tr>
        <!-- + May.29.2007 -->
        <tr>
            <td id="RptType">Report Type :</td>
            <td colspan="5" align="left">
<!-- + May.29.2007    
<select name="type">
-->
<select name="type" id="type">
    
<% while (itType.hasNext()) { String key = (String)itType.next(); %>
<option value="<%= key %>" <% if (key.equals(type)) {%> selected <%}%> ><%=itType.getValue() %></option>
<%}%>
</select>
            </td>
        </tr>
        <!-- + May.29.2007-->    
        <tr>
            <td>Start date :</td>
            <td align="left">
                <!-- Start Month -->
                <select name="b_m2" onchange="populateMD(false,1,'','')">
                <% while (itMonths_0.hasNext()) { String key = (String)itMonths_0.next();  String k2 = key; if (key.length() <2){k2="0"+key;}%>
                <option value="<%=key %>" <% if (k2.equals(b_m2)) {%> selected <%}%> ><%=itMonths_0.getValue() %></option>
                <%}%>
                </select>
            </td>
<!-- + 06.Jun.2007 Start MonthDate begins -->
            <td>
                <select name="b_d2">
<!-- + 07.JUn.2007 -->                    
<%
if (sDate != null) {
   
    int j = new Integer(b_m2);

    for(int i=0;i<=MonthDays[j];i++) {
        tmpKeyStg = Integer.toString(i);
        
        if (i==0) {
            tmpValueStg= " ";
        } else {
            tmpValueStg= Integer.toString(i);
        }

%>
<!-- + 08.Jun.2007 -->
<option value="<%=tmpKeyStg %>" 
<%
    if (tmpKeyStg.length()==1) {
        tmpChar = '*';
        if (b_d2.length()>1) {
            //case param is more than 1 digit
            if (b_d2.substring(0,1).equals("0")) {
                tmpChar = b_d2.charAt(1);
            }
        } else {
          // case param is single digit
          tmpChar = b_d2.charAt(0);
        }
       if (tmpKeyStg.indexOf(tmpChar) >= 0 ) {%> selected <%}                
    } else {
        // contains 2 digit 
        if (b_d2.length()>1) {
           if (tmpKeyStg.equals(b_d2)) {%> selected <%}                
        }
    } // end if
%>
>
<%=tmpValueStg %>
</option>

<%
    } // end for

}
%>
<!-- + 07.Jun.2007 -->                    
                </select>
            </td>
<!-- + 06.Jun.2007 Start MonthDate ends -->
            <td align="left">
                <!-- Start Year -->
                <select name="b_y2">
                <% while (itYears.hasNext()) { String key = (String)itYears.next();%>
                <option value="<%=key %>" <% if (key.equals(b_y2)) {%> selected <%}%> ><%=itYears.getValue() %></option>
                <%}%>
                </select>
            </td>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td>End date :</td>
            <td align="left">
                <!-- End Month -->
                <select name="b_m1" onchange="populateMD(false,2,'','')">
                <% while (itMonths.hasNext()) { String key = (String)itMonths.next();  String k1 = key; if (key.length() <2){k1="0"+key;} %>
                <option value="<%=key %>" <% if (k1.equals(b_m1)) {%> selected <%}%> ><%=itMonths.getValue() %></option>
                <%}%>
                </select>
            </td>
<!-- + 06.Jun.2007 End MonthDate begins -->
            <td>
                <select name="b_d1">
<!-- + 07.JUn.2007 -->                    
<%
if (eDate != null) {
   
    int j = new Integer(b_m1);
  
    for(int i=0;i<=MonthDays[j];i++) {
        tmpKeyStg = Integer.toString(i);
        
        if (i==0) {
            tmpValueStg= " ";
        } else {
            tmpValueStg= Integer.toString(i);
        }

%>

<!-- + 08.Jun.2007 -->
<option value="<%=tmpKeyStg %>" 
<%
    if (tmpKeyStg.length()==1) {
        tmpChar = '*';
        if (b_d1.length()>1) {
            //case param is more than 1 digit
            if (b_d1.substring(0,1).equals("0")) {
                tmpChar = b_d1.charAt(1);
            }
        } else {
          // case param is single digit
          tmpChar = b_d1.charAt(0);
        }
       if (tmpKeyStg.indexOf(tmpChar) >= 0 ) {%> selected <%}                
    } else {
        // contains 2 digit 
        if (b_d1.length()>1) {
           if (tmpKeyStg.equals(b_d1)) {%> selected <%}                
        }
    } // end if
%>
>
<%=tmpValueStg %>
</option>
<%
    } // end for

}
%>
<!-- + 07.Jun.2007 -->                    
                </select>
            </td>
<!-- + 06.Jun.2007 End MonthDate ends -->
            </td>
            <td align="left">
                <!-- End Year -->
                <select name="b_y1">
                <% while (itYears_0.hasNext()) { String key = (String)itYears_0.next();%>
                <option value="<%=key %>" <% if (key.equals(b_y1)) {%> selected <%}%> ><%=itYears_0.getValue() %></option>
                <%}%>
                </select>
            </td>
            <!-- + 05.Jun.2007 -->
            <td>&nbsp;</td>
            <td><INPUT TYPE=SUBMIT VALUE="Get Report"></td>
        </tr>
        <!--  The ReportType 2 only applies to Boutique and Classic Reports  + Jun.14.2007 starts -->
        <tr><td id="div05" >ReportType 2:</td>
            <td id="div06" colspan="5" align="left">
                <select name="bLstRT2" onchange="popRT3(document.forms[0].src.options[document.forms[0].src.selectedIndex].value,document.forms[0].bLstRT2.options[document.forms[0].bLstRT2.selectedIndex].value);">
                </select>
            </td>
        </tr>
        <tr><td id="div07" colspan="2" align="right">Filter by:</td>
            <td id="div08" colspan="4" align="left">
                <select name="bLstRT3">
                </select>
            </td>
        <!-- + Jun.14.2007 ends -->
        <tr><td colspan="6">&nbsp</td></tr>

</form>

<!-- debug area  + 06.Jun.2007 starts -->
<!--
<table border=1><tr><th>element</th><th>name</th><th>type</th><th>value</th>
<script language="javascript" type="text/javascript">
for (var i=0;i<document.forms[0].length;i++)
{
	current = document.forms[0].elements[i];
	document.write('<tr><td>' + i);
	document.write('<td>' + current.name);
	document.write('<td>' + current.type);
	document.write('<td>' + current.value + '</tr>');
}
</script>
</table>
-->

<div id="DEBUG">
<br><br>    
</div>

</body>
</html>
<%@ include file="includes/footer.jsp" %>
