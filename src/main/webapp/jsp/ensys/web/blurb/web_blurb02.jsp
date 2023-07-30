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
            var _tabview 	= this.parent.fnObj.tabView; 				//받아온데이터 대상객체(초기화할때사용함)
            var _urlGetData = this.parent.fnObj.tabView.urlGetData(); 	//받아온데이터
            var selectRow = 0;

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["web_blurb_02", "searchMst"],
                        data: JSON.stringify({

                            // PARTNER_TP : nvl($("select[name='S_PARTNER_TP']").val()),
                            // KEYWORD: $("#KEYWORD").val()
                        }),
                        callback: function (res) {
                            caller.gridView01.setData(res);

                            if (res.list.length <= selectRow) {
                                selectRow = 0
                            }

                            caller.gridView01.target.focus(selectRow);
                            caller.gridView01.target.select(selectRow);

                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                        }
                    });
                },
                PAGE_SAVE: function (caller, act, data) {
                    var saveDataH = [].concat(fnObj.gridView01.target.getList('deleted')).concat(fnObj.gridView01.target.getList('modified'));
                    var saveDataD = [].concat(fnObj.gridView02.target.getList('deleted')).concat(fnObj.gridView02.target.getList('modified'));

                    for (var i = 0 ; i < saveDataH.length ; i ++){
                        if (saveDataH[i].__deleted__) continue;

                        if (saveDataH[i].PACKAGE_CD == '' || saveDataH[i].PACKAGE_CD ==undefined){
                            qray.alert('패키지코드를 입력해주십시오.');
                            return;
                        }

                    }
                    for (var i = 0 ; i < saveDataD.length ; i ++){
                        if (saveDataD[i].__deleted__) continue;

                        if (saveDataD[i].ADVERTISE_CD == ''){
                            qray.alert('광고코드를 입력해주십시오.');
                            return;
                        }
                    }

                    if (fnObj.gridView01.target.getDirtyData().count == 0
                        && fnObj.gridView02.target.getDirtyData().count == 0){
                        qray.alert('변경된 데이터가 없습니다.');
                        return;
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["web_blurb_02", "save"],
                                data: JSON.stringify({
                                    saveDataH : saveDataH,
                                    saveDataD : saveDataD
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
                ITEM_ADD1: function(caller, act, data){
                    fnObj.gridView01.addRow();
                    var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);

                    fnObj.gridView01.target.setValue(lastIdx - 1, "PACKAGE_CD", GET_NO('MA', '23'));
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                ITEM_DEL: function(caller, act, data){

                    if (isChecked(fnObj.gridView01.target.list).length == 0) {
                        qray.alert('체크된 데이터가 없습니다.');
                        return false;
                    }

                    var grid = caller.gridView01.target.list;
                    var i = grid.length;
                    while (i--) {
                            caller.gridView01.delRow(i);
                    }
                    i = null;
                },
                ITEM_ADD2: function(caller, act, data){
                    fnObj.gridView02.addRow();
                    var lastIdx = nvl(fnObj.gridView02.target.list.length, fnObj.gridView02.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView02.target.focus(lastIdx - 1);
                    fnObj.gridView02.target.select(lastIdx - 1);

                    // fnObj.gridView02.target.setValue(lastIdx - 1, "PACKAGE_CD", );
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                ITEM_DEL2: function(caller, act, data){

                    if (isChecked(fnObj.gridView02.target.list).length == 0) {
                        qray.alert('체크된 데이터가 없습니다.');
                        return false;
                    }

                    var grid = caller.gridView02.target.list;
                    var i = grid.length;
                    while (i--) {
                        if (grid[i].CHK == 'Y') {
                            caller.gridView02.delRow(i);
                        }
                    }
                    i = null;
                },
            });



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

            fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {

                },
                getData: function (_type) {
                    var list = [];
                    var _list = this.target.getList(_type);
                    list = _list;

                    return list;
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

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


            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        }
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
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        childGrid : [fnObj.gridView02],
                        type : "POST",
                        classUrl : "Webblurb02",
                        methodUrl :  "packageHeader",
                        async : false,
                        param : function(){
                            var param = {

                            }
                            return JSON.stringify(param);
                        },
                        columns: [
                            {
                                key: "PACKAGE_CD", label: "패키지코드", width: 80, align: "left", editor: {
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
                                key: "PACKAGE_NM",
                                label: "패키지명",
                                width: '100',
                                align: "left",
                                editor: {type: "text"},
                                sortable: true,
                            },
                            {
                                key: "USE_YN",
                                label: "사용여부",
                                width: '60',
                                align: "left",
                                editor: {type: "text"},
                                sortable: true,
                            },

                            {key: "PRODUCE_DT", label: "생성일자", width: 150, align: "center", sortable: true,
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
                                var chekVal;
                                var sameSelected;
                                var idx;
                                idx = this.dindex;

                                $(this.list).each(function (i, e) {
                                    if(e.__created__) {
                                        if(i != idx) {
                                            chekVal = true;
                                        }
                                    }

                                    if(e.__selected__) {
                                        if(i == idx) {
                                            sameSelected = true;
                                        }
                                    }
                                });

                                if(sameSelected == false && chekVal == false) {
                                    $(fnObj.gridView02.target.list).each(function (i, e) {
                                        if(e.__modified__) {
                                            chekVal = true;
                                            return false;
                                        }
                                    });
                                }

                                if(sameSelected) return;

                                this.self.select(this.dindex);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                            },
                            onDataChanged: function () {
                                if(this.key == 'PACKAGE_CD') {
                                    var list = fnObj.gridView02.target.list;

                                    for(var i = 0; i < list.length; i++) {
                                        fnObj.gridView02.target.setValue(i, 'PACKAGE_CD', this.value);
                                    }
                                }
                            }
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD1);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DEL1);
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
                        classUrl : "Webblurb02",
                        methodUrl :  "packageDetail",
                        async : false,
                        param : function(){
                            var selected = fnObj.gridView01.target.getList('selected')[0];
                            return JSON.stringify($.extend({}, selected));
                        },
                        columns: [
                            {
                                key: "CHK", label: "", width: 40, align: "center", dirty: false,
                                label:
                                    '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                                }
                            },
                            {
                                key: "PACKAGE_CD",
                                label: "패키지코드",
                                width: 80,
                                align: "left",
                                editor: false,
                                hidden: true, sortable: true,
                            },
                            {key: "ADVERTISE_CD", label: "광고코드", width: 80, sortable: true, align: "left",editor: false},
                            {key: "SEQ", label: "순번", width: 60, align: "left", sortable: true, editor: false},
                            {key: "AM", label: "금액", width: 100, sortable: true, align: "left",editor: {type: "number"}},
                            {key: "SALE_RT", label: "할인율", width: 80, align: "left", sortable: true, editor: {type: "number"}}

                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                                selectRow = this.dindex;
                            },
                            onDataChanged: function () {
                                if(this.key == 'PACKAGE_CD') {
                                    if(this.value == '') {
                                        // fnObj.gridView02.target.setValue(this.dindex, "NM_PACKAGE", '');
                                    }
                                }
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