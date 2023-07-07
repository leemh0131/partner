<%@ page import="com.ensys.qray.utils.SessionUtils"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Base64.Encoder" %>
<%@ page import="java.util.Base64.Decoder" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.io.Reader" %>
<%@ page import="org.apache.ibatis.io.Resources" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags"%>
<script type="text/javascript" src="/assets/js/plugins.min.js"></script>
<script type="text/javascript" src="/assets/js/common/common.js"></script>
<script type="text/javascript" src="/assets/js/common/attrchange.js"></script>
<script type="text/javascript" src="/assets/js/axboot/dist/axboot.js"></script>
<script type="text/javascript" src="/axboot.config.js"></script>

<%--http://qray.daebogroup.com:8004/sso/login.jsp--%>
<%
    /**
     * agentProc - 인증이 완료된 후 호출 되는 페이지
     */
    String lastNavigatedPage = null;

    // 인코딩 테스트용 text
    String text = "2000|211611004|20220525104300";
    //String text = "MjAyMDEyMDEwMXwyMDIxMTIwOTE2MDE=";
    byte[] targetBytes = text.getBytes();

    // Base64 인코딩 /////////////////////////////////////////////////////
    Encoder encoder = Base64.getEncoder();
    byte[] encodedBytes = encoder.encode(targetBytes);
    // Base64 디코딩 /////////////////////////////////////////////////////
    Decoder decoder = Base64.getDecoder();
    byte[] decodedBytes = decoder.decode(encodedBytes);


    /*String test2 = "MjAwMHwyMTE2MTEwMDR8MjAyMjA1MjUwOTA5MjQ";
    byte[] decodedBytes2 = decoder.decode(test2);*/


    System.out.println("인코딩 전 : " + text);
    System.out.println("인코딩 text : " + new String(encodedBytes));
    System.out.println("디코딩 text : " + new String(decodedBytes));
    /*System.out.println("디코딩2 text : " + new String(decodedBytes2));*/

    String key = (String) request.getParameter("key");
    String resultCode = "";
    String id= "";
    String sessionId = "";
    String companyCd = "";
    if(key != null) {

        String DB_URL = null;
        String DB_USER = "qray";
        String DB_PASSWORD= "qray";

        try {
            Reader reader = Resources.getResourceAsReader("axboot-local.properties");
            Properties properties = new Properties();
            properties.load(reader);
            DB_URL = properties.getProperty("axboot.dataSource.url").toLowerCase();
        } catch (IOException e) {
            e.printStackTrace();
        }

        Connection conn;
        Statement stmt;
        ResultSet re;

        //디코딩
        key = new String(decoder.decode(key.getBytes()));
        String[] splitKey = key.split("\\|");
        companyCd = splitKey[0];
        String empNo = splitKey[1];
        String sql = "select user_id from es_user where company_cd = '" + companyCd + "' and emp_no = '" + empNo + "'";

        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            stmt = conn.createStatement();
            //out.println("postgresql jdbc test: connect ok!!")
            re = stmt.executeQuery(sql);
            while (re.next()){
                //companyCd = re.getString("company_cd");
                id = re.getString("user_id");
            }
            System.out.println("re : " + re);
            conn.close();
        } catch(Exception e) {
            out.println(e.getMessage());
        }

        System.out.println("sql : " + sql);

        sessionId = (String) session.getAttribute("sessionId");
        System.out.println("sessionId : " + sessionId);
        //id = splitKey[0];
        System.out.println("Id : " + id);

        if(sessionId != null && !id.equals(sessionId)) {  //같지 않으면 초기화
            session.invalidate();
        }
        if(session != null && request.isRequestedSessionIdValid()) {
            session.setAttribute("sessionId", id);
        }


        //현재시간
        Date currentDate = new Date();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");

        //시간
        Date secondKey = dateFormat.parse(splitKey[2]);

        long currnetTime = currentDate.getTime();
        long keyTime = secondKey.getTime();

        long minute = (currnetTime - keyTime) / 60000;

        System.out.println("분 : " + minute);
        if(minute < 5) {
            resultCode = "000000";
        } else {
            resultCode = "999999";
        }

        System.out.println("resultCode : " + resultCode);
    } else {
        resultCode = "999999";
    }


    /**
     *  TODO - 결과 코드가 성공이라면 인증 처리 페이지로 리다이렉션 처리
     *      업무 처리 페이지 안에서 세션에 사용자 정보를 취득하여 SSO 연동 작업을 한다.
     */
    System.out.println("로그인 : " + SessionUtils.isLoggedIn());
    if (SessionUtils.isLoggedIn()) {
        System.out.println("로그인 성공");
        lastNavigatedPage = "/jsp/main.jsp";
        request.setAttribute("redirect", lastNavigatedPage);
    } else {
        if(session != null && request.isRequestedSessionIdValid()){
            lastNavigatedPage = (String)session.getAttribute("redirect");
        }
        request.setAttribute("redirect", lastNavigatedPage);
    }



    //if ("000000".equals(resultCode)) {
