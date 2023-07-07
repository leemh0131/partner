<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="자동채번관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<style>
    .readonly {
        background: #EEEEEE !important;
    }
    .red {
        background: #ffe0cf !important;
    }
</style>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    var selectRow = 0;

    var dl_MODULE_CD = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, "ES_Q0004", false);   //모듈코드
    $("#MODULE_CD").ax5select({options: dl_MODULE_CD});

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["SysInformation08", "search"],
                data: JSON.stringify({
                    MODULE_CD : nvl($("select[name='MODULE_CD']").val()),
                    KEYWORD : $("#KEYWORD").val()
                }),
                callback: function (res) {
                    selectRow = 0;

                    caller.gridView01.target.setData(res);
                    caller.gridView01.target.select(0);
                }
            });
        },
        ITEM_ADD: function(caller, act, data) {
            caller.gridView01.addRow();

            var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
            selectRow = lastIdx - 1;

            caller.gridView01.target.select(lastIdx - 1);
            caller.gridView01.target.focus(lastIdx - 1);
        },
        ITEM_DEL: function(caller, act, data) {
            caller.gridView01.delRow("selected");
        },
        PAGE_SAVE: function(caller, act, data) {
            var checkData = [].concat(caller.gridView01.target.getList("deleted")).concat(caller.gridView01.target.getList("modified"));

            if(checkData.length == 0) {
                qray.alert('변경된 데이터가 존재하지않습니다.');
                return;
            }

            for(var i = 0; i < checkData.length; i ++) {
                if(nvl(checkData[i].__deleted__) == '') {
                    if(nvl(checkData[i].MODULE_CD) == '') {
                        qray.alert('모듈코드는 필수값입니다.');
                        return;
                    }
                    if(nvl(checkData[i].CLASS_CD) == '') {
                        qray.alert('항목코드는 필수값입니다.');
                        return;
                    }
                    if(nvl(checkData[i].CLASS_NM) == '') {
                        qray.alert('항목명은 필수값입니다.');
                        return;
                    }
                    if(nvl(checkData[i].CTRL_CD) == '') {
                        qray.alert('구분코드는 필수값입니다.');
                        return;
                    }
                    if(nvl(checkData[i].CLASS_LEN) == '') {
                        qray.alert('SERIAL 자리수는 필수값입니다.');
                        return;
                    }
                }
            }

            var list = fnObj.gridView01.target.list;
            for(var i = 0; i < fnObj.gridView01.target.list.length; i ++) {
                for(var i2 = 0; i2 < fnObj.gridView01.target.list.length; i2 ++) {
                    if(i == i2) continue;

                    if(list[i].MODULE_CD == list[i2].MODULE_CD) {
                        if(list[i].CLASS_CD == list[i2].CLASS_CD) {
                            qray.alert('같은 모듈코드에 항목코드가 중복됩니다.<br>' + $.changeTextValue(dl_MODULE_CD, list[i].MODULE_CD)
                                    + " (" + list[i].CLASS_CD + ")");
                            return;
                        }
                    }
                }
            }

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    qray.loading.show('저장중입니다.');
                    axboot.call({
                        type: "POST",
                        url: ["SysInformation08", "save"],
                        data: JSON.stringify({
                            saveData: checkData,
                        }),
                        callback: function (res) {
                            qray.loading.hide();
                            qray.alert("저장 되었습니다.").then(function() {
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            })
                        },
                        options : {
                            onError : function(err) {
                                qray.loading.hide().then(function() {
                                    qray.alert(err.message);
                                    return;
                                })
                            }
                        }
                    }).done(function() {

                    });
                }
            });
        }
    });
    // fnObj 기본 함수 스타트와 리사이즈
    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.gridView01.initView();

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
                columns: [
                    {key: "COMPANY_CD", label: "회사코드", width: 100, align: "center", sortable: true, hidden:true},
                    {key: "MODULE_CD", label: "모듈코드", width: 100, align: "center", sortable: true,
                        formatter: function () {
                            return $.changeTextValue(dl_MODULE_CD, this.value)
                        },
                        editor: {
                            type: "select", config: {
                                columnKeys: {
                                    optionValue: "CODE", optionText: "TEXT"
                                },
                                options: dl_MODULE_CD
                            },
                            disabled: function() {
                                if(nvl(this.item.__created__) == '') {
                                    return true;
                                }else {
                                    return false;
                                }
                            }
                        },
                        styleClass: function () {
                            if(nvl(this.item.__created__) == '') {
                                return "readonly";
                            }
                        }
                    },
                    {key: "CLASS_CD", label: "항목코드", width: 100, align: "center", sortable: true,
                        editor:{type: "text",
                            disabled: function() {
                                if(nvl(this.item.__created__) == '') {
                                    return true;
                                }else {
                                    return false;
                                }
                            }
                        },
                        styleClass: function () {
                            if(nvl(this.item.__created__) == '') {
                                return "readonly";
                            }
                        }
                    },
                    {key: "CLASS_NM", label: "항목명", width: "*", align: "left", sortable: true, editor:{type: "text"}},
                    {key: "CTRL_CD", label: "구분코드", width: 90, align: "center", sortable: true, editor:{type: "text"}},
                    {key: "CLASS_LEN", label: "SERIAL자리수", width: 100, align: "right", sortable: true, editor:{type: "number"}},
                    {key: "INSERT_ID", label: "입력아이디", width: 100, align: "center", sortable: true,
                        styleClass: function () {
                            return "readonly";
                        }
                    },
                    {key: "INSERT_DTS", label: "입력일자", width: 150, align: "center", sortable: true,
                        formatter : function() {
                            return $.changeDataFormat(this.value,"yyyyMMddhhmmss")
                        },
                        styleClass: function () {
                            return "readonly";
                        }
                    },
                    {key: "UPDATE_ID", label: "변경아이디", width: 100, align: "center", sortable: true,
                        styleClass: function () {
                            return "readonly";
                        }
                    },
                    {key: "UPDATE_DTS", label: "변경일자", width: 150, align: "center", sortable: true,
                        formatter : function() {
                            return $.changeDataFormat(this.value,"yyyyMMddhhmmss")
                        },
                        styleClass: function () {
                            return "readonly";
                        }
                    }
                ],
                body: {
                    onClick: function() {
                        var idx = this.dindex;

                        this.self.select(idx);
                    },
                    onDBLClick: function () {

                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-01-btn", {
                "add": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_ADD);
                },
                "delete": function () {
                    var beforeIdx = this.target.selectedDataIndexs[0];
                    var dataLen = this.target.getList().length;

                    if((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    ACTIONS.dispatch(ACTIONS.ITEM_DEL);

                    if(beforeIdx > 0 || beforeIdx == 0) {
                        this.target.select(beforeIdx);
                        selectRow = beforeIdx;
                    }
                },
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
        },
        lastRow: function () {
            return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length);
        }
    });

    $(document).ready(function () {
        changesize();
    });

    $(window).resize(function () {
        changesize();
    });

    //크기자동조정
    var _pop_top = 0;
    var _pop_top700 = 0;
    var _pop_height = 0;
    var _pop_height700 = 0;
    var _pop_width1400 = 0;
    function changesize() {
        //전체영역높이
        var totheight = $("#ax-base-root").height();

        if(totheight > 700) {
            _pop_height = 600;
            _pop_height700 = 700;
            _pop_top = parseInt((totheight - _pop_height) / 2);
            _pop_top700 = parseInt((totheight - 700) / 2);
        }else {
            _pop_height = totheight / 10 * 8;
            _pop_height700 = totheight / 10 * 9;
            _pop_top = parseInt((totheight - _pop_height) / 2);
            _pop_top700 = parseInt((totheight - _pop_height700) / 2);
        }

        if(totheight > 700) {
            _pop_width1400 = 1500;
        }else if(totheight > 550) {
            _pop_width1400 = 1000;
        }else {
            _pop_width1400 = 800;
        }

        //데이터가 들어갈 실제높이
        var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height() - $("#gridView01Btn").height();
        //타이틀을 뺀 상하단 그리드 합친높이
        //var tempgridheight = datarealheight - $("#top_title").height() - $("#bottom_left_title").height() - $("#bottom_left_amt").height();
        var tempgridheight = datarealheight;

        $("#top_grid").css("height", tempgridheight / 100 * 99);
    }
