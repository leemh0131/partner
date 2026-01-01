<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html>
<body id="wrap">
<%@ include file="/jsp/sc112/v2/header.jsp" %>
<main id="container">
    <div class="wrap">
        <section id="contain">
            <div class="solution order2 mobile">
                <c:forEach var="item" items="${commonLink}" varStatus="status">
                    <a href="${item.LINK}" target="_blank"><img class="inner ${item.TABLE_ID}" src="${item.IMG_URL}" alt="설명"></a>
                </c:forEach>
            </div>
            <div id="bbs_consult">
                <div class="header">
                    <div class="title">공지사항</div>
                </div>
                <div class="inquiry" style="padding: 0px">
                    <div class="list">
                        <ul>
                        <c:forEach var="item" items="${list}" varStatus="status">
                            <li>
                                <div class="head">
                                    <div class="num">${fn:length(list) - status.index}</div>
                                    <div class="type">공지사항</div>
                                    <div class="name">
                                        <span class="subject">${item.TITLE}</span>
                                    </div>
                                    <div class="arrow"></div>
                                </div>
                                <div class="cont">${item.CONTENTS}
                                </div>
                            </li>
                        </c:forEach>
                            <%--<li>
                                <div class="head">
                                    <div class="num">10</div>
                                    <div class="type">법률상담문의</div>
                                    <div class="name">
                                        <span class="subject">채용공고에 있는 안심번호에 문자 보내도 될까요?</span>
                                        <span class="icon icon_lock"></span>
                                    </div>
                                    <div class="arrow"></div>
                                </div>
                                <div class="cont">네, 가능합니다! 단, 채용담당자가 유선번호를 안심번호로 설정했다면 SMS 문자를 받을 수 없습니다. 문자 발송 후 오랫동안
                                    답장이 오지 않는다면 유선전화로 한번 더 확인해주세요.
                                </div>
                            </li>--%>
                        </ul>
                    </div>
                    <%--<div class="more">
                        <a href="#">더보기</a>
                    </div>--%>
                    <script>
                        $(function () {
                            $(document).on("click", ".head", function () {
                                var $li = $(this).closest("li");

                                if ($li.hasClass("active")) {
                                    $li.removeClass("active");
                                } else {
                                    $li.siblings("li").removeClass("active");
                                    $li.addClass("active");
                                }
                            });
                        });
                    </script>
                </div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>
</html>
