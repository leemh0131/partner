<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<section id="aside">
    <div class="latest">
        <div class="head gray">
            <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title5.svg"> 실시간 댓글</div>
            <div class="more"><a href="/sc112/dm/list?DM_TYPE=001">더보기</a></div>
        </div>
        <div class="content">
            <div class="list">
                <ul>
                    <c:forEach var="item" items="${liveComments}">
                        <li>
                            <a href="/sc112/dm/detail?DM_CD=${item.DM_CD}" class="inner">
                                <div class="title">
                                    <span class="cate cate${item.DM_TYPE}">${item.DM_TYPE_NM}</span>
                                    <span class="subject bold">${item.COMP_NM}</span>
                                </div>
                                <div class="comment">
                                    <span>${item.COMMENT}</span>
                                </div>
                            </a>
                        </li>
                    </c:forEach>
                    <%--<li>
                        <a href="#" class="inner">
                            <div class="title">
                                <span class="cate cate03">불법</span>
                                <span class="subject bold">김종국이 결혼식에 김희철을 안부른 이유?</span>
                            </div>
                            <div class="comment">
                                <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                            </div>
                        </a>
                    </li>--%>
                </ul>
            </div>
        </div>
    </div>
    <div class="latest">
        <div class="head gray">
            <div class="title"><img src="/jsp/sc112/v2/assets/img/ic_main_title6.svg"> 불법대부업</div>
            <div class="more"><a href="/sc112/dm/list?DM_TYPE=001">더보기</a></div>
        </div>
        <div class="content">
            <div class="ranking">
                <ul>
                    <c:forEach var="item" items="${liveRanks}" varStatus="status">
                        <li>
                            <a href="/sc112/dm/detail?DM_CD=${item.DM_CD}" class="inner">
                                <div class="rank">${status.count}위</div>
                                <div class="name">${item.COMP_NM}</div>
<%--                                <div class="change up">5</div>--%>
<%--                            <div class="change down">1</div>--%>
                            </a >
                        </li>
                    </c:forEach>
                    <%--<li>
                        <a href="#" class="inner">
                            <div class="rank">2위</div>
                            <div class="name">안대리</div>
                            <div class="change down">1</div>
                        </a>
                    </li>--%>
                </ul>
            </div>
        </div>
    </div>
    <div class="adarea">
        <div class="head">
            <div class="title">광고영역</div>
            <div class="label">AD</div>
        </div>
        <div class="cont">
            <a href="#"><img src="/jsp/sc112/v2/assets/img/adarea.svg"></a>
        </div>
    </div>
</section>