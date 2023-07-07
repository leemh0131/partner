<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="상세정보"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">


        <ax:script-lang key="ax.script"/>


        <script type="text/javascript">
            var url = document.location.search;

            var search = document.location.search.split('?')[1].split('&');
            var InitData = {};

            for (var i = 0; i < search.length; i++) {
                var key = search[i].split('=')[0];
                var value = search[i].split('=')[1];
                eval("InitData." + key + "= value");
            }

            var parentUrl = (InitData.BOARD_TYPE == 'notice') ? "/jsp/ensys/web/notice/web_notice01.jsp" : "../bbs/p_cz_q_bbs_file_m.jsp";

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["WEBNOTICE01", "updateHit"],
                        async: false,
                        data: JSON.stringify({
                            "BOARD_TYPE": InitData.BOARD_TYPE,
                            "SEQ": Number(InitData.seq),
                            "OPT": "UPT",
                            "NOWPAGE": 0,
                            "KEYWORD": 0,
                            "CONDITION": 0,
                            "PAGING_SIZE": 0
                        }),
                        callback: function (res) {

                            axboot.ajax({
                                type: "POST",
                                url: ["WEBNOTICE01", "selectDetail"],
                                async: false,
                                data: JSON.stringify({
                                    "BOARD_TYPE": InitData.BOARD_TYPE,
                                    "SEQ": Number(InitData.seq),
                                    "OPT": "DET"
                                }),
                                callback: function (res) {
                                    $("#HIT").html("");
                                    $("#INFO").html("");

                                    var result = res.map;
                                    if (result.INSERT_ID == SCRIPT_SESSION.userId) {
                                        $("#updateBtn").show();
                                        $("#deleteBtn").show();
                                    } else {
                                        $("#updateBtn").hide();
                                        $("#deleteBtn").hide();
                                    }
                                    document.getElementById('CONTENTS').innerHTML = result.CONTENTS;
                                    // $("#CONTENTS").val(result.CONTENTS);
                                    $("#TITLE").val(result.TITLE);
                                    $("#HIT").append("조회 : " + result.HIT);
                                    var html = "";
                                    html += $.changeDataFormat(result.INSERT_DTS, "yyyyMMddhhmmss");
                                    html += " | 작성자 : ";
                                    html += result.USER_NM;
                                    $("#INFO").append(html);

                                    axboot.ajax({
                                        type: "POST",
                                        url: ["WEBNOTICE01", "selectDetailLIK"],
                                        async: false,
                                        data: JSON.stringify({
                                            "BOARD_TYPE": InitData.BOARD_TYPE,
                                            "SEQ": Number(InitData.seq),
                                            "OPT": "LIK"
                                        }),
                                        callback: function (res) {

                                            var query = "/jsp/ensys/web/notice/web_notice_detail.jsp?";
                                            for (var i = 0; i < res.list.length; i++) {
                                                var result = res.list[i];
                                                if (result.STAT_CD == 'NEXT') {
                                                    var title = result.TITLE;
                                                    $("#NEXT").text(title);
                                                    $("#nextLink").attr("href", query + "seq=" + result.SEQ + "&BOARD_TYPE=" + InitData.BOARD_TYPE);
                                                }
                                                if (result.STAT_CD == 'PREV') {
                                                    var title = result.TITLE;
                                                    $("#PREV").text(title);
                                                    $("#prevLink").attr("href", query + "seq=" + result.SEQ + "&BOARD_TYPE=" + InitData.BOARD_TYPE);
                                                }
                                            }
                                            if (res.list.length == 1) {
                                                if (res.list[0].STAT_CD == 'NEXT') {
                                                    var title = "이전글이 없습니다.";
                                                    $("#PREV").text(title);
                                                    $("#prevLink").attr("href", "#");
                                                }
                                                if (res.list[0].STAT_CD == 'PREV') {
                                                    var title = "다음글이 없습니다.";
                                                    $("#NEXT").text(title);
                                                    $("#nextLink").attr("href", "#");
                                                }
                                            }
                                            if (res.list.length == 0) {
                                                var title = "이전글이 없습니다.";
                                                $("#PREV").text(title);
                                                $("#prevLink").attr("href", "#");

                                                var title = "다음글이 없습니다.";
                                                $("#NEXT").text(title);
                                                $("#nextLink").attr("href", "#");
                                            }

                                        }
                                    })
                                }
                            });
                        }
                    });

                    return false;
                },
                ITEM_RETURN: function (caller, act, data) {

                    location.href = parentUrl + url;
                },
                ITEM_UPDATE: function (caller, act, data) {
                    userCallBack = function(e){
                        qray.alert('성공적으로 저장되었습니다.').then(function(){
                            window.location.reload();
                        });
                    }
                    $.openCommonPopup("/jsp/ensys/web/notice/web_notice_write.jsp", "userCallBack", null, '',
                        {
                            BOARD_TYPE: InitData.BOARD_TYPE,
                            SEQ: Number(InitData.seq),
                            CONTENTS: document.getElementById('CONTENTS').innerHTML,
                            TITLE: $("#TITLE").val()
                        }, _pop_width1000, _pop_height, _pop_top);

                },
                ITEM_DELETE: function (caller, act, data) {
                    var data = {
                        "BOARD_TYPE": InitData.BOARD_TYPE,
                        "SEQ": Number(InitData.seq)
                    };
                    qray.confirm({
                        msg: "삭제하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {

                            axboot.ajax({
                                type: "PUT",
                                url: ["WEBNOTICE01", "delete"],
                                data: JSON.stringify(data),
                                callback: function (result) {
                                    qray.alert('성공적으로 삭제되었습니다.').then(function(){
                                        location.href = parentUrl;
                                    })
                                }
                            })
                        }
                    })
                },
            });

            function openCalenderModal(callBack, viewName, initData) {
                var map = new Map();
                map.set("modal", calenderModal);
                map.set("modalText", "calenderModal");
                map.set("viewName", viewName);
                map.set("initData", initData);

                $.openCommonUtils(callBack, map, 'calender');
            }

            /*function openFileModal(callBack, viewName, initData) {
                var map = new Map();
                map.set("modal", FileBrowserModal);
                map.set("modalText", "FileBrowserModal");
                map.set("viewName", viewName);
                map.set("initData", initData);

                $.openCommonUtils(callBack, map, 'fileBrowser');
            }*/

            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                this.pageButtonView.initView();

                $("#FILE").setTableId(InitData.BOARD_TYPE);
                $("#FILE").setTableKey(InitData.seq);
                $("#FILE").read();
                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };


            fnObj.pageResize = function () {

            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "update": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_UPDATE);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DELETE);
                        },
                        "list": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_RETURN);
                        }
                    });
                }
            });

            var _pop_top = 0;
            var _pop_top450 = 0;
            var _pop_height = 0;
            var _pop_width1000 = 0;
            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if (totheight > 700) {
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top450 = parseInt((totheight - 450) / 2);
                    _pop_width1000 = 1000;
                } else {
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top450 = parseInt((totheight - 450) / 2);
                    _pop_width1000 = 900;
                }
            }

            $(window).resize(function () {
                changesize();
                var winHeight = $(window).height();
                $("#scrollBody").attr("style", "overflow-y :auto;height:" + (winHeight - 100) + "px;");
            });

            $(document).ready(function () {
                changesize();
                var winHeight = $(window).height();
                $("#scrollBody").attr("style", "overflow-y :auto;height:" + (winHeight - 100) + "px;");
            });

            var getXmlHttpRequest = function () {
                if (window.ActiveXObject) {
                    try {
                        return new ActiveXObject("Msxml2.XMLHTTP");
                    } catch (e) {
                        try {
                            return new ActiveXObject("Microsoft.XMLHTTP");
                        } catch (e1) {
                            qray.alert('에러에러');
                        }
                    }
                } else if (window.XMLHttpRequest) {
                    return new XMLHttpRequest();
                } else {
                    qray.alert('에러에러');
                }
            }

        </script>
    </jsp:attribute>
    <jsp:body>
        <style>
            i {
                font-style: italic;
            }

            * {
                -moz-box-sizing: border-box;
                box-sizing: border-box;
            }

            html, body {
                margin: 0;
                padding: 0;
                width: 100%;
                height: 100%;
                font-size: 12px;
            }

            .wrapperDiv {
                width: 100%;
                height: 100%;
            }

            .leftDiv {
                background-color: #fcf8e3;
                position: absolute;
                width: auto;
                height: auto;
                top: 0px;
                right: 0px;
                bottom: 0px;
                left: 0px;
                margin-top: 100px;
                overflow: auto;
            }

            .rightDiv {
                background-color: #dff0d8;
                position: absolute;
                top: 0;
                right: 0;
                width: 100%;
                height: 100px;
            }

            .table-area {
                position: relative;
                z-index: 0;
            }

            table.responsive-table {
                display: table;
                table-layout: fixed;
                width: 100%;
                height: 100%;
            }

            table.responsive-table td {

            }

            .td {
                line-height: 5em;
                height: 50px;
            }

            .th {
                line-height: 5em;
                height: 50px;
                text-align: center;
            }

            td {
                border: 1px solid #ddd;
                padding: 25px;
            }


            #jb-container {
                padding: auto;
                margin: auto;
                width: 100%;
                border: 0px solid #eee;
            }

            #jb-content {
                width: 100%;
                height: 480px;
                min-height: 100px;
                max-height: 800px;
                border: 0px solid #eee;
            }

            #jb-footer1 {
                margin-top: 40px;
                clear: both;
                border: 0px solid #eee;
            }

            #jb-footer2 {
                align: center;
                clear: both;
                border: 0px solid #eee;
            }

            .inputText {
                outline-style: none;
                border: 0px solid #eee;
            }

            .left-box {
                float: left;
                width: 90%;
            }

            .right-box {
                float: right;
                padding-bottom: 5px;
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
                padding: 20px;
                /* resize: both; !* 사용자 변경이 모두 가능 *!
                 resize: horizontal; !* 좌우만 가능 *!
                 resize: vertical; !* 상하만 가능 *!*/
            }
            p {
                margin: 0px
            }
        </style>

        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload"
                        onclick="window.location.reload();" style="width:80px;">
                    <i class="icon_reload"></i></button>
                <button type="button" class="btn btn-info" id="updateBtn" data-page-btn="update"
                        style="width:80px;">수정
                </button>
                <button type="button" class="btn btn-info" id="deleteBtn" data-page-btn="delete"
                        style="width:80px;">삭제
                </button>
                <button type="button" class="btn btn-info" data-page-btn="list" style="width:80px;">목록</button>
            </div>
        </div>
        <div id="scrollBody" style="overflow-y :auto;height: 1000px;">
        <div id="jb-container">
            <div id="jb-header">
                <table class="responsive-table table">
                    <colgroup>
                        <col width="100px">
                        <col width="*">
                    </colgroup>
                    <tbody>
                    <tr>
                        <td class='th' style="vertical-align: middle;">제목</td>
                        <td class='td' style="vertical-align: middle;">
                            <div class="left-box"><input type="text" id="TITLE" class="inputText" style="width: 105%;"  disabled>
                            </div>
                            <div class="right-box" align="right" id="HIT"></div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div id="jb-content">
                <div class="right-box" align="right" id="INFO">
                </div>
                <br>
                <div id="CONTENTS" class="noresize" readonly></div>
            </div>
            <div id="jb-footer1">
                <table class="responsive-table table">
                    <colgroup>
                        <col width="100px">
                        <col width="*">
                    </colgroup>
                    <tbody>
                    <tr>
                        <td class='th' style="vertical-align: middle;">첨부파일</td>
                        <td class='td' style="vertical-align: middle; margin-left: 10px;">
                            <filemodal id="FILE" MODE="2" WIDTH="100%" HEIGHT="30px" READONLY DISABLED="true"/>
                        </td>
                    </tr>
                    <tr>
                        <td class='th' style="vertical-align: middle;">이전글</td>
                        <td class='td' style="vertical-align: middle;">
                            <p class="gray_font"><a style="margin-left: 10px;" id="prevLink"><span id="PREV"></span></a>
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td class='th' style="vertical-align: middle;">다음글</td>
                        <td class='td' style="vertical-align: middle;">
                            <p class="gray_font"><a style="margin-left: 10px;" id="nextLink"><span id="NEXT"></span></a>
                            </p>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </jsp:body>
</ax:layout>