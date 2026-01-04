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
            <div id="bbs_write">
                <div class="header">
                    <div class="title">${item.TITLE}</div>
                    <div class="info">
                        <p>${item.NAME}</p>
                        <p>${item.INSERT_DTS}</p>
                        <p>${item.HIT}회</p>
                    </div>
                </div>
                <div class="form">
                    <dl>
                        <dd>
                            <div class="flex">
                                <div class="text">${item.CONTENTS}</div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>링크</dt>
                        <dd id="linkArea">
                            <c:forEach var="link" items="${links}">
                                <div class="flex">
                                    <div class="input"><a target="_blank" href="${link.LINK}">${link.LINK}</a></div>
                                </div>
                            </c:forEach>
                        </dd>
                    </dl>
                    <dl>
                        <dt>첨부</dt>
                        <dd>
                            <c:forEach var="file" items="${files}">
                                <div class="flex">
                                    <div class="file">
                                        <a class="txt" href="/sc112/community/download/${file.TABLE_ID}/${file.FILE_NAME}" target="_blank">${file.ORGN_FILE_NAME}</a>
                                    </div>
                                </div>
                            </c:forEach>
                        </dd>
                    </dl>
                </div>
                <script>
                    $(function () {
                        $(document).on("click", ".link.add", function (e) {
                            e.preventDefault();

                            $(this)
                                .removeClass("add")
                                .addClass("delete")
                                .html('<i class="icon icon_delete"></i><span class="blind">링크 제거</span>');

                            let newFlex = `
                        <div class="flex">
                            <div class="input">
                                <input type="text" placeholder="링크를 입력해주세요.">
                            </div>
                            <div class="bttn">
                                <a href="#" class="link add"><i class="icon icon_plus"></i><span class="blind">링크 추가</span></a>
                            </div>
                        </div>`;

                            $("#linkArea").append(newFlex);
                        });

                        $(document).on("click", ".link.delete", function (e) {
                            e.preventDefault();
                            $(this).closest(".flex").remove();

                            let lastFlex = $("#linkArea .flex").last();
                            $("#linkArea .flex .link").removeClass("add").addClass("delete")
                                .html('<i class="icon icon_delete"></i><span class="blind">링크 제거</span>');
                            lastFlex.find(".link").removeClass("delete").addClass("add")
                                .html('<i class="icon icon_plus"></i><span class="blind">링크 추가</span>');
                        });
                    });
                    $(function () {
                        $("#file_input").on("change", function () {
                            let fileName = $(this).val().split("\\").pop();
                            if (fileName) {
                                $(this).closest(".file").find(".txt").text(fileName);
                            } else {
                                $(this).closest(".file").find(".txt").text("선택된 파일 없음");
                            }
                        });
                    });
                </script>
            </div>
            <div id="bbs_detail" style="margin-top: 30px;">
                <div class="comment">
                    <div class="title">댓글 (${fn:length(comments)})</div>
                    <form class="form createCommonForm" action="/sc112/community/create/comment" method="POST">
                        <input type="text" name="SEQ" value="${item.SEQ}" hidden="hidden">
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
                                            <c:if test="${comment.DELETE_YN eq 'N'}">
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
                                            </c:if>
                                            <div class="text">${comment.CONTENTS}</div>
                                            <div class="tool">
                                                <a href="#" class="reply-btn" data-seq="${comment.SEQ}" data-comment-cd="${comment.COMM_CD}">답글</a>
                                                <c:if test="${comment.DELETE_YN eq 'N'}">
                                                    <a href="#" class="update-btn" data-seq="${comment.SEQ}" data-comment-cd="${comment.COMM_CD}" data-nick-nm="${comment.NICK_NM}" data-contents="${comment.CONTENTS}">수정</a>
                                                    <a href="#" class="delete-btn" data-seq="${comment.SEQ}" data-comment-cd="${comment.COMM_CD}" data-nick-nm="${comment.NICK_NM}">삭제</a>
                                                </c:if>
                                            </div>
                                        </div>
                                        <c:forEach var="child" items="${comments}">
                                            <c:if test="${child.PARENT_CD eq comment.COMM_CD}">
                                                <div class="cmmt rep">
                                                    <c:if test="${child.DELETE_YN eq 'N'}">
                                                        <div class="top">
                                                            <div class="con">
                                                                <div class="name">${child.NICK_NM}</div>
                                                                <div class="date">${child.WRITE_DATE}</div>
                                                                <c:if test="${child.NEW_VALUE eq 'Y'}">
                                                                    <span class="icon icon_new"></span>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                    <div class="text">${child.CONTENTS}</div>
                                                    <div class="tool">
                                                        <c:if test="${child.DELETE_YN eq 'N'}">
                                                            <a href="#" class="update-btn" data-seq="${comment.SEQ}" data-comment-cd="${child.COMM_CD}" data-nick-nm="${child.NICK_NM}" data-contents="${child.CONTENTS}">수정</a>
                                                            <a href="#" class="delete-btn" data-seq="${comment.SEQ}" data-comment-cd="${child.COMM_CD}" data-nick-nm="${child.NICK_NM}">삭제</a>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </li>
                                </c:if>
                            </c:forEach>
                        </ul>
                    </div>
                    <script>
                        $(function () {
                            $("#listBtn").attr("href", location.pathname.replaceAll('detail', 'list') + location.search.replace(/&SEQ=[^&]*/g, "").replace(/&PW=[^&]*/g, ""));
                        });
                    </script>
                    <div class="button">
                        <c:if test="${!empty loginInfo}">
                            <a href="/sc112/community/delete?COMMUNITY_TP=${item.COMMUNITY_TP}&COMMUNITY_ST=${item.COMMUNITY_ST}&SEQ=${item.SEQ}" class="btn btn_01">삭제</a>
                        </c:if>
                        <a id="listBtn" href="" class="btn btn_01">목록</a>
                    </div>
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
        $(document).on("click", ".bttn button[type='submit']", function(e) {
            e.preventDefault();

            var $form = $(this).closest("form");

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

            $form.submit();
        });

    });

    $(function () {
        $(document).on("click", ".reply-btn", function (e) {
            e.preventDefault();

            const $btn = $(this);
            const seq = $btn.data("seq");
            const commentCd = $btn.data("comment-cd");
            const $li = $(this).closest("li");
            const $existingForm = $(".reply-form-wrap");

            if ($li.next(".reply-form-wrap").find(".reply-btn").length) {
                $li.next().remove();
                return;
            }

            if ($existingForm.length) {
                $existingForm.remove();
            }

            var formHtml = ''
                + '<li class="reply-form-wrap">'
                + '  <form class="form createCommonForm" action="/sc112/community/create/comment" method="POST">'
                + '    <input type="hidden" name="SEQ" value="' + seq + '">'
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

        $(document).on("click", ".delete-btn", function (e) {
            e.preventDefault();

            const $btn = $(this);
            const seq = $btn.data("seq");
            const nickNm = $btn.data("nick-nm");
            const commentCd = $btn.data("comment-cd");
            const $li = $(this).closest("li");
            const $existingForm = $(".reply-form-wrap");

            if ($li.next(".reply-form-wrap").find(".delete-btn").length) {
                $li.next().remove();
                return;
            }

            if ($existingForm.length) {
                $existingForm.remove();
            }

            var formHtml = ''
                + '<li class="reply-form-wrap">'
                + '  <form class="form createCommonForm" action="/sc112/community/delete/comment" method="POST">'
                + '    <input type="hidden" name="SEQ" value="' + seq + '">'
                + '    <input type="hidden" name="COMM_CD" value="' + commentCd + '">'

                + '    <div class="input">'
                +  '     <div class="inp"><input name="NICK_NM" type="text" value="' + nickNm +'" readonly disabled></div>'
                + '      <div class="inp"><input name="PASSWORD" type="password" placeholder="비밀번호"></div>'
                + '          <button class="delete-bttn">삭제</button>'
                + '    </div>'
                + '  </form>'
                + '</li>';

            $li.after(formHtml);
        });

        $(document).on("click", ".update-btn", function (e) {
            e.preventDefault();

            const $btn = $(this);
            const seq = $btn.data("seq");
            const nickNm = $btn.data("nick-nm");
            const contents = $btn.data("contents");
            const commentCd = $btn.data("comment-cd");
            const $li = $(this).closest("li");
            const $existingForm = $(".reply-form-wrap");

            if ($li.next(".reply-form-wrap").find(".update-btn").length) {
                $li.next().remove();
                return;
            }

            if ($existingForm.length) {
                $existingForm.remove();
            }

            var formHtml = ''
                + '<li class="reply-form-wrap">'
                + '  <form class="form createCommonForm" action="/sc112/community/update/comment" method="POST">'
                + '    <input type="hidden" name="SEQ" value="' + seq + '">'
                + '    <input type="hidden" name="COMM_CD" value="' + commentCd + '">'

                + '    <div class="input">'
                +  '     <div class="inp"><input name="NICK_NM" type="text" value="' + nickNm +'" readonly disabled></div>'
                + '      <div class="inp"><input name="PASSWORD" type="password" placeholder="비밀번호"></div>'
                + '    </div>'

                + '    <div class="textarea">'
                + '      <div class="text">'
                + '        <textarea name="CONTENTS" class="commentArea"'
                + '          placeholder="타인의 권리를 침해하거나 명예를 훼손하는 댓글은 관련 법률에 의해 제재를 받을 수 있습니다.">' + contents + '</textarea>'
                + '      </div>'

                + '      <div class="tool">'
                + '        <div class="util">'
                + '          <button class="imoji" type="button">'
                + '            <i class="icon icon_imoji"></i>'
                + '          </button>'
                + '        </div>'
                + '        <div class="bttn">'
                + '          <button type="submit">수정</button>'
                + '        </div>'
                + '      </div>'
                + '    </div>'

                + '    <div class="emoji-picker-container"'
                + '         style="display:none; position:absolute; z-index:9999;"></div>'
                + '  </form>'
                + '</li>';

            $li.after(formHtml);
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
