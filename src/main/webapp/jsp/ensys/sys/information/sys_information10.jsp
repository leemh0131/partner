<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="사용자권한관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var mask = new ax5.ui.mask();
    var modal = new ax5.ui.modal();
    var fnObj = {}, CODE = {};
    var cnt = 0;    //체크박스 변수
    var dl_Permission_TP = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, "ES_Q0132", true);	//	권한유형

    $('#PERMISSION_TP').ax5select({options: dl_Permission_TP});

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            cnt = 0;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", false);

            axboot.call({
                type: "POST",
                url: ["SysInformation10", "select"],
                data: JSON.stringify({
                    //caller.searchView.getData()
                    PERMISSION: $("select[name='PERMISSION_TP']").val(),
                    USER_ID : $("#USER_ID").getCode()
                }),
                callback: function (res) {
                    caller.gridView02.clear();
                    caller.gridView01.clear();

                    if(res.list.length > 0) {
                        caller.gridView02.target.setData(res);
                        caller.gridView02.target.select(0);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    }
                }
            }).done(function () {

            });

            return false;
        },
        PAGE_SAVE: function (caller, act, data) {

            var saveList2 = [].concat(caller.gridView01.target.getList("deleted"));
                saveList2 = saveList2.concat(caller.gridView01.target.getList("modified"));    //  부서

            var saveList = [].concat(caller.gridView02.target.getList("modified"));    //  사용자

            let option;  //계층조회
            /* 부서 추가할때 option을 셋팅해줘야해서 option을 구한다  */
            if(saveList2.length!=0){
                for(let i=0; i<caller.gridView02.target.getList().length; i++){
                    if(caller.gridView02.target.getList()[i].USER_ID == saveList2[0].USER_ID){
                        option = caller.gridView02.target.getList()[i].OPTION;
                        break;
                    }
                }
            }
            /* option 셋팅  */
            for(let i=0; i<saveList2.length; i++){
                saveList2[i].OPTION = option;
            }

            for(var i = 0; i < saveList.length; i++) {
                if(nvl(saveList[i].USER_ID) == '') {
                    qray.alert('사용자ID는 필수입니다.');
                    return false;
                }
            }

            var chk = caller.gridView01.target.getList("modified");
            for(var i = 0; i < chk.length; i++) {
                if(nvl(chk[i].USER_ID) == '') {
                    qray.alert('사용자ID는 필수입니다.');
                    return false;
                }
                if(nvl(chk[i].DEPT_CD) == '') {
                    qray.alert('부서는 필수입니다.');
                    return false;
                }
            }

            if(caller.gridView02.target.list.length > 0) {
                if(caller.gridView01.target.list.length == 0) {
                    qray.alert('부서를 하나 이상 등록해주세요.');
                    return false;
                }
            }

            for(var i = 0; i < caller.gridView02.target.list.length; i++) {
                for(var i2 = 0; i2 < caller.gridView02.target.list.length; i2++) {

                    if(i == i2) continue;

                    if(caller.gridView02.target.list[i].USER_ID == caller.gridView02.target.list[i2].USER_ID) {
                        qray.alert('사용자가 중복됩니다.');
                        return false;
                    }
                }
            }

            for(var i = 0; i < caller.gridView01.target.list.length; i++) {
                for(var i2 = 0; i2 < caller.gridView01.target.list.length; i2++) {

                    if(i == i2) continue;

                    if(caller.gridView01.target.list[i].DEPT_CD == caller.gridView01.target.list[i2].DEPT_CD) {
                        qray.alert('부서가 중복됩니다.');
                        return false;
                    }
                }
            }

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {

                    qray.loading.show("저장 중입니다.");
                    axboot.call({
                        type: "PUT",
                        url: ["SysInformation10", "saveAll"],
                        data: JSON.stringify({
                            gridData: saveList2,
                            gridData2: saveList,
                            gridDataDelete: caller.gridView02.target.getList("deleted"),
                            'PERMISSION': $("select[name='PERMISSION_TP']").val()
                        }),
                        callback: function (res) {
                            qray.loading.hide();
                            qray.alert('저장되었습니다.').then(function() {
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            });
                        }
                    }).done(function () {

                    });
                }
            });
        },
        FORM_CLEAR: function (caller, act, data) {
            qray.confirm({
                msg: LANG("ax.script.form.clearconfirm")
            }, function () {
                if(this.key == "ok") {
                    caller.gridView02.clear();
                }
            });
        },
        ITEM_CLICK: function (caller, act, data) {
            var gridM = caller.gridView02.target.getList('selected')[0];
            cnt = 0;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", false);

            axboot.ajax({
                type: "POST",
                url: ["SysInformation10", "selectDtl"],
                data: JSON.stringify({'USER_ID': gridM.USER_ID,'PERMISSION': $("select[name='PERMISSION_TP']").val()}),
                callback: function (res) {
                    caller.gridView01.clear();
                    if(res.list.length > 0) {
                        caller.gridView01.target.setData(res);
                    }
                }
            });
        },
        ITEM_ADD1: function (caller, act, data) {       //  부서
            var selected = caller.gridView02.target.getList('selected')[0];

            if(nvl(selected) == '') {
                qray.alert('사용자를 선택해주세요.');
                return false;
            }

            $.openCommonPopup("/jsp/ensys/help/deptHelper.jsp", "deptCallBack2", 'HELP_DEPT', '', {SEARCH_AUTH: 'A'}, 600, _pop_height, _pop_top);
        },
        ITEM_ADD2: function (caller, act, data) {       //  사용자
            caller.gridView01.clear();

            caller.gridView02.addRow();

            var lastIdx = nvl(fnObj.gridView02.target.list.length, fnObj.gridView02.lastRow());

            caller.gridView02.target.select(lastIdx - 1);
            caller.gridView02.target.focus(lastIdx - 1);
        },
        ITEM_DEL1: function (caller, act, data) {
            var grid = caller.gridView01.target.list;
            var i = grid.length;

            while(i--) {
                if(grid[i].CHK == 'Y') {
                    caller.gridView01.delRow(i);
                }
            }
            i = null;
        },
        ITEM_DEL2: function (caller, act, data) {
            caller.gridView02.delRow("selected");
            caller.gridView01.clear();
        }
    });

    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.searchView.initView();
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

    fnObj.searchView = axboot.viewExtend(axboot.searchView, {
        initView: function () {
            this.target = $(document["searchView0"]);
            this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);");
            this.DEPT_CD = $("#DEPT_CD");
            this.USER_ID = $("#USER_ID");
        },
        getData: function () {
            return {
                DEPT_CD: '',
                USER_ID: this.USER_ID.getCode()
            }
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
                showRowSelector: false,
                frozenColumnIndex: 0,
                showLineNumber: true,
                multipleSelect: true,
                lineNumberColumnWidth: 40,
                rowSelectorColumnWidth: 27,
                target: $('[data-ax5grid="grid-view-01"]'),
                columns: [
                    {
                        key: "CHK", label: "", width: 40, align: "center", dirty:false,
                        label:
                            '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                        }
                    },
                    {key: "DEPT_CD", label: "부서코드", width: 200, align: "center", editor: false, sortable: true,},
                    {key: "DEPT_NM", label: "부서명", width: 250, align: "left", editor: false, sortable: true,},
                    {key: "USER_ID", label: "사용자ID", width: 100, align: "left", editor: false, hidden: true},
                ],
                body: {
                    onClick: function () {

                    },
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
                columns: [
                    {
                        key: "USER_ID", label: "사용자ID", width: 150, align: "left", sortable: true, editor: {type: "text"},
                        picker: {
                            top: _pop_top,
                            width: 600,
                            height: _pop_height,
                            url: "/jsp/ensys/help/userHelper.jsp",
                            action: ["commonHelp", "HELP_USER"],
                            param: function() {
                                return{
                                    'MODE': 'SINGLE'
                                }
                            },
                            disabled: function () {
                                if(nvl(fnObj.gridView02.target.list[fnObj.gridView02.target.getList('selected')[0].__index].__created__) == '') {
                                    return true;
                                }else {
                                    return false;
                                }
                            },
                            callback: function (e) {
                                axboot.ajax({
                                    type: "POST",
                                    url: ["SysInformation10", "select"],
                                    async: false,
                                    data: JSON.stringify({
                                        DEPT_CD: '',
                                        USER_ID: ''
                                    }),
                                    callback: function (res) {
                                        var chkVal;
                                        for(var i = 0; i < res.list.length; i++) {
                                            if(res.list[i].USER_ID == e[0].USER_ID) {
                                                chkVal = true;
                                            }
                                        }
                                        if(chkVal) {
                                            qray.alert('중복된 사용자를 선택하셨습니다.');
                                            modal.close();
                                            return false;
                                        }
                                        for(var i = 0; i < fnObj.gridView01.target.list.length; i++) {
                                            fnObj.gridView01.target.setValue(i, "USER_ID", e[0].USER_ID);
                                        }

                                        fnObj.gridView02.target.setValue(fnObj.gridView02.target.getList('selected')[0].__index, "USER_ID", e[0].USER_ID);
                                        fnObj.gridView02.target.setValue(fnObj.gridView02.target.getList('selected')[0].__index, "USER_NM", e[0].EMP_NM);
                                    }
                                });
                            },
                        }
                    },
                    {key: "USER_NM", label: "사용자명", width: 100, align: "left", sortable: true, editor: false},
                    {key: "OPTION", label: "계층조회", width: 70, align: "center", sortable: false,
                        editor: {
                            type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                        }
                    },
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

                        if(fnObj.gridView01.target.getList('deleted').length > 0) {
                            qray.alert("삭제된 데이터가 있습니다. 저장 후 진행하세요");
                            return false;
                        }

                        // 해당 그리드의 선택된 INDEX
                        if(sameSelected == false && chekVal == false) {
                            $(fnObj.gridView01.target.getList()).each(function (i, e) {  //  그리드2 변경됬는 지 validate
                                if(e.__modified__ || e.__deleted__) {
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

                        this.self.select(this.dindex);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                    },
                    onDataChanged:function() {
                        if(this.key == 'USER_ID') {
                            if(this.value == '') {
                                fnObj.gridView02.target.setValue(this.dindex, 'USER_NM', '');
                            }
                        }
                    }

                }
            });

            axboot.buttonClick(this, "data-grid-view-02-btn", {
                "add": function () {
                    var chekVal;

                    if(nvl(fnObj.gridView01.target.getList('deleted')) != '') {
                        qray.alert("삭제된 데이터가 있습니다. 저장 후 진행하세요");
                        return false;
                    }

                    $(this.target.list).each(function (i, e) {
                        if(e.__created__) {
                            chekVal = true;
                        }
                    });

                    $(fnObj.gridView01.target.getList()).each(function (i, e) {
                        if(e.__modified__) {
                            chekVal = true;
                        }
                    });

                    if(chekVal) {
                        qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                        return false;
                    }
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

                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
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

    var deptCallBack2 = function (e) {
        var USER_ID = fnObj.gridView02.target.getList('selected')[0].USER_ID;
        var chkArr = [];

        for(var i = 0; i < fnObj.gridView01.target.list.length; i++) {
            chkArr.push(fnObj.gridView01.target.list[i].DEPT_CD);
        }

        if(e.length > 0) {
            for(var i = 0; i < e.length; i++) {

                if(chkArr.indexOf(e[i].DEPT_CD) > -1)
                    continue;

                fnObj.gridView01.addRow();

                var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());

                fnObj.gridView01.target.setValue(lastIdx - 1, "DEPT_CD", e[i].DEPT_CD);
                fnObj.gridView01.target.setValue(lastIdx - 1, "DEPT_NM", e[i].DEPT_NM);
                fnObj.gridView01.target.setValue(lastIdx - 1, "USER_ID", USER_ID);
            }
        }
    };

    $(document).on('click', '#headerBox', function (caller) {
        var gridList = fnObj.gridView01.target.list;

        if(cnt == 0) {
            cnt++;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                fnObj.gridView01.target.setValue(i, "CHK", "Y");
            });
        }else {
            cnt = 0;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                fnObj.gridView01.target.setValue(i, "CHK", "N");
            });
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
<div role="page-header" id="pageheader">
    <ax:form name="searchView0">
        <ax:tbl clazz="ax-search-tbl" minWidth="500px">
            <ax:tr>
                <ax:td label='권한종류' width="300px">
                    <div id="PERMISSION_TP" name="PERMISSION_TP" data-ax5select="PERMISSION_TP" data-ax5select-config='{}' form-bind-text='PERMISSION_TP' form-bind-type="selectBox"></div>
                </ax:td>
                <ax:td label='사용자' width="400px">
                    <multipicker id="USER_ID" HELP_ACTION="HELP_USER" HELP_URL="/jsp/ensys/help/userHelper.jsp"
                                 BIND-CODE="USER_ID" BIND-TEXT="USER_NM"/>
                </ax:td>
            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div style="width:100%;overflow:hidden">
    <div style="width:44%;float:left;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="left_title" name="왼쪽제목">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 사용자
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
             id="left_grid"
             name="왼쪽그리드"
        ></div>
    </div>
    <div style="width:55%;float:right;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="right_title" name="오른쪽타이틀">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 부서
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
             data-ax5grid-config="{  }"
             id="right_grid"
             name="오른쪽그리드"
        ></div>
    </div>
</div>
</jsp:body>
</ax:layout>