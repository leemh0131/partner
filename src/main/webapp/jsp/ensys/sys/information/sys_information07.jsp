<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="접근제어관리"/>
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
                url: ["SysInformation07", "LoginAccessLog"],
                data: JSON.stringify({
                    'START_DT': $("#SEARCH_DATE").getStartDate(),
                    'END_DT': $("#SEARCH_DATE").getEndDate()
                }),
                callback: function (res) {
                    caller.gridView01.target.setData(res.list);
                }
            });

            axboot.ajax({
                type: "POST",
                url: ["SysInformation07", "AccessIpBlock"],
                data: JSON.stringify(caller.searchView.getData()),
                callback: function (res) {
                    caller.gridView02.target.setData(res.list);
                }
            });
        },
        PAGE_SAVE: function (caller, act, data) {
            var saveList2 = [].concat(caller.gridView02.target.getList("modified")).concat(caller.gridView02.target.getList("deleted"));

            if(saveList2.length == 0) {
                qray.alert('변경된 내용이 없습니다.');
                return false;
            }

            for(var i = 0; i < caller.gridView02.target.list.length; i++) {
                for(var i2 = 0; i2 < caller.gridView02.target.list.length; i2++) {

                    if(i == i2) continue;

                    if(caller.gridView02.target.list[i].IP_ADDRESS_ACCESS == caller.gridView02.target.list[i2].IP_ADDRESS_ACCESS) {
                        qray.alert('중복된 IP 주소 입니다.');
                        caller.gridView02.target.getList("deleted");
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
                    url: ["SysInformation07", "save"],
                    data: JSON.stringify({
                    gridData: saveList2
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
        ITEM_ADD2: function (caller, act, data) {
            var chkData = isChecked(caller.gridView01.target.getList());
            var i = chkData.length;

            if(chkData.length == 0 ) {
                qray.alert("체크된 데이터가 없습니다.");
                return false;
            }

            for(var i = 0; i < chkData.length; i++) {
                for(var i2 = 0; i2 < chkData.length; i2++) {

                    if(i == i2) continue;

                    if(chkData[i].IP_ADDRESS_ACCESS == chkData[i2].IP_ADDRESS_ACCESS) {
                        qray.alert('중복된 IP 주소 입니다.');
                        return false;
                    }
                }
            }

            while(i--) {
                if(chkData[i].CHK == 'Y') {
                    caller.gridView02.addRow();

                    var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());

                    caller.gridView02.target.focus(lastIdx - 1);
                    caller.gridView02.target.select(lastIdx - 1);

                    caller.gridView02.target.setValue(lastIdx - 1, "USER_ID", chkData[i].USER_ID);
                    caller.gridView02.target.setValue(lastIdx - 1, "IP_ADDRESS_ACCESS", chkData[i].IP_ADDRESS);
                    caller.gridView02.target.setValue(lastIdx - 1, "ACCESS_DATE", chkData[i].ADD_DATE);
                }
            }
        },
        ITEM_DEL2: function (caller, act, data) {
            var checked = isCheckedDel(caller.gridView02.target.getList());

            if(checked.length == 0 ) {
                qray.alert("체크된 데이터가 없습니다.");
                return false;
            }

            var grid = caller.gridView02.target.list;
            var i = grid.length;

            while (i--) {
               if(grid[i].CHK == 'Y') {
                   caller.gridView02.delRow(i);
               }
            }

            i = null;

            if(caller.gridView02.target.list.length > 0) {
               caller.gridView02.target.select(0);
            }
        }
    });
    // fnObj 기본 함수 스타트와 리사이즈
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
        },
        getData: function () {
            return {}
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
                    {
                        key: "CHK", width: 40, align: "center", dirty:false,
                        label:
                            '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                        formatter:function() {
                            var CHK = this.item.CHK;
                            var ST_STAT = this.item.ST_STAT;
                            if(ST_STAT == '02') {
                                return '<div style="display:inline-block;position:relative;border:1px solid #ccc;border-radius:3px;background-color:#fff;background-image:-webkit-linear-gradient(top, #fff,#F0F0F0);background-image:linear-gradient(to bottom,#e0e0e0,#e0e0e0);height: 17px; width: 17px; margin-top: 2px;"></div>';
                            }else {
                                if(nvl(CHK, 'N') == 'N') {
                                    return '<div class="left_columnBox" id="left_columnBox' + this.dindex + '" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" style="height:17px;width:17px;margin-top:2px;"></div>';
                                }else {
                                    return '<div class="left_columnBox" id="left_columnBox' + this.dindex + '" data-ax5grid-editor="checkbox" data-ax5grid-checked="true" style="height:17px;width:17px;margin-top:2px;"></div>';
                                }
                            }

                        }
                    },
                    {key: "USER_ID", label: "접근아이디", width: '*', align: "center", sortable: true, editor: false},
                    {key: "IP_ADDRESS", label: "접근 IP주소", width: '*', align: "center", sortable: true, editor: false},
                    {key: "ADD_DATE", label: "접근일", width: '*', align: "center", sortable: true, editor: false,
                          formatter: function () {
                             if(this.value != undefined) {
                                 return this.value.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1-$2-$3 $4:$5:$6');
                             }
                         }
                    }
                ],
                body: {
                    onClick: function () {
                        var index = this.dindex;
                        if(fnObj.gridView02.target.getList("modified").length > 0) {
                            qray.confirm({
                                msg: "수정중인 데이터는 초기화됩니다. 이동하시겠습니까?"
                                , btns: {
                                    ok: {
                                        label: '확인', onClick: function (key) {
                                            fnObj.gridView01.target.select(index);
                                            qray.close();
                                        }
                                    },
                                    cancel: {
                                        label: '취소', onClick: function (key) {
                                            qray.close();
                                        }
                                    }
                                }
                            })
                        }else {
                            this.self.select(this.dindex);
                        }
                    }
                }
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
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
                        key: "CHK", width: 40, align: "center", dirty:false,
                        label:
                            '<div id="headerBox2" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                        formatter:function() {
                            var CHK = this.item.CHK;
                            var ST_STAT = this.item.ST_STAT;
                            if(ST_STAT == '02') {
                                return '<div style="display:inline-block;position:relative;border:1px solid #ccc;border-radius:3px;background-color:#fff;background-image:-webkit-linear-gradient(top, #fff,#F0F0F0);background-image:linear-gradient(to bottom,#e0e0e0,#e0e0e0);height: 17px; width: 17px; margin-top: 2px;"></div>';
                            }else {
                                if(nvl(CHK, 'N') == 'N') {
                                    return '<div class="right_columnBox" id="right_columnBox' + this.dindex + '" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" style="height:17px;width:17px;margin-top:2px;"></div>';
                                }else {
                                    return '<div class="right_columnBox" id="right_columnBox' + this.dindex + '" data-ax5grid-editor="checkbox" data-ax5grid-checked="true" style="height:17px;width:17px;margin-top:2px;"></div>';
                                }
                            }
                        }
                    },
                    {key: "USER_ID", label: "사용자아이디", width: '*', align: "center", sortable: true, editor: false},
                    {key: "IP_ADDRESS_ACCESS", label: "IP 주소", width: '*', align: "center", sortable: true, editor: false},
                    {key: "ACCESS_DATE", label: "IP 차단 적용일", width: '*', align: "center", sortable: true, editor: false,
                          formatter: function() {
                             if(this.value != undefined) {
                                 return this.value.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1-$2-$3 $4:$5:$6');
                             }
                         }
                    }
                ],
                body: {
                    onClick: function () {
                        this.self.select(this.dindex);
                    },
                    onDataChanged: function () {
                         if(this.key == "START_DT" && nvl(this.item.END_DT,'') != '' && nvl(this.value) != '') {
                            if(this.item.START_DT.replace(/-/g, "") > this.item.END_DT.replace(/-/g, "")) {
                                qray.alert("시작일의 설정이 잘못되었습니다.");
                                fnObj.gridView02.target.setValue(this.dindex, 'START_DT', undefined);
                                return false;
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

    function isChecked(data) {
        var array = [];

        for(var i = 0; i < data.length; i++) {
            if(data[i].CHK == 'Y') {
                array.push(data[i]);
            }
        }

        return array;
    }

    function isCheckedDel(data) {
        var result = [];
        var length = 0;
        var chkBox = $("div .right_columnBox");

        for(var i = 0; i < chkBox.length; i++) {
            if(chkBox[i].getAttribute('data-ax5grid-checked') == "true") {
                var index = chkBox[i].id.split("right_CheckBox")[1];

                result.push(fnObj.gridView02.target.list[index]);
                length++;
            }
        }

        return {
            length: length,
            result: result
        }
    }

    $(document).on('click', '.left_columnBox', function (caller) {
        var index = this.id.split('left_columnBox')[1];
        var chk = ($(this).attr("data-ax5grid-checked") == 'true') ? true : false;

        if(chk) {
            fnObj.gridView01.target.setValue(index, "CHK", "N");
        }else {
            fnObj.gridView01.target.setValue(index, "CHK", "Y");
        }
    });

    $(document).on('click', '.right_columnBox', function (caller) {
        var index = this.id.split('right_columnBox')[1];
        var chk = ($(this).attr("data-ax5grid-checked") == 'true') ? true : false;

        if(chk) {
            fnObj.gridView02.target.setValue(index, "CHK", "N");
        }else {
            fnObj.gridView02.target.setValue(index, "CHK", "Y");
        }
    });

    var cnt = 0;
    $(document).on('click', '#headerBox', function (caller) {
        var gridList = fnObj.gridView01.target.list;

        if(cnt == 0) {
            cnt++;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                if(e.ST_STAT != '02') {
                    fnObj.gridView01.target.setValue(i, "CHK", "Y");
                }
            });
        }else {
            cnt = 0;
            $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                if(e.ST_STAT != '02') {
                    fnObj.gridView01.target.setValue(i, "CHK", "N");
                }
            });
        }
    });

    var cnt = 0;
    $(document).on('click', '#headerBox2', function (caller) {
        var gridList = fnObj.gridView02.target.list;

        if(cnt == 0) {
            cnt++;
            $("div [data-ax5grid='grid-view-02']").find("div #headerBox2").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                if(e.ST_STAT != '02') {
                    fnObj.gridView02.target.setValue(i, "CHK", "Y");
                }
            });
        }else {
            cnt = 0;
            $("div [data-ax5grid='grid-view-02']").find("div #headerBox2").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                if(e.ST_STAT != '02') {
                    fnObj.gridView02.target.setValue(i, "CHK", "N");
                }
            });
        }
    });

    var leftcnt = 0;
    $(document).on('click', '#left_headerBox', function (caller) {
        var gridList = fnObj.gridDetailLeft.target.list;

        if(leftcnt == 0) {
            leftcnt++;
            $("div [data-ax5grid='grid-detail-left']").find("div #headerBox").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                fnObj.gridDetailLeft.target.setValue(i, "CHK", "Y");
            });
        }else {
            leftcnt = 0;
            $("div [data-ax5grid='grid-detail-left']").find("div #headerBox").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                fnObj.gridDetailLeft.target.setValue(i, "CHK", "N");
            });
        }
    });

    var rightcnt = 0;
    $(document).on('click', '#right_headerBox', function (caller) {
        var gridList = fnObj.gridDetailRight.target.list;

        if(rightcnt == 0) {
            rightcnt++;
            $("div [data-ax5grid='grid-detail-right']").find("div #headerBox").attr("data-ax5grid-checked", true);
            gridList.forEach(function (e, i) {
                fnObj.gridDetailRight.target.setValue(i, "CHK", "Y");
            });
        }else {
            rightcnt = 0;
            $("div [data-ax5grid='grid-detail-right']").find("div #headerBox").attr("data-ax5grid-checked", false);
            gridList.forEach(function (e, i) {
                fnObj.gridDetailRight.target.setValue(i, "CHK", "N");
            });
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
                style="width:80px;"><i class="icon_reload"></i></button>
        <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                class="icon_search"></i><ax:lang id="ax.admin.sample.modal.button.search"/></button>
        <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                class="icon_save"></i>저장
        </button>
    </div>
</div>
<div role="page-header" id="pageheader">
    <ax:form name="searchView0">
      <ax:tbl clazz="ax-search-tb1" minWidth="500px">
            <ax:tr>
                <ax:td label='조회일자' width="450px">
                    <period-datepicker mode="date" id="SEARCH_DATE"></period-datepicker>
                </ax:td>
            </ax:tr>
        </ax:tbl>
    </ax:form>
    <div class="H10"></div>
</div>
<div style="width:100%;overflow:hidden">
    <div style="width:48%;float:left;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽버튼영역">
            <div class="right">
            </div>
        </div>
        <div data-ax5grid="grid-view-01"
             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 30, }"
             id="left_grid"
             name="왼쪽그리드"
        >
        </div>
    </div>
    <div style="width:48%;float:right;">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽버튼영역">
            <div class="right">
                <button type="button" class="btn btn-small" data-grid-view-02-btn="delete" style="width:80px;">
                    <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
            </div>
        </div>
        <div data-ax5grid="grid-view-02"
             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 30, }"
             id="right_grid"
             name="오른쪽그리드"
        ></div>
    </div>
     <div style="margin:auto;width:30px;border:1px;padding:10px 0; line-height: 500px;height: 200px;">
          <button type="button" class="btn btn-small" data-grid-view-02-btn="add">>>></button>
     </div>
</div>
</jsp:body>
</ax:layout>