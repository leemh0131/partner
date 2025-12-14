<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html>
<body id="wrap">
<%@ include file="/jsp/sc112/v2/header.jsp" %>
<main id="container">
    <div class="wrap">
        <section id="contain">
            <div id="bbs_list">
                <div class="banner mobile">
                    <a href="#">
                        <div class="tit">불법대부업 채무 맞춤 솔루션</div>
                        <div class="txt">불법대부업 채무조정 및 종결협의</div>
                    </a>
                </div>
                <div class="header">
                    <div class="title" id="menuTitle">
                        <script>
                            $(function () {
                                var $target = $("a[id*='" + location.pathname + location.search.replace(/&CURRENT_PAGE=\d+/, "").replace(/&KEYWORD=[^&]*/, "") + "']");
                                if ($target) {
                                    $("#menuTitle").text($target.text());
                                    $(".start, .prev, .current, .current2, .next, .end").each(function () {
                                        const href = $(this).attr("href");
                                        $(this).attr("href", location.pathname + location.search.replace(/&CURRENT_PAGE=\d+/, "").replace(/&KEYWORD=[^&]*/, "") + href);
                                    });
                                    $(".list-create").attr("href", "/sc112/dm/create");
                                    $(".list-item").each(function () {
                                        const href = $(this).attr("href");
                                        // "/sc112/dm/detail" 는 하드코딩 공통코드에서 location.search 추가가능
                                        $(this).attr("href", "/sc112/dm/detail" + location.search + href);
                                    });
                                }
                            });
                        </script>
                    </div>
                </div>
                <div class="list">
                    <c:forEach var="item" items="${list}">
                        <ul class="item">
                            <li class="num">${item.COMM_NUM}</li>
                            <li class="title">
                                <a class="list-item" href="&DM_CD=${item.DM_CD}">
                                    <span class="subject"><c:out value="${item.TITLE}"/></span>
                                    <span class="reply">(${item.COMM_CUT})</span>
                                    <!-- NEW 표시 조건 -->
                                    <c:if test="${item.NEW_VALUE eq 'Y'}">
                                        <span class="icon icon_new"></span>
                                    </c:if>
                                </a>
                            </li>
                            <!-- 작성자 (WRITE_IP) -->
                            <li class="writer">
                                    <c:out value="${item.NAME}"/>
                                <!-- 조회수 VIEW_CNT -->
                            <li class="view"><fmt:formatNumber value="${item.HIT}" pattern="#,###"/>회</li>
                            <!-- 날짜 (INSERT_DATE: 20240518211046 → yyyy-MM-dd HH:mm) -->
                            <li class="date"><c:out value="${item.DTS}"/></li>
                        </ul>
                    </c:forEach>
                </div>

                <div class="bottom">
                    <div class="pager" id="pagination">

                        <!-- 맨 처음 -->
                        <c:if test="${CURRENT_PAGE > 1}">
                            <a href="&CURRENT_PAGE=1" class="start"></a>
                        </c:if>

                        <!-- 이전 -->
                        <c:if test="${CURRENT_PAGE > 1}">
                            <a href="&CURRENT_PAGE=${CURRENT_PAGE - 1}" class="prev"></a>
                        </c:if>

                        <!-- 페이지 번호 -->
                        <c:forEach var="i" begin="${START_PAGE}" end="${END_PAGE}">
                            <c:choose>
                                <c:when test="${i == CURRENT_PAGE}">
                                    <a href="&CURRENT_PAGE=${i}" class="current">${i}</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="&CURRENT_PAGE=${i}" class="current2">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <!-- 다음 -->
                        <c:if test="${CURRENT_PAGE < TOTAL_PAGE}">
                            <a href="&CURRENT_PAGE=${CURRENT_PAGE + 1}" class="next"></a>
                        </c:if>

                        <!-- 맨 끝 -->
                        <c:if test="${CURRENT_PAGE < TOTAL_PAGE}">
                            <a href="&CURRENT_PAGE=${TOTAL_PAGE}" class="end"></a>
                        </c:if>
                    </div>
                    <div class="button">
                        <a href="" class="btn btn_01 list-create">글쓰기</a>
                    </div>
                </div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>

</html>