//     	HttpPost httpPost = null;
//         CloseableHttpClient httpClient = HttpClients.createDefault();
%>


<%
    //session.invalidate();
    if ("000000".equals(resultCode)) {

%>
<c:if test="${redirect!=null}">
    <c:redirect url="${redirect}" />
</c:if>
<%
    } else if("999999".equals(resultCode)) {
%>
    <c:redirect url="/jsp/login.jsp" />
<%
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <style>
        table {
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid;
        }
    </style>

    <script>
        var CONTEXT_PATH = "";
        var resultCode = "<%=resultCode%>";
        var id = "<%=id%>";
        var companyCd = "<%=companyCd%>";
        // if (resultCode !== "000000" && "" !== resultMessage) {
        //     alert(resultMessage);
        // }

        if(resultCode === "000000") {

        }


        if(resultCode === "000000") {
            axboot.ajax({
                method : "POST",
                url : "/api/login",
                data : JSON.stringify({
                    "companyCd" : companyCd,
                    "groupCd" : "WEB01",
                    "userId" : id,
                    "ssoLogin" : "Y"
                }),
                async :false,
                callback : function(res) {

                    if (res && res.error) {
                        if (res.error.message == "Unauthorized") {
                            alert("로그인에 실패 하였습니다. 계정정보를 확인하세요");
                        } else {
                            qray.alert(res.error.message);
                        }

                    } else {
                        if ($("#idSave").is(":checked")) {
                            localStorage.companyCd = $("#companyCode")
                                .val();
                            localStorage.groupCd = $("#groupCode").val();
                            localStorage.userId = $("#userId").val()
                        } else {
                            localStorage.removeItem("companyCd");
                            localStorage.removeItem("groupCd");
                            localStorage.removeItem("userId");
                        }
                        location.reload();
                    }
                },
                options : {
                    nomask : false,
                    apiType : "login"
                }
            });
        }
    </script>

</head>
<body>
<%--<input type="button" onclick="javascript:location.href='<%=LOGOUT_PAGE%>'" style="cursor:hand" value="로그아웃" />--%>
<%--<input type="button" onclick="javascript:location.href='<%=PORTAL_PAGE%>?agentId=<%=agentId%>'" style="cursor:hand" value="사용자포털" />--%>
<%--<input type="button" onclick="javascript:location.href='<%=PKI_REGIST_PAGE%>?agentId=<%=agentId%>'" style="cursor:hand" value="PKI 등록" />--%>
<!-- <input type="button" onclick="return login()" style="cursor:hand" value="임시 호출" /> -->

<!-- <form method="post" action="/api/login" onsubmit="return login();"> -->
<!-- 	<button type="submit" class="btn-login">로그인</button>	 -->
<!-- </form> -->
<!-------------------------------------------------
  [ 세션 목록 리스팅 ]
  ------------------------------------------------->

<h2>등록되지 않은 사용자거나 url세션시간이 잘못되었습니다.</h2>
<h2>시스템관리자에게 문의하세요</h2>

<%--local--%>
<a href="http://localhost:8080/jsp/login.jsp">로그인페이지로 이동</a>

<%--sever--%>
<%--<a href="http://localhost:8080/jsp/login.jsp">로그인페이지로 이동</a>--%>

<%--<table>--%>
<%--    <tr>--%>
<%--        <th>Key</th>--%>
<%--        <th>Value</th>--%>
<%--    </tr>--%>
<%--    <tr>--%>
<%--        <td>Agent Id</td>--%>
<%--&lt;%&ndash;        <td><%=agentId%></td>&ndash;%&gt;--%>
<%--    </tr>--%>

<%--    <%--%>
<%--        Enumeration e = session.getAttributeNames();--%>
<%--        while (e.hasMoreElements()) {--%>
<%--            String name = e.nextElement().toString();--%>
<%--            String attrName = String.valueOf(session.getAttribute(name));--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <td bgcolor="#ffffff" width="30%"><%=name%></td>--%>
<%--        <td bgcolor="#dddddd"><%=attrName%></td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>

<%--</table>--%>


</body>
</html>