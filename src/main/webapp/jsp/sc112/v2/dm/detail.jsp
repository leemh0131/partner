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
                                            <p>고소한경찰서 : ${relation.WITHDR_LOCA}</p>
                                        </div>
                                        <div class="more">
                                            <a href="/sc112/dm/detail?DM_TYPE=001&DM_CD=${relation.DM_CD}">자세히 보기</a>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
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
                    <div class="title">댓글 (${fn:length(comments)})</div>
                    <form class="form createCommonForm" action="/sc112/dm/create/comment" method="POST">
                        <input type="text" name="DM_CD" value="${detail.DM_CD}" hidden="hidden">
                        <div class="input">
                            <div class="inp"><input name="NICK_NM" type="text" placeholder="닉네임"></div>
                            <div class="inp"><input name="PASSWORD" type="password" placeholder="비밀번호"></div>
                        </div>
                        <div class="textarea">
                            <div class="text">
                                <textarea name="CONTENTS" class="commentArea" placeholder="타인의 권리를 침해하거나 명예를 훼손하는 댓글은 관련 법률에 의해 제재를 받을 수 있습니다."></textarea>
                            </div>

                            <div class="tool">
                                <div class="util">
                                    <button class="imoji" type="button"><i class="icon icon_imoji"></i></button>
                                </div>
                                <div class="bttn"><button type="submit">등록</button></div>
                            </div>
                        </div>
                        <div class="emoji-picker-container" style="display:none; position:absolute; z-index:9999;"></div>
                    </form>
                    <div class="list">
                        <ul>
                            <c:forEach var="comment" items="${comments}">
                                <c:if test="${empty comment.PARENT_CD}">
                                    <li>
                                        <div class="cmmt">
                                            <div class="top">
                                                <div class="ico">
                                                    <img src="/jsp/sc112/v2/assets/img/profile.svg">
                                                </div>
                                                <div class="con">
                                                    <div class="name">${comment.NICK_NM}</div>
                                                    <div class="date">${comment.WRITE_DATE}</div>
                                                    <c:if test="${comment.NEW_VALUE eq 'Y'}">
                                                        <span class="icon icon_new"></span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="text">${comment.CONTENTS}</div>
                                            <div class="tool">
                                                <a href="#" class="reply-btn" data-dm-cd="${comment.DM_CD}" data-comment-cd="${comment.COMM_CD}">답글</a>
                                            </div>
                                        </div>
                                        <c:forEach var="child" items="${comments}">
                                            <c:if test="${child.PARENT_CD eq comment.COMM_CD}">
                                                <div class="cmmt rep">
                                                    <div class="top">
                                                        <div class="con">
                                                            <div class="name">${child.NICK_NM}</div>
                                                            <div class="date">${child.WRITE_DATE}</div>
                                                            <c:if test="${child.NEW_VALUE eq 'Y'}">
                                                                <span class="icon icon_new"></span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <div class="text">${child.CONTENTS}</div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </li>
                                </c:if>
                            </c:forEach>
                        </ul>
                    </div>
                    <%--<div class="more">
                        <a href="#">더보기</a>
                    </div>--%>
                    <%--<div class="button">
                        <a href="javascript:history.back();" class="btn btn_01">목록</a>
                    </div>--%>
                </div>
                <div id="emoji-picker-container" style="display:none; position:absolute; z-index:999;"></div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
