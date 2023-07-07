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
        <script type="text/javascript" src='/assets/js/plugins.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/common.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/axboot/dist/axboot.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/axboot.config.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/component.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/attrchange.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/bluebird.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/jquery-ui.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/jquery.multi-draggable.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src="/assets/js/jquery.easing.min.js?v=<%=System.currentTimeMillis()%>"></script>
        <script type="text/javascript" src="/assets/js/jquery.nicescroll.js?v=<%=System.currentTimeMillis()%>"></script>

        <link rel="stylesheet" type="text/css" href="/assets/css/font-awesome.min.css?v=<%=System.currentTimeMillis()%>">
        <link rel="stylesheet" type="text/css" href="/assets/css/axboot.css?v=<%=System.currentTimeMillis()%>">
        <link rel="stylesheet" href="/assets/css/content.css?v=<%=System.currentTimeMillis()%>" type="text/css">
        <link rel="stylesheet" href="/assets/css/reset.css?v=<%=System.currentTimeMillis()%>" type="text/css">
        <link href="/assets/css/layout.css?v=<%=System.currentTimeMillis()%>" rel="stylesheet" type="text/css"/>


        <script type="text/javascript">
                var CONTEXT_PATH = "<%=ContextUtil.getContext()%>";
                var SCRIPT_SESSION = (function(json){return json;})(${loginUser});
                let COLUMN_INFORMATION = {}
                axboot.ajax({
                        type: "POST",
                        url: ["common", "getColumnInformation"],
                        async: false,
                        callback: function (res) {
                                let list = nvl(res.listResponse.list);
                                let result = new Object();
                                if(list != ''){
                                        for(let i = 0; i < list.length; i++){
                                                let obj = {
                                                        DATA_TYPE : list[i].DATA_TYPE,
                                                        MAX_LENGTH : list[i].MAX_LENGTH
                                                }
                                                result[list[i].COLUMN_NAME] = obj;
                                        }
                                }

                                COLUMN_INFORMATION = nvl(result, {});
                        }
                });

                $(document).ready(function(){
                        var verifyList = $('[verify="true"]');
                        for (var i = 0; i < verifyList.length; i++) {
                                var el = verifyList[i];
                                var elType = $(el).attr('el-type');
                                var elId = $(el).attr('verify-target');
                                if(elType == 'selectBox') {
                                        $('#'+elId).find('a').css('background','#ffe0cf');
                                }else if(elType == 'checkBox') {
                                        // elData = $('#' + elId).prop('checked') == true ? 'Y' : 'N';
                                }else if(elType == 'codepicker') {
                                        $('#'+elId).find('input').css('background','#ffe0cf');
                                }else if(elType == 'multipicker') {
                                        $('#'+elId).find('a').css('background','#ffe0cf');
                                }else if(elType == 'period-datepicker') {
                                        $('#'+elId).find('input').css('background','#ffe0cf');
                                }else if(elType == 'datepicker') {
                                        $('#'+elId).find('input').css('background','#ffe0cf');
                                }else if(elType == 'money') {
                                }else {
                                        $('#'+elId).css('background','#ffe0cf');
                                }
                        }
                })




        </script>

        <jsp:invoke fragment="css"/>
        <jsp:invoke fragment="js"/>
        </head>
        <body class="ax-body ${axbody_class}" data-page-auto-height="${page_auto_height}">
        <div id="ax-base-root" data-root-container="true">
        <div class="ax-base-title" role="page-title">
        <jsp:invoke var="headerContent" fragment="header"/>
        <c:if test="${empty headerContent}">
            <h1 class="title"><i class="cqc-browser"></i> ${title}</h1>
            <p class="desc">${pageRemark}</p>
        </c:if>
        <c:if test="${!empty headerContent}">
            ${headerContent}
        </c:if>
        </div>
        <div class="ax-base-content">
        <jsp:doBody/>
        </div>
        </div>
        <jsp:invoke fragment="script"/>
        </body>
        </html>