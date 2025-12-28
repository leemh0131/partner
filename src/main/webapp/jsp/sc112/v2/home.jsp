<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!doctype html>
<html>
<body id="wrap">
<%@ include file="/jsp/sc112/v2/header.jsp" %>
<main id="container">
    <div class="wrap">
        <section id="main">
            <div class="solution order2">
                <c:forEach var="item" items="${commonLink}" varStatus="status">
                    <a href="${item.LINK}" target="_blank"><img class="inner ${item.TABLE_ID}" src="${item.IMG_URL}" alt="설명"></a>
                </c:forEach>
            </div>
            <div class="latest order4">
                <div class="head">
                    <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title3.svg">피해등록현황</div>
                    <div class="more"><a href="/sc112/dm/list?DM_TYPE=001">더보기</a></div>
                </div>
                <div class="content">
                    <div class="list">
                        <ul>
                            <c:forEach var="dm" items="${dm001}">
                                <li>
                                    <a href="/sc112/dm/detail?DM_TYPE=001&DM_CD=${dm.DM_CD}" class="inner">
                                        <div class="title">
                                            <span class="name">${dm.NAME}</span>
                                            <span class="subject">${dm.TITLE}</span>
                                            <span class="reply">(${dm.COMM_CUT})</span>
                                            <c:if test="${dm.NEW_VALUE eq 'Y'}">
                                                <span class="icon icon_new"></span>
                                            </c:if>
                                            <span class="date">${dm.DTS}</span>
                                        </div>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="latest order1">
                <div class="head">
                    <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title1.svg"> 공지사항</div>
                    <div class="more"><a href="/sc112/board/list?BOARD_TYPE=04">더보기</a></div>
                </div>
                <div class="content">
                    <div class="list">
                        <ul>
                            <c:forEach var="board" items="${boards}">
                                <li>
                                    <a href="/sc112/board/list?BOARD_TYPE=04" class="inner">
                                        <div class="title">
                                            <span class="subject">${board.TITLE}</span>
                                            <c:if test="${board.NEW_VALUE eq 'Y'}">
                                                <span class="icon icon_new"></span>
                                            </c:if>
                                            <span class="date">${board.DTS}</span>
                                        </div>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="latest order3">
                <div class="head">
                    <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title2.svg">자유게시판</div>
                    <div class="more"><a href="/sc112/community/list?COMMUNITY_TP=08&COMMUNITY_ST=14">더보기</a></div>
                </div>
                <div class="content">
                    <div class="list">
                        <ul>
                            <c:forEach var="cm" items="${community08}">
                                <li>
                                    <a href="/sc112/community/detail?COMMUNITY_TP=08&COMMUNITY_ST=14&SEQ=${cm.SEQ}" class="inner">
                                        <div class="title">
                                            <span class="name">${cm.NAME}</span>
                                            <span class="subject">${cm.TITLE}</span>
                                            <span class="reply">(${cm.COMM_CUT})</span>
                                            <c:if test="${cm.NEW_VALUE eq 'Y'}">
                                                <span class="icon icon_new"></span>
                                            </c:if>
                                            <span class="date">${cm.DTS}</span>
                                        </div>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="latest order5">
                <div class="head">
                    <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title4.svg">단도박게시판</div>
                    <div class="more"><a href="/sc112/community/list?COMMUNITY_TP=07&COMMUNITY_ST=14">더보기</a></div>
                </div>
                <div class="content">
                    <div class="list">
                        <ul>
                            <c:forEach var="cm" items="${community07}">
                                <li>
                                    <a href="/sc112/community/detail?COMMUNITY_TP=07&COMMUNITY_ST=14&SEQ=${cm.SEQ}" class="inner">
                                        <div class="title">
                                            <span class="name">${cm.NAME}</span>
                                            <span class="subject">${cm.TITLE}</span>
                                            <span class="reply">(${cm.COMM_CUT})</span>
                                            <c:if test="${cm.NEW_VALUE eq 'Y'}">
                                                <span class="icon icon_new"></span>
                                            </c:if>
                                            <span class="date">${cm.DTS}</span>
                                        </div>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
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
