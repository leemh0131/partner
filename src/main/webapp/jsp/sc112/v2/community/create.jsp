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
                                    debugger;
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
                </div>
                <form class="form" id="createForm" action="/sc112/community/create" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="COMMUNITY_TP" value="${param.COMMUNITY_TP}">
                    <input type="hidden" name="COMMUNITY_ST" value="${param.COMMUNITY_ST}">
                    <input type="hidden" name="LINK_ARR" value="">
                    <dl class="w50p">
                        <dt>닉네임</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="NAME" type="text" placeholder="닉네임"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl class="w50p">
                        <dt>비밀번호</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="PW" type="password" placeholder="비밀번호"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>제목</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="TITLE" type="text" placeholder="제목"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>내용</dt>
                        <dd>
                            <div class="flex">
                                <div class="text"><textarea name="CONTENTS" placeholder="내용을 입력하세요."></textarea></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>링크</dt>
                        <dd id="linkArea">
                            <div class="flex">
                                <div class="input"><input name="LINK" type="text" placeholder="링크를 입력해주세요."></div>
                                <div class="bttn">
                                    <a href="#" class="link delete"><i class="icon icon_delete"></i><span class="blind">링크 제거</span></a>
                                </div>
                            </div>
                            <div class="flex">
                                <div class="input"><input name="LINK" type="text" placeholder="링크를 입력해주세요."></div>
                                <div class="bttn">
                                    <a href="#" class="link add"><i class="icon icon_plus"></i><span class="blind">링크 추가</span></a>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>첨부</dt>
                        <dd>
                            <div class="flex">
                                <div class="file">
                                    <label class="btn"><input name="FILE" type="file" id="file_input">파일선택</label>
                                    <span class="txt">선택된 파일 없음</span>
                                </div>
                            </div>
                            <div class="flex">
                                <div class="caution">* 용량이 50.0M 파일만 업로드 가능</div>
                            </div>
                        </dd>
                    </dl>
                </form>
                <div class="button">
                    <a href="javascript:history.back();" class="btn btn_02">취소</a>
                    <a href="#" class="btn btn_01" onclick="submitCreateForm();">등록</a>
                </div>
                <script>
                    function submitCreateForm() {
                        const name = $("input[name='NAME']").val().trim();
                        const pw = $("input[name='PW']").val().trim();
                        const title = $("input[name='TITLE']").val().trim();
                        const contents = $("textarea[name='CONTENTS']").val().trim();

                        if (name === "") {
                            alert("닉네임을 입력하세요.");
                            return false;
                        }
                        if (pw === "") {
                            alert("비밀번호를 입력하세요.");
                            return false;
                        }
                        if (title === "") {
                            alert("제목을 입력하세요.");
                            return false;
                        }
                        if (contents === "") {
                            alert("내용을 입력하세요.");
                            return false;
                        }

                        let linkArr = [];
                        $("input[name='LINK']").each(function () {
                           linkArr.push($(this).val());
                        });
                        $("input[name='LINK_ARR']").val(linkArr);
                        $("#createForm").submit();
                    }
                    $(function () {
                        $(document).on("click", ".link.add", function (e) {
                            e.preventDefault();

                            $(this)
                                .removeClass("add")
                                .addClass("delete")
                                .html('<i class="icon icon_delete"></i><span class="blind">링크 제거</span>');

                            let newFlex = `<div class="flex">
                                                <div class="input">
                                                    <input name="LINK" type="text" placeholder="링크를 입력해주세요.">
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
