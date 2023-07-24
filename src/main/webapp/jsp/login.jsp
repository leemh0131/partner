<%@ page import="com.chequer.axboot.core.context.AppContextManager"%>
<%@ page import="com.ensys.qray.utils.SessionUtils"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags"%>
<%
	String lastNavigatedPage = null;
	String redirect = (String) request.getAttribute("redirect");
	String connect_company = (String) request.getAttribute("connect");

	if (SessionUtils.isLoggedIn()) {
		lastNavigatedPage = "/jsp/main.jsp";
		request.setAttribute("redirect", lastNavigatedPage);
	}
%>

<c:if test="${redirect!=null}">
	<c:redirect url="${redirect}" />
</c:if>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>로그인</title>
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="Content-Style-Type" content="text/css" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" href="/assets/css/reset.css" type="text/css">
<link rel="stylesheet" href="/assets/css/common.css" type="text/css">
<link rel="stylesheet" href="/assets/css/login.css" type="text/css">
<link rel="stylesheet" href="/assets/css/layout.css" type="text/css">
<link rel="stylesheet" href="/assets/css/axboot.css" type="text/css">
<script type="text/javascript" src="/assets/js/plugins.min.js"></script>
<script type="text/javascript" src="/assets/js/common/common.js"></script>
<script type="text/javascript" src="/assets/js/common/attrchange.js"></script>
<script type="text/javascript" src="/assets/js/axboot/dist/axboot.js"></script>
<script type="text/javascript" src="/axboot.config.js"></script>
<script type="text/javascript" src="http://jsgetip.appspot.com/?getip">
<script type="text/javascript" src="<c:url value='/assets/js/axboot/dist/good-words.js' />"></script>
<script type="text/javascript">
	var CONTEXT_PATH = "";
	var SCRIPT_SESSION = (function(json) {
		return json;
	})({
		"userCd" : null,
		"userNm" : null,
		"locale" : null,
		"timeZone" : null,
		"dateFormat" : null,
		"login" : false,
		"details" : {},
		"dateTimeFormat" : "null null",
		"timeFormat" : null
	});
</script>
<script type="text/javascript">

	var connect_company = '<%= connect_company  %>'

	axboot.requireSession('${config.sessionCookie}');
	var fnObj = {
		pageStart : function() {
			if (localStorage.getItem("companyCd") != null
					&& localStorage.getItem("groupCd") != null
					&& localStorage.getItem("userId") != null) {
				$("#companyCode").val(localStorage.getItem("companyCd"));
				$("#userId").val(localStorage.getItem("userId"));
				$("#groupCode").val(localStorage.getItem("groupCd"));
				$("#idSave").prop("checked", true);
			}

			if(connect_company != '' && connect_company != 'undefined' && connect_company != 'null'){
				$('#companyCode').val(connect_company);
			}
		}
		, joinUser : function() {
			$.openCommonPopup("/jsp/joinUser.jsp", '', '', '', {}, 1200, 1200);
		}
		, findId : function() {
			$.openCommonPopup("/jsp/findId.jsp", '', '', '', {}, 600, 600);
		}
		, findPw : function() {
			$.openCommonPopup("/jsp/findPw.jsp", '', '', '', {}, 600, 600);
		}
		, login : function() {
			axboot.ajax({
				method : "POST",
				url : "/api/login",
				data : JSON.stringify({
					"companyCd" : '1000',
					"groupCd" : 'WEB01',
					"userId" : $("#userId").val(),
					"passWord" : $("#password").val()
				}),
				callback : function() {
					if ($("#idSave").is(":checked")) {
						localStorage.companyCd = $("#companyCode").val();
						localStorage.groupCd = $("#groupCode").val();
						localStorage.userId = $("#userId").val()
					} else {
						localStorage.removeItem("companyCd");
						localStorage.removeItem("groupCd");
						localStorage.removeItem("userId");
					}
					location.reload();
				}
			});
		}
	};

	/*로그인 폼 UI 변경
	 *param S : SMS, L : Login
	 */
	function loginFormTogle(param) {
		var sms = '';
		var login = '';

		if(param == 'S') {
			login = 'none';
		}else if(param == 'L') {
			sms = 'none';
		}

		$('#passwordArea').css('display', login);
		$('#userIdArea').css('display', login);
		$('#login').css('display', login);

		$('#smsArea').css('display', sms);
		$('#verify').css('display', sms);
	}

	//엔터키 이벤트
	function enterLogin() {
		//키 이벤트
		if(window.event.keyCode == 13) {
			fnObj.login();
		}
	}
</script>
</head>

<body>
	<form name="login-form" class="register" method="post" action="/api/login" onsubmit="return fnObj.login();" autocomplete="off">
		<section class="login">
			<div class="trans"></div>
			<div class="login-warp">
				<p class="login-locataion">
					<b>Login</b><!--Expense Management System-->
				</p>
				<div class="login-form" style="height: 400px">
					<p class="logo">
						<%--<img src="/assets/images/login/img_logo.svg" alt="PARTNER">--%>
					</p>
					<p class="title"></p>
					<%--<div class="form-depth1">
						<label>
							<span>
								<img src="/assets/images/login/ico_server.svg" alt="Company">
							</span>
							<input type="text" id="companyCode" value="1000" placeholder="회사코드를 입력하세요.">>
						</label> 
						<label> 
							<span>
								<img src="/assets/images/login/ico_server2.svg" alt="Group">
							</span>
							<input type="text" id="groupCode" value="WEB01" placeholder="그룹코드를 입력하세요.">
						</label>
					</div>--%>

					<div class="form-depth2">
						<p id="userIdArea">
							<input type="text" name="userId" id="userId" placeholder="아이디를 입력하세요." onkeyup="enterLogin();">
						</p>
						<p id="passwordArea">
							<input type="password" name="password" id="password" placeholder="비밀번호를 입력하세요." onkeyup="enterLogin();">
						</p>
						<p id="smsArea" style="display: none">
							<input type="text" id="sms" smsKey= "" placeholder="인증번호를 입력하세요." >
						</p>
						<label class="check-wrap"> 
							<input type="checkbox" name="idSave" id="idSave"><b></b>
							<span>아이디 저장</span>
						</label>
						<div class="btn-wrap">
							<button type="button" onclick="fnObj.login();" id="login" class="btn-login">로그인</button>
						</div>
					</div>
				</div>
			</div>
		</section>
	</form>
</body>
</html>