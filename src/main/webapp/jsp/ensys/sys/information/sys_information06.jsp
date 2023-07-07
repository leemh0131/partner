<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="사용자메뉴관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH: function (caller, act, data) {
            axboot.ajax({
                type: "POST",
                url: ["SysInformation06", "select"],
                data: JSON.stringify(caller.searchView.getData()),
                callback: function (res) {
                    caller.gridView01.clear();
                    caller.gridView02.clear();

                    if(res.list.length > 0) {
                        caller.gridView01.target.setData(res);
                        //caller.gridView01.target.select(0);

                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    }
                }
            });
        },
        PAGE_SAVE: function (caller, act, data) {
            var saveList = [].concat(caller.gridView02.target.list);

            qray.confirm({
                msg: "저장하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "PUT",
                        url: ["SysInformation06", "saveAuth"],
                        data: JSON.stringify({
                            gridData: saveList
                        }),
                        callback: function (res) {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            qray.alert("저장 되었습니다.");
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
            var gridM = caller.gridView01.target.getList('selected')[0];

            if(nvl(gridM) == '') {
                return false;
            }

            axboot.ajax({
                type: "POST",
                url: ["SysInformation06", "selectDtl"],
                data: JSON.stringify({
                    'GROUP_CD': gridM.GROUP_CD,
                    'USER_ID': gridM.USER_ID
                }),
                callback: function (res) {
                    caller.gridView02.clear();

                    if(res.list.length > 0) {
                        caller.gridView02.target.setData(res);
                    }
                }
            });
        },
        ITEM_ADD1: function (caller, act, data) {
            caller.gridView02.clear();

            caller.gridView01.addRow();

            var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());

            caller.gridView01.target.select(lastIdx - 1);
            caller.gridView01.target.focus(lastIdx - 1);

            caller.gridView01.target.setValue(lastIdx - 1, "AUTH_TYPE", '1');

            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
        },
        ITEM_DEL1: function (caller, act, data) {
            caller.gridView01.delRow("selected");
            caller.gridView02.clear();
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

    //== view 시작
    fnObj.searchView = axboot.viewExtend(axboot.searchView, {
        initView: function () {
            this.target = $(document["searchView0"]);
            this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);");
            this.GROUP_CD = $('[data-ax5select="GROUP_CD"]');
        },
        getData: function () {
            return {
                GROUP_CD: this.GROUP_CD.ax5select("getValue")[0].value
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
                target: $('[data-ax5grid="grid-view-01"]'),
                columns: [
                    {key: "GROUP_CD", label: "권한타입", width: 80, align: "left", hidden: true},
                    {key: "USER_ID", label: "사원번호", width: 100, align: "center", editor: false},
                    {key: "USER_NM", label: "사원명", width: 200, align: "center", editor: false}
                ],
                body: {
                    onClick: function () {
                        var idx = this.__origin_index__;
                        var chekVal;
                        var sameSelected;

                        $(this.list).each(function (i, e) { //  해당 그리드
                            if(e.__selected__) {   //  선택되어있다면
                                if(i == idx) {     //  선택된 ROW와 새로추가된 ROW가 같다면
                                    sameSelected = true;
                                }
                            }
                        });

                        $(fnObj.gridView02.target.list).each(function (i, e) {  //  그리드2 변경됬는 지 validate
                            if(e.__modified__) {
                                chekVal = true;
                                return false;
                            }
                        });

                        if(sameSelected) return;

                        if(chekVal) {  //  팅겨내기
                            qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                            return;
                        }
                        
                        this.self.select(this.dindex);

                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
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
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-02"]'),
                columns: [
                    {key: "GROUP_CD", label: "그룹코드", width: 120, align: "left", hidden: true},
                    {
                        key: "USE_YN", width: 30, align: "center",
                        label:
                            '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                        formatter: function () {
                            var DIS_YN = this.item.DIS_YN;
                            var USE_YN = this.item.USE_YN;
                            if(DIS_YN == 'Y') {
                                if(USE_YN == 'N') {
                                    return '<div id="columnBox' + this.item.__origin_index__ + '" class="columnBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:itemChk(' + this.__origin_index__ + ');"></div>';
                                }else {
                                    return '<div id="columnBox' + this.item.__origin_index__ + '" class="columnBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:itemChk(' + this.__origin_index__ + ');"></div>';
                                }
                            }else {
                                this.item.USE_YN = 'N';
                                return '';
                            }
                        }
                    },
                    {key: "PARENT_ID", label: "상위메뉴ID", width: 100, align: "left", hidden: true},
                    {key: "MENU_ID", label: "메뉴ID", width: "*", align: "left", enableFilter: true, treeControl: true,
                        formatter:function() {
                            return this.item.MENU_NM;
                        }
                    },
                    {key: "MENU_NM", label: "메뉴명", width: 200, align: "left", editor: false, hidden: true},
                    {
                        key: "DIS_YN",
                        label: "Y:체크가능, N:안가능",
                        width: 200,
                        align: "left",
                        hidden: true,
                        editor: false
                    },
                    {key: "AUTH_TYPE", label: "권한구분", width: 100, align: "left", hidden: true},
                    {key: "AUTH_CODE", label: "권한코드", width: 120, align: "left", hidden: true}
                ],
                tree: {
                    use: true,
                    indentWidth: 10,
                    arrowWidth: 15,
                    iconWidth: 18,
                    icons: {
                        openedArrow: '<i class="cqc-chevron-down" aria-hidden="true"></i>',
                        collapsedArrow: '<i class="cqc-chevron-right" aria-hidden="true"></i>',
                        groupIcon: '<i style="font-size: 15px;padding-left: 2px;"" class="cqc-folder" aria-hidden="true"></i>',
                        collapsedGroupIcon: '<i style="font-size: 15px;padding-left: 2px;" class="cqc-folder" aria-hidden="true"></i>',
                        itemIcon: '<i style="font-size:18px;" class="cqc-file" aria-hidden="true"></i>'
                    },
                    columnKeys: {
                        parentKey: "PARENT_ID",
                        selfKey: "MENU_ID"
                    }
                },
                body: {
                    onClick: function () {
                        if(this.column.key == 'USE_YN') {
                            var checked = $("#columnBox" + this.doindex).attr('data-ax5grid-checked');

                            if(nvl(checked) != '') {
                                if(checked == 'true') {
                                    fnObj.gridView02.target.setValue(this.doindex, 'USE_YN', 'N');
                                    $("#columnBox" + this.doindex).attr('data-ax5grid-checked', false);
                                }else if(checked ==  'false') {
                                    fnObj.gridView02.target.setValue(this.doindex, 'USE_YN', 'Y');
                                    $("#columnBox" + this.doindex).attr('data-ax5grid-checked', true);
                                }
                            }
                        }
                    },
                    onDataChanged: function () {
                        if(this.key == 'USE_YN') {
                            var data = this.list[this.doindex];
                            var value = data.USE_YN;
                            var thisLevel = data.__depth__;

                            for(var level = thisLevel; level >= 0; level --) {
                                var chkVal, broArr = [], pidx = -1;

                                for(var i = 0; i < this.list.length; i ++) {
                                    
                                    if(level == thisLevel) {
                                        if(this.list[i]['__hp__'].substr(0, data.__hs__.length) === data.__hs__) {
                                            fnObj.gridView02.target.setValue(i, 'USE_YN', data.USE_YN, true);
                                        }
                                    }

                                    if(data.__hp__ == this.list[i].__hp__ && this.list[i].__hs__ !=  data.__hs__) {
                                        broArr.push(this.list[i]);
                                        
                                        if(this.list[i].USE_YN != data.USE_YN) {
                                            chkVal = true;
                                        }
                                    }
                                }

                                for(var i = 0; i < this.list.length; i ++) {
                                    if(data.__hp__ == this.list[i].__hs__) {
                                        pidx = this.list[i].__origin_index__;
                                        data = this.list[i];
                                    }
                                }

                                if(pidx != -1) {
                                    if(broArr.length == 0) {
                                        fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
                                    }else {
                                        if(chkVal) {
                                            fnObj.gridView02.target.setValue(pidx, 'USE_YN', 'Y', true);
                                        }else {
                                            fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
                                        }
                                    }
                                }
                            }
                        }
                        fnObj.gridView02.target.repaint();
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

    var cnt = 0;
    $(document).on('click', '#headerBox', function (caller) {
        var gridList = fnObj.gridView02.target.list;

        if(cnt == 0) {
            cnt++;
            $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                if(fnObj.gridView02.target.list[i].DIS_YN == 'Y') {
                    fnObj.gridView02.target.setValue(i, 'USE_YN', 'Y');
                }
            });
            $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", true);
        }else {
            cnt = 0;
            $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                if(fnObj.gridView02.target.list[i].DIS_YN == 'Y') {
                    fnObj.gridView02.target.setValue(i, 'USE_YN', 'N');
                }
            });
            $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", false);
        }
    });

    //////////////////////////////////////
    $(document).ready(function() {
        changesize();

        //선택박스 그룹코드 세팅
        axboot.ajax({
            type: "POST",
            url: ["SysInformation06", "selectMst"],
            data: JSON.stringify(),
            async: false,
            callback: function (res) {
                var options = [];
                res.list.forEach(function (n) {
                    options.push({value: n.GROUP_CD, text: n.GROUP_NM});
                });
                $('[data-ax5select]').ax5select({
                    options: options,

                    onChange: function () {
                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                    }
                });
            }
        });
    });
    
    $(window).resize(function() {
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

        $("#left_grid").css("height",tempgridheight /100 * 99);
        $("#right_grid").css("height",tempgridheight /100 * 99);
    }
</script>
</jsp:attribute>
<jsp:body>
<div data-page-buttons="">
    <div class="button-warp">
        <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                style="width:80px;"><i class="icon_reload"></i></button>
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
        <ax:tbl clazz="ax-search-tb1" minWidth="500px">
            <ax:tr>
                <ax:td label="그룹" width="400px">
                    <div data-ax5select="GROUP_CD" data-ax5select-config="{
                    multiple: false,
                    reset:'<i class=\'fa fa-trash\'></i>'
                    }"></div>
                </ax:td>

            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div style = "width:100%;overflow:hidden">
    <div style="width:24%;float:left;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽타이틀">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 사용자
                </h2>
            </div>
        </div>
        <div data-ax5grid="grid-view-01"
             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
             id="left_grid"
             name="왼쪽그리드"
        ></div>
    </div>
    <div style="width:75%;float:right">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 메뉴정보
                </h2>
            </div>
        </div>
        <div data-ax5grid="grid-view-02"
             data-ax5grid-config="{showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
             id="right_grid"
             name="오른쪽그리드"
        ></div>
    </div>
</div>
</jsp:body>
</ax:layout>