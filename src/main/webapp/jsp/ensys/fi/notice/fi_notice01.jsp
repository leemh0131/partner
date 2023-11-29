<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="피해관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var selectRow = 0;
            var userCallBack;

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE("ES_Q0001", "ES_Q0139", "ES_Q0140");
            var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0001', true);        /** Y, N*/
            var ES_Q0139 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0139', true);        /** 피해구분*/
            var ES_Q0140 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0140', true);        /** 피해종류*/

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    fnObj.gridView01.clear();
                    fnObj.gridView02.clear();
                    fnObj.gridView03.clear();
                    fnObj.gridView01.target.dirtyClear();
                    fnObj.gridView02.target.dirtyClear();
                    fnObj.gridView03.target.dirtyClear();

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
                ITEM_CLICK : function(caller, act, data){
                    fnObj.gridView02.clear();
                    fnObj.gridView02.target.read().done(function(res){
                        fnObj.gridView02.setData(res);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });

                    fnObj.gridView03.clear();
                    fnObj.gridView03.target.read().done(function(res){
                        fnObj.gridView03.setData(res);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });
                },
                PAGE_SAVE: function (caller, act, data) {
                    var gridView01 = fnObj.gridView01.target.getDirtyData();
                    var gridView02 = fnObj.gridView02.target.getDirtyData();
                    var gridView03 = fnObj.gridView03.target.getDirtyData();

                    if (gridView01.count == 0 && gridView02.count == 0 && gridView03.count == 0){
                        qray.alert('변경된 데이터가 없습니다.');
                        return;
                    }

                    for(var i = 0; i < gridView01.verify.length; i++) {
                        if (nvl(gridView01.verify[i].DM_TYPE) == "") {
                            qray.alert("피해 정보의 피해 구분을 선택해주세요.");
                            return false;
                        }
                        if (nvl(gridView01.verify[i].DM_KIND) == "") {
                            qray.alert("피해 정보의 피해 구분을 선택해주세요.");
                            return false;
                        }
                        if (nvl(gridView01.verify[i].COMP_NM) == "") {
                            qray.alert("피해 정보의 업체명을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView01.verify[i].DM_CONTENTS) == "") {
                            qray.alert("피해 정보의 피해 내용을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView01.verify[i].USE_YN) == "") {
                            qray.alert("피해 정보의 사용여부를 선택해주세요.");
                            return false;
                        }
                    }

                    for(var i = 0; i < gridView02.verify.length; i++) {
                        if (nvl(gridView02.verify[i].BANK_CD) == "") {
                            qray.alert("피해 계좌의 은행명을 선택해주세요.");
                            return false;
                        }
                        if (nvl(gridView02.verify[i].NO_DEPOSIT) == "") {
                            qray.alert("피해 계좌의 계좌번호를 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView02.verify[i].NM_DEPOSITOR) == "") {
                            qray.alert("피해 계좌의 예금주명을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView02.verify[i].USE_YN) == "") {
                            qray.alert("피해 계좌의 사용여부를 선택해주세요.");
                            return false;
                        }
                    }

                    for(var i = 0; i < gridView03.verify.length; i++) {
                        if (nvl(gridView03.verify[i].PARENT_CD) == "") {
                            qray.alert("피해 댓글의 부모댓글코드를 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView03.verify[i].NICK_NM) == "") {
                            qray.alert("피해 댓글의 닉네임을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView03.verify[i].PASSWORD) == "") {
                            qray.alert("피해 댓글의 비밀번호을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView03.verify[i].CONTENTS) == "") {
                            qray.alert("피해 댓글의 내용을 입력해주세요.");
                            return false;
                        }
                        if (nvl(gridView03.verify[i].USE_YN) == "") {
                            qray.alert("피해 댓글의 사용여부를 선택해주세요.");
                            return false;
                        }
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["/api/fi/notice01", "save"],
                                data: JSON.stringify({
                                    gridView01 : gridView01,
                                    gridView02 : gridView02,
                                    gridView03 : gridView03
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
                //피해 추가
                ITEM_ADD: function(caller, act, data){
                    caller.gridView01.addRow();

                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow()) - 1;
                    selectRow = lastIdx - 1;

                    caller.gridView01.target.select(lastIdx);
                    caller.gridView01.target.focus(lastIdx);

                    caller.gridView01.target.setValue(lastIdx, "DM_CD", GET_NO('MA', '25'));
                    caller.gridView01.target.setValue(lastIdx, "USE_YN", 'Y');
                },
                //피해 삭제
                ITEM_DEL: function(caller, act, data){
                    // caller.gridView01.delRow("selected");
                },
                //피해 계좌 추가
                ITEM_ADD2: function(caller, act, data){
                    let selected = nvl(caller.gridView01.target.getList('selected')[0], {});

                    if(nvl(selected, '') == '') {
                        qray.alert("피해 정보를 입력해주세요.");
                        return;
                    }

                    caller.gridView02.addRow();

                    var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow()) - 1;
                    selectRow = lastIdx - 1;

                    caller.gridView02.target.select(lastIdx);
                    caller.gridView02.target.focus(lastIdx);

                    caller.gridView02.target.setValue(lastIdx, "DM_CD", selected.DM_CD);
                    caller.gridView02.target.setValue(lastIdx, "USE_YN", 'Y');
                },
                //피해 계좌 삭제
                ITEM_DEL2: function(caller, act, data){
                    caller.gridView02.delRow("selected");
                },
                //피해 댓글 추가
                ITEM_ADD3: function(caller, act, data){
                    let selected = nvl(caller.gridView01.target.getList('selected')[0], {});

                    if(nvl(selected, '') == '') {
                        qray.alert("피해 정보를 입력해주세요.");
                        return;
                    }

                    caller.gridView03.addRow();

                    var lastIdx = nvl(caller.gridView03.target.list.length, caller.gridView03.lastRow()) - 1;
                    selectRow = lastIdx - 1;

                    caller.gridView03.target.select(lastIdx);
                    caller.gridView03.target.focus(lastIdx);

                    caller.gridView03.target.setValue(lastIdx, "DM_CD", selected.DM_CD);
                    caller.gridView03.target.setValue(lastIdx, "COMM_CD", GET_NO('MA', '26'));
                    caller.gridView03.target.setValue(lastIdx, "USE_YN", 'Y');
                    caller.gridView03.target.setValue(lastIdx, "REPORT_YN", 'N');
                },
                //피해 댓글 삭제
                ITEM_DEL3: function(caller, act, data){
                    caller.gridView03.delRow("selected");
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
                initView: function () {
                    this.target = axboot.gridBuilder({
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        childGrid : [fnObj.gridView01],
                        type : "POST",
                        classUrl : "/api/fi/notice01",
                        methodUrl :  "select",
                        async : false,
                        param : function(){
                            return JSON.stringify({
                                KEYWORD: nvl($("#KEYWORD").val())
                            });
                        },
                        callback : function(res){
                        },
                        columns: [
                            { key: "DM_CD",             label: "피해코드", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "DM_TYPE",           label: "피해구분", width: 100, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0139, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0139
                                    }
                                }
                            },
                            { key: "DM_KIND",           label: "피해종류", width: 100, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0140, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0140
                                    }
                                }
                            },
                            { key: "COMP_NM",           label: "업체명", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "BORW_SITE",         label: "차용사이트", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "DEBTOR_TEL",        label: "연락처", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "DEBTOR_KAKAO",      label: "카카오톡", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "DEBTOR_TELE",       label: "텔레그렘", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "DEBTOR_SNS",        label: "기타SNS", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "WITHDR_LOCA",       label: "스마트출금위치", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "COMPL_POLICE",      label: "고소한경찰서명", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "DM_CONTENTS",       label: "피해내용", width: 100, align: "center", editor: "text", sortable: true, },
                            { key: "USE_YN",            label: "사용여부", width: 100, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0001, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0001
                                    }
                                }
                            },
                            { key: "WRITE_DATE",        label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "WRITE_IP",          label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "INSERT_DATE",       label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "UPDATE_DATE",       label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;

                                if (selectRow == idx){
                                    return;
                                }

                                selectRow = idx;
                                this.self.select(idx);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            },
                            onDBLClick: function(){
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
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

                }
            });

            fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
                initView: function () {
                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        parentGrid : fnObj.gridView01,
                        type : "POST",
                        classUrl : "/api/fi/notice01",
                        methodUrl :  "selectPlDmDeposit",
                        async : false,
                        param : function(){
                            let selected = nvl(fnObj.gridView01.target.getList('selected')[0], {});
                            return JSON.stringify({
                                DM_CD: selected.DM_CD
                            });
                        },
                        callback : function(res){
                        },
                        target: $('[data-ax5grid="grid-view-02"]'),
                        columns: [
                            {key: "DM_CD", label: "피해코드", width: 100, align: "left", sortable: true, editor: false, hidden:true },
                            {key: "SEQ", label: "계좌순번", width: 80, align: "left", sortable: true, editor: false, hidden:true },
                            {key: "BANK_CD", label: "은행코드", width: 100, align: "left", sortable: true, editor: false, hidden:true },
                            {key: "BANK_NM", label: "은행명", width: 100, align: "left", sortable: true, editor: false,
                                picker: {
                                    top: _pop_top,
                                    width: 600,
                                    height: _pop_height,
                                    url: "/jsp/ensys/help/bankHelper.jsp",
                                    action: ["commonHelp", "HELP_BANK"],
                                    param: function () {
                                        return {
                                            MODE   : 'SINGLE'
                                        }
                                    },
                                    callback: function (e) {
                                        fnObj.gridView02.target.setValue(this.dindex, "BANK_CD", e[0].BANK_CD);
                                        fnObj.gridView02.target.setValue(this.dindex, "BANK_NM", e[0].BANK_NM);
                                    },
                                }
                            },
                            {key: "NO_DEPOSIT", label: "계좌번호", width: 100, align: "left", sortable: true, editor: "text"},
                            {key: "NM_DEPOSITOR", label: "예금주명", width: "*", align: "left", sortable: true, editor: "text"},
                            { key: "USE_YN",            label: "사용여부", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0001, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0001
                                    }
                                }
                            },
                            { key: "INSERT_DATE",label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "UPDATE_DATE",label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
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

            fnObj.gridView03 = axboot.viewExtend(axboot.gridView, {
                initView: function () {
                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        parentGrid : fnObj.gridView01,
                        type : "POST",
                        classUrl : "/api/fi/notice01",
                        methodUrl :  "selectPlDmComm",
                        async : false,
                        param : function(){
                            let selected = nvl(fnObj.gridView01.target.getList('selected')[0], {});
                            return JSON.stringify({
                                DM_CD: selected.DM_CD
                            });
                        },
                        callback : function(res){

                        },
                        target: $('[data-ax5grid="grid-view-03"]'),
                        columns: [
                            {key: "DM_CD", label: "피해코드", width: 120, align: "left", sortable: true, editor: false, hidden:true },
                            {key: "COMM_CD", label: "댓글코드", width: 120, align: "left", sortable: true, editor: false, hidden:true },
                            {key: "PARENT_CD", label: "부모댓글코드", width: 120, align: "left", sortable: true, editor: "text"},
                            {key: "NICK_NM", label: "닉네임", width: 120, align: "left", sortable: true, editor: "text"},
                            {key: "PASSWORD", label: "비밀번호", width: 120, align: "left", sortable: true,editor: {type: "password"},
                                formatter: function() {
                                    var value = this.item.PASSWORD;

                                    if(nvl(value) == '') return value;

                                    var returnValue = '';
                                    var len = value.length;
                                    for(var i = 0; i <= len; i ++) {
                                        returnValue += "*";
                                    }
                                    return returnValue;
                                }
                            },
                            {key: "CONTENTS", label: "내용", width: "*", align: "left", sortable: true, editor: "text"},
                            { key: "USE_YN",            label: "사용여부", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0001, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0001
                                    }
                                }
                            },
                            { key: "REPORT_YN",            label: "신고여부", width: 80, align: "center", sortable: true,
                                formatter : function() {
                                    return $.changeTextValue(ES_Q0001, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: ES_Q0001
                                    }
                                }
                            },
                            {key: "WRITE_DATE",        label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            {key: "WRITE_IP",          label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            {key: "INSERT_DATE",       label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                            {key: "UPDATE_DATE",       label: "", width: 100, align: "center", editor: false, sortable: true, hidden:true },
                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                            },
                            onDataChanged: function () {
                            },
                            onDBLClick: function(){
                            }
                        }
                    });
                    axboot.buttonClick(this, "data-grid-view-03-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD3);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DEL3);
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-03']").find("div [data-ax5grid-panel='body'] table tr").length);
                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                this.gridView02.initView();
                this.gridView03.initView();

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

                $("#left_grid").css("height", tempgridheight / 100 * 47);
                $("#right_grid").css("height", tempgridheight / 100 * 47);
                $("#bottom_grid").css("height", tempgridheight / 100 * 47);
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
                        class="icon_search" TRIGGER_NAME="SEARCH" ></i>조회
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
                        <ax:td label='피해 검색' width="400px">
                            <input type="text" class="form-control" name="KEYWORD"  id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
            <div class="H10"></div>
        </div>

        <div style="width:100%;overflow:hidden">
            <div style="width:59%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 피해 정보
                        </h2>
                    </div>
                    <div class="right" style="padding-right: 15px;">
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                            <%--<button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                                <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>--%>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:40%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-02" name="오른쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 피해 계좌
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-02-btn="add" style="width:80px;"><i class="icon_add"></i>
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
            <div style="width:99%;float:left">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-03" name="하단타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 피해 댓글
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-03-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                            <button type="button" class="btn btn-small" data-grid-view-03-btn="delete" style="width:80px;">
                                <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-03"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="bottom_grid"
                     name="하단그리드"
                ></div>
            </div>
        </div>
    </jsp:body>
</ax:layout>