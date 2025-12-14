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
            <div id="bbs_detail">
                <div class="banner mobile">
                    <a href="#">
                        <div class="tit">불법대부업 채무 맞춤 솔루션</div>
                        <div class="txt">불법대부업 채무조정 및 종결협의</div>
                    </a>
                </div>
                <div class="header">
                    <div class="title">${detail.COMP_NM}</div>
                    <div class="info">
                        <p>${detail.DM_TYPE}</p>
<%--                        <p>키륵키륵</p>--%>
                        <p>${detail.WRITE_DATE}</p>
<%--                        <p>${detail.HIT}회</p>--%>
                    </div>
                </div>
                <div class="content">
                    <div class="head">
                        <div class="title">상세정보</div>
                    </div>
                    <div class="text">
                        <c:if test="${not empty detail.DM_KIND}">
                            <dl>
                                <dt>피해종류</dt>
                                <dd>${detail.DM_KIND}</dd>
                            </dl>
                        </c:if>
                        <dl>
                            <dt>차용사이트</dt>
                            <dd>${detail.BORW_SITE}</dd>
                        </dl>
                        <dl>
                            <dt>연락처</dt>
                            <dd>${detail.DEBTOR_TEL}</dd>
                        </dl>
                        <dl>
                            <dt>카카오톡</dt>
                            <dd>${detail.DEBTOR_KAKAO}</dd>
                        </dl>
                        <dl>
                            <dt>텔레그램</dt>
                            <dd>${detail.DEBTOR_TELE}</dd>
                        </dl>
                        <dl>
                            <dt>기타 SNS</dt>
                            <dd>${detail.DEBTOR_SNS}</dd>
                        </dl>
                        <dl>
                            <dt>상환계좌</dt>
                            <dd>
                                <ul>
                                    <c:forEach var="deposit" items="${detailDeposit}">
                                        <li>${deposit.DEPOSIT}</li>
                                    </c:forEach>
                                </ul>
                            </dd>
                        </dl>
                        <dl>
                            <dt>스마트출금 위치</dt>
                            <dd>
                                <ul>
                                    <c:forEach var="loca" items="${fn:split(detail.WITHDR_LOCA, ',')}">
                                        <li>${fn:trim(loca)}</li>
                                    </c:forEach>
                                </ul>
                            </dd>
                        </dl>
                        <dl>
                            <dt>피해내용</dt>
                            <dd>${detail.DM_CONTENTS}</dd>
                        </dl>
                        <dl>
                            <dt>고소한 경찰서</dt>
                            <dd>${detail.COMPL_POLICE}</dd>
                        </dl>
                    </div>
                </div>
                <div class="relation">
                    <div class="title">관련 불법사채업자</div>
                    <div class="list">
                        <div class="slider" id="relation_slider">
                            <ul class="swiper-wrapper">
                                <c:forEach var="relation" items="${relationList}">
                                    <li class="swiper-slide">
                                        <div class="name">${relation.COMP_NM}</div>
                                        <div class="info">
                                            <p>연락처 : ${relation.DEBTOR_TEL}</p>
                                            <p>카카오톡 : ${relation.DEBTOR_KAKAO}</p>
                                            <p>텔레그램 : ${relation.DEBTOR_TELE}</p>
                                            <p>기타SNS : ${relation.DEBTOR_SNS}</p>
                                            <p>고소경찰서 : ${relation.WITHDR_LOCA}</p>
                                        </div>
                                        <div class="more">
                                            <a href="/sc112/dm/detail?DM_TYPE=001&DM_CD=${relation.DM_CD}">자세히 보기</a>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                        <button type="button" class="swiper-button-prev"><span class="blind">이전</span></button>
                        <button type="button" class="swiper-button-next"><span class="blind">다음</span></button>
                        <script>
                            var relation = new Swiper("#relation_slider", {
                                loop: true,
                                slidesPerView: 3,
                                spaceBetween: 25,
                                speed: 800,
                                observer: true,
                                observeParents: true,
                                navigation: {
                                    nextEl: '.relation .swiper-button-next',
                                    prevEl: '.relation .swiper-button-prev',
                                },
                                breakpoints: {
                                    300: {
                                        slidesPerView: 'auto',
                                        spaceBetween: 16,
                                    },
                                    1024: {
                                        slidesPerView: 3,
                                        spaceBetween: 25,
                                    }
                                }
                            });
                        </script>
                    </div>
                </div>
                <div class="comment">
                    <div class="title">댓글 (12)</div>
                    <div class="form">
                        <div class="input">
                            <div class="inp"><input type="text" placeholder="닉네임"></div>
                            <div class="inp"><input type="password" placeholder="비밀번호"></div>
                        </div>
                        <div class="textarea">
                            <div class="text"><textarea id="commentArea"
                                                        placeholder="타인의 권리를 침해하거나 명예를 훼손하는 댓글은 관련 법률에 의해 제재를 받을 수 있습니다."></textarea>
                            </div>
                            <div class="tool">
                                <div class="util">
                                    <label class="camera"><input type="file"><i class="icon icon_camera"></i><span
                                            class="blind">이미지 등록</span></label>
                                    <button class="imoji"><i class="icon icon_imoji"></i><span
                                            class="blind">이모지 선택</span></button>
                                </div>
                                <div class="bttn">
                                    <button type="button">등록</button>
                                </div>
                            </div>
                        </div>
                        <script src="https://unpkg.com/emoji-mart@latest/dist/browser.js"></script>
                        <script>
                            $(function () {
                                const $pickerContainer = $("#emoji-picker-container");
                                const $imojiBtn = $(".imoji");
                                const $textarea = $("#commentArea");
                                let pickerVisible = false;

                                const picker = new EmojiMart.Picker({
                                    onEmojiSelect: emoji => {
                                        insertAtCursor($textarea[0], emoji.native);
                                    },
                                    locale: "ko", // 한국어
                                    previewPosition: "none",
                                    skinTonePosition: "none",
                                    searchPosition: "none"
                                });
                                $pickerContainer.append(picker);

                                $imojiBtn.on("click", function (e) {
                                    e.preventDefault();
                                    const pos = $(this).offset();
                                    $pickerContainer.css({
                                        top: pos.top - $pickerContainer.outerHeight() - 10,
                                        left: pos.left
                                    }).toggle();
                                    pickerVisible = !pickerVisible;
                                });

                                function insertAtCursor(textarea, text) {
                                    const start = textarea.selectionStart;
                                    const end = textarea.selectionEnd;
                                    textarea.value = textarea.value.substring(0, start) + text + textarea.value.substring(end);
                                    textarea.selectionStart = textarea.selectionEnd = start + text.length;
                                    textarea.focus();
                                }

                                $(document).on("click", function (e) {
                                    if (!$(e.target).closest('.imoji, #emoji-picker-container').length) {
                                        $pickerContainer.hide();
                                        pickerVisible = false;
                                    }
                                });
                            });
                        </script>
                    </div>
                    <div class="list">
                        <ul>
                            <li>
                                <div class="cmmt">
                                    <div class="top">
                                        <div class="ico"><img src="/jsp/sc112/v2/assets/img/profile.svg"></div>
                                        <div class="con">
                                            <div class="name">김****</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                                <div class="cmmt rep">
                                    <div class="top">
                                        <div class="con">
                                            <div class="name">kimsu</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                                <div class="form">
                                    <div class="input">
                                        <div class="inp"><input type="text" placeholder="닉네임"></div>
                                        <div class="inp"><input type="password" placeholder="비밀번호"></div>
                                    </div>
                                    <div class="textarea">
                                        <div class="text"><textarea
                                                placeholder="타인의 권리를 침해하거나 명예를 훼손하는 댓글은 관련 법률에 의해 제재를 받을 수 있습니다."></textarea>
                                        </div>
                                        <div class="tool">
                                            <div class="util">
                                                <label class="camera"><input type="file"><i
                                                        class="icon icon_camera"></i><span
                                                        class="blind">이미지 등록</span></label>
                                                <button class="imoji"><i class="icon icon_imoji"></i><span
                                                        class="blind">이모지 선택</span></button>
                                            </div>
                                            <div class="bttn">
                                                <button type="button">등록</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <div class="cmmt">
                                    <div class="top">
                                        <div class="ico"><img src="/jsp/sc112/v2/assets/img/profile.svg"></div>
                                        <div class="con">
                                            <div class="name">김****</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <div class="cmmt">
                                    <div class="top">
                                        <div class="ico"><img src="/jsp/sc112/v2/assets/img/profile.svg"></div>
                                        <div class="con">
                                            <div class="name">김****</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <div class="cmmt">
                                    <div class="top">
                                        <div class="ico"><img src="/jsp/sc112/v2/assets/img/profile.svg"></div>
                                        <div class="con">
                                            <div class="name">김****</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <div class="cmmt">
                                    <div class="top">
                                        <div class="ico"><img src="/jsp/sc112/v2/assets/img/profile.svg"></div>
                                        <div class="con">
                                            <div class="name">김****</div>
                                            <div class="date">2022-04-30 15:00</div>
                                        </div>
                                    </div>
                                    <div class="text">추심 피해가 너무 심각합니다.</div>
                                    <div class="tool">
                                        <a href="#">수정</a>
                                        <a href="#">삭제</a>
                                        <a href="#">답글</a>
                                        <a href="#">신고</a>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                    <div class="more">
                        <a href="#">더보기</a>
                    </div>
                    <div class="button">
                        <a href="/sc112/dm/list?DM_TYPE=001" class="btn btn_01">목록</a>
                    </div>
                </div>
                <div id="emoji-picker-container" style="display:none; position:absolute; z-index:999;"></div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>
</html>
