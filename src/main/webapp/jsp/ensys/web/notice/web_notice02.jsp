<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="상담 / 커뮤니티 관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var selectRow = 0;
            var selectRow2 = 0;
            var userCallBack;

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0137', 'ES_Q0138', 'ES_Q0144');
            var ES_Q0137 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0137", true);   //주제
            var ES_Q0138 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0138", true);   //형태
            var ES_Q0144 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0144");   //구분

            $("#S_COMMUNITY_TP").ax5select({options: ES_Q0138});

            $("#S_COMMUNITY_GB").ax5select({options: ES_Q0144});
            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                //조회
                PAGE_SEARCH: function (caller, act, data) {

                    fnObj.gridView01.clear();
                    fnObj.gridView02.clear();
                    fnObj.gridView01.target.dirtyClear();
                    fnObj.gridView02.target.dirtyClear();

                    fnObj.gridView01.target.read().done(function(res){
                        caller.gridView01.setData(res);
                        caller.gridView01.target.focus(selectRow);
                        caller.gridView01.target.select(selectRow);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });


                },
                //저장
                PAGE_SAVE: function (caller, act, data) {

                    var gridView01 = fnObj.gridView01.target.getDirtyData();
                    var gridView02 = fnObj.gridView02.target.getDirtyData();

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["/api/web/notice02", "save"],
                                data: JSON.stringify({
                                    gridView01 : gridView01,
                                    gridView02 : gridView02
                                }),
                                callback: function (res) {
                                    qray.alert('저장되었습니다.').then(function(){
                                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                    })
                                }
                            });
                        }
                    });
                },
                ITEM_CLICK : function(caller, act, data){

                    fnObj.gridView02.clear();
                    fnObj.gridView02.target.read().done(function(res){
                        fnObj.gridView02.setData(res);
                        fnObj.gridView02.setData(res);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });
                },
                //그리드1 추가
                ITEM_ADD: function(caller, act, data){
                    caller.gridView02.clear();
                    fnObj.gridView01.addRow();
                    var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);

                    fnObj.gridView01.target.setValue(lastIdx - 1, "PKG_CD", GET_NO('MA', '23'))
                    fnObj.gridView01.target.setValue(lastIdx - 1, "PKG_NM", '')
                    fnObj.gridView01.target.setValue(lastIdx - 1, "USE_YN", 'Y');
                    fnObj.gridView01.target.setValue(lastIdx - 1, "CREATE_DT", '')
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                //그리드1 삭제
                ITEM_DEL: function(caller, act, data){

                    var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
                    var dataLen = fnObj.gridView01.target.getList().length;

                    if ((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }
                    selectRow = beforeIdx;
                    fnObj.gridView01.delRow('selected');
                    if (beforeIdx > 0 || beforeIdx == 0) {
                        fnObj.gridView01.target.select(selectRow);
                        fnObj.gridView01.target.focus(selectRow);
                    }
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                //그리드2 추가
                ITEM_ADD2: function(caller, act, data){

                    caller.gridView02.addRow();
                    var PKG_CD = caller.gridView01.target.getList('selected')[0].PKG_CD;

                    var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
                    selectRow2 = lastIdx - 1;

                    caller.gridView02.target.select(lastIdx - 1);
                    caller.gridView02.target.focus(lastIdx - 1);

                    caller.gridView02.target.setValue(lastIdx - 1, 'PKG_CD', PKG_CD);
                    caller.gridView02.target.setValue(lastIdx - 1, 'ADV_CD', "");
                    caller.gridView02.target.setValue(lastIdx - 1, 'ADV_NM', "");
                    caller.gridView02.target.setValue(lastIdx - 1, 'SEQ', 0);
                    caller.gridView02.target.setValue(lastIdx - 1, 'AM', 0);
                    caller.gridView02.target.setValue(lastIdx - 1, 'SALE_RT', 0);

                },
                //그리드2 삭제
                ITEM_DEL2: function(caller, act, data){

                    var beforeIdx = fnObj.gridView02.target.selectedDataIndexs[0];
                    var dataLen = fnObj.gridView02.target.getList().length;

                    if ((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }
                    selectRow2 = beforeIdx;
                    fnObj.gridView02.delRow('selected');
                    if (beforeIdx > 0 || beforeIdx == 0) {
                        fnObj.gridView02.target.select(selectRow2);
                        fnObj.gridView02.target.focus(selectRow2);
                    }
                },
            });

            //최상단 이벤트
            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        },
                    });
                }
            });

            /**
             * gridView01
             */
            fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        childGrid : [fnObj.gridView02],
                        type : "POST",
                        classUrl : "/api/web/notice02",
                        methodUrl :  "select",
                        async : false,
                        param : function(){
                            var param = {
                                KEYWORD: nvl($("#KEYWORD").val()),
                                COMMUNITY_GB : nvl($("select[name='S_COMMUNITY_GB']").val()),
                                COMMUNITY_TP : nvl($("select[name='S_COMMUNITY_TP']").val()),
                            };
                            return JSON.stringify(param);
                        },
                        columns: [
                            {key: "COMMUNITY_GB", label: "구분", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0144, this.value);
                                },
                            },
                            {key: "COMMUNITY_TP", label: "형태", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0138, this.value);
                                },
                            },
                            {key: "COMMUNITY_ST", label: "주제", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0137, this.value);
                                },
                            },
                            {key: "TITLE", label: "제목", width: 150, align: "center", sortable: true,},
                            {key: "CONTENTS", label: "내용", width: 200, align: "center", sortable: true,},
                            {key: "HIT", label: "조회수", width: 80, align: "center", sortable: true,},
                            {key: "LIKE_NUM", label: "좋아요", width: 80, align: "center", sortable: true,},
                            {key: "NO_NUM", label: "싫어요", width: 80, align: "center", sortable: true,},
                            {key: "INSERT_DTS", label: "생성일자", width: 150, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeDataFormat(this.value,"yyyyMMddhhmmss")
                                },
                            },
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridView01.target.list[idx];

                                if (selectRow == idx){
                                    return;
                                }

                                selectRow = idx;
                                this.self.focus(idx);
                                this.self.select(idx);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            },
                            onDataChanged: function () {

                            },
                            onDBLClick: function () {
                                $.openCommonPopup("/jsp/ensys/web/notice/noteHelper.jsp", "CallBack", '', '', this.item, 830, 750);
                            }
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DEL);
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length);
                }
            });

            /**
             * gridView02
             */
            fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-02"]'),
                        parentGrid : fnObj.gridView01,
                        type : "POST",
                        classUrl : "/api/web/notice02",
                        methodUrl :  "selectDetail",
                        async : false,
                        param : function(){
                            var selected = fnObj.gridView01.target.getList('selected')[0];
                            return JSON.stringify($.extend({}, selected));
                        },
                        columns: [


                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                                this.self.focus(this.dindex);
                                selectRow2 = this.dindex;
                            },
                            onDataChanged: function () {


                            },
                            onDBLClick: function(){

                             }
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-02-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD2);
                        },
                        "delete": function () {
                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            ACTIONS.dispatch(ACTIONS.ITEM_DEL2);

                            if(beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
                            }
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length);
                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                this.gridView02.initView();

                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };

            fnObj.pageResize = function () {

            };

            $(document).ready(function () {
                changesize();
            });

            $(window).resize(function () {
                changesize();
            });

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();

                if(totheight > 700) {
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }else {
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
                //타이틀을 뺀 상하단 그리드 합친높이
                var tempgridheight = datarealheight - $("#left_title").height();

                $("#left_grid").css("height", tempgridheight / 100 * 99);
                $("#right_grid").css("height", tempgridheight / 100 * 99);
            }

        </script>
    </jsp:attribute>

    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;">
                    <i class="icon_reload"></i></button>
                <button type="button" class="btn btn-info" data-page-btn="search" TRIGGER_NAME="SEARCH" style="width:80px;"><i
                        class="icon_search"></i>조회
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                        class="icon_save"></i>저장
                </button>
            </div>
        </div>

        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tbl" minWidth="500px">
                    <ax:tr>
                        <ax:td label='제목 검색' width="400px">
                            <input type="text" class="form-control" name="KEYWORD"  id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
                        </ax:td>
                        <ax:td label='구분' width="300px">
                            <div id="S_COMMUNITY_GB" name="S_COMMUNITY_GB" data-ax5select="S_COMMUNITY_GB" data-ax5select-config='{}'>
                            </div>
                        </ax:td>
                        <ax:td label='형태' width="300px">
                            <div id="S_COMMUNITY_TP" name="S_COMMUNITY_TP" data-ax5select="S_COMMUNITY_TP" data-ax5select-config='{}'>
                            </div>
                        </ax:td>

                    </ax:tr>
                </ax:tbl>
            </ax:form>
            <div class="H10"></div>
        </div>

        <div style="width:100%;overflow:hidden">
            <div style="width:45%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 상담 / 커뮤니티 리스트
                        </h2>
                    </div>
                    <div class="right">
                        <%--<button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>--%>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:54%;float:right">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 답글
                        </h2>
                    </div>
                    <div class="right">
                        <%--<button type="button" class="btn btn-small" data-grid-view-02-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>--%>
                        <button type="button" class="btn btn-small" data-grid-view-02-btn="delete" style="width:80px;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-02"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="right_grid"
                     name="오른쪽그리드"
                ></div>
            </div>
        </div>
    </jsp:body>
</ax:layout>