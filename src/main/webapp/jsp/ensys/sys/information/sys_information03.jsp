<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="사용자관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    var selectRow = 0;
    
    var dl_USER_GB = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0003', true);
    
    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["SysInformation03", "search"],
                data: JSON.stringify({
                    USER_NM : nvl($("#USER_NM").val()),
                    USE_YN: nvl($("#USE_YN").val()),
                    USER_TP: nvl($("#USER_TP").val()),
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

            fnObj.gridView01.target.setValue(lastIdx - 1, 'USE_YN' , 'Y');
        },
        ITEM_DEL: function(caller, act, data) {
            caller.gridView01.delRow("selected");
        },
        PAGE_SAVE: function(caller, act, data) {
            var checkData1 = [].concat(caller.gridView01.target.getList("modified")).concat(caller.gridView01.target.getList("deleted"));

            if(checkData1.length == 0 ) {
                qray.alert('변경된 데이터가 존재하지않습니다.');
                return;
            }

            for(var i = 0; i < checkData1.length; i ++) {

                if(nvl(checkData1[i].__deleted__) != ''){
                    continue;
                }

                if(nvl(checkData1[i].USER_ID) == '') {
                    qray.alert('사용자아이디를 입력해주십시오.');
                    return;
                }
                
                if(nvl(checkData1[i].USER_NM) == '') {
                    qray.alert('사용자명을 입력해주십시오.');
                    return;
                }
    
                if(nvl(checkData1[i].PASS_WORD) == '') {
                    qray.alert('비밀번호를 입력해주십시오.');
                    return;
                }
                if(nvl(checkData1[i].USER_GB) == '') {
                    qray.alert('사용자 구분을 선택해주십시오.');
                    return;
                }
            }
    
            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    qray.loading.show('저장중입니다.');
                    axboot.call({
                        type: "POST",
                        url: ["SysInformation03", "save"],
                        data: JSON.stringify({
                            saveData: checkData1
                        }),
                        callback: function (res) {
                            qray.loading.hide();
                            qray.alert("저장 되었습니다.").then(function() {
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            })
                        },
                        options : {
                            onError : function(err) {
                                qray.loading.hide();
                                qray.alert(err.message);
                                return;
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
            var _this = this;
    
            this.target = axboot.gridBuilder({
                showRowSelector: true,
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-01"]'),
                columns: [
                    {key: "COMPANY_CD", label: "회사코드", width: 150, align: "center", sortable: true, editor: false, hidden:true},
                    {key: "USER_ID", label: "사용자아이디", width: 150, align: "center", sortable: true,
                        editor: {type: "text", 
                            disabled:function() {
                                if(nvl(this.item.__created__) == '') {
                                    return true;
                                }else {
                                    return false;
                                }
                            }
                        }
                    },
                    {key: "USER_NM", label: "사용자명", width: 150, align: "left", sortable: true,editor: {type: "text"}},
                    {key: "PASS_WORD", label: "비밀번호", width: 150, align: "left", sortable: true,editor: {type: "password"},
                        formatter: function() {
                            var value = this.item.PASS_WORD;
    
                            if(nvl(value) == '') return value;
    
                            var returnValue = '';
                            var len = value.length;
                            for(var i = 0; i <= len; i ++) {
                                returnValue += "*";
                            }
                            return returnValue;
                        }
                    },
                    {key: "CRYPTO_YN", label: "암호화여부", width: 80, align: "center", sortable: true, hidden:true,
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                        }
                    },
                    {key: "USER_GB", label: "사용자구분", width: 150, align: "center", sortable: true,
                        formatter: function () {
                            return $.changeTextValue(dl_USER_GB, this.value);
                        }, 
                        editor: {
                            type: "select", config: {
                                columnKeys: {
                                    optionValue: "CODE", optionText: "TEXT"
                                },
                                options: dl_USER_GB
                            }
                        }
                    },
                    {key: "USER_TP", label: "사용자유형", width: 150, align: "center", sortable: true,editor: {type: "text"}, hidden:true},
                    {key: "USE_YN", label: "사용여부", width: 80, align: "center", sortable: true,
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                        }
                    },
                    
                    {key: "INSERT_DTS", label: "가입일시", width: 150, align: "center", sortable: true,editor: false},
                    
                ],
                body: {
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
        <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                style="width:80px;">
            <i class="icon_reload"></i></button>
        <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                class="icon_search" TRIGGER_NAME="SEARCH"></i><ax:lang
                id="ax.admin.sample.modal.button.search"/></button>
        <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                class="icon_save"></i>저장
        </button>
    </div>
</div>
<div role="page-header" id="pageheader">
    <ax:form name="searchView0">
        <ax:tbl clazz="ax-search-tb1" minWidth="500px">
            <ax:tr>
                <%-- <ax:td label='유형' width="400px">
                    <input type="text" class="form-control" name="TP_USER"  id="TP_USER"/>
                </ax:td>
                <ax:td label='사용여부' width="400px">
                    <input type="text" class="form-control" name="YN_USE"  id="YN_USE"/>
                </ax:td> --%>
                <ax:td label='사용자명' width="400px">
                    <input type="text" class="form-control" name="USER_NM"  id="USER_NM" TRIGGER_TARGET="SEARCH"/>
                </ax:td>
            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
    <div class="left">
        <h2>
            <i class="icon_list"></i> 사용자정보
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