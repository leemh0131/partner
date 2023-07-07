<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="그룹메뉴관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">


        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">

            var tpBill;
            var tpDrcr;
            var mask = new ax5.ui.mask();
            var modal = new ax5.ui.modal();
            var selectRow = 0;
            var checkedIdx = [];


            var authGroupCallBack = function (e) {
                if (e.length > 0) {
                    for (var i = 0; i < fnObj.gridView01.target.getList().length; i++) {
                        if (e[0].GROUP_CD == fnObj.gridView01.target.list[i].AUTH_CODE) {
                            modal.close();
                            qray.alert('중복된 그룹코드를 선택하셨습니다.');
                            return false;
                        }
                    }
                    fnObj.gridView01.target.setValue(selectRow, "AUTH_CODE", e[0].GROUP_CD);
                    fnObj.gridView01.target.setValue(selectRow, "AUTH_NAME", e[0].GROUP_NM);

                    var GROUP_CD = e[0].GROUP_CD;

                    $(fnObj.gridView02.target.list).each(function (i, e) {
                        fnObj.gridView02.target.setValue(i, "AUTH_CODE", GROUP_CD);
                    });


                }
                modal.close();
            };


            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    caller.gridView01.clear();
                    caller.gridView02.clear();
                    checkedIdx = [];


                    axboot.ajax({
                        type: "POST",
                        url: ["SysInformation04", "authMselect"],
                        data: JSON.stringify({'AUTH_TYPE': '3'}),
                        callback: function (res) {
                            caller.gridView01.setData(res);
                            if (res.list.length > 0) {
                                caller.gridView01.target.select(0);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK, '');
                            }
                        }
                    });

                    return false;
                },
                PAGE_SAVE: function (caller, act, data) {

                    for (var i = 0; i < caller.gridView01.target.list.length; i++) {
                        for (var i2 = 0; i2 < caller.gridView01.target.list.length; i2++) {
                            if (i == i2) continue;

                            var list = caller.gridView01.target.list;

                            if (list[i].AUTH_CODE == list[i2].AUTH_CODE) {
                                qray.alert('그룹코드가 중복됩니다.');
                                return false;
                            }
                        }
                    }

                    var checkData = [].concat(caller.gridView01.target.getList("modified"));
                    var chkVal;
                    $(checkData).each(function (i, e) {
                        if (checkData[i].AUTH_CODE == undefined) {
                            chkVal = true;

                        }
                    });
                    if (chkVal) {
                        qray.alert("권한코드는 필수입력 입니다.");
                        return;
                    }

                    var saveList = [].concat(caller.gridView01.target.getList("modified"));
                    saveList = saveList.concat(caller.gridView01.target.getList("deleted"));
                    var saveList2 = [].concat(fnObj.gridView02.target.getList());

                    if (saveList.length == 0 && [].concat(caller.gridView02.target.getList("modified")).concat(caller.gridView02.target.getList("deleted")).length == 0) {
                        qray.alert('변경된 내용이 없습니다.');
                        return false;
                    }

                    var data = {
                        listM: saveList
                        , listD: saveList2
                    };
                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "PUT",
                                url: ["SysInformation04", "saveAuth"],
                                data: JSON.stringify(data),
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
                        if (this.key == "ok") {
                            caller.gridView02.clear();
                        }
                    });
                },
                ITEM_CLICK: function (caller, act, data) {

                    axboot.ajax({
                        type: "POST",
                        url: ["SysInformation04", "authDselect"],
                        data: JSON.stringify({
                            'AUTH_TYPE': '3',
                            'AUTH_CODE': caller.gridView01.target.getList('selected')[0].AUTH_CODE
                        }),
                        callback: function (res) {
                            caller.gridView02.setData(res);
                            // caller.gridView02.target.select(0);
                        }
                    });

                    return false;
                },
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
                    this.tpBill = $("#tpBill");
                    this.nmDmk = $("#nmDmk");
                },
                getData: function () {
                    return {
                        tpBill: this.tpBill.val(),
                        nmDmk: this.nmDmk.val()
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
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,

                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            {key: "AUTH_TYPE", label: "권한타입", width: 80, align: "left", hidden: true},
                            {key: "AUTH_CODE", label: "그룹코드", width: 100, align: "left", editor: false},
                            {key: "AUTH_NAME", label: "그룹명", width: 200, align: "left", editor: false},
                        ],
                        body: {
                            onClick: function () {
                                var chekVal, sameChk;
                                var data = this.item;
                                var idx = this.dindex;
                                var columnKey = this.column.key;


                                $(this.list).each(function (i, e) {
                                    if (e.__selected__) {
                                        if (i == idx) {
                                            sameChk = true;
                                        }
                                    }
                                });

                                $(fnObj.gridView02.target.list).each(function (i, e) {
                                    if (e.__modified__) {
                                        chekVal = true;
                                    }
                                });

                                if (sameChk) return;

                                if (chekVal) {
                                    qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                                    return false;
                                }

                                this.self.select(this.dindex);


                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                            }
                        },
                        onPageChange: function (pageNumber) {
                            _this.setPageData({pageNumber: pageNumber});
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
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
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-02"]'),
                        columns: [
                            {
                                key: "USE_YN", label: "", width: 30, align: "center",
                                label:
                                    '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                                }
                            },
                            {key: "PARENT_ID", label: "상위메뉴ID", width: 100, align: "left", hidden: true},
                            {key: "MENU_ID", label: "메뉴ID", width: "*", align: "left", enableFilter: true, treeControl: true,
                                formatter:function(){
                                    return this.item.MENU_NM;
                                }
                            },
                            {key: "MENU_NM", label: "메뉴명", width: 200, align: "left", editor: false, hidden: true},
                            {key: "AUTH_TYPE", label: "권한구분", width: 100, align: "left", hidden: true},
                            {key: "AUTH_CODE", label: "권한코드", width: 120, align: "left", hidden: true},
                            {key: "GROUP_CD", label: "권한코드", width: 120, align: "left", hidden: true},
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
                            onDataChanged: function () {
                                if (this.key == 'USE_YN') {
                                    //this.self.updateChildRows(this.dindex, {USE_YN: data.USE_YN});
                                    var data = this.list[this.doindex];
                                    var value = data.USE_YN;
                                    var thisLevel = data.__depth__;
                                    for (var level = thisLevel ; level >= 0; level --){

                                        var chkVal, broArr = [], pidx = -1;
                                        for (var i = 0 ; i < this.list.length ; i ++){

                                            if (level == thisLevel){
                                                if (this.list[i]['__hp__'].substr(0, data.__hs__.length) === data.__hs__) {
                                                    fnObj.gridView02.target.setValue(i, 'USE_YN', data.USE_YN, true);
                                                }
                                            }
                                            if (data.__hp__ == this.list[i].__hp__ && this.list[i].__hs__ !=  data.__hs__){
                                                broArr.push(this.list[i]);

                                                if (this.list[i].USE_YN != data.USE_YN){
                                                    chkVal = true;
                                                }
                                            }
                                        }
                                        for (var i = 0 ; i < this.list.length ; i ++){
                                            if (data.__hp__ == this.list[i].__hs__){

                                                pidx = this.list[i].__origin_index__;
                                                data = this.list[i];

                                            }
                                        }
                                        if (pidx != -1){
                                            if (broArr.length == 0){
                                                fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
                                            }else{
                                                if (chkVal){
                                                    fnObj.gridView02.target.setValue(pidx, 'USE_YN', 'Y', true);

                                                }else{
                                                    fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
                                                }
                                            }
                                        }
                                    }
                                }
                                fnObj.gridView02.target.repaint();
                            }
                        },
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length)
                }


            });

            //== view 시작
            /**
             * searchView
             */

            var cnt = 0;
            $(document).on('click', '#headerBox', function (caller) {
                var gridList = fnObj.gridView02.target.list;

                if (cnt == 0) {
                    cnt++;

                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", true);

                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "USE_YN", "Y");
                    });

                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", true)
                } else {
                    cnt = 0;

                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);

                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "USE_YN", "N");
                    });

                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", false)
                }

            });


            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            $(document).ready(function() {
                changesize();
            });
            $(window).resize(function(){
                changesize();
            });
            function changesize(){
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if(totheight > 700){
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                else{
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

        <div data-page-buttons="" id="pageheader">
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

        <div style="width:100%;overflow:hidden">
            <div style="width:24%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽제목">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 그룹정보
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;display:none;"><i
                                class="icon_add"></i> <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;display:none;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>


                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="left_grid"
                     name ="왼쪽그리드"
                ></div>
            </div>
            <div style="width:75%;float:right">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽제목">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 메뉴정보
                        </h2>
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