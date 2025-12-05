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
                                <c:choose>
                                    <c:when test="${item.RANK_DIFF == 0}">
                                    </c:when>
                                    <c:when test="${item.RANK_DIFF > 0}">
                                        <div class="change up">${item.RANK_DIFF}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="change down">${item.RANK_DIFF}</div>
                                    </c:otherwise>
                                </c:choose>
                            </a >
                        </li>
                    </c:forEach>
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