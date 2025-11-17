<%@ page language="java" contentType="text/html;charset=utf-8" 
%><%@ page import="java.net.Proxy" 
%><%@ page import="SmarTone.HttpConnect" 
%><%@ page import="org.json.*,java.util.regex.*,java.util.*,java.io.*,org.json.*,java.text.*,java.net.*,java.sql.*,java.util.Calendar,java.util.Date,java.util.regex.Matcher,java.util.regex.Pattern,java.text.SimpleDateFormat,java.util.Date,pos.online_store.*,java.util.HashMap,java.util.regex.Matcher,java.util.regex.Pattern,org.apache.commons.io.IOUtils,java.security.MessageDigest,java.nio.charset.StandardCharsets,java.math.BigInteger,javax.servlet.http.Cookie,java.time.LocalDate,java.time.format.DateTimeFormatter" 
%><%@ page import="JGlobal.JGlobalFunction" 
%><%@ page import="SmarTone.API_error" 
%><%@ page import="SmarTone.APIcommon"
%><%@ page import="SmarTone.eCommMaster"
%><%@ page import="SmarTone.EndPoint"
%><%@ page import="SmarTone.Payment_common_function"
%><%@ page import="SmarTone.EcommGuestCrmHelper"
%>
<%@ page import="om.soap.OMAPIMsisdnServiceHelper"
%><%@ include file="/jsp/common.inc" 
%><%@ include file="/jsp/smt-common-ui/smt-common-ui-component.jsp" 
%><jsp:useBean id="Corpweb_Logger" class="SmarTone.Logger" scope="application">
<jsp:setProperty name="Corpweb_Logger" property="sLogPath" value="/home/webdev/CorpWeb/Logger/"/>
<jsp:setProperty name="Corpweb_Logger" property="bRequiredLabel" value="false"/>
</jsp:useBean><%
response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", 0);

String sAPIName = "test_corpweb-cms-api";

String sCMSApiURL = "https://cmsapi.smartone.com/corpweb/v1/content/pages/home";

try {
    String sPageUrl ="testing";
    JSONObject joApiSetup = SmtUI_getApiSetup(request,sServerMode);
//    String sApi = joApiSetup.optString("apiDomain") + "page?where[pageUrl][equals]=" + sPageUrl + "&depth=3&draft="+joApiSetup.optString("draft")+"&locale=" + "zh-HK";    

//    JSONObject joRes = SmtUi_getCmsData(request, response, sServerMode, Corpweb_Logger, sApi, joApiSetup.optString("authKey"), joApiSetup.optString("authToken"));
//out.println(joRes.toString());

    String getAPIURL = om.soap.OMAPIMsisdnServiceHelper.S_ENDPOINT_UAT;
    

    String sCustomerType = "Ecomm";
    //String sCustomerType = "POSTPAID";
    String sEmail ="";
    String sSubrNum ="97204501";
    String sCustNum ="";
    String sLoginId = "9500f8e9a23a04bd7087d5390fb957fe";
    String sLoginId_dec = SmarTone.eCommMaster.decrypt(sLoginId);
    String sCustId = "0ac2fbc7e455636269c505e80cd9062c";
    String sCustId_dec = SmarTone.eCommMaster.decrypt(sCustId);

    String sUserIdType = (sCustomerType.equals("Ecomm")? "email" : "cust_num");
    String sUserId = (sCustomerType.equals("Ecomm")? sEmail : sSubrNum);

    String sLogKey = "custId:"+sCustId_dec+"|customerType:"+sCustomerType+"|subrNum:"+sSubrNum+"|loginid:"+sLoginId_dec;   
    
    if ("Ecomm".equals(sCustomerType)){
        JSONObject joEpcCrmOnlineInfo_log = new JSONObject();
        JSONObject joEpcCrmOnlineInfo_input = new JSONObject();
        joEpcCrmOnlineInfo_input.put("requesterId","OnlineStore");    
        joEpcCrmOnlineInfo_input.put("eCommId",sLoginId_dec);
        joEpcCrmOnlineInfo_input.put("encrypted","N");
        joEpcCrmOnlineInfo_log.put("input",joEpcCrmOnlineInfo_input);
        JSONObject joEpcCrmOnlineInfo_response = EcommGuestCrmHelper.epcCrmOnlineInfo(joEpcCrmOnlineInfo_input);
        joEpcCrmOnlineInfo_log.put("response",joEpcCrmOnlineInfo_response);
        Corpweb_Logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + "|"+sLogKey+"|EcommGuestCrmHelper.epcCrmOnlineInfo|input:"+joEpcCrmOnlineInfo_input+"|response:"+joEpcCrmOnlineInfo_response);    
        if (joEpcCrmOnlineInfo_response==null||joEpcCrmOnlineInfo_response.length()<=0) throw new Exception("EcommGuestCrmHelper.epcCrmOnlineInfo return empty");
        sEmail = joEpcCrmOnlineInfo_response.optString("email");
        Corpweb_Logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + "|"+sLogKey+"|EcommGuestCrmHelper.epcCrmOnlineInfo|"+joEpcCrmOnlineInfo_log);    
    }

    JSONObject jEndPointDetails = EndPoint.GetEndPointDetails(request,"CwCmsQueryPayMethodVipList");
    JSONObject jPara = jEndPointDetails.optJSONObject("para");

    String sApi = joApiSetup.optString("apiDomain") + "accessControl?where[name][equals]=" + URLEncoder.encode(jPara.optString("paramName"), StandardCharsets.UTF_8.toString());
    //String sApi = joApiSetup.optString("apiDomain") + "accessControl?where[name][equals]=" + "Testing%20Whitelist";
        sApi += "&where[accessItems.accessItemType][equals]=" + sUserIdType;
        sApi += "&where[accessItems.accessItemValue][equals]=" + sUserId;
        sApi += "&select[accessType]=true";
        sApi += "&draft=" + String.valueOf(jPara.optBoolean("paramDraft"));

    Corpweb_Logger.WriteLog(GetClientIP(request), "SmtUi_getCmsData|url:"+sApi, System.getProperty("user.dir"));

    JSONObject joRes = SmtUi_getCmsData(request, response, sServerMode, Corpweb_Logger, sApi, joApiSetup.optString("authKey"), joApiSetup.optString("authToken"));
