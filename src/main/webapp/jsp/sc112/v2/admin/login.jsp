<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-container { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); width: 100%; max-width: 360px; }
        .login-container h2 { text-align: center; margin-bottom: 30px; color: #333; letter-spacing: 2px; }
        .form-group { margin-bottom: 15px; }
        input[type="text"], input[type="password"] {
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 16px; outline: none;
        }
        input:focus { border-color: #007bff; }
        .checkbox-group { margin-bottom: 20px; display: flex; align-items: center; font-size: 14px; color: #666; }
        .checkbox-group input { width: auto; margin-right: 8px; cursor: pointer; }
        button { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer; transition: background 0.3s; font-weight: bold; }
        button:hover { background: #0056b3; }
        .links { text-align: center; margin-top: 20px; font-size: 13px; color: #999; }
        .links a { color: #666; text-decoration: none; margin: 0 5px; }
        .links a:hover { text-decoration: underline; color: #007bff; }
    </style>
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
        $(document).ready(function() {
            // 아이디 저장 불러오기
            var savedId = localStorage.getItem("userId");
            if (savedId) {
                $("#userId").val(savedId);
                $("#idSave").prop("checked", true);
            }
        });

        function doLogin(e) {
            // 폼의 기본 submit 동작(페이지 이동)을 막습니다.
            e.preventDefault();

            var userId = $("#userId").val();
            var password = $("#password").val();

            // 아이디 저장 로직
            if ($("#idSave").is(":checked")) {
                localStorage.setItem("userId", userId);
            } else {
                localStorage.removeItem("userId");
            }

            // axboot.ajax 형식을 유지하여 서버의 @RequestBody(JSON) 처리와 맞춤
            axboot.ajax({
                method: "POST",
                url: "/api/login",
                data: JSON.stringify({
                    "companyCd": "1000",
                    "groupCd": "WEB01",
                    "ssoLogin": "Y",
                    "userId": userId,
                    "passWord": password
                }),
                callback: function (res) {
                    // 로그인 성공 시 페이지 새로고침 혹은 이동
                    location.href = "/sc112/admin/main";
                },
                options: {
                    onError: function (err) {
                        alert("로그인 정보가 올바르지 않습니다.");
                    }
                }
            });

            return false;
        }
    </script>
</head>
<body>
<div class="login-container">
    <h2>LOGIN</h2>

    <form id="loginForm" onsubmit="return doLogin(event);" autocomplete="off">
        <div class="form-group">
            <input type="text" id="userId" placeholder="아이디" required>
        </div>

        <div class="form-group">
            <input type="password" id="password" placeholder="비밀번호" required>
        </div>

        <div class="checkbox-group">
            <input type="checkbox" id="idSave">
            <label for="idSave">아이디 저장</label>
        </div>

        <button type="submit">로그인</button>
    </form>
</div>
</body>
</html>