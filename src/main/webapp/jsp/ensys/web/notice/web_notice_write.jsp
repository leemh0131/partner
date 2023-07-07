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
        <script type="text/javascript">
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
                    DATA.CONTENTS = document.getElementById('CONTENTS').innerHTML;
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
                                url: ["WEBNOTICE01", "save"],
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

                if (CONTENTS) {
                    document.getElementById('CONTENTS').innerHTML = initData["CONTENTS"];
                }
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

            function htmledit(excute, values) {
                if (values == null) {
                    document.execCommand(excute);
                } else {
                    document.execCommand(excute, "", values);
                }
            }


        </script>
    </jsp:attribute>
    <jsp:body>
        <style>

            i {
                font-style: italic;
            }

            html, body {
                margin: 0;
                padding: 0;
                width: 100%;
                height: 100%;
                font-size: 12px;
            }

            td {
                border: 1px solid #ddd;
                padding-top: 7px;
            }


            #jb-container {
                padding: auto;
                margin: auto;
                width: 100%;
                height: 500px;
                border: 0px solid #eee;
            }

            #jb-header {
                margin-bottom: 20px;
            }

            #jb-content {
                width: 100%;
                height: 400px;
                min-height: 50px;
                max-height: 500px;
                border: 0px solid #eee;
            }

            .inputText {
                outline-style: none;
                border: 0px solid #eee;
            }

            input:disabled {
                background-color: #ffffff;
            }

            .noresize {
                outline-style: none;
                border: 1px solid #eee;
                resize: none; /* 사용자 임의 변경 불가 */
                width: 100%;
                height: 100%;
                overflow: auto;
            }

            .editor {
                margin: 0 auto 5px;
                height: 40px;
                border: 1px solid #ddd;
            }

            .editor table {
                border: 0px;
            }

            .editor table tr {
                border: 0px;
            }

            .editor table td {
                border: 0px;
            }

            .editor button:first-child {
                width: 45px;
                height: 25px;
                border-radius: 3px;
                background: none;
                border: none;
                box-sizing: border-box;
                padding: 0;
                color: #a6a6a6;
                cursor: pointer;
                outline: none;
            }

            .editor button {
                width: 45px;
                height: 25px;
                border-radius: 3px;
                background: none;
                border-left: 1px solid #eee;
                box-sizing: border-box;
                padding: 0;
                color: #a6a6a6;
                cursor: pointer;
                outline: none;
            }

            .editor button:last-child {
                width: 45px;
                height: 25px;
                border-radius: 3px;
                background: none;
                border-right: 1px solid #eee;
                box-sizing: border-box;
                padding: 0;
                color: #a6a6a6;
                cursor: pointer;
                outline: none;
            }

            .editor select {
                width: 80px;
                height: 25px;
                border-radius: 3px;
                background: none;
                border: 1px solid #eee;
                box-sizing: border-box;
                padding: 0;
                color: #a6a6a6;
                cursor: pointer;
                outline: none;
            }
        </style>

        <div id="jb-container">
            <div id="jb-header">
                <table style="minWidth:800px;">
                    <tr>
                        <td style="background: #f6f6f6; width: 150px; text-align: center; letter-spacing: 2px;"><label
                                style="color: #656a6f;">제목</label>
                        </td>
                        <td style="padding: 10px;">
                            <input type="text" id="TITLE" class="inputText" style="width: 760px; height: 30px;">
                        </td>
                    </tr>
                </table>
            </div>
            <div id="jb-content">
                <div class="editor" for="CONTENTS">
                    <table>
                        <colgroup>
                            <col style="width:120px">
                            <col style="width:100px">
                            <col style="width:95px">
                            <col>
                        </colgroup>
                        <tr>
                            <td style="padding-left:20px;">
                                <select onchange="htmledit('fontname',this.value);">
                                    <option value="돋음">글꼴</option>
                                    <option value="돋음">돋음</option>
                                    <option value="굴림">굴림</option>
                                    <option value="궁서">궁서</option>
                                </select>
                            </td>
                            <td>
                                <select onchange="htmledit('fontSize',this.value);">
                                    <option value="2">크기</option>
                                    <option value="2">2</option>
                                    <option value="4">4</option>
                                    <option value="6">6</option>
                                    <option value="8">8</option>
                                </select>
                            </td>
                            <!--
                            <td style="padding-left: 10px;"><img src="/assets/images/editor/btn_n_bold.gif"
                                                                 style="height: 25px;" onclick="htmledit('BOLD');">
                            </td>
                            <td><img src="/assets/images/editor/btn_n_underline.gif" style="height: 25px;"
                                     onclick="htmledit('underline');"></td>
                            <td><img src="/assets/images/editor/btn_n_Italic.gif" style="height: 25px;"
                                     onclick="htmledit('italic')"></td>

                            <td style="padding-left: 10px;"><img src="/assets/images/editor/btn_n_alignleft.gif"
                                                                 style="height: 25px;" onclick="htmledit('justifyleft');">
                            </td>
                            <td><img src="/assets/images/editor/btn_n_aligncenter.gif" style="height: 25px;"
                                     onclick="htmledit('justifycenter');">
                            </td>
                            <td><img src="/assets/images/editor/btn_n_alignright.gif" style="height: 25px;"
                                     onclick="htmledit('justifyright');"></td>
                            <td><img src="/assets/images/editor/btn_n_alignjustify.gif" style="height: 25px;"
                                     onclick="htmledit('justify');">
                            </td>
                            -->
                            <td style="font-size:0;">
                                <img src="/assets/images/editor/btn_n_bold.gif" style="display:inline-block; height: 25px;" onclick="htmledit('BOLD');">
                                <img src="/assets/images/editor/btn_n_underline.gif" style="display:inline-block; height: 25px;" onclick="htmledit('underline');">
                                <img src="/assets/images/editor/btn_n_Italic.gif" style="display:inline-block; height: 25px;" onclick="htmledit('italic')">
                            </td>
                            <td style="font-size:0;">
                                <img src="/assets/images/editor/btn_n_alignleft.gif" style="display:inline-block; height: 25px;" onclick="htmledit('justifyleft');">
                                <img src="/assets/images/editor/btn_n_aligncenter.gif" style="display:inline-block; height: 25px;" onclick="htmledit('justifycenter');">
                                <img src="/assets/images/editor/btn_n_alignright.gif" style="display:inline-block; height: 25px;" onclick="htmledit('justifyright');">
                                <img src="/assets/images/editor/btn_n_alignjustify.gif" style="display:inline-block; height: 25px;" onclick="htmledit('justify');">
                            </td>
                        </tr>
                    </table>
                </div>


                <table style="minWidth:800px;">
                    <tr>
                        <td style="background: #f6f6f6; width: 150px; text-align: center; letter-spacing: 2px; padding:10px;"><label
                                style="color: #656a6f;">내용</label>
                        </td>
                        <td style="padding: 10px;">
                            <div id="CONTENTS" name="CONTENTS" class="noresize" contenteditable="true"
                                 style="width: 765px; height: 300px; "/>
                        </td>
                    </tr>
                </table>
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
        </div>
    </jsp:body>
</ax:layout>