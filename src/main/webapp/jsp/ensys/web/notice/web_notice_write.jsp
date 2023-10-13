<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="글쓰기"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript" src="/assets/naver_smart_editor2/js/HuskyEZCreator.js?" charset="utf-8"></script>
        <link rel="stylesheet" type="text/css" href="/assets/naver_smart_editor2/css/smart_editor2_in.css">
        <script type="text/javascript">
            let oEditors = []
            var param = ax5.util.param(ax5.info.urlUtil().param);
            var initData = parent[param.modalName].modalConfig.sendData().initData;

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SAVE: function (caller, act, data) {

                    //네이버 에디터 내용 community_editor 에 저장 함수
                    oEditors.getById["community_editor"].exec("UPDATE_CONTENTS_FIELD", []);
                    let COMPANY_INTRO_HTML = nvl($("#community_editor").val());
                    parent[param.callBack](COMPANY_INTRO_HTML);
                    eval("parent." + param.modalName + ".close()");

                },
                PAGE_CLOSE: function (caller, act, data) {
                    eval("parent." + param.modalName + ".close()");
                },
            });

            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                this.pageButtonView.initView();

                nhn.husky.EZCreator.createInIFrame({
                    oAppRef: oEditors,
                    elPlaceHolder: "community_editor",
                    sSkinURI: "/assets/naver_smart_editor2/SmartEditor2SkinCommunity.html",
                    fCreator: "createSEditor2",
                    htParams : {
                        bUseModeChanger : true, // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
                        bUseToolbar : true
                    },
                    fOnAppLoad : function() {
                        // Editor 에 값 셋팅
                        if(nvl(initData.CONTENTS) != ''){
                            oEditors.getById["community_editor"].exec("PASTE_HTML", [initData.CONTENTS]);
                        } else {
                            oEditors.getById["community_editor"].exec("PASTE_HTML", ['']);
                        }
                    },
                });

            };


            fnObj.pageResize = function () {

            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        },
                        "close": function () {
                            ACTIONS.dispatch((ACTIONS.PAGE_CLOSE));
                        }
                    });
                }
            });

        </script>
    </jsp:attribute>
    <jsp:body >
        <%--상단버튼--%>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-info" data-page-btn="save">확인</button>
                <button type="button" class="btn btn-info" data-page-btn="close">취소</button>
            </div>
        </div>
        <br>
        <div id="smarteditor" style="margin-top:10px;height:600px;">
                            <textarea name="community_editor" id="community_editor"
                                      rows="35" cols="10"
                                      placeholder="내용을 입력해주세요"
                                      style="width:100%;height:540px;"></textarea>
        </div>
    </jsp:body>
</ax:layout>