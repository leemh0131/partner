<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="카테고리 설정"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    var selectRow = 0;
    var selectRow2 = 0;

    var ES_CODES = $.SELECT_COMMON_ARRAY_CODE("ES_Q0001", "ES_Q0033");
    var ES_Q0033 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0033', true);        /** 거래처구분*/

    $("#PARTNER_TP").ax5select({options: ES_Q0033}); //거래처구분

    var dl_ICON = [
          {CODE:'img/icon/i_icon_01.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_01.svg"></div>'}
        , {CODE:'img/icon/i_icon_02.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_02.svg"></div>'}
        , {CODE:'img/icon/i_icon_03.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_03.svg"></div>'}
        , {CODE:'img/icon/i_icon_04.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_04.svg"></div>'}
        , {CODE:'img/icon/i_icon_05.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_05.svg"></div>'}
        , {CODE:'img/icon/i_icon_06.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_06.svg"></div>'}
        , {CODE:'img/icon/i_icon_07.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_07.svg"></div>'}
        , {CODE:'img/icon/i_icon_08.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_08.svg"></div>'}
        , {CODE:'img/icon/i_icon_09.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_09.svg"></div>'}
        , {CODE:'img/icon/i_icon_10.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_10.svg"></div>'}
        , {CODE:'img/icon/i_icon_11.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_11.svg"></div>'}
        , {CODE:'img/icon/i_icon_12.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_12.svg"></div>'}
        , {CODE:'img/icon/i_icon_13.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_13.svg"></div>'}
        , {CODE:'img/icon/i_icon_14.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_14.svg"></div>'}
        , {CODE:'img/icon/i_icon_15.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_15.svg"></div>'}
        , {CODE:'img/icon/i_icon_16.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_16.svg"></div>'}
        , {CODE:'img/icon/i_icon_17.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_17.svg"></div>'}
        , {CODE:'img/icon/i_icon_18.svg', TEXT:'<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="img/icon/i_icon_18.svg"></div>'}
    ];

    var ACTIONS = axboot.actionExtend(fnObj, {
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
        PAGE_SAVE: function (caller, act, data) {

            var gridView01 = fnObj.gridView01.target.getDirtyData();
            var gridView02 = fnObj.gridView02.target.getDirtyData();

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "POST",
                        url: ["/api/web/category", "save"],
                        data: JSON.stringify({
                            saveData : gridView01,
                            saveData2 : gridView02
                        }),
                        callback: function (res) {
                            qray.alert("저장 되었습니다.").then(function() {
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            });
                        }
                    });
                }
            });
        },
        ITEM_CLICK: function (caller, act, data) {

            fnObj.gridView02.clear();
            fnObj.gridView02.target.read().done(function(res){
                fnObj.gridView02.setData(res);
            }).fail(function(err){
                qray.alert(err.message);
            }).always(function(){
                qray.loading.hide();
            });

        },
        //추가
        ITEM_ADD: function(caller, act, data) {

            // 그리드 추가
            fnObj.gridView01.addRow();

            //마지막 인덱스를 구하는 로직
            var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
            selectRow = lastIdx - 1;

            //그리드row 포커스
            fnObj.gridView01.target.select(selectRow);
            fnObj.gridView01.target.focus(selectRow);
            fnObj.gridView01.target.setValue(lastIdx - 1, "PARENT_CD", $('select[name="PARTNER_TP"]').val());

        },
        //삭제
        ITEM_DEL: function(caller, act, data) {

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


        },
        //추가
        ITEM_ADD2: function(caller, act, data) {

            let selected = fnObj.gridView01.target.getList('selected')[0];

            if(nvl(selected) == ''){
                qray.alert("중분류를 선택해주세요.");
                return
            }

            // 그리드 추가
            fnObj.gridView02.addRow();

            //마지막 인덱스를 구하는 로직
            var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
            selectRow2 = lastIdx - 1;

            //그리드row 포커스
            fnObj.gridView02.target.select(selectRow2);
            fnObj.gridView02.target.focus(selectRow2);
            fnObj.gridView02.target.setValue(lastIdx - 1, "PARENT_CD", selected.CATEGORY_CD);

        },
        //삭제
        ITEM_DEL2: function(caller, act, data) {

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
    // fnObj 기본 함수 스타트와 리사이즈
    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.gridView01.initView();
        this.gridView02.initView();

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
                childGrid : [fnObj.gridView01],
                type : "POST",
                classUrl : "/api/web/category",
                methodUrl :  "select",
                async : false,
                param : function(){
                    return JSON.stringify({PARENT_CD : $('select[name="PARTNER_TP"]').val()});
                },
                callback : function(res){

                },
                columns: [
                    {key: "CATEGORY_NM", label: "카테고리 이름", width: 150, align: "left", editor: {type: "text"}, sortable: true},
                    {key: "USE_YN", label: "사용여부", width: 150, align: "center", sortable: true,
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                        }
                    },
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        selectRow = idx;
                        this.self.select(selectRow);
                        this.self.focus(selectRow);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
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
                classUrl : "/api/web/category",
                methodUrl :  "select",
                async : false,
                param : function(){
                    let selected = nvl(fnObj.gridView01.target.getList('selected')[0], {});
                    let param;
                    if(nvl(fnObj.gridView01.target.getList('selected')[0]) != ''){
                        param = {PARENT_CD : selected.CATEGORY_CD};
                    }
                    return JSON.stringify(param);
                },
                callback : function(res){

                },
                columns: [
                    {key: "CATEGORY_NM", label: "카테고리 이름", width: 150, align: "left", editor: {type: "text"}, sortable: true},
                    {key: "CATEGORY_ICON", label: "아이콘", width: 90, align: "left",
                        formatter: function () {
                            if (!this.value) {
                                return "";
                            }
                            return '<div style="height: 27px;"><img style="width: 100%;height: 100%;" src="' + this.value + '"></div>';
                        },
                        editor: {
                            type: "select", config: {
                                columnKeys: {
                                    optionValue: "CODE", optionText: "TEXT"
                                },
                                options: dl_ICON
                            }
                        }
                    },
                    {key: "USE_YN", label: "사용여부", width: 150, align: "center", sortable: true,
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                        }
                    },
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        selectRow2 = idx;
                        this.self.select(selectRow2);
                        this.self.focus(selectRow2);
                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-02-btn", {
                "add": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_ADD2);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_DEL2);
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

    //////////////////////////////////////
    $(document).ready(function () {
        changesize();

        $("#PARTNER_TP").change(function () {
            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
        });

    });

    $(window).resize(function () {
        changesize();
    });

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
        var tempgridheight = datarealheight - $("#left_title").height() - $("#bottom_left_title").height() - $("#bottom_left_amt").height();

        $("#left_grid").css("height", tempgridheight / 100 * 99);
        $("#right_grid").css("height", tempgridheight / 100 * 99);
    }
</script>
</jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();" style="width:80px;">
                    <i class="icon_reload"></i></button>
                <button type="button" class="btn btn-info" data-page-btn="search" TRIGGER_NAME="SEARCH" style="width:80px;"><i
                        class="icon_search"></i><ax:lang
                        id="ax.admin.sample.modal.button.search"/></button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i class="icon_save"></i>저장</button>
            </div>
        </div>
        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tb1" minWidth="500px">
                    <ax:tr>
                        <ax:td label='구분' width="400px">
                            <div id="PARTNER_TP" name="PARTNER_TP" data-ax5select="PARTNER_TP" data-ax5select-config='{}'
                                 form-bind-text='PARTNER_TP' form-bind-type="selectBox" style="width: 63%;"></div>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
            <div class="H10"></div>
        </div>
        <div style="width:100%;overflow:hidden">
            <div style="width:49%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 중분류
                        </h2>
                    </div>
                    <div class="right">
                        <%--<button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>--%>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:49%;float:right">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 상세분류
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