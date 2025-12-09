<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="repeat" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="substring" uri="http://java.sun.com/jsp/jstl/functions" %>
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
                                var $target = $("a[id*='" + location.pathname + location.search + "']");
                                if ($target) {
                                    $("#menuTitle").text($target.text());
                                    $(".list-create").attr("href", "/sc112/community/create" + location.search);
                                    $(".list-item").each(function () {
                                        const href = $(this).attr("href");
                                        // "/sc112/community/detail" 는 하드코딩 공통코드에서 location.search 추가가능
                                        $(this).attr("href", "/sc112/community/detail" + location.search + href);
                                    });
                                }
                            });
                        </script>
                    </div>
                    <div class="sort">
                        <select>
                            <option>최신순</option>
                        </select>
                    </div>
                </div>
                <div class="list">
                    <%--<ul class="item notice">
                        <li class="title">
                            <a href="/sc112/dm/detail?DM_CD=111111111">
                                <span class="cate cate001">공지</span>
                                <span class="subject">OOOO에게 피해를 당했습니다.</span>
                                <span class="reply">(92)</span>
                                <span class="icon icon_new"></span>
                                <span class="like on">12</span>
                            </a>
                        </li>
                        <li class="writer">김OO</li>
                        <li class="view">1,524,000회</li>
                        <li class="date">2023-08-27 14:22</li>
                    </ul>--%>

                    <c:forEach var="item" items="${list}">
                        <ul class="item">
                            <li class="num">${item.COMM_NUM}</li>
                            <li class="title">
                                <a class="list-item" href="&SEQ=${item.SEQ}">
                                    <span class="subject"><c:out value="${item.TITLE}"/></span>
                                    <span class="reply">(${item.COMM_CUT})</span>
                                    <!-- NEW 표시 조건 -->
                                        <%--                                    <c:if test="${item.NEW_YN eq 'Y'}">--%>
                                    <span class="icon icon_new"></span>
                                        <%--                                    </c:if>--%>
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
            <a href="?page=1" class="start"></a>
        </c:if>

        <!-- 이전 -->
        <c:if test="${CURRENT_PAGE > 1}">
            <a href="?page=${CURRENT_PAGE - 1}" class="prev"></a>
        </c:if>

        <!-- 페이지 번호 -->
        <c:forEach var="i" begin="${START_PAGE}" end="${END_PAGE}">
            <c:choose>
                <c:when test="${i == CURRENT_PAGE}">
                    <a href="#" class="current">${i}</a>
                </c:when>
                <c:otherwise>
                    <a href="?page=${i}">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <!-- 다음 -->
        <c:if test="${CURRENT_PAGE < TOTAL_PAGE}">
            <a href="?page=${CURRENT_PAGE + 1}" class="next"></a>
        </c:if>

        <!-- 맨 끝 -->
        <c:if test="${CURRENT_PAGE < TOTAL_PAGE}">
            <a href="?page=${TOTAL_PAGE}" class="end"></a>
        </c:if>

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
