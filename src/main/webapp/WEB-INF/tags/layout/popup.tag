    <%@ tag import="com.chequer.axboot.core.utils.ContextUtil" %>
        <%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
<%
 response.setHeader("Cache-Control","no-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",0);
%>
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv="Expires" content="-1"/>
        <meta http-equiv="Pragma" content="no-cache"/>
        <meta http-equiv="Cache-Control" content="no-cache"/>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport"
        content="width=1024, user-scalable=yes, initial-scale=1, maximum-scale=1, minimum-scale=1"/>
        <meta name="apple-mobile-web-app-capable" content="yes">
        <title>${pageName}</title>

        <link rel="shortcut icon" href="<c:url value='/assets/favicon.ico'/>" type="image/x-icon"/>
        <link rel="icon" href="<c:url value='/assets/favicon.ico'/>" type="image/x-icon"/>

        <c:forEach var="css" items="${config.extendedCss}">
            <link rel="stylesheet" type="text/css" href="<c:url value='${css}'/>"/>
        </c:forEach>

        <script type="text/javascript">
        var CONTEXT_PATH = "<%=ContextUtil.getContext()%>";
        var SCRIPT_SESSION = (function(json){return json;})(${loginUser});
        </script>
        <script type="text/javascript" src='/assets/js/plugins.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/common.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/axboot/dist/axboot.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/axboot.config.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/attrchange.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/bluebird.js?v=<%=System.currentTimeMillis()%>'></script>
        <link rel="stylesheet" type="text/css" href="/assets/css/font-awesome.min.css">
        <link rel="stylesheet" type="text/css" href="/assets/css/axboot.css">
        <link rel="stylesheet" href="/assets/css/content.css" type="text/css">
        <link href="/assets/css/layout.css?v=<%=System.currentTimeMillis()%>" rel="stylesheet" type="text/css"/>
        <jsp:invoke fragment="css"/>
        <jsp:invoke fragment="js"/>
        </head>
        <body class="ax-body ${axbody_class}" data-page-auto-height="${page_auto_height}">
	      	<div id="ax-base-root" data-root-container='true'>
		        <section class="popup" style="background:#fff;">
		            <div class="popup-head">
		                <p class="popup-name">${title}</p>
		                		<button style="cursor: pointer;" class="popup-close">
		                			<img src="/assets/images/common/ico_close_b.svg" alt="">
		                		</button>
		                </div>
		            <div class="popup-container">
		    			<jsp:doBody/>
		    		</div>
		        </section>
	        </div>
        
        <jsp:invoke fragment="script"/>
        </body>
        </html>
        
        
        <script type="text/javascript">

            
			$(document).ready(function(){
				$(".popup-close").click(function(){
					fnObj.popView.close.call(parent[window.param.modalName]);
					//parent[window.param.modalName].close()
				});
			})
    		
        </script>