</script>
</jsp:attribute>
<jsp:body>
<div data-page-buttons="">
    <div class="button-warp">
        <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();" style="width:80px;">
            <i class="icon_reload"></i></button>
        <button type="button" class="btn btn-info" data-page-btn="search" TRIGGER_NAME="SEARCH" style="width:80px;">
        <i class="icon_search"></i><ax:lang id="ax.admin.sample.modal.button.search"/></button>
         <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;">
         <i class="icon_save"></i>저장</button>
    </div>
</div>
<div role="page-header" id="pageheader">
    <ax:form name="searchView0">
        <ax:tbl clazz="ax-search-tb1" minWidth="500px">
            <ax:tr>
                <ax:td label='모듈' width="400px">
                    <div id="MODULE_CD" data-ax5select="MODULE_CD" name="MODULE_CD" data-ax5select-config='{}'></div>
                </ax:td>
                <ax:td label='항목' width="400px">
                    <input type="text" class="form-control" name="KEYWORD"  id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
                </ax:td>

            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
        <div class="left">
            <h2>
                <i class="icon_list"></i> 채번리스트
            </h2>
        </div>
        <div class="right">
            <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                    class="icon_add"></i>
                <ax:lang id="ax.admin.add"/></button>
            <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
        </div>
    </div>
<div data-ax5grid="grid-view-01"
     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27,  singleSelect: false}"
     id="top_grid"
></div>
</jsp:body>
</ax:layout>