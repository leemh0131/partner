<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="그룹사용자관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var mask = new ax5.ui.mask();
    var modal = new ax5.ui.modal();
    var fnObj = {}, CODE = {};
    var CallBack2;  //그룹사용자 추가시 도움창에서 선택한 데이터
    var selectRow = 0;
    var cnt = 0;    //체크박스 선택개수

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            cnt = 0;
            $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);

            qray.loading.show('조회중입니다.').then(function(){
                fnObj.gridView01.target.dirtyClear();
                fnObj.gridView01.clear();
                fnObj.gridView02.target.dirtyClear();
                fnObj.gridView02.clear();

                fnObj.gridView01.target.read().done(function(res){
                    fnObj.gridView01.target.setData(res);

                    if(res.list.length > 0) {
                        fnObj.gridView01.target.select(0);
                        fnObj.gridView01.target.focus(0);

                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    }
                }).fail(function(err){
                    qray.alert(err.message);
                }).always(function(){
                    qray.loading.hide();
                });
            });
        },
        PAGE_SAVE: function (caller, act, data) {
            var saveList = fnObj.gridView01.target.getDirtyData();
            var saveList2 = fnObj.gridView02.target.getDirtyData();


            for(var i = 0; i < saveList.verify.length; i++) {
                if(nvl(saveList.verify[i].GROUP_NM) == "") {
                    qray.alert("그룹명은 필수입력 입니다.");
                    return false;
                }

                for(var j = i + 1; j < saveList.verify.length; j++) {
                    if(saveList[i].GROUP_CD == saveList[j].GROUP_CD) {
                        qray.alert('그룹코드가 중복됩니다.');
                        return false;
                    }
                }
            }

            if(caller.gridView02.target.list.length == 0) {
                qray.alert('사용자를 한 명이상 등록해주십시오.');
                return false;
            }

            for(var i = 0; i < saveList2.verify.length; i++) {

                if(nvl(saveList2.verify[i].USER_ID) == "") {
                    qray.alert("사용자ID는 필수입력 입니다.");
                    return false;
                }

                for(var i2 = 0; i2 < saveList2.verify.length; i2++) {
                    if(i == i2) continue;

                    var list = saveList2.verify;

                    if(list[i].USER_ID == list[i2].USER_ID) {
                        qray.alert('사용자 아이디가 중복됩니다.');
                        return false;
                    }
                }
            }

            if(saveList.count == 0 && saveList2.count == 0) {
                qray.alert('변경된 내용이 없습니다.');
                return false;
            }

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "PUT",
                        url: ["SysInformation05", "saveAuthGroup"],
                        data: JSON.stringify({
                            saveList : saveList.merge,
                            saveList2 : saveList2.merge
                        }),
                        callback: function (res) {

                            if(nvl(res.map) != '') {
                                if(nvl(res.map.MSG) != '') {
                                    if(res.map.MSG.cause.message.indexOf('-20009') > -1) {
                                        qray.alert('해당 그룹에 동일한 사용자 아이디가 존재합니다.');
                                    }else if(res.map.MSG.cause.message.indexOf('-20008') > -1) {
                                        qray.alert('그룹코드가 중복됩니다.');
                                    }else {
                                        qray.alert(res.map.MSG.cause.message);
                                    }
                                    return false;
                                }
                            }
                            qray.alert("성공적으로 저장하였습니다.").then(function () {
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            });
                        }
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

            qray.loading.show('조회중입니다.').then(function(){
                fnObj.gridView02.target.read().done(function(res){
                    fnObj.gridView02.target.setData(res);
                    fnObj.gridView02.target.select(0);
                }).fail(function(err){
                    qray.alert(err.message);
                }).always(function(){
                    qray.loading.hide();
                });
            });


            /*
            axboot.ajax({
                type: "POST",
                url: ["SysInformation05", "groupUserList"],
                data: JSON.stringify({
                    'GROUP_CD': caller.gridView01.target.getList('selected')[0].GROUP_CD
                }),
                callback: function (res) {
                    caller.gridView02.target.setData(res.list);
                    caller.gridView02.target.select(0);
                }
            });
            */
        },
        ITEM_ADD1: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["common", "groupAdd"],
                async: false,
                callback: function (res) {
                    caller.gridView02.clear();

                    caller.gridView01.addRow();

                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());

                    caller.gridView01.target.select(lastIdx - 1);
                    caller.gridView01.target.focus(lastIdx - 1);

                    caller.gridView01.target.setValue(lastIdx - 1, "GROUP_CD", "WEB" + res.list[0].WEBSEQ);
                }
            });
        },
        ITEM_ADD2: function (caller, act, data) {
            CallBack2 = function (e) {
                var chkArr = [];

                for(var i = 0; i < fnObj.gridView02.target.list.length; i++) {
                    chkArr.push(fnObj.gridView02.target.list[i].USER_ID);
                }
                chkArr = chkArr.join('|');

                if(e.length > 0) {
                    for(var i = 0; i < e.length; i++) {

                        if(chkArr.indexOf(e[i].USER_ID) > -1) continue;

                        fnObj.gridView02.addRow();

                        var lastIdx = nvl(fnObj.gridView02.target.list.length, fnObj.gridView02.lastRow());
                        var groupCd = fnObj.gridView01.target.getList('selected')[0].GROUP_CD;

                        fnObj.gridView02.target.select(lastIdx - 1);
                        fnObj.gridView02.target.focus(lastIdx - 1);

                        fnObj.gridView02.target.setValue(lastIdx - 1, "USER_NM", e[i].USER_NM);
                        fnObj.gridView02.target.setValue(lastIdx - 1, "USER_ID", e[i].USER_ID);
                        fnObj.gridView02.target.setValue(lastIdx - 1, "GROUP_CD", groupCd);
                    }
                }
            };
            $.openCommonPopup("/jsp/ensys/help/userHelper.jsp", "CallBack2", 'HELP_USER', '', null, 600, _pop_height, _pop_top);
        },
        ITEM_DEL1: function (caller, act, data) {
            qray.confirm({
                msg: "삭제하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    caller.gridView02.clear();

                    var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
                    var dataLen = fnObj.gridView01.target.getList().length;

                    if((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    caller.gridView01.delRow("selected");

                    if(beforeIdx > 0 || beforeIdx == 0) {
                        fnObj.gridView01.target.select(beforeIdx);

                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK, fnObj.gridView01.target.list[beforeIdx]);
                    }
                }
            });
        },
        ITEM_DEL2: function (caller, act, data) {
            var DelCnt = 0;

            for(var i = 0; i < caller.gridView02.target.list.length; i ++) {
                if(caller.gridView02.target.list[i].CHK == 'Y') {
                    DelCnt++;
                    break;
                }
            }
            if(DelCnt == 0) {
                qray.alert('체크된 데이터가 없습니다.');
                return false;
            }

            qray.confirm({
                msg: "삭제하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    var grid = caller.gridView02.target.list;
                    var i = grid.length;

                    while (i--) {
                        if(grid[i].CHK == 'Y') {
                            caller.gridView02.delRow(i);
                        }
                    }
                    i = null;
                }
            });
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
                classUrl : "SysInformation05",
                methodUrl :  "groupList",
                async : false,
                param : function(){
                    var param = {

                    }
                    return JSON.stringify(param);
                },
                columns: [
                    {
                        key: "GROUP_CD", label: "그룹코드", width: 80, align: "left", editor: {
                            type: "text",
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
                        key: "GROUP_NM",
                        label: "그룹명",
                        width: '200',
                        align: "left",
                        editor: {type: "text"},
                        sortable: true,
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
                        /*
                        if(chekVal) {
                            qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                            return false;
                        }
                        */
                        if(sameSelected) return;

                        this.self.select(this.dindex);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                    },
                    onDataChanged: function () {
                        if(this.key == 'GROUP_CD') {
                            var list = fnObj.gridView02.target.list;

                            for(var i = 0; i < list.length; i++) {
                                fnObj.gridView02.target.setValue(i, 'GROUP_CD', this.value);
                            }
                        }
                    }
                }
            });

            axboot.buttonClick(this, "data-grid-view-01-btn", {
                "add": function () {
                    var chekVal;
                    /*
                    $(this.target.list).each(function (i, e) {
                        if(e.__created__) {
                            chekVal = true;
                            return false;
                        }
                    });

                    $(fnObj.gridView02.target.list).each(function (i, e) {
                        if(e.__modified__) {
                            chekVal = true;
                            return false;
                        }
                    });

                    if(chekVal) {
                        qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                        return;
                    }
                    */
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
                classUrl : "SysInformation05",
                methodUrl :  "groupUserList",
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
                        key: "GROUP_CD",
                        label: "그룹아이디",
                        width: 80,
                        align: "left",
                        editor: {type: "text"},
                        hidden: true, sortable: true,
                    },
                    {key: "USER_ID", label: "사용자ID", width: 150, sortable: true, align: "left",editor: false},
                    {key: "USER_NM", label: "사용자명", width: 100, align: "left", sortable: true, editor: false}

                ],
                body: {
                    onClick: function () {
                        this.self.select(this.dindex);
                        selectRow = this.dindex;
                    },
                    onDataChanged: function () {
                        if(this.key == 'USER_ID') {
                            if(this.value == '') {
                                fnObj.gridView02.target.setValue(this.dindex, "USER_NM", '');
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
    <div style="width:39%;float:left;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 그룹정보
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
    <div style="width:60%;float:right">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 그룹사용자
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