<script src="https://unpkg.com/emoji-mart@latest/dist/browser.js"></script>
<script>
    $(function () {
        $(document).on("submit", ".createCommonForm", function (e) {
            e.preventDefault(); // ★ 무조건 막고 시작

            var $form = $(this);

            var nick = $.trim($form.find("input[name='NICK_NM']").val());
            var pw = $.trim($form.find("input[name='PASSWORD']").val());
            var contents = $.trim($form.find("textarea[name='CONTENTS']").val());

            if (!nick) {
                alert("닉네임을 입력해주세요.");
                $form.find("input[name='NICK_NM']").focus();
                return;
            }

            if (!pw) {
                alert("비밀번호를 입력해주세요.");
                $form.find("input[name='PASSWORD']").focus();
                return;
            }

            if (!contents) {
                alert("글 내용을 입력해주세요.");
                $form.find("textarea[name='CONTENTS']").focus();
                return;
            }

            this.submit();
        });

    });

    $(function () {
        $(document).on("click", ".reply-btn", function (e) {
            e.preventDefault();

            const $btn = $(this);
            const dmCd = $btn.data("dm-cd");
            const commentCd = $btn.data("comment-cd");
            const $li = $(this).closest("li");
            const $existingForm = $(".reply-form-wrap");

            if ($li.next().hasClass("reply-form-wrap")) {
                $li.next().remove();
                return;
            }

            if ($existingForm.length) {
                $existingForm.remove();
            }

            var formHtml = ''
                + '<li class="reply-form-wrap">'
                + '  <form class="form createCommonForm" action="/sc112/dm/create/comment" method="POST">'
                + '    <input type="hidden" name="DM_CD" value="' + dmCd + '">'
                + '    <input type="hidden" name="PARENT_CD" value="' + commentCd + '">'

                + '    <div class="input">'
                + '      <div class="inp"><input name="NICK_NM" type="text" placeholder="닉네임"></div>'
                + '      <div class="inp"><input name="PASSWORD" type="password" placeholder="비밀번호"></div>'
                + '    </div>'

                + '    <div class="textarea">'
                + '      <div class="text">'
                + '        <textarea name="CONTENTS" class="commentArea"'
                + '          placeholder="타인의 권리를 침해하거나 명예를 훼손하는 댓글은 관련 법률에 의해 제재를 받을 수 있습니다."></textarea>'
                + '      </div>'

                + '      <div class="tool">'
                + '        <div class="util">'
                + '          <button class="imoji" type="button">'
                + '            <i class="icon icon_imoji"></i>'
                + '          </button>'
                + '        </div>'
                + '        <div class="bttn">'
                + '          <button type="submit">등록</button>'
                + '        </div>'
                + '      </div>'
                + '    </div>'

                + '    <div class="emoji-picker-container"'
                + '         style="display:none; position:absolute; z-index:9999;"></div>'
                + '  </form>'
                + '</li>';

            $li.after(formHtml);
            $li.next().find("textarea").focus();
        });
    });

    $(function () {
        $(document).on("click", ".imoji", function (e) {
            e.preventDefault();

            const $form = $(this).closest("form");
            const $textarea = $form.find(".commentArea");
            const $pickerContainer = $form.find(".emoji-picker-container");

            // picker 없으면 생성
            if (!$pickerContainer.data("picker")) {
                const picker = new EmojiMart.Picker({
                    onEmojiSelect: emoji => {
                        insertAtCursor($textarea[0], emoji.native);
                    },
                    locale: "ko",
                    previewPosition: "none",
                    skinTonePosition: "none",
                    searchPosition: "none"
                });

                $pickerContainer.append(picker);
                $pickerContainer.data("picker", picker);
            }

            // 위치 계산
            const pos = $(this).offset();
            $pickerContainer.css({
                top: pos.top - $pickerContainer.outerHeight() - 10,
                left: pos.left
            }).toggle();
        });

        // textarea 커서 위치 삽입
        function insertAtCursor(textarea, text) {
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;

            textarea.value =
                textarea.value.substring(0, start) +
                text +
                textarea.value.substring(end);

            textarea.selectionStart = textarea.selectionEnd = start + text.length;
            textarea.focus();
        }

        // 외부 클릭 시 picker 닫기
        $(document).on("click", function (e) {
            if (!$(e.target).closest(".imoji, .emoji-picker-container").length) {
                $(".emoji-picker-container").hide();
            }
        });
    });
</script>
</body>
</html>
