<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="키등록"/>
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

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["registerKey", "select"],
                data: JSON.stringify({
                    LINESENSE_KEY : $("#LINESENSE_KEY").val()
                }),
                callback: function (res) {
                    selectRow = 0;

                    caller.gridView01.target.setData(res);
                    caller.gridView01.target.select(0);
                }
            });
        },
        PAGE_SAVE: function(caller, act, data) {

            qray.confirm({
                msg: "키 등록하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    qray.loading.show('등록중입니다.');
                    axboot.call({
                        type: "POST",
                        url: ["registerKey", "save"],
                        data: JSON.stringify(data),
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
                    {key: "CD_COMPANY", label: "모듈아이디", width: 150, align: "center", sortable: true, editor: false},
                    {key: "NM_COMPANY", label: "모듈명", width: 150, align: "center", sortable: true,editor: false},
                    {key: "NO_COMPANY", label: "메뉴아이디", width: 150, align: "center", sortable: true,editor: false},
                    {key: "EN_COMPANY", label: "메뉴명", width: 150, align: "center", sortable: true,editor: false},
                    {key: "NO_TEL", label: "화면아이디", width: 150, align: "center", sortable: true,editor: false},
                    {key: "NO_POST", label: "화면명", width: 150, align: "center", sortable: true,editor: false}
                ],
                body: {
                    onDBLClick: function () {

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

    //////////////////////////////////////
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
        var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
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
        <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                style="width:80px;">
            <i class="icon_reload"></i></button>
        <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                class="icon_search"></i><ax:lang
                id="ax.admin.sample.modal.button.search"/></button>
         <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                class="icon_save"></i><ax:lang
                id="ax.admin.sample.modal.button.save"/></button>
    </div>
</div>
<div role="page-header" id="pageheader">
    <ax:form name="searchView0">
        <ax:tbl clazz="ax-search-tb1" minWidth="500px">
            <ax:tr>
                <ax:td label='라인센스 키' width="400px">
                    <input type="text" class="form-control" name="LINESENSE_KEY"  id="LINESENSE_KEY"/>
                </ax:td>
            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div data-ax5grid="grid-view-01"
     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27,  singleSelect: false}"
     id="top_grid"
></div>
</jsp:body>
</ax:layout>