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
        <div class="logo"><a href="/sc112/home"><img src="/jsp/sc112/v2/assets/img/fogo.svg" alt="사채패치"></a></div>
        <div class="tool">
            <div class="search">
                <input type="text" placeholder="검색어 입력">
                <button type="button"><i class="icon icon_search"></i><span class="blind">검색</span></button>
            </div>
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
                    <img src="${item.FLAG1_CD}" alt="${item.SYSDEF_NM}"/>${item.SYSDEF_NM}
                </a>
            </c:forEach>
<%--            <a href="/sc112/dm/create" class="on"><img src="/jsp/sc112/v2/assets/img/ic_main_title2.svg"> 피해등록하기</a>--%>
<%--            <a href="/sc112/dm/list?DM_TYPE=001"><img src="/jsp/sc112/v2/assets/img/ic_main_title3.svg"> 불법대부업 현황</a>--%>
<%--            <a href="#"><img src="/jsp/sc112/v2/assets/img/ic_main_title1.svg"> 자유게시판</a>--%>
<%--            <a href="#"><img src="/jsp/sc112/v2/assets/img/ic_main_title6.svg"> 단도박게시판</a>--%>
<%--            <a href="#"><img src="/jsp/sc112/v2/assets/img/ic_main_title5.svg"> 법률상담문의</a>--%>
<%--            <a href="#"><img src="/jsp/sc112/v2/assets/img/ic_main_title4.svg"> 고객센터</a>--%>
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
                    <%--<li class="swiper-slide">
                        <a href="#" class="inner">
                            <div class="rank">1위</div>
                            <div class="name">김실장</div>
                            <div class="change up">5</div>
                            <div class="change down">5</div>
                        </a >
                    </li>--%>
                </ul>
            </div>
            <div class="more active">
                <a href="#"></a>
            </div>
        </div>
        <div class="real-time-detail">
            <div class="tabs">
                <button type="button" class="tab on">실시간 댓글</button>
                <button type="button" class="tab">불법대부업</button>
               <!-- <button type="button" class="tab">공지사항</button>-->
            </div>
            <div class="cont on">
                <div class="list">
                    <ul>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="cate cate001">자유</span>
                                    <span class="subject">김종국이 결혼식에 김희철을 안부른 이유?</span>
                                    <span class="icon icon_new"></span>
                                </div>
                                <div class="comment">
                                    <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="cate cate02">단도</span>
                                    <span class="subject">김종국이 결혼식에 김희철을 안부른 이유?</span>
                                    <span class="icon icon_new"></span>
                                </div>
                                <div class="comment">
                                    <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="cate cate02">단도</span>
                                    <span class="subject">김종국이 결혼식에 김희철을 안부른 이유?</span>
                                    <span class="icon icon_new"></span>
                                </div>
                                <div class="comment">
                                    <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="cate cate03">불법</span>
                                    <span class="subject">김종국이 결혼식에 김희철을 안부른 이유?</span>
                                    <span class="icon icon_new"></span>
                                </div>
                                <div class="comment">
                                    <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="cate cate03">불법</span>
                                    <span class="subject">김종국이 결혼식에 김희철을 안부른 이유?</span>
                                    <span class="icon icon_new"></span>
                                </div>
                                <div class="comment">
                                    <span>뭔가 찔리는게 있어서 안나온거 아님?</span>
                                </div>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="cont">
                <div class="ranking">
                    <ul>
                        <li>
                            <a href="#" class="inner">
                                <div class="rank">1위</div>
                                <div class="name">김실장</div>
                                <div class="change up">5</div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="rank">2위</div>
                                <div class="name">안대리</div>
                                <div class="change down">1</div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="rank">3위</div>
                                <div class="name">안대리</div>
                                <div class="change up">5</div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="rank">4위</div>
                                <div class="name">안대리</div>
                                <div class="change down">1</div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="rank">5위</div>
                                <div class="name">김실장</div>
                                <div class="change up">5</div>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            <!--<div class="cont">
                <div class="list">
                    <ul>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="subject">[09/01] [안내] 사채패치 업데이트 안내</span>
                                    <span class="icon icon_new"></span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="subject">[08/27] 유머게시판 개편 및 이벤트</span>
                                    <span class="icon icon_new"></span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="subject">[06/24] [공지] 포인트 서비스 종료 안내</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="subject">[06/24] [공지] 포인트 서비스 종료 안내</span>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="inner">
                                <div class="title">
                                    <span class="subject">[09/01] [안내] 사채패치 업데이트 안내</span>
                                </div>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>-->
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
        
            $(function () {
                $(".real-time .more").on("click", function (e) {
                    e.preventDefault();
                    $(this).toggleClass("active");
                    $(".real-time-detail")
                        .toggleClass("active")
                        .stop(true, true)
                        .slideToggle(300);
                });
            });
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