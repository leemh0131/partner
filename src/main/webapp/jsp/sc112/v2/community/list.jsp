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
                                    $(".list-item").each(function () {
                                        const href = $(this).attr("href");
                                        // "/sc112/community/detail" 는 하드코딩 공통코드에서 location.search 추가가능
                                        $(this).attr("href", "/sc112/community/detail" + location.search + href);
                                    });
                                }
                            });
                        </script>
                    </div>
                    <div class="bookmark"><img src="/jsp/sc112/v2/assets/img/ic_star.svg"></div>
                    <div class="sort">
                        <select>
                            <option>최신순</option>
                        </select>
                    </div>
                </div>
                <div class="list">
                    <ul class="item notice">
                        <li class="title">
                            <a href="/sc112/dm/detail?DM_CD=111111111">
                                <span class="cate cate001">공지</span>
                                <span class="subject">OOOO에게 피해를 당했습니다.</span>
                                <span class="reply">(92)</span>
                                <span class="icon icon_new"></span>
                                <!--<span class="like on">12</span>-->
                            </a>
                        </li>
                        <li class="writer">김OO</li>
                        <li class="view">1,524,000회</li>
                        <li class="date">2023-08-27 14:22</li>
                    </ul>
                    <c:forEach var="item" items="${list}">
                        <ul class="item">
                            <li class="num">${item.COMM_NUM}</li>
                            <li class="title">
                                <a class="list-item" href="&SEQ=${item.SEQ}">
                                    <span class="subject"><c:out value="${item.TITLE}" /></span>
                                    <span class="reply">(${item.COMM_CUT})</span>
                                    <!-- NEW 표시 조건 -->
<%--                                    <c:if test="${item.NEW_YN eq 'Y'}">--%>
                                        <span class="icon icon_new"></span>
<%--                                    </c:if>--%>
                                </a>
                            </li>
                            <!-- 작성자 (WRITE_IP) -->
                            <li class="writer"><c:out value="${item.NAME}" />
                            <!-- 조회수 VIEW_CNT -->
                            <li class="view"><fmt:formatNumber value="${item.HIT}" pattern="#,###" />회</li>
                            <!-- 날짜 (INSERT_DATE: 20240518211046 → yyyy-MM-dd HH:mm) -->
                            <li class="date"><c:out value="${item.DTS}" /></li>
                        </ul>
                    </c:forEach>

                </div>

                 <div class="bottom">
                     <div class="pager" id="pagination">
                        <%--<a href="#" class="start"></a>
                        <a href="#" class="prev"></a>
                        <a href="#" class="current">1</a>
                        <a href="#">2</a>
                        <a href="#">3</a>
                        <a href="#">4</a>
                        <a href="#">5</a>

                        <a href="#" class="next"></a>
                        <a href="#" class="end"></a>--%>
                    </div>
                    <div class="button">
                        <a href="#" class="btn btn_01">글쓰기</a>
                    </div>
                </div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
<script type="text/javascript">
    var totalCount  = parseInt('${totalCount}'  || '0');
    var currentPage = parseInt('${page}'        || '1');
    var pageSize    = parseInt('${pageSize}'    || '10');
    var totalPages  = Math.ceil(totalCount / pageSize);

    function renderPagination() {
        if (totalPages <= 0) {
            document.getElementById('pagination').innerHTML = '<a href="#" class="current">1</a>';
            return;
        }

        var html = '';

        // 처음으로 (start)
        if (currentPage > 1) {
            html += '<a href="?page=1&pageSize=' + pageSize + '" class="start"></a>';
        } else {
            html += '<a href="#" class="start disabled"></a>';
        }

        // 이전 (prev)
        if (currentPage > 1) {
            html += '<a href="?page=' + (currentPage - 1) + '&pageSize=' + pageSize + '" class="prev"></a>';
        } else {
            html += '<a href="#" class="prev disabled"></a>';
        }

        // 숫자 5개 (앞뒤 2개씩 고정)
        var startPage = Math.max(1, currentPage - 2);
        var endPage   = Math.min(totalPages, currentPage + 2);

        // 5개 부족하면 보정
        if (endPage - startPage + 1 < 5) {
            if (currentPage <= 3) {
                endPage = Math.min(totalPages, 5);
            } else {
                startPage = Math.max(1, totalPages - 4);
                endPage = totalPages;
            }
        }

        for (var i = startPage; i <= endPage; i++) {
            if (i == currentPage) {
                html += '<a href="#" class="current">' + i + '</a>';
            } else {
                html += '<a href="?page=' + i + '&pageSize=' + pageSize + '">' + i + '</a>';
            }
        }

        // 다음 (next)
        if (currentPage < totalPages) {
            html += '<a href="?page=' + (currentPage + 1) + '&pageSize=' + pageSize + '" class="next"></a>';
        } else {
            html += '<a href="#" class="next disabled"></a>';
        }

        // 끝으로 (end)
        if (currentPage < totalPages) {
            html += '<a href="?page=' + totalPages + '&pageSize=' + pageSize + '" class="end"></a>';
        } else {
            html += '<a href="#" class="end disabled"></a>';
        }

        document.getElementById('pagination').innerHTML = html;
    }

    window.onload = renderPagination;
</script>
</body>

</html>