out.println(joRes.toString());
out.println(getAPIURL);
out.println("<br/>");
out.println("<br/>");

    JSONObject joResponse = queryCorpwebCmsVipWhitelist(request, Corpweb_Logger, sCustomerType, sSubrNum, sCustNum, sEmail);
    out.println(joResponse.toString());

    


/*
    JSONObject jEndPointDetails = EndPoint.GetEndPointDetails(request, "CwCmsQueryPayMethodVipList");
    //out.println(jEndPointDetails);
    JSONObject joEndPointDetailsPara = jEndPointDetails.optJSONObject("para");
    

    JSONObject joConnectCorpwebCMS_input = new JSONObject();
        joConnectCorpwebCMS_input.put("apiURL", sCMSApiURL);
        joConnectCorpwebCMS_input.put("authKey", "your_auth_key");
        joConnectCorpwebCMS_input.put("authToken", "your_auth_token");
    JSONObject joConnectCorpwebCMS_output = new JSONObject();

    JSONObject joApiSetup = SmtUI_getApiSetup(request,sServerMode);
    String sApi = joApiSetup.optString("apiDomain") + "page?where[name][equals]=" + joEndPointDetailsPara.optString("paramName") + "&where[accessItems.accessItemType][equals]=3&draft="+joApiSetup.optString("draft")+"&locale=" + sLocale;

    JSONObject joRes = SmtUi_getCmsData(request, response, sServerMode, Corpweb_Logger, sApi, joApiSetup.optString("authKey"), joApiSetup.optString("authToken"));
    
    JSONArray jaResponse = connectCorpwebCMS(request, response, sServerMode, Corpweb_Logger, joConnectCorpwebCMS_input, joConnectCorpwebCMS_output);
*/
} catch (Exception e) {
    Corpweb_Logger.WriteLog(GetClientIP(request), "SmtUi_getPageContent|sPageUrl is null or empty", System.getProperty("user.dir"));
    out.println("<h2>Error Occurred</h2>");
    out.println("<p>" + e.getMessage() + "</p>");
}

