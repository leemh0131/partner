<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0, user-scalable=yes">
    <title>사채패치</title>

    <link rel="stylesheet" type="text/css" href="/jsp/sc112/v2/assets/css/swiper.css">
    <link rel="stylesheet" type="text/css" href="/jsp/sc112/v2/assets/css/common.css">
    <link rel="stylesheet" type="text/css" href="/jsp/sc112/v2/assets/css/layout.css">

    <script type="text/javascript" src="/jsp/sc112/v2/assets/js/jquery-3.7.1.min.js"></script>
    <script type="text/javascript" src="/jsp/sc112/v2/assets/js/swiper.js"></script>
    <script type="text/javascript" src="/jsp/sc112/v2/assets/js/common.js"></script>

    <script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>
</head>
<header id="header">
    <div class="wrap">
        <div class="logo"><a href="/sc112/home"><img src="/jsp/sc112/v2/assets/img/logo.svg" alt="사채패치"></a></div>
        <div class="tool">
            <form id="searchForm" action="/sc112/dm/list" method="GET">
            <div class="search">
                    <input type="text" name="DM_TYPE" value="001" hidden="hidden">
                    <input type="text" name="KEYWORD" placeholder="피해현황 검색" value="${param.KEYWORD}">
                <button type="submit"><i class="icon icon_search"></i><span class="blind">검색</span></button>
            </div>
            </form>
            <div class="menu"><span class="blind">전체메뉴</span></div>
        </div>
    </div>
</header>
<section id="gnb">
    <div class="wrap">
        <div class="gnb">
            <c:forEach var="item" items="${commonHeader}">
                <a id="${item.SYSDEF_CD}"
                   href="${item.SYSDEF_CD}"
                   style="${item.FLAG2_CD == 'false' ? 'display:none;' : ''}">
                    <%--<img src="${item.FLAG1_CD}" alt="${item.SYSDEF_NM}"/>--%>${item.SYSDEF_NM}
                </a>
            </c:forEach>
        </div>
        <div class="real-time">
            <div class="title">실시간 순위</div>
            <div class="slider" id="realtime_slider">
                <ul class="swiper-wrapper">
                    <c:forEach var="item" items="${liveRanks}" varStatus="status">
                        <li class="swiper-slide">
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
            <%--<div class="more active">
                <a href="#"></a>
            </div>--%>
        </div>
        <script>
            $(function () {
                if (window.location.pathname === '/sc112/home') {
                    $('#mobile_real_time').show();
                } else {
                    $('#mobile_real_time').hide();
                }
            });
        </script>
        <div id="mobile_real_time" class="real-time-detail active">
            <div class="tabs">
                <button type="button" class="tab on">실시간 댓글</button>
<%--                <button type="button" class="tab">불법대부업</button>--%>
            </div>
            <div class="cont on">
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
                                    <span class="date">${item.DTS}</span>
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
            <div class="cont">
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
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </div>
        <div class="dimmed"></div>
         <script>
            var realtime = new Swiper("#realtime_slider", {
                loop: true,
                autoplay : {
                    delay : 3000,
                    disableOnInteraction : false,
                },
                direction: 'vertical',
                slidesPerView: 1,
                spaceBetween: 0,
                speed: 800,
                observer: true,
                observeParents: true,
            });

            $(function () {
                $("#header .menu").on("click", function () {
                    $("#gnb").toggleClass("active");
                    $("#header").toggleClass("active");
                    $(this).toggleClass("active");
                });
            });
        
            /*$(function () {
                $(".real-time .more").on("click", function (e) {
                    e.preventDefault();
                    $(this).toggleClass("active");
                    $(".real-time-detail")
                        .toggleClass("active")
                        .stop(true, true)
                        .slideToggle(300);
                });
            });*/
            $(function () {
                $(".tabs .tab").on("click", function () {
                    var idx = $(this).index();

                    $(".tabs .tab").removeClass("on");
                    $(this).addClass("on");

                    $(".cont").removeClass("on");
                    $(".cont").eq(idx).addClass("on");
                });
            });
        </script>
    </div>
</section>   