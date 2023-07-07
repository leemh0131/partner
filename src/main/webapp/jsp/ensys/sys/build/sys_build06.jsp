<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="실시간로그"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="dashBoard">
<jsp:attribute name="script">

<script type="text/javascript" >
    function popup(){
        var url = "/jsp/ensys/sys/build/sys_build06_popup01.jsp";
        var name = "popup";
        var option = "width = 1300, height = 850, top = 100, left = 200, location = no"
        window.open(url, name, option);
    }
</script>
</jsp:attribute>
<jsp:body>
    <div>
        <button type="button" onclick="popup()" class="btn btn-info" style="width:120px;float: right;margin-left: 2px">실시간 로그 확인</button>
    </div>
</jsp:body>
</ax:layout>
