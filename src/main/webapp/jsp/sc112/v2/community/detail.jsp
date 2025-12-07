<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!doctype html>
<html>
<body id="wrap">
<%@ include file="/jsp/sc112/v2/header.jsp" %>
<main id="container">
    <div class="wrap">
        <section id="contain">
            <div id="bbs_write">
                <div class="header">
                    <div class="title">${item.TITLE}</div>
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
                        <dt>닉네임 : ${item.TITLE} 작성날짜 : ${item.INSERT_DTS}</dt>
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
                            <div class="flex">
                                <div class="file">
                                    <label class="btn"><input type="file" id="file_input">파일선택</label>
                                    <span class="txt">선택된 파일 없음</span>
                                </div>
                            </div>
                            <%--<div class="flex">
                                <div class="caution">* 용량이 50.0M 파일만 업로드 가능</div>
                            </div>--%>
                        </dd>
                    </dl>
                </div>
                <%--<div class="button">
                    <a href="#" class="btn btn_02">취소</a>
                    <a href="#" class="btn btn_01">등록</a>
                </div>--%>
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
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>
</html>
