<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="광고패키지"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>

        <style>
            .red {
                background: #f8d2cb !important;
            }

        </style>

        <script type="text/javascript">
            var selectRow = 0;
            var selectRow2 = 0;
            var userCallBack;

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0001');
            var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", true);   //사용여부

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
                        if (res.list.length <= selectRow) {
                            selectRow = 0
                        }
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

                    //fnObj.gridView01.target.getDirtyData().verify[0]


                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["/api/web/blurb02", "save"],
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

                    var selected = caller.gridView01.target.getList('selected')[0];

                    caller.gridView02.addRow();
                    var PKG_CD = caller.gridView01.target.getList('selected')[0].PKG_CD;

                    var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
                    selectRow = lastIdx - 1;

                    caller.gridView02.target.select(lastIdx - 1);
                    caller.gridView02.target.focus(lastIdx - 1);

                    // caller.gridView02.target.setValue(lastIdx - 1, 'COMPANY_CD', selected.COMPANY_CD);
                    caller.gridView02.target.setValue(lastIdx - 1, 'PKG_CD', PKG_CD);
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
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        childGrid : [fnObj.gridView02],
                        type : "POST",
                        classUrl : "/api/web/blurb02",
                        methodUrl :  "packageHeader",
                        async : false,
                        param : function(){
                            var param = {

                            }
                            return JSON.stringify(param);
                        },
                        columns: [
                            {
                                key: "PKG_CD", label: "패키지코드", width: 150, align: "left", editor: {
                                    type: false,
                                    disabled: function () {
                                        var created = fnObj.gridView01.target.getList('selected')[0].__created__;

                                        if(nvl(created, '') == '') {
                                            return true;
                                        }else {
                                            return false;
                                        }
                                    }
                                }, sortable: true,
                            },
                            {
                                key: "PKG_NM",
                                label: "패키지명",
                                width: '150',
                                align: "left",
                                editor: {type: "text"},
                                sortable: true,
                            },
                            {
                                key: "USE_YN",
                                label: "사용여부",
                                width: '60',
                                align: "left",
                                editor: {
                                    type: "select", config: {
                                        options: ES_Q0001
                                    }
                                },
                                formatter: function () {
                                    return $.changeTextValue(ES_Q0001, this.value);
                                },
                                sortable: true,
                            },

                            {key: "CREATE_DT", label: "생성일자", width: 100, align: "center", sortable: true,
                                editor: {
                                    type: "date", config: {
                                        content: {
                                            config: {
                                                mode: "day",
                                                selectMode: "day"
                                            }
                                        }
                                    }
                                },
                            },
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridView01.target.list[idx];


                                selectRow = idx;
                                this.self.focus(idx);
                                this.self.select(idx);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            },
                            onDataChanged: function () {

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
                        classUrl : "/api/web/blurb02",
                        methodUrl :  "packageDetail",
                        async : false,
                        param : function(){
                            var selected = fnObj.gridView01.target.getList('selected')[0];
                            return JSON.stringify($.extend({}, selected));
                        },
                        columns: [
                            {
                                key: "PKG_CD",
                                label: "패키지코드",
                                width: 80,
                                align: "left",
                                editor: false,
                                hidden: true, sortable: true,
                            },
                            {key: "ADV_CD", label: "광고코드", width: 100, align: "left", sortable: true,editor: false,
                                picker: {
                                    top: _pop_top,
                                    width: 600,
                                    height: _pop_height,
                                    url: "/jsp/ensys/help/blurbHelper.jsp",
                                    action: ["commonHelp", "HELP_BLURB"],
                                    param: function () {
                                        return {
                                            MODE   : 'SINGLE'
                                        }
                                    },
                                    callback: function (e) {
                                        fnObj.gridView02.target.setValue(this.dindex, "ADV_CD", e[0].ADV_CD);
                                    },
                                }
                            },
                            {key: "SEQ", label: "순번", width: 60, align: "left", sortable: true, editor: false},
                            {key: "AM", label: "금액", width: 100, sortable: true, align: "left",editor: {type: "number"}},
                            {key: "SALE_RT", label: "할인율", width: 80, align: "left", sortable: true, editor: {type: "number"}}

                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                                this.self.focus(this.dindex);
                                selectRow2 = this.dindex;
                            },
                            onDataChanged: function () {
                                if(this.key == 'PACKAGE_CD') {
                                    if(this.value == '') {
                                        // fnObj.gridView02.target.setValue(this.dindex, "NM_PACKAGE", '');
                                    }
                                }
                            },
                            // onDBLClick: function(){
                            //     userCallBack = function (e){
                            //         ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            //     }
                            //     $.openCommonPopup("/jsp/ensys/help/blurbHelper.jsp", "userCallBack",  '', '', this.item, $(".ax-body").width(), $(".ax-body").height(), null, null, false);
                            // }
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
//                console.log(this);

                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };

            fnObj.pageResize = function () {

            };

            //전체체크 이벤트
            $(document).on('click', '#headerBox', function (caller) {
                var gridList = fnObj.gridView02.target.list;

                if(cnt == 0) {
                    cnt++;
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", true);
                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "CHK", "Y");
                    });
                }else {
                    cnt = 0;
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);
                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "CHK", "N");
                    });
                }
            });

            //체크된 row
            function isChecked(data) {
                var array = [];
                for (var i = 0; i < data.length; i++) {
                    if (data[i].CHK == true || data[i].CHK == 'Y') {
                        array.push(data[i]);
                    }
                }
                return array;
            }

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
                <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                        class="icon_search"></i>조회
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                        class="icon_save"></i>저장
                </button>
            </div>
        </div>

        <div style="width:100%;overflow:hidden">
            <div style="width:45%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 패키지정보
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                            <i
                                    class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
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
                            <i class="icon_list"></i> 패키지상세
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-02-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
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