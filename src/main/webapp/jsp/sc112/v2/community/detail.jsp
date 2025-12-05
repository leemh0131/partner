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
                    <div class="title" id="menuTitle">
                        <script>
                            $(function () {
                                $(function () {
                                    var current = location.pathname + location.search;
                                    var $target = $("a").filter(function () {
                                        var idValue = $(this).attr("id");
                                        return current.startsWith(idValue);
                                    });
                                    if ($target.length) {
                                        $(".title").text($target.text());
                                    }
                                });
                            });
                        </script>
                    </div>
                    <div class="bookmark"><img src="/jsp/sc112/v2/assets/img/ic_star.svg"></div>
                </div>
                <div class="form">
                    <dl class="w50p">
                        <dt>닉네임</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="password" placeholder="닉네임"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl class="w50p">
                        <dt>비밀번호</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="password" placeholder="비밀번호"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>제목</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="제목"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>내용</dt>
                        <dd>
                            <div class="flex">
                                <div class="text"><textarea placeholder="내용을 입력하세요."></textarea></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>링크</dt>
                        <dd id="linkArea">
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="링크를 입력해주세요."></div>
                                <div class="bttn">
                                    <a href="#" class="link delete"><i class="icon icon_delete"></i><span class="blind">링크 제거</span></a>
                                </div>
                            </div>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="링크를 입력해주세요."></div>
                                <div class="bttn">
                                    <a href="#" class="link add"><i class="icon icon_plus"></i><span
                                            class="blind">링크 추가</span></a>
                                </div>
                            </div>
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
                            <div class="flex">
                                <div class="caution">* 용량이 50.0M 파일만 업로드 가능</div>
                            </div>
                        </dd>
                    </dl>
                </div>
                <div class="button">
                    <a href="#" class="btn btn_02">취소</a>
                    <a href="#" class="btn btn_01">등록</a>
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
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>
</html>
