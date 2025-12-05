<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="공통코드관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    var selectRow = 0;
    var selectRow2 = 0;

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["SysInformation02", "select"],
                data: JSON.stringify({
                    KEYWORD: nvl($("#KEYWORD").val())
                }),
                callback: function (res) {
                    caller.gridView01.clear();
                    caller.gridView02.clear();

                    caller.gridView01.target.setData(res);
                    caller.gridView01.target.select(0);

                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                }
            });
        },
        PAGE_SAVE: function (caller, act, data) {
            var saveDataH = [].concat(caller.gridView01.target.getList("deleted")).concat(caller.gridView01.target.getList("modified"));
            var saveDataD = [].concat(caller.gridView02.target.getList("deleted")).concat(caller.gridView02.target.getList("modified"));

            if(saveDataH.length == 0 && saveDataD.length == 0 ) {
                qray.alert('변경된 데이터가 존재하지않습니다.');
                return;
            }

            for(var i = 0; i < saveDataH.length; i ++) {

                if(nvl(saveDataH[i].__deleted__) != '') continue;

                if(nvl(saveDataH[i].FIELD_NM) == '') {
                    qray.alert('코드그리드의 명을 입력해주십시오.');
                    return;
                }
            }

            for(var i = 0; i < saveDataD.length; i ++) {

                if(nvl(saveDataD[i].__deleted__) != '') continue;

                if(nvl(saveDataD[i].SYSDEF_CD) == '') {
                    qray.alert('상세그리드의 코드을 입력해주십시오.');
                    return;
                }
                if(nvl(saveDataD[i].SYSDEF_NM) == '') {
                    qray.alert('상세그리드의 명을 입력해주십시오.');
                    return;
                }
            }

            for(var i = 0; i < caller.gridView02.target.list.length; i++) {
                for(var i2 = 0; i2 < caller.gridView02.target.list.length; i2++) {
                    if(i == i2) continue;

                    if(caller.gridView02.target.list[i].SYSDEF_CD.toUpperCase() == caller.gridView02.target.list[i2].SYSDEF_CD.toUpperCase()) {
                        qray.alert('코드값이 중복됩니다.');
                        return false;
                    }
                }
            }

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "POST",
                        url: ["SysInformation02", "save"],
                        data: JSON.stringify({
                            saveDataH: saveDataH,
                            saveDataD: saveDataD
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
            var selected = caller.gridView01.target.getList('selected')[0];

            if(nvl(selected) == '') {
                return false;
            }

            axboot.ajax({
                type: "POST",
                url: ["SysInformation02", "selectDtl"],
                data: JSON.stringify({
                    FIELD_CD: selected.FIELD_CD
                }),
                callback: function (res) {
                    caller.gridView02.target.setData(res);
                    caller.gridView02.target.select(0);
                }
            });
        },
        ITEM_ADD1: function (caller, act, data) {
            caller.gridView02.clear();

            caller.gridView01.addRow();

            var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
            selectRow = lastIdx - 1;

            caller.gridView01.target.select(lastIdx - 1);
            caller.gridView01.target.focus(lastIdx - 1);

            caller.gridView01.target.setValue(lastIdx - 1, "SYSCODE_FG1", 'Y');
        },
        ITEM_ADD2: function (caller, act, data) {

            if(caller.gridView01.target.getList('selected').length == 0) {
                qray.alert("상위코드를 먼저 입력하세요.");
                return;
            }

            caller.gridView02.addRow();

            var cdField = caller.gridView01.target.getList('selected')[0].FIELD_CD;
            var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
            selectRow2 = lastIdx - 1;

            caller.gridView02.target.select(lastIdx - 1);

            caller.gridView02.target.focus(lastIdx - 1);

            caller.gridView02.target.setValue(lastIdx - 1, "FIELD_CD", cdField);
            caller.gridView02.target.setValue(lastIdx - 1, "USE_YN", 'Y');
        },
        ITEM_DEL1: function (caller, act, data) {
            caller.gridView01.delRow("selected");
        },
        ITEM_DEL2: function (caller, act, data) {
            caller.gridView02.delRow("selected");
        }
    });
    // fnObj 기본 함수 스타트와 리사이즈
    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.gridView01.initView();
        this.gridView02.initView();

        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
    };

    fnObj.beforeClose = {
        initView: function () {
            var gridView01 = [].concat(fnObj.gridView01.target.getList("modified")).concat(fnObj.gridView01.target.getList("deleted"));
            var gridView02 = [].concat(fnObj.gridView02.target.getList("modified")).concat(fnObj.gridView02.target.getList("deleted"));

            if(gridView01.length > 0 || gridView02.length > 0) {
                return true;
            }else {
                return false;
            }
        },
        ok: function () {   //  저장하시겠습니까? yes
            var result = ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
            return result;
        }
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
                columns: [
                    {key: "FIELD_CD", label: "코드", width: 100, align: "left", editor: false, sortable: true},
                    {key: "FIELD_NM", label: "명", width: 300, align: "left", editor: {type: "text"}, sortable: true},
                    {
                        key: "SYSCODE_FG1", label: "표시여부", width: 80, align: "left", editor: {
                            type: "select", config: {
                                columnKeys: {
                                    optionValue: "value", optionText: "text"
                                },
                                options: [{value: 'Y', text: 'Y'}, {value: 'N', text: 'N'}]
                            }, disabled: function () {
                                if(SCRIPT_SESSION.idUser != 'WEBSYS') {
                                    return true;
                                }else {
                                    return false;
                                }

                            }
                        }
                    }
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;          //  선택한 ROW의 INDEX
                        var chekVal = false;        //  FLAG
                        var sameSelected = false;   //  FLAG

                        $(this.list).each(function (i, e) { //  해당 그리드
                            if(e.__created__) {    //  새로 추가되었다면
                                if(i != idx) {     //  선택된 ROW와 새로추가된 ROW가 다르다면
                                    chekVal = true; //
                                    return false;
                                }
                            }
                            if(e.__selected__) {   //  선택되어있다면
                                if(i == idx) {     //  선택된 ROW와 새로추가된 ROW가 같다면
                                    sameSelected = true;
                                }
                            }
                        });
                        //  selectRow : 해당 그리드의 선택된 INDEX
                        if(selectRow != idx && chekVal == false) {
                            $(fnObj.gridView02.target.list).each(function (i, e) {  //  그리드2 변경됬는 지 validate
                                if(e.__modified__) {
                                    chekVal = true;
                                    return false;
                                }
                            });
                        }

                        if(chekVal) {  //  팅겨내기
                            qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                            return;
                        }

                        if(sameSelected) {     //  같은 ROW를 선택했을 경우
                            return;                 // ACTIONS.ITEM_CLICK_H [ 디테일그리드 조회 데이터소스 ] 를 읽지 못하게끔 막기
                        }

                        selectRow = idx;
                        this.self.select(selectRow);

                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-01-btn", {
                "add": function () {
                    var chekVal;

                    $(this.target.list).each(function (i, e) {
                        if(e.__created__) {
                            chekVal = true;
                        }

                    });

                    $(fnObj.gridView02.target.list).each(function (i, e) {
                        if(e.__modified__) {
                            chekVal = true;
                        }
                    });

                    if(chekVal) {
                        qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                        return;
                    }

                    ACTIONS.dispatch(ACTIONS.ITEM_ADD1);
                },
                "delete": function () {
                    var beforeIdx = this.target.selectedDataIndexs[0];
                    var dataLen = this.target.getList().length;

                    if((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    ACTIONS.dispatch(ACTIONS.ITEM_DEL1);

                    if(beforeIdx > 0 || beforeIdx == 0) {
                        this.target.select(beforeIdx);
                        selectRow = beforeIdx;
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    }
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
                columns: [
                    {
                        key: "SYSDEF_CD", label: "코드", width: 100, align: "center", sortable: true, editor: {
                            type: "text",
                            maxlength: 100,
                            disabled: function () {
                                var selected = fnObj.gridView02.target.getList('selected')[0];
                                if(nvl(selected.__created__, '') == '') {
                                    return true;
                                }else {
                                    return false;
                                }
                            }
                        }
                    },
                    {key: "SYSDEF_NM", label: "명", width: 150, align: "left", editor: {type: "text"}, sortable: true},
                    {key: "FLAG1_CD", label: "관련1", width: 150, align: "left", editor: {type: "text"}},
                    {key: "FLAG2_CD", label: "관련2", width: 150, align: "left", editor: {type: "text"}},
                    {key: "FLAG3_CD", label: "관련3", width: 150, align: "left", editor: {type: "text"}},
                    {key: "FLAG4_CD", label: "관련4", width: 150, align: "left", editor: {type: "text"}},
                    {key: "SYSDEF_E_NM", label: "비고", width: "*", align: "left", editor: {type: "text"}},
                    {
                        key: "USE_YN", label: "사용여부", width: 70, align: "center"
                        , editor: {
                            type: "select", config: {
                                columnKeys: {
                                    optionValue: "CODE", optionText: "NAME"
                                },
                                options: [{CODE: 'Y', NAME: "Y"}, {CODE: 'N', NAME: "N"}]

                            }
                        }
                    }
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;          //  선택한 ROW의 INDEX

                        selectRow2 = idx;
                        this.self.select(selectRow2);
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
                        selectRow2 = beforeIdx;
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

    //////////////////////////////////////
    $(document).ready(function () {
        changesize();
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
                <ax:td label='코드명' width="400px">
                    <input type="text" class="form-control" name="KEYWORD" id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
                </ax:td>
            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div style="width:100%;overflow:hidden">
    <div style="width:25%;float:left;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽타이틀">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 코드
                </h2>
            </div>
            <div class="right">
                <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i class="icon_add"></i>
                    <ax:lang id="ax.admin.add"/></button>
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
    <div style="width:74%;float:right">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 상세
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