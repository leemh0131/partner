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
                                        $("#menuTitle").text($target.text());
                                    }
                                });
                            });
                        </script>
                    </div>
                </div>
                <form class="form" id="createForm" action="/sc112/dm/create" method="POST">
                    <input type="hidden" name="WITHDR_LOCA_ARR" value="">
                    <input type="hidden" name="BANK_CD_ARR" value="">
                    <input type="hidden" name="NO_DEPOSIT_ARR" value="">
                    <input type="hidden" name="NM_DEPOSITOR_ARR" value="">
                    <dl>
                        <dt>피해구분</dt>
                        <dd>
                            <div class="flex">
                                <div class="select">
                                    <select name="DM_TYPE" class="DM_TYPE">
                                        <c:forEach var="code" items="${codes}">
                                            <c:if test="${code.FIELD_CD eq 'ES_Q0139'}">
                                            <option value="${code.SYSDEF_CD}">${code.SYSDEF_NM}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl id="DM_KIND" style="display: none;">
                        <dt>피해종류</dt>
                        <dd>
                            <div class="flex">
                                <div class="select">
                                    <select name="DM_KIND">
                                        <c:forEach var="code" items="${codes}">
                                            <c:if test="${code.FIELD_CD eq 'ES_Q0140'}">
                                            <option value="${code.SYSDEF_CD}">${code.SYSDEF_NM}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>업체명</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="COMP_NM" type="text" placeholder="업체명"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>차용사이트</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="BORW_SITE" type="text" placeholder="차용사이트"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>연락처</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="DEBTOR_TEL" type="text" placeholder="연락처"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>카카오톡</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="DEBTOR_KAKAO" type="text" placeholder="카카오톡"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>텔레그램</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="DEBTOR_TELE" type="text" placeholder="텔레그램"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>기타SNS</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="DEBTOR_SNS" type="text" placeholder="기타SNS"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>상환계좌</dt>
                        <dd>
                            <div class="flex col">
                                <div class="select w200">
                                    <select name="BANK_CD">
                                        <option>은행명</option>
                                        <c:forEach var="code" items="${codes}">
                                            <c:if test="${code.FIELD_CD eq 'ES_Q0009'}">
                                            <option value="${code.SYSDEF_CD}">${code.SYSDEF_NM}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="input"><input name="NO_DEPOSIT" type="text" placeholder="계좌번호를 입력하세요."></div>
                                <div class="flex">
                                    <div class="input w200"><input name="NM_DEPOSITOR" type="text" placeholder="입금자명"></div>
                                    <div class="bttn"><a href="#" class="btn bank">추가</a></div>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>스마트출금위치</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="WITHDR_LOCA" type="text" placeholder="스마트출금위치"></div>
                                <div class="bttn"><a href="#" class="btn smart">추가</a></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>고소한경찰서명</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="COMPL_POLICE" type="text" placeholder="고소한경찰서명"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>피해내용</dt>
                        <dd>
                            <div class="flex">
                                <div class="text"><textarea name="DM_CONTENTS" placeholder="직접 입력하세요."></textarea></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>비밀번호</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input name="PW" type="password" placeholder="비밀번호"></div>
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
                        const dmType = $("#DM_TYPE").val();
                        const dmKind = $("#DM_KIND").val();
                        const compNm = $("input[name='COMP_NM']").val().trim();
                        const borwSite = $("input[name='BORW_SITE']").val().trim();
                        const debtorTel = $("input[name='DEBTOR_TEL']").val().trim();
                        const debtorKakao = $("input[name='DEBTOR_KAKAO']").val().trim();
                        const debtorTele = $("input[name='DEBTOR_TELE']").val().trim();
                        const debtorSns = $("input[name='DEBTOR_SNS']").val().trim();
                        const complPolice = $("input[name='COMPL_POLICE']").val().trim();
                        const dmContents = $("textarea[name='DM_CONTENTS']").val().trim();
                        const pw = $("input[name='PW']").val().trim();

                        if (compNm === "") {
                            alert("업체명을 입력하세요.");
                            return false;
                        }
                        if (dmContents === "") {
                            alert("피해내용을 입력하세요.");
                            return false;
                        }
                        if (pw === "") {
                            alert("비밀번호를 입력하세요.");
                            return false;
                        }

                        $('input[name="BANK_CD_ARR"]').val($('select[name="BANK_CD"]').toArray().map(s => s.value).join('|'));
                        $('input[name="NO_DEPOSIT_ARR"]').val($('input[name="NO_DEPOSIT"]').toArray().map(s => s.value).join('|'));
                        $('input[name="NM_DEPOSITOR_ARR"]').val($('input[name="NM_DEPOSITOR"]').toArray().map(s => s.value).join('|'));
                        $("input[name='WITHDR_LOCA_ARR']").val($("input[name='WITHDR_LOCA']").map(function() {return $(this).val().trim();}).get().join(','));
                        $("#createForm").submit();
                    }
                    $(document).on("change", ".DM_TYPE", function () {
                        if ("001" === $(this).val()) {
                            $("#DM_KIND").hide();
                        } else {
                            $("#DM_KIND").show();
                        }
                    });
                    $(function () {
                        $(document).on("click", "dd > .flex .btn.smart", function (e) {
                            e.preventDefault();
                            let currentFlex = $(this).closest(".flex");
                            let area = currentFlex.closest("dd");
                            let isAdd = $(this).hasClass("add") || !$(this).hasClass("delete");

                            if (isAdd) {
                                $(this)
                                    .removeClass("add")
                                    .addClass("delete")
                                    .html('<i class="icon icon_delete"></i>제거');
                                let newFlex =
                                    `<div class="flex">
                                        <div class="input">
                                            <input name="WITHDR_LOCA" type="text" placeholder="스마트출금위치">
                                        </div>
                                        <div class="bttn"><a href="#" class="btn smart">추가</a></div>
                                    </div>`;
                                area.append(newFlex);
                            }
                        });
                        $(document).on("click", "dd > .flex .btn.delete.smart", function (e) {
                            e.preventDefault();
                            let area = $(this).closest("dd");
                            $(this).closest(".flex").remove();
                            let lastFlex = area.find(".flex").last();

                            area.find(".flex .btn.smart")
                                .removeClass("add")
                                .addClass("delete")
                                .html('<i class="icon icon_delete"></i>제거');

                            lastFlex.find(".btn.smart")
                                .removeClass("delete")
                                .addClass("add")
                                .html('<i class="icon icon_plus"></i>추가');
                        });
                    });

                    $(function () {
                        $(document).on("click", "dd > .flex .btn.bank", function (e) {
                            e.preventDefault();
                            let currentFlex = $(this).closest(".flex");
                            let area = currentFlex.closest("dd");
                            let isAdd = $(this).hasClass("add") || !$(this).hasClass("delete");

                            if (isAdd) {
                                $(this)
                                    .removeClass("add")
                                    .addClass("delete")
                                    .html('<i class="icon icon_delete"></i>제거');

                                let newFlex =
                                    `<div class="flex col">
                                        <div class="select w200">
                                            <select name="BANK_CD">
                                                <option>은행명</option>
                                                <c:forEach var="code" items="${codes}">
                                                    <c:if test="${code.FIELD_CD eq 'ES_Q0009'}">
                                                    <option value="${code.SYSDEF_CD}">${code.SYSDEF_NM}</option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="input"><input name="NO_DEPOSIT" type="text" placeholder="계좌번호를 입력하세요."></div>
                                        <div class="flex">
                                            <div class="input w200"><input name="NM_DEPOSITOR" type="text" placeholder="입금자명"></div>
                                            <div class="bttn"><a href="#" class="btn bank">추가</a></div>
                                        </div>
                                    </div>`;

                                area.append(newFlex);
                            }
                        });

                        // 제거 버튼 클릭 시
                        $(document).on("click", "dd > .flex .btn.delete.bank", function (e) {
                            e.preventDefault();
                            let area = $(this).closest("dd");
                            $(this).closest(".flex.col").remove();

                            let lastFlex = area.find(".flex.col").last();

                            // 전체 버튼을 제거 버튼으로 통일
                            area.find(".flex .btn.bank")
                                .removeClass("add")
                                .addClass("delete")
                                .html('제거');

                            // 마지막만 추가 버튼으로 변경
                            lastFlex.find(".btn.bank")
                                .removeClass("delete")
                                .addClass("add")
                                .html('추가');
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
