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
            var BOARD_TYPE = nvl(initData["BOARD_TYPE"], '') != '' ? true : false;
            var SEQ = nvl(initData["SEQ"], '') != '' ? true : false;
            var CONTENTS = nvl(initData["CONTENTS"], '') != '' ? true : false;
            var TITLE = nvl(initData["TITLE"], '') != '' ? true : false;

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {

                PAGE_SAVE: function (caller, act, data) {
                    var DATA = {};
                    DATA.BOARD_TYPE = initData["BOARD_TYPE"];
                    DATA.TITLE = $("#TITLE").val();
                    oEditors.getById["community_editor"].exec("UPDATE_CONTENTS_FIELD", []);
                    let content = document.getElementById("community_editor").value;
                    DATA.CONTENTS = content;
                    DATA.SEQ = Number(initData["SEQ"]);

                    var parameterData = {};
                    parameterData.bbsData = DATA;
                    parameterData.fileData = $("#FILE").saveData();

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["SPDNORMAL00001", "save"],
                                data: JSON.stringify(parameterData),
                                callback: function (result) {
                                    parent[param.callBack](DATA);
                                    eval("parent." + param.modalName + ".close()");
                                }
                            });
                        }
                    })
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
                        bUseModeChanger : false, // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
                        bUseToolbar : true
                    },
                    fOnAppLoad : function() {
                        // Editor 에 값 셋팅
                        if(CONTENTS){
                            oEditors.getById["community_editor"].exec("PASTE_HTML", [initData.CONTENTS]);
                        } else {
                            oEditors.getById["community_editor"].exec("PASTE_HTML", ['']);
                        }
                    },
                });

                if (TITLE) {
                    $("#TITLE").val(initData["TITLE"])
                }
                $("#FILE").setTableId(initData["BOARD_TYPE"]);
                $("#FILE").setTableKey(initData["SEQ"]);
                $("#FILE").read();

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
                <button type="button" class="btn btn-info" data-page-btn="save">저장</button>
                <button type="button" class="btn btn-info" data-page-btn="close">취소</button>
            </div>
        </div>

        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tbl" minWidth="500px">
                    <ax:tr>
                        <ax:td label='제목' width="400px">
                            <input type="text" id="TITLE" class="inputText" style="width: 300px; height: 30px;">
                        </ax:td>
                        <ax:td label='형태' width="100px">

                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>
        <br>
        <div id="content" style="overflow-y:auto;" name="콘텐츠">
            <ax:form name="binder-form">
                <ax:tbl clazz="ax-search-tb2" minWidth="650px">
                    <ax:tr>
                        <ax:td label='내용' width="100%">
                            <div id="smarteditor" style="margin-top:10px;height:360px;">
                            <textarea name="community_editor" id="community_editor"
                                      rows="35" cols="10"
                                      placeholder="내용을 입력해주세요"
                                      style="width:100%;height:310px;"></textarea>
                            </div>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>
        <%--<div id="jb-container" style="overflow-scrolling: auto;">
            <div id="jb-content">
                <table style="minWidth:800px;">
                    <tr>
                        <td style="background: #f6f6f6; width: 150px; text-align: center; letter-spacing: 2px;"><label
                                style="color: #656a6f;">첨부파일</label>
                        </td>
                        <td style="padding: 10px;">

                            <filemodal id="FILE" MODE="2" WIDTH="100%" HEIGHT="30px" READONLY/>

                        </td>
                    </tr>
                </table>
            </div>

            <div align="center" style="padding: 30px;">
                <button type="button" class="btn btn-info" data-page-btn="save">저장</button>
                <button type="button" class="btn btn-info" data-page-btn="close">취소</button>
            </div>
        </div>--%>
    </jsp:body>
</ax:layout>