%><%!
//Ref: from EPC Core: \src\main\java\com\smc\ocsf\core\service\PaymentService.java
public JSONObject queryCorpwebCmsVipWhitelist(HttpServletRequest request, SmarTone.Logger logger, String sCustomerType, String sSubrNum, String sCustNum, String sEmail){
    final String sFunc = "queryCorpwebCmsVipWhitelist";
    //final String CMS_API_DOMAIN = "https://corpweb-cms-uat.smartone.com";    //FIXME set according to environment
    //final String CMS_API_KEY = "cc04539c-52dd-46c7-9c5b-bd8f368374c8";       //FIXME set according to environment
    //final boolean DRAFT = true;                                              //FIXME set according to environment
    //final String CMS_API_URI = "/api/accessControl";
    //ENUM
    final String CUST_N_SUBR = "cust_num";
    final String EMAIL = "email";

    // get EndPoint and parameters
    JSONObject jEndPointDetails = EndPoint.GetEndPointDetails(request,"CwCmsQueryPayMethodVipList");
    JSONObject jPara = jEndPointDetails.optJSONObject("para");

    //String sName = "Testing Whitelist";
    
    String sUserIdType = (sCustomerType.equals("Ecomm")? EMAIL : CUST_N_SUBR);
    String sUserId = (sCustomerType.equals("Ecomm")? sEmail : sSubrNum);

    boolean bResultVipCust = false;
    boolean bConnectSuccess = false;
    URI uri = null;
    int responseCode = -1;
    StringBuilder sbResponse = null;
    JSONObject jResponse = null;
    String sErrMsg = "";
    HttpURLConnection conn = null;
    try {
      // URL connect to corpweb CMS
      // e.g. https://corpweb-cms-uat.smartone.com/api/accessControl?where[name][equals]=Testing Whitelist&where[accessItems.accessItemValue][equals]=55994905&where[accessItems.accessItemType][equals]=cust_num&select[accessType]=true&draft=false
            //uri = UriComponentsBuilder.fromUriString(CMS_API_DOMAIN).path(CMS_API_URI)
    String sName = URLEncoder.encode(jPara.optString("paramName"), StandardCharsets.UTF_8.toString());
      String sApi = jEndPointDetails.optString("endpoint") + "?where[name][equals]=" + sName;
        sApi += "&where[accessItems.accessItemType][equals]=" + sUserIdType;
        sApi += "&where[accessItems.accessItemValue][equals]=" + sUserId;
        sApi += "&select[accessType]=true";
        sApi += "&draft=" + String.valueOf(jPara.optBoolean("paramDraft"));
      
      logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + "connectCorpwebCMS|debug url|" + sApi);            
      URL url = new URL(sApi);
/*     
    conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");
    conn.setRequestProperty(jPara.optString("cmsHeaderName"), jPara.optString("cmsHeaderValue"));
    conn.setRequestProperty("Accept", "application/json");
    //conn.setConnectTimeout(5000);
    //conn.setReadTimeout(5000);

    int conResponseCode = conn.getResponseCode();
    InputStream inputStream = null;

    if (conResponseCode == HttpURLConnection.HTTP_OK) {
        inputStream = conn.getInputStream();
    } else {
        inputStream = conn.getErrorStream(); // fallback for error responses
        logger.WriteLog(GetClientIP(request), "SmtUi_getCmsData|GET failed with response code: " + conResponseCode, System.getProperty("user.dir"));
    }

    if (inputStream != null) {
        BufferedReader in = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
        StringBuilder conResponse = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            conResponse.append(inputLine);
        }
        in.close();

        joRes = new JSONObject(conResponse.toString());
    }else {
        logger.WriteLog(GetClientIP(request), "SmtUi_getCmsData|InputStream is null", System.getProperty("user.dir"));
    }
*/

      //URL url = uri.toURL();

      // Open connection
       conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty(jPara.optString("cmsHeaderName"), jPara.optString("cmsHeaderValue"));

      //conn.setRequestProperty("Accept", "application/json");

            // Check response code
            responseCode = conn.getResponseCode();

      // Read response
      BufferedReader in = null;
      if (responseCode == 200) {
        in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      }
      else {
        in = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
      }
            String inputLine;
            sbResponse = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                sbResponse.append(inputLine);
            }
            in.close();    
      logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + "connectCorpwebCMS|connectResponse|" + responseCode + "|" + sbResponse.toString());              

      try {
        jResponse = new JSONObject(sbResponse.toString());
      }
      catch (Exception e) {
        throw new Exception("parseJsonException");
      }

      // parse success response
      if (responseCode == 200) {
        int count = jResponse.optInt("totalDocs", -1);
        if (count == 1) {
          bResultVipCust = true;
        } else if (count == 0) {
          bResultVipCust = false;
        } else if (count > 1) {
            logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + sFunc + "|checkCountOverOneWarning|custType: " + sCustomerType + "|subrNum: " + sSubrNum + "|custNum: " + sCustNum + "|email: " + sEmail + "|name: " + sName + "|userIdType: " + sUserIdType + "|userId: " + sUserId);                        
          //sendAlertEmail(name, userIdType, userId, count);
          bResultVipCust = true;
          sErrMsg = "[ALERT] ACL '" + sName + "' for userIdType '" + sUserIdType + "' and userId '" + sUserId + "' returned count: " + count;
        } else {
          throw new RuntimeException("Invalid response from CMS. count: "  + count);
        }

        bConnectSuccess = true;
      }

    } catch (Exception e) {
      StringWriter sw = new StringWriter();
      e.printStackTrace(new PrintWriter(sw));
      logger.WriteLog(JGlobalFunction.GetRemoteIP_V2(request), request.getRequestURI() + sFunc + "|httpConnectException|" + sCustomerType + "|" + sSubrNum + "|" + sCustNum + "|" + sEmail + "|" + e + "|" + e.getStackTrace()[0].toString() + "|" + e.getStackTrace()[1].toString() + "|" + sw.toString());                              
      sErrMsg = e.toString();
    }
    finally {
      if (conn != null) {
        conn.disconnect();
      }
    }

    JSONObject jRepsonse = new JSONObject();
        jRepsonse.put("status", bConnectSuccess? "ok" : "fail");
        jRepsonse.put("bResultVipCust", bResultVipCust);
        jRepsonse.put("err_msg", sErrMsg);
        jRepsonse.put("requestUrl", (uri==null? "" : uri.toString()));
        jRepsonse.put("response", (sbResponse==null? "" : (jResponse==null? sbResponse.toString() : jResponse)) );
        jRepsonse.put("responseCode", responseCode);
    return jRepsonse;
}
 
%>
